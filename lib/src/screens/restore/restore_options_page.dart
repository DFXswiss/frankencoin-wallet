import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/seedqr.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/widgets/option_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';

class RestoreOptionsPage extends BasePage {
  RestoreOptionsPage(this.walletVM, {super.key});

  final WalletViewModel walletVM;

  @override
  String? get title => S.current.restore_wallet;

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        OptionCard(
          title: S.of(context).restore_wallet_from_seed_option,
          description:
              S.of(context).restore_wallet_from_seed_option_description,
          leadingIcon: Icons.key,
          action: () =>
              Navigator.of(context).pushNamed(Routes.walletRestoreSeed),
        ),
        OptionCard(
          title: S.of(context).restore_wallet_with_seed_qr_option,
          description:
              S.of(context).restore_wallet_with_seed_qr_option_description,
          leadingIcon: Icons.qr_code,
          action: () => _onRestore(context),
        ),
      ],
    );
  }

  Future<void> _onRestore(BuildContext context) async {
    String? seed = await showDialog(
      context: context,
      builder: (dialogContext) => QRScanDialog(
        validateQR: (code, raw) => isSeedQr(code!) || isCompactSeedQr(raw!),
        onData: (code, raw) {
          if (isSeedQr(code!)) {
            final seed = getSeedFromSeedQr(code);
            Navigator.of(dialogContext, rootNavigator: true).pop(seed);
          } else if (isCompactSeedQr(raw!)) {
            final seed = getSeedFromCompactSeedQr(raw);
            Navigator.of(dialogContext, rootNavigator: true).pop(seed);
          }
        },
      ),
    );

    if (seed == null) return;

    await walletVM.restoreWallet(seed);
    Navigator.of(context).pushNamed(Routes.dashboard);
  }
}
