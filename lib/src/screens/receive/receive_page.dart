import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/widget/qr_address_widget.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';

class ReceivePage extends BasePage {
  ReceivePage(this._walletAccount, {super.key});

  final WalletAccount _walletAccount;

  @override
  Widget body(BuildContext context) {
    final address = _walletAccount.primaryAddress.address.hex;

    return Center(
      child: QRAddressWidget(
        address: address
      ),
    );
  }
}
