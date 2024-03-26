import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/create_wallet/create_wallet_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/dashboard_page.dart';
import 'package:frankencoin_wallet/src/screens/pool/pool_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/receive_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_from_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_options_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/send_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/manage_nodes_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/settings_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/show_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/web_view/web_view_page.dart';
import 'package:frankencoin_wallet/src/screens/welcome/welcome_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/equity_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';

Route<dynamic> createRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.welcome:
      return MaterialPageRoute<void>(
          builder: (_) => WelcomePage(getIt.get<WalletViewModel>()));

    case Routes.walletCreate:
      final seed = settings.arguments as String;
      return MaterialPageRoute<void>(builder: (_) => CreateWalletPage(seed));

    case Routes.walletRestoreSeed:
      return MaterialPageRoute<void>(
          builder: (_) => RestoreFromSeedPage(getIt.get<WalletViewModel>()));

    case Routes.walletRestore:
      return MaterialPageRoute<void>(
          builder: (_) => RestoreOptionsPage(getIt.get<WalletViewModel>()));

    case Routes.dashboard:
      return MaterialPageRoute<void>(
          builder: (_) => DashboardPage(getIt.get<BalanceViewModel>()));

    case Routes.receive:
      return MaterialPageRoute<void>(
          builder: (_) =>
              ReceivePage(getIt.get<AppStore>().wallet!.currentAccount));

    case Routes.send:
      return MaterialPageRoute<void>(
          builder: (_) => SendPage(getIt.get<SendViewModel>()));

    case Routes.settings:
      return MaterialPageRoute<void>(
          builder: (_) => SettingsPage(getIt.get<WalletViewModel>(),
              getIt.get<BalanceViewModel>(), getIt.get<SettingsStore>()));

    case Routes.settingsNodes:
      return MaterialPageRoute<void>(
          builder: (_) => ManageNodesPage(getIt.get<AppStore>()));

    case Routes.settingsSeed:
      return MaterialPageRoute<void>(
          builder: (_) => ShowSeedPage(getIt.get<AppStore>()));

    case Routes.pool:
      return MaterialPageRoute<void>(
          builder: (_) => PoolPage(
              getIt.get<BalanceViewModel>(), getIt.get<EquityViewModel>()));

    case Routes.webView:
      final args = settings.arguments as List;
      final title = args.first as String;
      final url = args[1] as Uri;
      return CupertinoPageRoute<void>(builder: (_) => WebViewPage(title, url));

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
