import 'dart:async';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/alias_resolver/alias_resolver.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'send_view_model.g.dart';

class SendViewModel = SendViewModelBase with _$SendViewModel;

abstract class SendViewModelBase with Store {
  final BalanceViewModel balanceVM;
  final AppStore appStore;

  SendViewModelBase(this.balanceVM, this.appStore) {
    reaction((_) => spendCurrency, (_) async {
      await updateGasPrice();
      await estimateGas();
    });

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
  int _gasPrice = 0;

  @observable
  int _estimatedGas = 0;

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
  CryptoCurrency spendCurrency = CryptoCurrency.zchf;

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

    final isErc20Token = CryptoCurrency.erc20Tokens.contains(spendCurrency);

    final currentAccount = appStore.wallet!.currentAccount.primaryAddress;
    final currentAddress = currentAccount.address;
    final client = appStore.getClient(spendCurrency.chainId);

    state = CreatingExecutionState();

    final receiveAddress = resolvedAlias?.address ?? address;

    if (!RegExp(r'^(0x)?[0-9a-f]{40}$', caseSensitive: false)
        .hasMatch(receiveAddress)) {
      state = FailureState(S.current.invalid_receive_address);
      return;
    }

    if (BigInt.parse(balanceVM.balances[spendCurrency]?.balance ?? "0") <
        cryptoAmount) {
      state = FailureState(S.current.not_enough_token(spendCurrency.name));
      return;
    }

    final transaction = Transaction(
      from: currentAddress,
      to: EthereumAddress.fromHex(receiveAddress),
      maxPriorityFeePerGas: spendCurrency.chainId == 1
          ? EtherAmount.fromInt(EtherUnit.gwei, priority.tip)
          : null,
      value:
          isErc20Token ? EtherAmount.zero() : EtherAmount.inWei(cryptoAmount),
    );

    try {
      if (!isErc20Token) {
        var signedTransaction = await client.signTransaction(
            currentAccount, transaction,
            chainId: spendCurrency.chainId);

        _sendTransaction = () => client
            .sendRawTransaction(prependTransactionType(2, signedTransaction));
      } else {
        final erc20 = ERC20(
          client: client,
          address: EthereumAddress.fromHex(spendCurrency.address),
          chainId: spendCurrency.chainId,
        );

        _sendTransaction = () => erc20.transfer(
              EthereumAddress.fromHex(address),
              cryptoAmount,
              credentials: currentAccount,
              transaction: transaction,
            );
      }
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

abstract class ExecutionState {}

class InitialExecutionState extends ExecutionState {}

class IsExecutingState extends ExecutionState {}

class CreatingExecutionState extends IsExecutingState {}

class AwaitingConfirmationExecutionState extends IsExecutingState {}

class CommittingExecutionState extends IsExecutingState {}

class ExecutedSuccessfullyState extends ExecutionState {
  ExecutedSuccessfullyState({this.payload});

  final dynamic payload;
}

class FailureState extends InitialExecutionState {
  FailureState(this.error);

  final String error;
}
