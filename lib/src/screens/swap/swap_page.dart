import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/currency_picker.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/swap_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/estimated_tx_fee.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/swap_route_infos.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class SwapPage extends BasePage {
  final BalanceViewModel balanceVM;
  final SwapViewModel equityVM;
  final BottomSheetService bottomSheetService;

  SwapPage(this.balanceVM, this.equityVM, this.bottomSheetService, {super.key});

  @override
  String? get title => S.current.swap;

  @override
  Widget body(BuildContext context) =>
      _SwapPageBody(balanceVM, equityVM, bottomSheetService);
}

class _SwapPageBody extends StatefulWidget {
  final BalanceViewModel balanceVM;
  final SwapViewModel equityVM;
  final BottomSheetService bottomSheetService;

  const _SwapPageBody(this.balanceVM, this.equityVM, this.bottomSheetService);

  @override
  State<StatefulWidget> createState() => _SwapPageBodyState();
}

class _SwapPageBodyState extends State<_SwapPageBody> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.equityVM.sendVM.syncFee();
  }

  @override
  void dispose() {
    super.dispose();
    widget.equityVM.sendVM.stopSyncFee();
  }

  @override
  Widget build(BuildContext context) {
    _setEffects(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 26, right: 26, top: 26, bottom: 10),
            child: CupertinoTextField(
              prefix: Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  enableFeedback: false,
                  onTap: () => _presentPicker(context, true),
                  child: Observer(
                    builder: (_) => Image.asset(
                      getCryptoAssetImagePath(widget.equityVM.sendCurrency),
                      width: 42,
                    ),
                  ),
                ),
              ),
              placeholder: "0.0000",
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: Observer(builder: (_) {
                final rawBalanceAmount = EtherAmount.inWei(widget
                        .balanceVM.balances[widget.equityVM.sendCurrency]!
                        .getBalance())
                    .getInWei;
                return CupertinoButton(
                  onPressed: () => _amountController.text = formatFixed(
                      rawBalanceAmount, widget.equityVM.sendCurrency.decimals),
                  child: Text(
                    formatFixed(
                        rawBalanceAmount, widget.equityVM.sendCurrency.decimals,
                        fractionalDigits: 3, trimZeros: false),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 50,
            child: Observer(
              builder: (_) => widget.equityVM.isLoadingEstimate
                  ? const CupertinoActivityIndicator(
                      color: FrankencoinColors.frRed,
                    )
                  : IconButton(
                      onPressed: () {
                        widget.equityVM.switchCurrencies();
                        _amountController.text = "";
                      },
                      iconSize: 25,
                      icon: const Icon(
                        CupertinoIcons.arrow_up_arrow_down,
                        color: FrankencoinColors.frRed,
                      ),
                    ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
            child: CupertinoTextField(
              readOnly: true,
              prefix: Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  enableFeedback: false,
                  onTap: () => _presentPicker(context, false),
                  child: Observer(
                    builder: (_) => Image.asset(
                      getCryptoAssetImagePath(widget.equityVM.receiveCurrency),
                      width: 42,
                    ),
                  ),
                ),
              ),
              placeholder: "0.0000",
              controller: _receiveController,
            ),
          ),
          Observer(
            builder: (_) => Padding(
              padding: const EdgeInsets.only(left: 26, right: 26),
              child: EstimatedTxFee(
                estimatedFee: EtherAmount.inWei(
                        BigInt.from(widget.equityVM.sendVM.estimatedFee))
                    .getValueInUnit(EtherUnit.ether),
                nativeSymbol: Blockchain.getFromChainId(
                        widget.equityVM.sendCurrency.chainId)
                    .nativeSymbol,
              ),
            ),
          ),
          Observer(
            builder: (_) => Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 26, right: 26),
              child: SwapRouteInfos(
                swapRoute: widget.equityVM.swapRoute,
                bottomSheetService: widget.bottomSheetService,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Observer(
              builder: (_) => CupertinoButton(
                onPressed: widget.equityVM.isReadyToCreate
                    ? widget.equityVM.createTradeTransaction
                    : null,
                color: FrankencoinColors.frRed,
                child: widget.equityVM.state is InitialExecutionState
                    ? Text(
                        S.of(context).send,
                        style: const TextStyle(fontSize: 16),
                      )
                    : const CupertinoActivityIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _effectsInstalled = false;

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;

    _amountController.addListener(() {
      if (_amountController.text.isEmpty) {
        widget.equityVM.investAmount = BigInt.zero;
        return;
      }

      final amount = parseFixed(_amountController.text.replaceAll(",", "."),
          widget.equityVM.sendCurrency.decimals);

      if (amount != widget.equityVM.investAmount) {
        widget.equityVM.investAmount = amount;
      }
    });

    reaction((_) => widget.equityVM.expectedReturn, (BigInt expectedReturn) {
      final amount =
          formatFixed(expectedReturn, widget.equityVM.receiveCurrency.decimals);

      if (amount != _receiveController.text) _receiveController.text = amount;
    });

    reaction((_) => widget.equityVM.state, (ExecutionState state) {
      if (state is AwaitingConfirmationExecutionState) {
        final amount = formatFixed(widget.equityVM.investAmount,
            widget.equityVM.sendCurrency.decimals);
        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.equityVM.sendVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: amount,
            estimatedFee: estimatedFee.toString(),
            spendCurrency: widget.equityVM.sendCurrency,
            onConfirm: () => widget.equityVM.commitTransaction(),
            onDecline: () => widget.equityVM.state = InitialExecutionState(),
          ),
        );
      }

      if (state is ExecutedSuccessfullyState) {
        final txId = state.payload as String;

        showDialog<void>(
          context: context,
          builder: (_) => SuccessfulTxDialog(
            txId: txId,
            onConfirm: () {},
          ),
        );
      }

      if (state is DFXFailureState &&
          widget.equityVM.swapRoute is DFX_SwapRoute) {
        widget.equityVM.launchDFXSwap(context);
        return;
      }

      if (state is FailureState) {
        widget.bottomSheetService.queueBottomSheet(
          isModalDismissible: true,
          widget: BottomSheetMessageDisplayWidget(message: state.error),
        );
      }
    });

    _effectsInstalled = true;
  }

  Future<void> _presentPicker(BuildContext context, bool isSend) async {
    final selected = await widget.bottomSheetService.queueBottomSheet(
      isModalDismissible: true,
      widget: SingleChildScrollView(
        child: CurrencyPicker(
          availableCurrencies: widget.equityVM.swapService.swappableAssets,
          selectedCurrency: isSend
              ? widget.equityVM.sendCurrency
              : widget.equityVM.receiveCurrency,
          textColor: Colors.white,
        ),
      ),
    ) as CryptoCurrency?;

    if (selected != null) {
      if ((!isSend
              ? widget.equityVM.sendCurrency
              : widget.equityVM.receiveCurrency) ==
          selected) {
        widget.equityVM.switchCurrencies();
      } else if (isSend) {
        widget.equityVM.sendCurrency = selected;
      } else {
        widget.equityVM.receiveCurrency = selected;
      }
    }
  }
}
