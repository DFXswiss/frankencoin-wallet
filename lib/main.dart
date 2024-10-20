import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/default_custom_erc20_tokens.dart';
import 'package:frankencoin_wallet/src/core/default_nodes.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/balance_info.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/entities/node.dart';
import 'package:frankencoin_wallet/src/screens/router.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/utils/load_tokenslist.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/load_wallet.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final dir = await getApplicationSupportDirectory();
    final isar = await Isar.open([
      AddressBookEntrySchema,
      BalanceInfoSchema,
      CustomErc20TokenSchema,
      NodeSchema,
    ], directory: dir.path, inspector: false);
    final sharedPreferences = await SharedPreferences.getInstance();

    await setup(sharedPreferences, isar);
    setupDependencyInjection(isar: isar, sharedPreferences: sharedPreferences);

    final walletCreated = getIt.get<WalletViewModel>().isCreated;

    if (walletCreated) await loadCurrentWallet();

    runApp(FankencoinApp(walletCreated: walletCreated));
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: true,
        home: Scaffold(
          body: Container(
            margin:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Text(
              'Error:\n${e.toString()}',
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> setup(SharedPreferences sharedPreferences, Isar isar) async {
  final isSetup = sharedPreferences.getBool("isSetup") ?? false;

  await isar.writeTxn(() async {
    for (final node in defaultNodes.values) {
      if (await isar.nodes.get(node.id) == null) {
        await isar.nodes.put(node);
      }
    }

    final tokenList = await loadTrustedTokenList();
    tokenList.addAll(defaultCustomErc20Tokens);

    for (final token in tokenList) {
      if (await isar.customErc20Tokens.get(token.id) == null) {
        await isar.customErc20Tokens.put(token);
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
    AppLinks().uriLinkStream.listen((uri) {
      if (uri.host == 'dfx') {
        getIt
            .get<DFXService>()
            .completeSell(navigatorKey.currentContext!, uri.toString());
      }
    });

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
        navigatorKey: navigatorKey,
        locale: Locale(language.code),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: createRoute,
        initialRoute: walletCreated ? Routes.dashboard : Routes.welcome,
      );
    });
  }
}
// frankencoin-wallet://test
