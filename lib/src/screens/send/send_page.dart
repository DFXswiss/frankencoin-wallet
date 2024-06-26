import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/currency_picker.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class SendPage extends BasePage {
  SendPage(this.sendVM, this.bottomSheetService,
      {super.key, this.initialAddress, this.initialAmount, this.initialAsset});

  @override
  String? get title => S.current.send;

  final SendViewModel sendVM;
  final BottomSheetService bottomSheetService;
  final String? initialAddress;
  final String? initialAmount;
  final CryptoCurrency? initialAsset;

  @override
  Widget body(BuildContext context) => _SendPageBody(
        sendVM: sendVM,
        bottomSheetService: bottomSheetService,
        initialAddress: initialAddress,
        initialAmount: initialAmount,
        initialAsset: initialAsset,
      );
}

class _SendPageBody extends StatefulWidget {
  final SendViewModel sendVM;
  final String? initialAddress;
  final String? initialAmount;
  final CryptoCurrency? initialAsset;
  final BottomSheetService bottomSheetService;

  const _SendPageBody({
    required this.sendVM,
    required this.bottomSheetService,
    this.initialAddress,
    this.initialAmount,
    this.initialAsset,
  });

  @override
  State<StatefulWidget> createState() => _SendPageBodyState();
}

class _SendPageBodyState extends State<_SendPageBody> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEffects(context);

    _addressController.text = widget.initialAddress ?? "";
    _cryptoAmountController.text = widget.initialAmount ?? "";
    widget.sendVM.spendCurrency = widget.initialAsset ?? CryptoCurrency.zchf;
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
    return Column(children: [
      Padding(
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 26, bottom: 10),
        child: CupertinoTextField(
          controller: _addressController,
          placeholder: S.of(context).wallet_address_receiver,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.deny(RegExp(r" ")),
          ],
          suffix: SizedBox(
            height: 55,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
              child: Row(
                children: [
                  if (DeviceInfo.instance.isMobile)
                    IconButton(
                      onPressed: () => _presentQRScanner(context),
                      icon: const Icon(Icons.qr_code),
                    ),
                  IconButton(
                    onPressed: _openAddressBook,
                    icon: const Icon(CupertinoIcons.book),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
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
            final rawBalanceAmount = widget.sendVM.balanceStore
                    .balances[widget.sendVM.spendCurrency.balanceId]
                    ?.getBalance() ??
                BigInt.zero;

            return CupertinoButton(
              onPressed: () => widget.sendVM.rawCryptoAmount = formatFixed(
                  rawBalanceAmount, widget.sendVM.spendCurrency.decimals),
              child: Text(
                formatFixed(
                    rawBalanceAmount, widget.sendVM.spendCurrency.decimals,
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
            amount: BigInt.from(widget.sendVM.estimatedFee),
            currencySymbol: widget.sendVM.spendCurrency.blockchain.nativeSymbol,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Observer(
          builder: (_) => CupertinoButton(
            onPressed: widget.sendVM.isReadyToCreate
                ? widget.sendVM.createTransaction
                : null,
            color: FrankencoinColors.frRed,
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
      if (state is AwaitingConfirmationExecutionState) {
        final cryptoAmount = EtherAmount.inWei(parseFixed(
            widget.sendVM.rawCryptoAmount.replaceAll(",", "."),
            widget.sendVM.spendCurrency.decimals));

        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.sendVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);
        final receiverAddress =
            widget.sendVM.resolvedAlias?.address ?? widget.sendVM.address;
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

      if (state is FailureState) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(errorMessage: state.error),
        );
      }
    });

    _effectsInstalled = true;
  }

  Future<void> _openAddressBook() async {
    final address = await Navigator.of(context)
        .pushNamed(Routes.addressBook, arguments: true) as AddressBookEntry?;

    if (address != null) _addressController.text = address.address;
  }

  Future<void> _presentPicker(BuildContext context) async {
    final selected = await widget.bottomSheetService.queueBottomSheet(
      isModalDismissible: true,
      widget: Expanded(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: CurrencyPicker(
                availableCurrencies: CryptoCurrency.spendCurrencies,
                selectedCurrency: widget.sendVM.spendCurrency,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ) as CryptoCurrency?;

    if (selected != null) widget.sendVM.spendCurrency = selected;
  }

  Future<void> _presentQRScanner(BuildContext context) async {
    String address = await showDialog(
      context: context,
      builder: (dialogContext) => QRScanDialog(
        validateQR: (code, _) =>
            RegExp(r'(\b0x[a-fA-F0-9]{40}\b)').hasMatch(code!),
        onData: (code, _) =>
            Navigator.of(dialogContext, rootNavigator: true).pop(code),
      ),
    );

    if (address.startsWith("0x")) {
      _addressController.text = address;
    } else {
      final uri = ERC681URI.fromString(address);
      _addressController.text = uri.address;
      _cryptoAmountController.text = uri.amount;
      widget.sendVM.spendCurrency = uri.asset ?? CryptoCurrency.zchf;
    }
  }
}
