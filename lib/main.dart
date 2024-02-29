import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/entites/wallet_info.dart';
import 'package:frankencoin_wallet/src/screens/router.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open([BalanceInfoSchema, WalletInfoSchema],
      directory: dir.path, inspector: false);

  setupDependencyInjection(isar);

  runApp(const FankencoinApp());
}

class FankencoinApp extends StatelessWidget {
  const FankencoinApp({super.key, this.walletCreated = false});

  final bool walletCreated;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frankencoin Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale("de"),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: createRoute,
      initialRoute: Routes.welcome,
    );
  }
}
