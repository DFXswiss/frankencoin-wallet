import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';

class CreateWalletPage extends StatelessWidget {
  const CreateWalletPage(this.seed, {super.key});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Image.asset("assets/images/frankencoin.png"),
            ),
            Text(
              S.of(context).your_seed,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                seed,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Text(
              S.of(context).your_seed_disclaimer,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: CupertinoButton(
                onPressed: () {},
                color: const Color.fromRGBO(251, 113, 133, 1.0),
                child: Text(
                  S.of(context).create_wallet,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
