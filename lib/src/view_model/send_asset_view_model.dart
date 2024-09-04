import 'dart:async';

import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/alias_resolver/alias_resolver.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/create_transaction.dart';
import 'package:frankencoin_wallet/src/wallet/is_evm_address.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'send_asset_view_model.g.dart';

class SendAssetViewModel = SendAssetViewModelBase with _$SendAssetViewModel;

abstract class SendAssetViewModelBase with Store {
  final AppStore appStore;
  final BalanceStore balanceStore;

  SendAssetViewModelBase(this.balanceStore, this.appStore) {
    reaction((_) => address, (String address) async {
      if (address.contains(".")) {
        resolvedAlias =
            await AliasResolver.resolve(address, spendCurrency.symbol, "ETH");
        if (resolvedAlias != null) {
          getIt.get<BottomSheetService>().queueBottomSheet(
                isModalDismissible: true,
                widget: BottomSheetMessageDisplayWidget(
                    title: S.current.alias_detected,
                    message: resolvedAlias!.name.isNotEmpty
                        ? "${resolvedAlias!.name}: ${resolvedAlias!.address}"
                        : resolvedAlias!.address),
              );
        }
      } else {
        resolvedAlias = null;
      }
    });
  }

  @observable
  String rawCryptoAmount = '';

  @observable
  String address = '';

  @observable
  AliasRecord? resolvedAlias;

  @observable
  TransactionPriority priority = TransactionPriority.medium;

  @computed
  bool get isReadyToCreate =>
      state is InitialExecutionState &&
      rawCryptoAmount.isNotEmpty &&
      address.isNotEmpty;

  @observable
  ExecutionState state = InitialExecutionState();

  @observable
  CustomErc20Token spendCurrency = CustomErc20Token.fromCryptoCurrency(CryptoCurrency.zchf);

  @observable
  int _gasPrice = 0;

  @observable
  int _estimatedGas = 0;

  @computed
  int get estimatedFee {
    final priorityFee =
    EtherAmount.fromInt(EtherUnit.gwei, priority.tip).getInWei.toInt();
    return (_gasPrice + priorityFee) * _estimatedGas;
  }

  @action
  Future<void> updateGasPrice() async => _gasPrice =
      (await appStore.getClient(spendCurrency.chainId).getGasPrice())
          .getInWei
          .toInt();

  @action
  Future<void> estimateGas() async => _estimatedGas =
      (await appStore.getClient(spendCurrency.chainId).estimateGas()).toInt();

  Timer? _updateGasPriceTimer;
  Timer? _estimateGasTimer;

  Future<void> syncFee() async {
    await updateGasPrice();
    await estimateGas();

    _updateGasPriceTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) async => await updateGasPrice());
    _estimateGasTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) async => await estimateGas());
  }

  void stopSyncFee() {
    _updateGasPriceTimer?.cancel();
    _estimateGasTimer?.cancel();
  }

  Future<String> Function()? _sendTransaction;

  @action
  Future<void> createTransaction() async {
    final cryptoAmount = parseFixed(
        rawCryptoAmount.replaceAll(",", "."), spendCurrency.decimals);

    final client = appStore.getClient(spendCurrency.chainId);

    state = CreatingExecutionState();

    final receiveAddress = resolvedAlias?.address ?? address;

    if (!receiveAddress.isEthereumAddress) {
      state = FailureState(S.current.invalid_receive_address);
      return;
    }

    if (balanceStore.getCustomBalance(spendCurrency) < cryptoAmount) {
      state = FailureState(S.current.not_enough_token(spendCurrency.name, balanceStore.getCustomBalance(spendCurrency).toString(), cryptoAmount.toString()));
      return;
    }

    try {
      _sendTransaction = await createERC20Transaction(
        client,
        currentAccount: appStore.wallet!.currentAccount.primaryAddress,
        receiveAddress: receiveAddress,
        amount: cryptoAmount,
        contractAddress: spendCurrency.address,
        chainId: spendCurrency.chainId,
        priority: priority,
      );
      state = AwaitingConfirmationExecutionState();
    } catch (e) {
      state = FailureState(e.toString());
    }
  }

  @action
  Future<void> commitTransaction() async {
    if (_sendTransaction == null) throw Exception("No pending transaction");
    state = CommittingExecutionState();
    try {
      final txId = await _sendTransaction!.call();
      state = ExecutedSuccessfullyState(payload: txId);
    } catch (e) {
      print("Failed ${e.toString()}");
      state = FailureState(e.toString());
    }
  }
}
