import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage(this.walletVW, {super.key});

  final WalletViewModel walletVW;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: WillPopScope(
        //canPop: false,
        onWillPop: () async => false,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Image.asset("assets/images/frankencoin.png"),
              ),
              Text(
                S.of(context).welcome_frankecoin_wallet,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 5, right: 20, left: 20),
                child: Text(
                  S.of(context).welcome_disclaimer,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: CupertinoButton(
                  onPressed: () => _onCreateWallet(context),
                  color: const Color.fromRGBO(251, 113, 133, 1.0),
                  child: Text(
                    S.of(context).create_wallet,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: CupertinoButton(
                  onPressed: () => _onRestoreWallet(context),
                  child: Text(
                    S.of(context).restore_wallet,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(251, 113, 133, 1.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCreateWallet(BuildContext context) async {
    final wallet = await walletVW.createNewWallet();

    Navigator.of(context)
        .pushNamed(Routes.walletCreate, arguments: wallet.seed);
  }

  void _onRestoreWallet(BuildContext context) {
    if (DeviceInfo.instance.isDesktop) {
      Navigator.of(context).pushNamed(Routes.walletRestoreSeed);
    } else {
      Navigator.of(context).pushNamed(Routes.walletRestore);
    }
  }
}
