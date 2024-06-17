import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage(this.walletVW, {super.key});

  final WalletViewModel walletVW;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset("assets/images/frankencoin.png"),
                ),
                Text(
                  S.of(context).welcome_frankecoin_wallet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 5, right: 20, left: 20),
                  child: InkWell(
                    onTap: () => launchUrl(
                        Uri.parse("https://docs.frankencoin.app/en/tou.html"),
                        mode: LaunchMode.externalApplication),
                    enableFeedback: false,
                    child: StyledText(
                      text: S.of(context).welcome_disclaimer,
                      tags: {
                        'underline': StyledTextTag(
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey,
                          ),
                        ),
                      },
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: CupertinoButton(
                    onPressed: () => _onCreateWallet(context),
                    color: FrankencoinColors.frRed,
                    child: Text(
                      S.of(context).create_wallet,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () => _onRestoreWallet(context),
                  child: Text(
                    S.of(context).restore_wallet,
                    style: const TextStyle(
                      fontSize: 16,
                      color: FrankencoinColors.frRed,
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
