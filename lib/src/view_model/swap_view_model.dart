import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/dfx_route.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/fps_routes.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/swap_progress_modal.dart';
import 'package:mobx/mobx.dart';

part 'swap_view_model.g.dart';

class SwapViewModel = SwapViewModelBase with _$SwapViewModel;

abstract class SwapViewModelBase with Store {
  final AppStore appStore;
  final SendViewModel sendVM;
  final SwapService swapService;

  SwapViewModelBase(
      this.appStore, this.sendVM, this.swapService) {
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

  @observable
  bool isLoadingEstimate = false;

  @computed
  bool get isReadyToCreate =>
      state is InitialExecutionState && investAmount > BigInt.zero;

  CancelableOperation? _completer;

  @action
  Future<void> updateExpectedReturn() async {
    if (investAmount == BigInt.zero) {
      expectedReturn = BigInt.zero;
      return;
    }

    isLoadingEstimate = true;

    _completer?.cancel();
    _completer = CancelableOperation.fromFuture(
      swapService
          .getRoute(sendCurrency, receiveCurrency)
          .estimateReturn(investAmount),
      onCancel: () {},
    );
    _completer?.then((xpReturn) {
      expectedReturn = xpReturn;
      isLoadingEstimate = false;
    });
  }

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
      if (route is DFX_SwapRoute) {
        state = DFXFailureState(S.current.dfx_unavailable);
        return;
      }

      state = FailureState(sendCurrency == CryptoCurrency.fps
          ? S.current.fps_cannot_redeem_yet
          : S.current.dfx_unavailable);
      return;
    }

    if (route.requireApprove) {
      final isApproved = await route.isApproved(investAmount, currentAccount);

      // Show Swap BottomSheet
      final txId = await appStore.bottomSheetService.queueBottomSheet(
        widget: SwapProgressModal(
          approveSwap: () async =>
              await route.approve(investAmount, currentAccount),
          isApproved: isApproved,
          confirmSwap: () async =>
              route.routeAction(investAmount, expectedReturn, currentAccount),
          investAmount: "${formatFixed(investAmount, sendCurrency.decimals)} ${sendCurrency.symbol}",
          estimatedProceeds: "${formatFixed(expectedReturn, receiveCurrency.decimals)} ${receiveCurrency.symbol}",
          sourceChain: sendCurrency.blockchain,
          targetChain: receiveCurrency.blockchain,
        ),
      ) as String?;

      state = txId == null
          ? InitialExecutionState()
          : ExecutedSuccessfullyState(payload: txId);
      return;
    }

    _sendTransaction = () async =>
        route.routeAction(investAmount, expectedReturn, currentAccount);

    state = AwaitingConfirmationExecutionState();
  }

  Future<void> launchDFXSwap(BuildContext context) async {
    if (swapRoute is DFX_SwapRoute) {
      (swapRoute as DFX_SwapRoute)
          .dfxSwapService
          .launchProvider(context, sendCurrency, receiveCurrency, investAmount);
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
      log("Failed ${e.toString()}");
      state = FailureState(e.toString().replaceAll("Exception: ", ''));
    }
  }
}
