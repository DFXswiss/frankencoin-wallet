import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/estimated_tx_fee.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:frankencoin_wallet/src/utils/evm_chain_formatter.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/equity_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class PoolPage extends BasePage {
  final BalanceViewModel balanceVM;
  final EquityViewModel equityVM;

  PoolPage(this.balanceVM, this.equityVM, {super.key});

  @override
  String? get title => S.current.invest;

  @override
  Widget body(BuildContext context) => _PoolPageBody(balanceVM, equityVM);
}

class _PoolPageBody extends StatefulWidget {
  final BalanceViewModel balanceVM;
  final EquityViewModel equityVM;

  const _PoolPageBody(this.balanceVM, this.equityVM);

  @override
  State<StatefulWidget> createState() => _PoolPageBodyState();
}

class _PoolPageBodyState extends State<_PoolPageBody> {
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

  String getLeadingImagePath(CryptoCurrency cryptoCurrency) {
    switch (cryptoCurrency) {
      case CryptoCurrency.zchf:
        return "assets/images/crypto/zchf.png";
      case CryptoCurrency.fps:
        return "assets/images/crypto/fps.png";
      default:
        return "assets/images/frankencoin.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    _setEffects(context);

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 26, bottom: 10),
          child: CupertinoTextField(
            prefix: Padding(
              padding: const EdgeInsets.all(5),
              child: Observer(
                  builder: (_) => Image.asset(
                      getLeadingImagePath(widget.equityVM.sendCurrency),
                      width: 42)),
            ),
            placeholder: "0.0000",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: Observer(builder: (_) {
              final rawBalanceAmount = EtherAmount.inWei(BigInt.parse(widget
                      .balanceVM
                      .balances[widget.equityVM.sendCurrency]!
                      .balance))
                  .getValueInUnit(EtherUnit.ether);
              return CupertinoButton(
                onPressed: () =>
                    _amountController.text = rawBalanceAmount.toString(),
                child: Text(
                  rawBalanceAmount.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 16, fontFamily: 'Lato'),
                ),
              );
            }),
          ),
        ),
        IconButton(
            onPressed: () {
              widget.equityVM.sendCurrency = widget.equityVM.reverseCurrency;
              _amountController.text = "";
            },
            iconSize: 25,
            icon: const Icon(
              CupertinoIcons.arrow_up_arrow_down,
              color: FrankencoinColors.frRed,
            )),
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            prefix: Padding(
              padding: const EdgeInsets.all(5),
              child: Observer(
                builder: (_) => Image.asset(
                    getLeadingImagePath(widget.equityVM.reverseCurrency),
                    width: 42),
              ),
            ),
            placeholder: "0.0000",
            controller: _receiveController,
            enabled: false,
          ),
        ),
        Observer(
          builder: (_) => Padding(
            padding: const EdgeInsets.only(left: 26, right: 26),
            child: EstimatedTxFee(
              estimatedFee: EtherAmount.inWei(
                      BigInt.from(widget.equityVM.sendVM.estimatedFee))
                  .getValueInUnit(EtherUnit.ether),
              nativeSymbol: "ETH",
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
    );
  }

  bool _effectsInstalled = false;

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;

    _amountController.addListener(() {
      final amountString = EVMChainFormatter.parseEVMChainAmount(
          _amountController.text.replaceAll(",", "."));

      final amount = BigInt.from(amountString);

      if (amount != widget.equityVM.investAmount) {
        widget.equityVM.investAmount = amount;
      }
    });

    reaction((_) => widget.equityVM.investAmount, (BigInt investAmount) {
      widget.equityVM.updateExpectedReturn();
    });

    reaction((_) => widget.equityVM.expectedReturn, (BigInt expectedReturn) {
      final amount = EtherAmount.inWei(expectedReturn)
          .getValueInUnit(EtherUnit.ether)
          .toString();

      if (amount != _receiveController.text) _receiveController.text = amount;
    });

    reaction((_) => widget.equityVM.state, (ExecutionState state) {
      if (state is AwaitingConfirmationExecutionState) {
        final amount = EtherAmount.inWei(widget.equityVM.investAmount)
            .getValueInUnit(EtherUnit.ether);
        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.equityVM.sendVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: amount.toString(),
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

      if (state is FailureState) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(errorMessage: state.error),
        );
      }
    });
    _effectsInstalled = true;
  }
}
