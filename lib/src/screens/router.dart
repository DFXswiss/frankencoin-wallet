import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/screens/create_wallet/create_wallet_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/welcome/welcome_page.dart';

Route<dynamic> createRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.welcome:
      return MaterialPageRoute<void>(builder: (_) => const WelcomePage());

    case Routes.walletCreate:
      final seed = settings.arguments as String;
      return MaterialPageRoute<void>(builder: (_) => CreateWalletPage(seed));

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
