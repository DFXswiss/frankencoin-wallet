import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/create_wallet/create_wallet_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/dashboard_page.dart';
import 'package:frankencoin_wallet/src/screens/pool/pool_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/receive_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/send_page.dart';
import 'package:frankencoin_wallet/src/screens/welcome/welcome_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
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

    case Routes.walletRestore:
      return MaterialPageRoute<void>(
          builder: (_) => RestorePage(getIt.get<WalletViewModel>()));

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

    case Routes.pool:
      return MaterialPageRoute<void>(
          builder: (_) => PoolPage(getIt.get<BalanceViewModel>(), getIt.get<EquityViewModel>()));

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
