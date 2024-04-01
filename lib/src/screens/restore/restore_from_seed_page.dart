import 'package:bip39/src/wordlists/english.dart' as wordlist;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/seed_editing_controller.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';

class RestoreFromSeedPage extends BasePage {
  RestoreFromSeedPage(this.walletVM, {super.key});

  final WalletViewModel walletVM;

  @override
  Widget body(BuildContext context) => _RestoreFromSeedPageBody(walletVM: walletVM);
}

class _RestoreFromSeedPageBody extends StatefulWidget {
  final WalletViewModel walletVM;

  const _RestoreFromSeedPageBody({required this.walletVM});

  @override
  State<StatefulWidget> createState() => _RestoreFromSeedPageState();
}

class _RestoreFromSeedPageState extends State<_RestoreFromSeedPageBody> {
  final TextEditingController _controller = SeedEditingController();

  String extractedSeed = "";
  bool _seedIsReady = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).restore_wallet_from_seed,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            S.of(context).restore_wallet_from_seed_description,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: "Seed",
            maxLines: null,
            minLines: 4,
            onChanged: _validateSeed,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: CupertinoButton(
            onPressed: _seedIsReady || _isLoading ? () => _onRestore() : null,
            color: FrankencoinColors.frRed,
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : Text(
                    S.of(context).restore_wallet,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  void _validateSeed(String seed) {
    final seedWords = seed.split(" ").where((element) => element.isNotEmpty);

    if (seedWords.length == 12 && _containsAll(wordlist.WORDLIST, seedWords)) {
      setState(() => _seedIsReady = true);
    } else {
      setState(() => _seedIsReady = false);
    }
  }

  bool _containsAll(Iterable a, Iterable b) {
    for (final element in b) {
      if (!a.contains(element)) return false;
    }
    return true;
  }

  Future<void> _onRestore() async {
    setState(() => _isLoading = true);
    final normalizedSeed = _controller.text
        .split(" ")
        .where((element) => element.isNotEmpty)
        .join(" ");
    await widget.walletVM.restoreWallet(normalizedSeed);
    Navigator.of(context).pushNamed(Routes.dashboard);
  }
}
