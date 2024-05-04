import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';

class AddContactPage extends BasePage {
  final AddressBookViewModel addressBookVM;
  final String? initialName;
  final String? initialAddress;

  AddContactPage(this.addressBookVM,
      {this.initialName, this.initialAddress, super.key});

  @override
  String get title => S.current.add_contact;

  @override
  Widget body(BuildContext context) => _AddContactPageBody(
        addressBookVM: addressBookVM,
        initialName: initialName,
        initialAddress: initialAddress,
      );
}

class _AddContactPageBody extends StatefulWidget {
  final AddressBookViewModel addressBookVM;
  final String? initialName;
  final String? initialAddress;

  const _AddContactPageBody({
    required this.addressBookVM,
    this.initialName,
    this.initialAddress,
  });

  @override
  State<StatefulWidget> createState() => _AddContactPageBodyState();
}

class _AddContactPageBodyState extends State<_AddContactPageBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _bottomSheetService = getIt.get<BottomSheetService>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.initialName ?? "";
    _addressController.text = widget.initialAddress ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _nameController,
            placeholder: S.of(context).name,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _addressController,
            placeholder: S.of(context).address,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(RegExp(r" ")),
            ],
            suffix: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pasteText,
                      icon: const Icon(Icons.paste),
                    ),
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
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: CupertinoButton(
            onPressed: _isLoading ? null : _save,
            color: FrankencoinColors.frRed,
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : Text(
                    S.of(context).save,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    ));
  }

  Future<void> _save() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final address = _addressController.text.trim();

    if (!RegExp(r'^(0x)?[0-9a-f]{40}$', caseSensitive: false)
        .hasMatch(address)) {
      setState(() => _isLoading = false);
      _bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget:
            BottomSheetMessageDisplayWidget(message: S.current.invalid_address),
      );
      return;
    }

    await widget.addressBookVM.saveEntry(
        AddressBookEntry(address: address, name: _nameController.text.trim()));
    setState(() => _isLoading = false);

    Navigator.of(context).pop();
  }

  Future<void> _pasteText() async {
    final value = await Clipboard.getData('text/plain');

    if (value?.text?.isNotEmpty ?? false) {
      _addressController.text = value!.text!;
    }
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
    }
  }
}
