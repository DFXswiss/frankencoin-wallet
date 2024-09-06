import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/blockchain_selector.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/frankencoin_pay/send_frankencoin_pay_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class SendFrankencoinPayPage extends BasePage {
  SendFrankencoinPayPage(this.sendVM, this.bottomSheetService, this.dfxService,
      {super.key, required this.frankencoinPayRequest});

  @override
  String? get title => S.current.send;

  final SendFrankencoinPayViewModel sendVM;
  final BottomSheetService bottomSheetService;
  final DFXService dfxService;
  final FrankencoinPayRequest frankencoinPayRequest;

  @override
  Widget body(BuildContext context) => _SendFrankencoinPayPageBody(
        sendVM: sendVM,
        bottomSheetService: bottomSheetService,
        dfxService: dfxService,
        frankencoinPayRequest: frankencoinPayRequest,
      );
}

class _SendFrankencoinPayPageBody extends StatefulWidget {
  final SendFrankencoinPayViewModel sendVM;
  final FrankencoinPayRequest frankencoinPayRequest;
  final DFXService dfxService;
  final BottomSheetService bottomSheetService;

  const _SendFrankencoinPayPageBody({
    required this.sendVM,
    required this.bottomSheetService,
    required this.dfxService,
    required this.frankencoinPayRequest,
  });

  @override
  State<StatefulWidget> createState() => _SendFrankencoinPayPageBodyState();
}

class _SendFrankencoinPayPageBodyState
    extends State<_SendFrankencoinPayPageBody> {
  @override
  void initState() {
    super.initState();
    _setEffects(context);

    widget.sendVM.address = widget.frankencoinPayRequest.address;
    widget.sendVM.cryptoAmount = widget.frankencoinPayRequest.amount;
    widget.sendVM.timeLeft = widget.frankencoinPayRequest.expiry;
    widget.sendVM.startTimeLeft();
    widget.sendVM.syncFee();

    final needsRefill = widget.sendVM.needsRefill();
    if (!needsRefill) {
      final amount = formatFixed(
          widget.sendVM.refillAmount(), widget.sendVM.spendCurrency.decimals);
      widget.dfxService.launchProvider(context, true,
          paymentMethod: "card",
          blockchain: widget.sendVM.spendCurrency.blockchain,
          amount: amount);
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
          S.of(context).frankencoin_pay_bill,
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
              S.of(context).to(widget.frankencoinPayRequest.receiverName),
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
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Observer(
          builder: (_) => CupertinoButton(
            onPressed: widget.sendVM.timeLeft != 0
                ? widget.sendVM.createTransaction
                : null,
            color: FrankencoinColors.frRed,
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
    ]);
  }

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;
    reaction((_) => widget.sendVM.state, (ExecutionState state) {
      if (state is AwaitingConfirmationExecutionState) {
        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.sendVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: formatFixed(widget.sendVM.cryptoAmount,
                widget.sendVM.spendCurrency.decimals),
            estimatedFee: estimatedFee.toString(),
            receiverAddress: widget.sendVM.address,
            spendCurrency: CustomErc20Token.fromCryptoCurrency(
                widget.sendVM.spendCurrency),
            onConfirm: () =>
                widget.sendVM.commitTransaction(widget.frankencoinPayRequest),
            onDecline: () => widget.sendVM.state = InitialExecutionState(),
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
        widget.sendVM.spendCurrency = CryptoCurrency.maticZCHF;
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
}
