import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';

class CreateWalletPage extends StatelessWidget {
  const CreateWalletPage(this.seed, {super.key});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset(
                    "assets/images/frankencoin.png",
                    width: 155,
                  ),
                ),
                Text(
                  S.of(context).your_seed,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: Text(
                    S.of(context).your_seed_disclaimer,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Text(
                  seed,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CupertinoButton(
                    onPressed: _copySeed,
                    child: Text(
                      S.of(context).copy_seed,
                      style: const TextStyle(
                          fontSize: 16, color: FrankencoinColors.frRed),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: CupertinoButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.dashboard),
                    color: FrankencoinColors.frRed,
                    child: Text(
                      S.of(context).create_wallet,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copySeed() async =>
      Clipboard.setData(ClipboardData(text: seed));
}
