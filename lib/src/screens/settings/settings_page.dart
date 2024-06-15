import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entities/language.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/language_picker.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/option_row.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/confirm_dialog.dart';

class SettingsPage extends BasePage {
  SettingsPage(this.walletVM, this.balanceVM, this.settingsStore, {super.key});

  final WalletViewModel walletVM;
  final BalanceViewModel balanceVM;
  final SettingsStore settingsStore;

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
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                S.of(context).settings_general,
                style: const TextStyle(color: FrankencoinColors.frRed),
              ),
            ),
          ),
          OptionRow(
            name: "WalletConnect",
            type: OptionRowType.navigate,
            onTap: (_) =>
                Navigator.of(context).pushNamed(Routes.settingsWalletConnect),
          ),
          OptionRow(
            name: S.of(context).contacts,
            type: OptionRowType.navigate,
            onTap: (_) => Navigator.of(context).pushNamed(Routes.addressBook),
          ),
          OptionRow(
            name: S.of(context).nodes,
            type: OptionRowType.navigate,
            onTap: (_) => Navigator.of(context).pushNamed(Routes.settingsNodes),
          ),
          OptionRow(
            name: S.of(context).assets,
            type: OptionRowType.navigate,
            onTap: (_) =>
                Navigator.of(context).pushNamed(Routes.settingsCustomTokens),
          ),
          Observer(
            builder: (_) => OptionRow(
              name: S.of(context).settings_language,
              type: OptionRowType.edit,
              suffix: settingsStore.language.name,
              onTap: _setLanguage,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                S.of(context).danger_zone,
                style: const TextStyle(color: FrankencoinColors.frRed),
              ),
            ),
          ),
          OptionRow(
            name: S.of(context).show_seed,
            type: OptionRowType.navigate,
            onTap: (_) => Navigator.of(context).pushNamed(Routes.settingsSeed),
          ),
          Observer(
            builder: (_) => OptionRow(
              name: S.of(context).experimental_features,
              type: OptionRowType.edit,
              suffix: settingsStore.enableExperimentalFeatures
                  ? S.of(context).enabled
                  : S.of(context).disabled,
              onTap: (_) => settingsStore.enableExperimentalFeatures =
                  !settingsStore.enableExperimentalFeatures,
            ),
          ),
          CupertinoButton(
            onPressed: () => _deleteWallet(context),
            child: Text(
              S.of(context).sign_out,
              style: const TextStyle(color: FrankencoinColors.frRed),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _setLanguage(BuildContext context) async {
    final setLanguage = await showDialog(
      context: context,
      builder: (_) => LanguagePicker(
        availableLanguages: Language.values,
        selectedLanguage: settingsStore.language,
      ),
    );

    settingsStore.language = setLanguage;
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
