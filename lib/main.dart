import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/default_nodes.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/entites/node.dart';
import 'package:frankencoin_wallet/src/screens/router.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/load_wallet.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open([BalanceInfoSchema, NodeSchema],
      directory: dir.path, inspector: false);
  final sharedPreferences = await SharedPreferences.getInstance();

  await setup(sharedPreferences, isar);
  setupDependencyInjection(isar: isar, sharedPreferences: sharedPreferences);

  final walletCreated = getIt.get<WalletViewModel>().isCreated;

  if (walletCreated) await loadCurrentWallet();

  runApp(FankencoinApp(walletCreated: walletCreated));
}

Future<void> setup(SharedPreferences sharedPreferences, Isar isar) async {
  final isSetup = sharedPreferences.getBool("isSetup") ?? false;

  await isar.writeTxn(() async {
    for (final node in defaultNodes.values) {
      if (await isar.nodes.get(node.id) == null) {
        await isar.nodes.put(node);
      }
    }
  });

  if (isSetup) return;
  sharedPreferences.setBool("isSetup", true);
}

class FankencoinApp extends StatelessWidget {
  const FankencoinApp({super.key, this.walletCreated = false});

  final bool walletCreated;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return Observer(builder: (_) {
      final language = getIt.get<SettingsStore>().language;

      return MaterialApp(
        title: 'Frankencoin Wallet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: FrankencoinColors.frRed),
          useMaterial3: true,
        ),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale(language.code),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: createRoute,
        initialRoute: walletCreated ? Routes.dashboard : Routes.welcome,
      );
    });
  }
}
