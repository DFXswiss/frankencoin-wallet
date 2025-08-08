import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/savings_edit_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class EditSavingsPage extends BasePage {
  EditSavingsPage(this.savingsEditVM, this.bottomSheetService, {super.key});

  @override
  String? get title => S.current.savings_edit;

  final SavingsEditViewModel savingsEditVM;
  final BottomSheetService bottomSheetService;

  @override
  Widget body(BuildContext context) => _EditSavingsPageBody(
    savingsEditVM: savingsEditVM,
        bottomSheetService: bottomSheetService,
      );
}

class _EditSavingsPageBody extends StatefulWidget {
  final SavingsEditViewModel savingsEditVM;
  final BottomSheetService bottomSheetService;

  const _EditSavingsPageBody({
    required this.savingsEditVM,
    required this.bottomSheetService,
  });

  @override
  State<StatefulWidget> createState() => _EditSavingsPageBodyState();
}

class _EditSavingsPageBodyState extends State<_EditSavingsPageBody> {
  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEffects(context);

    _cryptoAmountController.text = widget.savingsEditVM.rawCryptoAmount;
    widget.savingsEditVM.syncFee();
  }

  @override
  void dispose() {
    super.dispose();
    widget.savingsEditVM.stopSyncFee();
  }

  bool _effectsInstalled = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
        child: CupertinoTextField(
          controller: _cryptoAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          placeholder: "0.0000",
          prefix: Text(widget.savingsEditVM.spendCurrency.symbol),
          suffix: Observer(builder: (_) {
            final rawBalanceAmount = widget.savingsEditVM.balanceStore
                    .balances[widget.savingsEditVM.spendCurrency.balanceId]
                    ?.getBalance() ??
                BigInt.zero;

            return CupertinoButton(
              onPressed: widget.savingsEditVM.setMaxAmount,
              child: Text(
                formatFixed(
                    rawBalanceAmount, widget.savingsEditVM.spendCurrency.decimals,
                    fractionalDigits: 3, trimZeros: false),
              ),
            );
          }),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]")),
          ],
        ),
      ),
      Observer(
        builder: (_) => Padding(
          padding: const EdgeInsets.only(left: 26, right: 26),
          child: AmountInfoRow(
            title: S.of(context).estimated_fee,
            amount: BigInt.from(widget.savingsEditVM.estimatedFee),
            currencySymbol: widget.savingsEditVM.spendCurrency.blockchain.nativeSymbol,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Observer(
          builder: (_) => CupertinoButton(
            onPressed: widget.savingsEditVM.isReadyToCreate
                ? widget.savingsEditVM.createTransaction
                : null,
            color: FrankencoinColors.frRed,
            child: widget.savingsEditVM.state is InitialExecutionState
                ? Text(
                    S.of(context).save,
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

    _cryptoAmountController.addListener(() {
      final amount = _cryptoAmountController.text;

      if (amount != widget.savingsEditVM.rawCryptoAmount) {
        widget.savingsEditVM.rawCryptoAmount = amount;
      }
    });

    reaction((_) => widget.savingsEditVM.rawCryptoAmount, (String rawCryptoAmount) {
      if (rawCryptoAmount != _cryptoAmountController.text) {
        _cryptoAmountController.text = rawCryptoAmount;
      }
    });

    reaction((_) => widget.savingsEditVM.state, (ExecutionState state) {
      if (state is AwaitingConfirmationExecutionState) {
        final cryptoAmount = EtherAmount.inWei(parseFixed(
            widget.savingsEditVM.rawCryptoAmount.replaceAll(",", "."),
            widget.savingsEditVM.spendCurrency.decimals));

        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.savingsEditVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);
        final spendCurrency = widget.savingsEditVM.spendCurrency;

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: cryptoAmount.getValueInUnit(EtherUnit.ether).toString(),
            estimatedFee: estimatedFee.toString(),
            spendCurrency: CustomErc20Token.fromCryptoCurrency(spendCurrency),
            onConfirm: () => widget.savingsEditVM.commitTransaction(),
            onDecline: () => widget.savingsEditVM.state = InitialExecutionState(),
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
