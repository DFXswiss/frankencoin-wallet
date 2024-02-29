import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: WillPopScope(
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
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: Text(
                  S.of(context).welcome_disclaimer,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  onPressed: null,
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
    final wallet = Wallet.random();
    await wallet.save();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("walletCreated", true);

    Navigator.of(context)
        .pushNamed(Routes.walletCreate, arguments: wallet.seed);
  }
}
