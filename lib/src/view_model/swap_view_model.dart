import 'dart:developer';

import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/core/swap_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:mobx/mobx.dart';

part 'swap_view_model.g.dart';

class SwapViewModel = SwapViewModelBase with _$SwapViewModel;

abstract class SwapViewModelBase with Store {
  final AppStore appStore;
  final SendViewModel sendVM;
  final SwapService swapService;

  SwapViewModelBase(this.appStore, this.sendVM, this.swapService) {
    reaction((_) => sendCurrency,
        (_) => swapRoute = swapService.getRoute(sendCurrency, receiveCurrency));
    reaction((_) => receiveCurrency,
        (_) => swapRoute = swapService.getRoute(sendCurrency, receiveCurrency));

    reaction((_) => investAmount, (_) => updateExpectedReturn());
  }

  @observable
  BigInt investAmount = BigInt.zero;

  @observable
  BigInt expectedReturn = BigInt.zero;

  @observable
  CryptoCurrency sendCurrency = CryptoCurrency.zchf;

  @observable
  CryptoCurrency receiveCurrency = CryptoCurrency.fps;

  @observable
  SwapRoute swapRoute = ZCHF_FPS_SwapRoute();

  @observable
  ExecutionState state = InitialExecutionState();

  @computed
  bool get isReadyToCreate =>
      state is InitialExecutionState && investAmount > BigInt.zero;

  @action
  Future<void> updateExpectedReturn() async =>
      expectedReturn = await swapService
          .getRoute(sendCurrency, receiveCurrency)
          .estimateReturn(investAmount);

  @action
  void switchCurrencies() {
    final newReceiveCurrency = sendCurrency;

    sendCurrency = receiveCurrency;
    receiveCurrency = newReceiveCurrency;
  }

  Future<String> Function()? _sendTransaction;

  Future<void> createTradeTransaction() async {
    state = CreatingExecutionState();

    final currentAccount = appStore.wallet!.currentAccount.primaryAddress;
    final route = swapRoute;

    final canSwap =
        await route.isAvailable(investAmount, currentAccount.address);

    if (!canSwap) {
      state = FailureState(sendCurrency == CryptoCurrency.fps
          ? S.current.fps_cannot_redeem_yet
          : S.current.dfx_unavailable);
      return;
    }

    _sendTransaction = () async =>
        await route.routeAction(investAmount, expectedReturn, currentAccount);

    state = AwaitingConfirmationExecutionState();
  }

  @action
  Future<void> commitTransaction() async {
    if (_sendTransaction == null) throw Exception("No pending transaction");
    state = CommittingExecutionState();
    try {
      final txId = await _sendTransaction!.call();
      state = ExecutedSuccessfullyState(payload: txId);
    } catch (e) {
      log("Failed ${e.toString()}");
      state = FailureState(e.toString());
    }
  }
}
