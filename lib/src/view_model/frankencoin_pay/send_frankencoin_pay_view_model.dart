import 'dart:async';
import 'dart:developer';

import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/create_transaction.dart';
import 'package:frankencoin_wallet/src/wallet/is_evm_address.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'send_frankencoin_pay_view_model.g.dart';

class SendFrankencoinPayViewModel = SendFrankencoinPayViewModelBase
    with _$SendFrankencoinPayViewModel;

abstract class SendFrankencoinPayViewModelBase with Store {
  final AppStore appStore;
  final BalanceStore balanceStore;
  final FrankencoinPayService frankencoinPayService;
  final FrankencoinPayRequest request;

  SendFrankencoinPayViewModelBase(
      this.appStore, this.frankencoinPayService, this.balanceStore,
      {required this.request});

  @observable
  BigInt cryptoAmount = BigInt.zero;

  @observable
  int _gasPrice = 0;

  @observable
  int _estimatedGas = 0;

  @observable
  int timeLeft = 0;

  @observable
  TransactionPriority priority = TransactionPriority.medium;

  @observable
  CryptoCurrency spendCurrency = CryptoCurrency.zchf;

  @observable
  ExecutionState state = InitialExecutionState();

  @computed
  int get estimatedFee {
    final priorityFee =
        EtherAmount.fromInt(EtherUnit.gwei, priority.tip).getInWei.toInt();
    return (_gasPrice + priorityFee) * _estimatedGas;
  }

  @action
  bool needsRefill() {
    for (final zchf in [
      CryptoCurrency.polZCHF,
      CryptoCurrency.baseZCHF,
      CryptoCurrency.opZCHF,
      CryptoCurrency.arbZCHF,
      CryptoCurrency.zchf,
    ]) {
      if (balanceStore.getBalance(zchf) >= cryptoAmount) {
        log('Choose ${zchf.blockchain.name} for Frankencoin Pay');
        spendCurrency = zchf;
        return true;
      }
    }
    return false;
  }

  BigInt refillAmount() {
    var amount = cryptoAmount;
    for (final zchf in [
      CryptoCurrency.polZCHF,
      CryptoCurrency.baseZCHF,
      CryptoCurrency.opZCHF,
      CryptoCurrency.arbZCHF,
      CryptoCurrency.zchf,
    ]) {
      final refillAmount = cryptoAmount - balanceStore.getBalance(zchf);
      if (refillAmount < amount) amount = refillAmount;
    }
    return amount;
  }

  @action
  Future<void> updateGasPrice() async => _gasPrice =
      (await appStore.getClient(spendCurrency.chainId).getGasPrice())
          .getInWei
          .toInt();

  @action
  Future<void> estimateGas() async => _estimatedGas =
      (await appStore.getClient(spendCurrency.chainId).estimateGas()).toInt();

  @action
  void updateTimeLeft() {
    if (timeLeft <= 0) return _updateTimeLeftTimer?.cancel();
    timeLeft -= 1;
  }

  Timer? _updateGasPriceTimer;
  Timer? _estimateGasTimer;
  Timer? _updateTimeLeftTimer;

  Future<void> syncFee() async {
    await updateGasPrice();
    await estimateGas();

    _updateGasPriceTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) async => await updateGasPrice());
    _estimateGasTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) async => await estimateGas());
  }

  void startTimeLeft() {
    _updateTimeLeftTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) => updateTimeLeft());
  }

  void stopTimers() {
    _updateGasPriceTimer?.cancel();
    _estimateGasTimer?.cancel();
    _updateTimeLeftTimer?.cancel();
  }

  String? _signedTransaction;

  @action
  Future<void> createTransaction() async {
    assert([
      CryptoCurrency.zchf,
      CryptoCurrency.polZCHF,
      CryptoCurrency.baseZCHF,
      CryptoCurrency.opZCHF,
      CryptoCurrency.arbZCHF
    ].contains(spendCurrency));

    final client = appStore.getClient(spendCurrency.chainId);

    state = CreatingExecutionState();

    final address = await frankencoinPayService.getFrankencoinPayAddress(
        request.quote, request.callbackUrl, spendCurrency);

    log(address);

    if (!address.isEthereumAddress) {
      state = FailureState(S.current.invalid_receive_address);
      return;
    }

    if (balanceStore.getBalance(spendCurrency) < cryptoAmount) {
      state = FailureState(S.current.not_enough_token(
          spendCurrency.name,
          balanceStore.getBalance(spendCurrency).toString(),
          cryptoAmount.toString()));
      return;
    }

    try {
      _signedTransaction = await prepareERC20Transaction(
        client,
        currentAccount: appStore.wallet!.currentAccount.primaryAddress,
        receiveAddress: address,
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
  Future<void> commitTransaction(FrankencoinPayRequest request) async {
    if (_signedTransaction == null) throw Exception("No pending transaction");
    state = CommittingExecutionState();
    try {
      final txId = await frankencoinPayService.commitFrankencoinPayRequest(
        _signedTransaction!,
        callbackUrl: request.callbackUrl,
        blockchain: spendCurrency.blockchain.name,
        quote: request.quote,
        asset: spendCurrency.symbol,
      );
      state = ExecutedSuccessfullyState(payload: txId);
    } catch (e) {
      print("Failed ${e.toString()}");
      state = FailureState(e.toString());
    }
  }
}
