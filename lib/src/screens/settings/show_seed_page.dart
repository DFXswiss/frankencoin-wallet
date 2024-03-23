import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';

class ShowSeedPage extends BasePage {
  ShowSeedPage(this.appStore, {super.key});

  final AppStore appStore;

  @override
  String get title => S.current.your_seed;

  @override
  Widget body(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              S.of(context).show_seed_description,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Observer(
              builder: (_) => Text(
                appStore.wallet!.seed,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Spacer(),
          CupertinoButton(
            color: const Color.fromRGBO(251, 113, 133, 1),
            onPressed: _copySeed,
            child: Text(S.of(context).copy_seed),

          )
        ],
      ),
    );
  }

  Future<void> _copySeed() async =>
      Clipboard.setData(ClipboardData(text: appStore.wallet!.seed));
}
