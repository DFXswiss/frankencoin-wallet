import 'dart:async';

import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/secrets.g.dart' as secrets;
import 'package:frankencoin_wallet/src/core/contracts/ReferredSavings.g.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_edit_view_model.g.dart';

class SavingsEditViewModel = SavingsEditViewModelBase
    with _$SavingsEditViewModel;

abstract class SavingsEditViewModelBase with Store {
  final AppStore appStore;
  final BalanceStore balanceStore;
  final ReferredSavings _savings;

  SavingsEditViewModelBase(this.balanceStore, this.appStore)
      : _savings = ReferredSavings(
          address: EthereumAddress.fromHex(CryptoCurrency.savings.address),
          client: appStore.getClient(CryptoCurrency.savings.chainId),
        ) {
    rawCryptoAmount =
        balanceStore.balances[CryptoCurrency.savings.balanceId]?.balance ?? '';
  }

  CryptoCurrency spendCurrency = CryptoCurrency.zchf;

  @observable
  String rawCryptoAmount = '';

  @observable
  int _gasPrice = 0;

  @observable
  int _estimatedGas = 0;

  @observable
  TransactionPriority priority = TransactionPriority.medium;

  @computed
  bool get isReadyToCreate =>
      state is InitialExecutionState && rawCryptoAmount.isNotEmpty;

  @observable
  ExecutionState state = InitialExecutionState();

  @computed
  int get estimatedFee {
    final priorityFee =
        EtherAmount.fromInt(EtherUnit.gwei, priority.tip).getInWei.toInt();
    return (_gasPrice + priorityFee) * _estimatedGas;
  }

  @action
  Future<void> updateGasPrice() async => _gasPrice =
      (await appStore.getClient(CryptoCurrency.savings.chainId).getGasPrice())
          .getInWei
          .toInt();

  @action
  Future<void> estimateGas() async => _estimatedGas =
      (await appStore.getClient(CryptoCurrency.savings.chainId).estimateGas())
          .toInt();

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
  void setMaxAmount() {
    final cryptoAmount = parseFixed(
        rawCryptoAmount.replaceAll(",", "."), CryptoCurrency.savings.decimals);

    final freeBalance =
        balanceStore.balances[spendCurrency.balanceId]?.getBalance() ??
            BigInt.zero;

    rawCryptoAmount =
        formatFixed(cryptoAmount + freeBalance, spendCurrency.decimals);
  }

  @action
  Future<void> createTransaction() async {
    final cryptoAmount = parseFixed(
        rawCryptoAmount.replaceAll(",", "."), CryptoCurrency.savings.decimals);

    state = CreatingExecutionState();

    if (balanceStore.getBalance(CryptoCurrency.zchf) < cryptoAmount) {
      state = FailureState(S.current.not_enough_token(
          CryptoCurrency.zchf.name,
          balanceStore.getBalance(CryptoCurrency.zchf).toString(),
          cryptoAmount.toString()));
      return;
    }

    try {
      _sendTransaction = () async => _savings.adjust((
            targetAmount: cryptoAmount,
            referralFeePPM: BigInt.from(secrets.savingsReferralPPM),
            referrer: EthereumAddress.fromHex(secrets.savingsReferralAddress)
          ), credentials: appStore.wallet!.currentAccount.primaryAddress);

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

class DFXFailureState extends FailureState {
  DFXFailureState(super.error);
}
