import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/option_row.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/widgets/chain_asset_icon.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';

class ManageCustomTokensPage extends BasePage {
  ManageCustomTokensPage(this.customErc20TokenStore, this.bottomSheetService,
      {super.key});

  final CustomErc20TokenStore customErc20TokenStore;
  final BottomSheetService bottomSheetService;

  @override
  String get title => S.current.edit_assets;

  @override
  Widget body(BuildContext context) =>
      _ManageCustomTokensPageBody(customErc20TokenStore, bottomSheetService);

  @override
  Widget? trailing(BuildContext context) => MergeSemantics(
        child: SizedBox(
          height: 37,
          width: 37,
          child: ButtonTheme(
            minWidth: double.minPositive,
            child: Semantics(
              label: S.of(context).edit_asset,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent),
                ),
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.settingsCustomTokensEdit, arguments: null),
                child: Icon(
                  Icons.add,
                  color: pageIconColor(context),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      );
}

class _ManageCustomTokensPageBody extends StatefulWidget {
  final CustomErc20TokenStore customErc20TokenStore;
  final BottomSheetService bottomSheetService;

  const _ManageCustomTokensPageBody(
      this.customErc20TokenStore, this.bottomSheetService);

  @override
  State<StatefulWidget> createState() => _ManageCustomTokensPageBodyState();
}

class _ManageCustomTokensPageBodyState
    extends State<_ManageCustomTokensPageBody> {
  void _alertNotEditable(CustomErc20Token erc20token) =>
      widget.bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(
          message: S.of(context).unable_to_edit_trusted_asset(erc20token.name),
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Observer(
          builder: (_) => Column(
            children: [
              ...widget.customErc20TokenStore.erc20Tokens.map(
                (e) => OptionRow(
                  name: e.name,
                  type: OptionRowType.edit,
                  leading: CustomTokenIcon(
                    erc20token: e,
                  ),
                  subtitle: e.address,
                  canEdit: e.editable,
                  onTap: e.editable
                      ? (_) => Navigator.of(context)
                          .pushNamed(Routes.settingsCustomTokensEdit, arguments: e)
                      : (_) => _alertNotEditable(e),
                ),
              ),
            ],
          ),
        ),
      );
}
