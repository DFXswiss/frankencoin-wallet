import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/confirm_dialog.dart';

class SettingsPage extends BasePage {
  SettingsPage(this.walletVM, this.balanceVM, {super.key});

  final WalletViewModel walletVM;
  final BalanceViewModel balanceVM;

  @override
  String get title => S.current.settings;

  @override
  Widget body(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
              child: Text(
                S.of(context).danger_zone,
                style: const TextStyle(color: Color.fromRGBO(251, 113, 133, 1)),
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () => _deleteWallet(context),
            child: Text(
              S.of(context).sign_out,
              style: const TextStyle(color: Color.fromRGBO(251, 113, 133, 1)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _deleteWallet(BuildContext context) async {
    final isSure = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: S.of(context).are_you_sure,
        message: S.of(context).sign_out_confirmation,
      ),
    );

    if (isSure) {
      await walletVM.deleteWallet();
      Navigator.of(context).pushNamed(Routes.welcome);
    }
  }
}
