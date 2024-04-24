import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/widgets/qr_address_widget.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';

class ReceivePage extends BasePage {
  ReceivePage(this._walletAccount, {super.key});

  final WalletAccount _walletAccount;

  @override
  Widget body(BuildContext context) {
    final address = _walletAccount.primaryAddress.address.hexEip55;
    final shortenedAddress =
        "${address.substring(0, 7)}...${address.substring(address.length - 10)}";

    return Center(
      child: QRAddressWidget(
        address: EthereumURI(address: address, amount: '').toString(),
        subtitle: shortenedAddress,
      ),
    );
  }
}
