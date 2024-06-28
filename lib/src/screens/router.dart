import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/address_book/add_contact_page.dart';
import 'package:frankencoin_wallet/src/screens/address_book/address_book_page.dart';
import 'package:frankencoin_wallet/src/screens/asset/asset_details_page.dart';
import 'package:frankencoin_wallet/src/screens/asset/fps_asset_details_page.dart';
import 'package:frankencoin_wallet/src/screens/create_wallet/create_wallet_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/dashboard_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/more_assets_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/frankencoin_pay_receive_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/receive_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_from_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_options_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/send_frankencoin_pay_page.dart';
import 'package:frankencoin_wallet/src/screens/send/send_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/edit_custom_token_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/edit_node_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/manage_custom_tokens_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/manage_nodes_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/settings_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/show_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/wallet_connect_page.dart';
import 'package:frankencoin_wallet/src/screens/swap/swap_page.dart';
import 'package:frankencoin_wallet/src/screens/web_view/web_view_page.dart';
import 'package:frankencoin_wallet/src/screens/welcome/welcome_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/frankencoin_pay/send_frankencoin_pay_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/swap_view_model.dart';
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

    case Routes.assetDetails:
      final cryptoCurrency = settings.arguments as CryptoCurrency;

      if (cryptoCurrency == CryptoCurrency.fps) {
        return MaterialPageRoute<void>(
            builder: (_) => FPSAssetDetailsPage(
                getIt.get<FPSAssetViewModel>(), getIt.get<BalanceViewModel>()));
      }

      return MaterialPageRoute<void>(
          builder: (_) =>
              AssetDetailsPage(cryptoCurrency, getIt.get<BalanceViewModel>()));

    case Routes.moreAssets:
      return MaterialPageRoute<void>(
          builder: (_) => MoreAssetsPage(getIt.get<BalanceViewModel>(),
              getIt.get<CustomErc20TokenStore>()));

    case Routes.receive:
      return MaterialPageRoute<void>(
          builder: (_) => ReceivePage(getIt.get<AppStore>()));

    case Routes.receiveFrankencoinPay:
      return MaterialPageRoute<void>(
          builder: (_) => FrankencoinPayReceivePage(
              frankencoinPayService: getIt.get<FrankencoinPayService>()));

    case Routes.send:
      final arguments = settings.arguments as List;

      return MaterialPageRoute<void>(
          builder: (_) => SendPage(
                getIt.get<SendViewModel>(),
                getIt.get<BottomSheetService>(),
                initialAddress: arguments[0] as String?,
                initialAmount: arguments[1] as String?,
                initialAsset: arguments[2] as CryptoCurrency?,
              ));

    case Routes.sendFrankencoinPay:
      final arguments = settings.arguments as FrankencoinPayRequest;

      return MaterialPageRoute<void>(
          builder: (_) => SendFrankencoinPayPage(
                getIt.get<SendFrankencoinPayViewModel>(),
                getIt.get<BottomSheetService>(),
                getIt.get<DFXService>(),
                frankencoinPayRequest: arguments,
              ));

    // case Routes.send:
    //   final arguments = settings.arguments as List;
    //
    //   return MaterialPageRoute<void>(
    //       builder: (_) => SendZCHFPage(
    //             getIt.get<SendViewModel>(),
    //             getIt.get<BottomSheetService>(),
    //             initialAddress: arguments[0] as String?,
    //             initialAmount: arguments[1] as String?,
    //           ));

    case Routes.settings:
      return MaterialPageRoute<void>(
          builder: (_) => SettingsPage(getIt.get<WalletViewModel>(),
              getIt.get<BalanceViewModel>(), getIt.get<SettingsStore>()));

    case Routes.settingsCustomTokens:
      return MaterialPageRoute<void>(
          builder: (_) => ManageCustomTokensPage(
              getIt.get<CustomErc20TokenStore>(),
              getIt.get<BottomSheetService>()));

    case Routes.settingsCustomTokensEdit:
      final customErc20Token = settings.arguments as CustomErc20Token?;

      return MaterialPageRoute<void>(
          builder: (_) => EditCustomTokenPage(
                getIt.get<AppStore>(),
                getIt.get<CustomErc20TokenStore>(),
                getIt.get<BottomSheetService>(),
                customToken: customErc20Token,
              ));

    case Routes.settingsNodes:
      return MaterialPageRoute<void>(
          builder: (_) => ManageNodesPage(getIt.get<AppStore>()));

    case Routes.settingsNodesEdit:
      final chainId = settings.arguments as int;

      return MaterialPageRoute<void>(
          builder: (_) => EditNodePage(
                getIt.get<AppStore>(),
                chainId: chainId,
              ));

    case Routes.settingsWalletConnect:
      return MaterialPageRoute<void>(
          builder: (_) => WalletConnectPage(getIt.get<WalletConnectService>()));

    case Routes.settingsSeed:
      return MaterialPageRoute<void>(
          builder: (_) => ShowSeedPage(getIt.get<AppStore>()));

    case Routes.swap:
      return MaterialPageRoute<void>(
          builder: (_) => SwapPage(getIt.get<BalanceViewModel>(),
              getIt.get<SwapViewModel>(), getIt.get<BottomSheetService>()));

    case Routes.webView:
      final args = settings.arguments as List;
      final title = args.first as String;
      final url = args[1] as Uri;
      return CupertinoPageRoute<void>(builder: (_) => WebViewPage(title, url));

    case Routes.addressBook:
      final isSelector = settings.arguments as bool?;

      return MaterialPageRoute<AddressBookEntry?>(
          builder: (_) => AddressBookPage(getIt.get<AddressBookViewModel>(),
              isSelector: isSelector ?? false));

    case Routes.addressBookAdd:
      return MaterialPageRoute<void>(
          builder: (_) => AddContactPage(getIt.get<AddressBookViewModel>()));

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
