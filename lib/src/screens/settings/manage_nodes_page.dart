import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/option_row.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';

class ManageNodesPage extends BasePage {
  ManageNodesPage(this.appStore, {super.key});

  final AppStore appStore;

  @override
  String get title => S.current.nodes;

  @override
  Widget body(BuildContext context) =>
      _ManageNodesPageBody(appStore.settingsStore);
}

class _ManageNodesPageBody extends StatefulWidget {
  final SettingsStore settingsStore;

  const _ManageNodesPageBody(this.settingsStore);

  @override
  State<StatefulWidget> createState() => _ManageNodesPageBodyState();
}

class _ManageNodesPageBodyState extends State<_ManageNodesPageBody> {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Observer(
          builder: (_) => Column(
            children: [
              ...widget.settingsStore.nodes.map(
                (e) => OptionRow(
                  name: e.name,
                  type: OptionRowType.navigate,
                  leading: Image.asset(
                    getChainAssetImagePath(e.chainId),
                    width: 40,
                  ),
                  canEdit: true,
                  onTap: (_) => Navigator.of(context).pushNamed(
                      Routes.settingsNodesEdit,
                      arguments: e.chainId),
                ),
              ),
            ],
          ),
        ),
      );
}
