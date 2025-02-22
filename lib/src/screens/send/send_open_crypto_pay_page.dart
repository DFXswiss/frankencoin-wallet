import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/models.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/blockchain_selector.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_open_crypto_pay_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:mobx/mobx.dart';

class SendOpenCryptoPayPage extends BasePage {
  SendOpenCryptoPayPage(this.sendVM, this.bottomSheetService, this.dfxService,
      {super.key, required this.openCryptoPayRequest});

  @override
  String? get title => S.current.send;

  final SendOpenCryptoPayViewModel sendVM;
  final BottomSheetService bottomSheetService;
  final DFXService dfxService;
  final OpenCryptoPayRequest openCryptoPayRequest;

  @override
  Widget body(BuildContext context) => _SendOpenCryptoPayPageBody(
        sendVM: sendVM,
        bottomSheetService: bottomSheetService,
        dfxService: dfxService,
        openCryptoPayRequest: openCryptoPayRequest,
      );
}

class _SendOpenCryptoPayPageBody extends StatefulWidget {
  final SendOpenCryptoPayViewModel sendVM;
  final OpenCryptoPayRequest openCryptoPayRequest;
  final DFXService dfxService;
  final BottomSheetService bottomSheetService;

  const _SendOpenCryptoPayPageBody({
    required this.sendVM,
    required this.bottomSheetService,
    required this.dfxService,
    required this.openCryptoPayRequest,
  });

  @override
  State<StatefulWidget> createState() => _SendOpenCryptoPayPageBodyState();
}

class _SendOpenCryptoPayPageBodyState
    extends State<_SendOpenCryptoPayPageBody> {
  @override
  void initState() {
    super.initState();
    _setEffects(context);

    widget.sendVM.cryptoAmount = widget.openCryptoPayRequest.amount;
    widget.sendVM.timeLeft = widget.openCryptoPayRequest.expiry;
    widget.sendVM.startTimeLeft();
    widget.sendVM.syncFee();

    final needsRefill = widget.sendVM.needsRefill();
    if (!needsRefill && widget.dfxService.isAvailable) {
      final amount = formatFixed(
          widget.sendVM.refillAmount(), widget.sendVM.spendCurrency.decimals);
      widget.dfxService.launchProvider(
        context,
        true,
        paymentMethod: "card",
        blockchain: widget.sendVM.spendCurrency.blockchain,
        amount: amount,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.sendVM.stopTimers();
  }

  bool _effectsInstalled = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          S.of(context).open_crypto_pay_bill,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Lato',
            color: Colors.white,
          ),
        ),
      ),
      Expanded(
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${formatFixed(widget.sendVM.cryptoAmount, widget.sendVM.spendCurrency.decimals)} ZCHF',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
            Text(
              S.of(context).to(widget.openCryptoPayRequest.receiverName),
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ],
        )),
      ),
      Observer(
        builder: (_) => Padding(
          padding: const EdgeInsets.only(left: 26, right: 26),
          child: BlockchainSelector(
            bottomSheetService: widget.bottomSheetService,
            blockchain: widget.sendVM.spendCurrency.blockchain,
            onSelect: _onSelectBlockchain,
          ),
        ),
      ),
      Observer(
        builder: (_) => Padding(
          padding: const EdgeInsets.only(left: 26, right: 26),
          child: AmountInfoRow(
            title: S.of(context).estimated_fee,
            amount: BigInt.from(widget.sendVM.estimatedFee),
            currencySymbol: widget.sendVM.spendCurrency.blockchain.nativeSymbol,
          ),
        ),
      ),
      Padding(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CupertinoButton(
                    onPressed: onPressedCancel,
                    color: FrankencoinColors.frRed,
                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white,
                      size: 19,
                    )),
              ),
            ),
            Expanded(
              flex: 2,
              child: Observer(
                builder: (_) => CupertinoButton(
                  onPressed: widget.sendVM.timeLeft != 0
                      ? widget.sendVM.createTransaction
                      : null,
                  color: FrankencoinColors.frGreen,
                  child: widget.sendVM.state is InitialExecutionState
                      ? Text(
                          widget.sendVM.timeLeft != 0
                              ? "${S.of(context).pay} - ${S.of(context).seconds(widget.sendVM.timeLeft.toString())}"
                              : S.of(context).expired,
                          style: const TextStyle(fontSize: 16),
                        )
                      : const CupertinoActivityIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;
    reaction((_) => widget.sendVM.state, (ExecutionState state) {
      if (state is ExecutedSuccessfullyState) Navigator.of(context).pop();

      if (state is FailureState) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(errorMessage: state.error),
        );
      }
    });

    _effectsInstalled = true;
  }

  void _onSelectBlockchain(Blockchain blockchain) {
    switch (blockchain) {
      case Blockchain.ethereum:
        widget.sendVM.spendCurrency = CryptoCurrency.zchf;
        break;
      case Blockchain.polygon:
        widget.sendVM.spendCurrency = CryptoCurrency.polZCHF;
        break;
      case Blockchain.base:
        widget.sendVM.spendCurrency = CryptoCurrency.baseZCHF;
        break;
      case Blockchain.arbitrum:
        widget.sendVM.spendCurrency = CryptoCurrency.arbZCHF;
        break;
      case Blockchain.optimism:
        widget.sendVM.spendCurrency = CryptoCurrency.opZCHF;
        break;
    }
  }

  void onPressedCancel() {
    widget.sendVM.cancelRequest();
    Navigator.of(context).pop();
  }
}
