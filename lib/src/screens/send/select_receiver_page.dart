import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/address_book/widgets/address_book_entry_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:mobx/mobx.dart';

class SelectReceiverPage extends BasePage {
  SelectReceiverPage(this.sendVM, this.addressBookVM, this.bottomSheetService,
      {super.key, this.initialAmount});

  @override
  String? get title => "Empänger"; //  ToDo

  final SendViewModel sendVM;
  final AddressBookViewModel addressBookVM;
  final BottomSheetService bottomSheetService;
  final String? initialAmount;

  @override
  Widget body(BuildContext context) => _SelectReceiverPageBody(
        sendVM: sendVM,
        addressBookVM: addressBookVM,
        bottomSheetService: bottomSheetService,
        initialAmount: initialAmount,
      );
}

class _SelectReceiverPageBody extends StatefulWidget {
  final SendViewModel sendVM;
  final AddressBookViewModel addressBookVM;
  final String? initialAmount;
  final BottomSheetService bottomSheetService;

  const _SelectReceiverPageBody({
    required this.sendVM,
    required this.addressBookVM,
    required this.bottomSheetService,
    this.initialAmount,
  });

  @override
  State<StatefulWidget> createState() => _SelectReceiverPageBodyState();
}

class _SelectReceiverPageBodyState extends State<_SelectReceiverPageBody> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEffects(context);

    _cryptoAmountController.text = widget.initialAmount ?? "";
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
                ],
              ),
            ),
          ),
        ),
      ),
      Text(
        "or Select from Address Book",
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Lato',
          color: Colors.white,
        ),
      ),
      Expanded(
          child: SingleChildScrollView(
        child: Column(
          children: widget.addressBookVM.entries
              .map(
                (e) => AddressBookEntryCard(
                  onTap: () {
                    print(e.name);
                  },
                  title: e.name,
                  address: e.address,
                  backgroundColor: FrankencoinColors.frDark,
                ),
              )
              .toList(),
        ),
      )),
    ]);
  }

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;

    _addressController.addListener(() {
      final address = _addressController.text;
      if (address != widget.sendVM.address) widget.sendVM.address = address;
    });

    reaction((_) => widget.sendVM.address, (String address) {
      if (address != _addressController.text) _addressController.text = address;
    });

    _effectsInstalled = true;
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
