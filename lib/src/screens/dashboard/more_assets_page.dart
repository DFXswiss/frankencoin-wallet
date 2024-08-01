import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/custom_balance_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';

class MoreAssetsPage extends BasePage {
  final BalanceViewModel balanceVM;
  final CustomErc20TokenStore erc20tokenStore;

  MoreAssetsPage(this.balanceVM, this.erc20tokenStore, {super.key});

  @override
  String get title => S.current.assets;

  @override
  Widget body(BuildContext context) =>
      _MoreAssetsBody(balanceVM, erc20tokenStore);
}

class _MoreAssetsBody extends StatefulWidget {
  const _MoreAssetsBody(this.balanceVM, this.erc20tokenStore);

  final BalanceViewModel balanceVM;
  final CustomErc20TokenStore erc20tokenStore;

  @override
  State<StatefulWidget> createState() => _MoreAssetsBodyState();
}

class _MoreAssetsBodyState extends State<_MoreAssetsBody> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        children: widget.erc20tokenStore.erc20Tokens
            .map(
              (token) => CustomBalanceCard(
                balance:
                    widget.balanceVM.balances[token.balanceId]?.getBalance(),
                token: token,
                backgroundColor: FrankencoinColors.frDark,
                onTapSend: () => Navigator.of(context).pushNamed(Routes.sendAsset, arguments: [token, null, null]),
              ),
            )
            .toList(),
      ),
    );
  }
}
