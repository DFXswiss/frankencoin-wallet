import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class SendAssetPage extends BasePage {
  SendAssetPage(
    this.sendAssetVM,
    this.bottomSheetService, {
    super.key,
    required this.sendCurrency,
    this.initialAddress,
    this.initialAmount,
  }) {
    sendAssetVM.spendCurrency = sendCurrency;
  }

  @override
  String? get title => S.current.send;

  final SendAssetViewModel sendAssetVM;
  final BottomSheetService bottomSheetService;
  final String? initialAddress;
  final String? initialAmount;
  final CustomErc20Token sendCurrency;

  @override
  Widget body(BuildContext context) => _SendAssetPageBody(
        sendAssetVM: sendAssetVM,
        bottomSheetService: bottomSheetService,
        initialAddress: initialAddress,
        initialAmount: initialAmount,
        sendCurrency: sendCurrency,
      );
}

class _SendAssetPageBody extends StatefulWidget {
  final SendAssetViewModel sendAssetVM;
  final String? initialAddress;
  final String? initialAmount;
  final CustomErc20Token sendCurrency;
  final BottomSheetService bottomSheetService;

  const _SendAssetPageBody({
    required this.sendAssetVM,
    required this.bottomSheetService,
    required this.sendCurrency,
    this.initialAddress,
    this.initialAmount,
  });

  @override
  State<StatefulWidget> createState() => _SendAssetPageBodyState();
}

class _SendAssetPageBodyState extends State<_SendAssetPageBody> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEffects(context);

    _addressController.text = widget.initialAddress ?? "";
    _cryptoAmountController.text = widget.initialAmount ?? "";
    widget.sendAssetVM.syncFee();
  }

  @override
  void dispose() {
    super.dispose();
    widget.sendAssetVM.stopSyncFee();
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
              onPressed: null,
              child: Text(widget.sendAssetVM.spendCurrency.symbol),
            ),
          ),
          suffix: Observer(builder: (_) {
            final rawBalanceAmount = widget.sendAssetVM.balanceStore
                    .balances[widget.sendAssetVM.spendCurrency.balanceId]
                    ?.getBalance() ??
                BigInt.zero;

            return CupertinoButton(
              onPressed: () => widget.sendAssetVM.rawCryptoAmount = formatFixed(
                  rawBalanceAmount, widget.sendAssetVM.spendCurrency.decimals),
              child: Text(
                formatFixed(
                    rawBalanceAmount, widget.sendAssetVM.spendCurrency.decimals,
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
            amount: BigInt.from(widget.sendAssetVM.estimatedFee),
            currencySymbol:
                widget.sendAssetVM.spendCurrency.blockchain.nativeSymbol,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Observer(
          builder: (_) => CupertinoButton(
            onPressed: widget.sendAssetVM.isReadyToCreate
                ? widget.sendAssetVM.createTransaction
                : null,
            color: FrankencoinColors.frRed,
            child: widget.sendAssetVM.state is InitialExecutionState
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
      if (address != widget.sendAssetVM.address)
        widget.sendAssetVM.address = address;
    });

    _cryptoAmountController.addListener(() {
      final amount = _cryptoAmountController.text;

      if (amount != widget.sendAssetVM.rawCryptoAmount) {
        widget.sendAssetVM.rawCryptoAmount = amount;
      }
    });

    reaction((_) => widget.sendAssetVM.address, (String address) {
      if (address != _addressController.text) _addressController.text = address;
    });

    reaction((_) => widget.sendAssetVM.rawCryptoAmount,
        (String rawCryptoAmount) {
      if (rawCryptoAmount != _cryptoAmountController.text) {
        _cryptoAmountController.text = rawCryptoAmount;
      }
    });

    reaction((_) => widget.sendAssetVM.state, (ExecutionState state) {
      if (state is AwaitingConfirmationExecutionState) {
        final cryptoAmount = formatFixed(
            parseFixed(widget.sendAssetVM.rawCryptoAmount.replaceAll(",", "."),
                widget.sendAssetVM.spendCurrency.decimals),
            widget.sendAssetVM.spendCurrency.decimals);

        final estimatedFee =
            EtherAmount.inWei(BigInt.from(widget.sendAssetVM.estimatedFee))
                .getValueInUnit(EtherUnit.ether);
        final receiverAddress = widget.sendAssetVM.resolvedAlias?.address ??
            widget.sendAssetVM.address;

        showDialog<void>(
          context: context,
          builder: (BuildContext context) => ConfirmationAlert(
            amount: cryptoAmount.toString(),
            estimatedFee: estimatedFee.toString(),
            receiverAddress: receiverAddress,
            spendCurrency: widget.sendAssetVM.spendCurrency,
            onConfirm: () => widget.sendAssetVM.commitTransaction(),
            onDecline: () => widget.sendAssetVM.state = InitialExecutionState(),
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
    }
  }
}
