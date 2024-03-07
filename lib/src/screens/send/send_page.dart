import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widget/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/screens/send/widget/currency_picker.dart';
import 'package:frankencoin_wallet/src/screens/send/widget/successful_tx_dialog.dart';
import 'package:frankencoin_wallet/src/utils/evm_chain_formatter.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class SendPage extends BasePage {
  SendPage(this.sendVM, {super.key});

  @override
  String? get title => S.current.send;

  final SendViewModel sendVM;

  @override
  Widget body(BuildContext context) => _SendPageBody(sendVM: sendVM);
}

class _SendPageBody extends StatefulWidget {
  final SendViewModel sendVM;

  const _SendPageBody({required this.sendVM});

  @override
  State<StatefulWidget> createState() => _SendPageBodyState();
}

class _SendPageBodyState extends State<_SendPageBody> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.sendVM.syncFee();
  }

  @override
  void dispose() {
    super.dispose();
    widget.sendVM.stopSyncFee();
  }

  bool _effectsInstalled = false;

  @override
  Widget build(BuildContext context) {
    _setEffects(context);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(26),
        child: CupertinoTextField(
          controller: _addressController,
          placeholder: S.of(context).wallet_address_receiver,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.deny(RegExp(r" ")),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(26),
        child: CupertinoTextField(
          controller: _cryptoAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          placeholder: "0.0000",
          prefix: Observer(
            builder: (_) => CupertinoButton(
              onPressed: () => _presentPicker(context),
              child: Text(widget.sendVM.spendCurrency.symbol),
            ),
          ),
          suffix: Observer(builder: (_) {
            final rawBalanceAmount = EtherAmount.inWei(BigInt.parse(widget
                    .sendVM
                    .balanceVM
                    .balances[widget.sendVM.spendCurrency]!
                    .balance))
                .getValueInUnit(EtherUnit.ether)
                .toString();
            return CupertinoButton(
              onPressed: () => widget.sendVM.rawCryptoAmount = rawBalanceAmount,
              child: Text(
                rawBalanceAmount,
              ),
            );
          }),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]")),
          ],
        ),
      ),
      Observer(
        builder: (_) => Text(
          EtherAmount.inWei(BigInt.from(widget.sendVM.estimatedFee))
              .getValueInUnit(EtherUnit.ether)
              .toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Observer(
          builder: (_) => CupertinoButton(
            onPressed: widget.sendVM.isReadyToCreate
                ? widget.sendVM.createTransaction
                : null,
            color: const Color.fromRGBO(251, 113, 133, 1.0),
            child: widget.sendVM.state is InitialExecutionState
                ? Text(
                    S.of(context).send,
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

    _addressController.addListener(() {
      final address = _addressController.text;

      if (address != widget.sendVM.address) widget.sendVM.address = address;
    });

    _cryptoAmountController.addListener(() {
      final amount = _cryptoAmountController.text;

      if (amount != widget.sendVM.rawCryptoAmount) {
        widget.sendVM.rawCryptoAmount = amount;
      }
    });

    reaction((_) => widget.sendVM.address, (String address) {
      if (address != _addressController.text) _addressController.text = address;
    });

    reaction((_) => widget.sendVM.rawCryptoAmount, (String rawCryptoAmount) {
      if (rawCryptoAmount != _cryptoAmountController.text) {
        _cryptoAmountController.text = rawCryptoAmount;
      }
    });

    reaction((_) => widget.sendVM.state, (ExecutionState state) {
      print(state);
      if (state is AwaitingConfirmationExecutionState) {
        final cryptoAmountString = EVMChainFormatter.parseEVMChainAmount(
            widget.sendVM.rawCryptoAmount.replaceAll(",", "."));

        final cryptoAmount =
            EtherAmount.fromInt(EtherUnit.wei, cryptoAmountString);
        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.sendVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);
        final receiverAddress = widget.sendVM.address;
        final spendCurrency = widget.sendVM.spendCurrency;

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: cryptoAmount.getValueInUnit(EtherUnit.ether).toString(),
            estimatedFee: estimatedFee.toString(),
            receiverAddress: receiverAddress,
            spendCurrency: spendCurrency,
            onConfirm: () => widget.sendVM.commitTransaction(),
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
    });

    _effectsInstalled = true;
  }

  void _presentPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Observer(
        builder: (_) => CurrencyPicker(
            availableCurrencies: CryptoCurrency.values,
            selectedCurrency: widget.sendVM.spendCurrency,
            onSelect: (CryptoCurrency cryptoCurrency) {
              widget.sendVM.spendCurrency = cryptoCurrency;
            }),
      ),
    );
  }
}
