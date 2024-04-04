import 'dart:async';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'send_view_model.g.dart';

class SendViewModel = SendViewModelBase with _$SendViewModel;

abstract class SendViewModelBase with Store {
  final BalanceViewModel balanceVM;
  final AppStore appStore;

  SendViewModelBase(this.balanceVM, this.appStore);

  @observable
  String rawCryptoAmount = '';

  @observable
  String address = '';

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
  Future<void> updateGasPrice() async =>
      _gasPrice = (await appStore.client.getGasPrice()).getInWei.toInt();

  @action
  Future<void> estimateGas() async =>
      _estimatedGas = (await appStore.client.estimateGas()).toInt();

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
    print(RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false).hasMatch(address));

    // ToDo: Check for valid Address
    final cryptoAmount = EtherAmount.fromBase10String(
        EtherUnit.ether, rawCryptoAmount.replaceAll(",", "."));

    final isErc20Token = CryptoCurrency.erc20Tokens.contains(spendCurrency);

    final currentAccount = appStore.wallet!.currentAccount.primaryAddress;
    final currentAddress = currentAccount.address;
    final chainId = appStore.chainId;

    // ToDo: Balance Check
    state = CreatingExecutionState();

    final transaction = Transaction(
      from: currentAddress,
      to: EthereumAddress.fromHex(address),
      maxPriorityFeePerGas: EtherAmount.fromInt(EtherUnit.gwei, priority.tip),
      value: isErc20Token ? EtherAmount.zero() : cryptoAmount,
    );

    try {
      if (!isErc20Token) {
        final signedTransaction = await appStore.client
            .signTransaction(currentAccount, transaction, chainId: chainId);

        _sendTransaction =
            () => appStore.client.sendRawTransaction(prependTransactionType(2, signedTransaction));
      } else {
        final erc20 = ERC20(
          client: appStore.client,
          address: EthereumAddress.fromHex(spendCurrency.address),
          chainId: chainId,
        );

        _sendTransaction = () => erc20.transfer(
              EthereumAddress.fromHex(address),
              cryptoAmount.getInWei,
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
