import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/models.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/open_crypto_pay_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/address_book/add_contact_page.dart';
import 'package:frankencoin_wallet/src/screens/address_book/address_book_page.dart';
import 'package:frankencoin_wallet/src/screens/asset/asset_details_page.dart';
import 'package:frankencoin_wallet/src/screens/asset/fps_asset_details_page.dart';
import 'package:frankencoin_wallet/src/screens/asset/send_asset_page.dart';
import 'package:frankencoin_wallet/src/screens/create_wallet/create_wallet_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/dashboard_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/more_assets_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/open_crypto_pay_receive_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/receive_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_from_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/restore/restore_options_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/savings/savings_page.dart';
import 'package:frankencoin_wallet/src/screens/send/send_open_crypto_pay_page.dart';
import 'package:frankencoin_wallet/src/screens/send/send_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/edit_custom_token_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/edit_node_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/manage_custom_tokens_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/manage_nodes_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/settings_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/show_seed_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/wallet_connect_page.dart';
import 'package:frankencoin_wallet/src/screens/swap/edit_savings_page.dart';
import 'package:frankencoin_wallet/src/screens/swap/swap_page.dart';
import 'package:frankencoin_wallet/src/screens/web_view/web_view_page.dart';
import 'package:frankencoin_wallet/src/screens/welcome/welcome_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/savings_edit_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/savings_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_open_crypto_pay_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/swap_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';

Route<dynamic> createRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.welcome:
      return MaterialPageRoute<void>(
          builder: (_) => WelcomePage(getIt<WalletViewModel>()));

    case Routes.walletCreate:
      final seed = settings.arguments as String;
      return MaterialPageRoute<void>(builder: (_) => CreateWalletPage(seed));

    case Routes.walletRestoreSeed:
      return MaterialPageRoute<void>(
          builder: (_) => RestoreFromSeedPage(getIt<WalletViewModel>()));

    case Routes.walletRestore:
      return MaterialPageRoute<void>(
          builder: (_) => RestoreOptionsPage(getIt<WalletViewModel>()));

    case Routes.dashboard:
      return MaterialPageRoute<void>(
        builder: (_) => DashboardPage(
          getIt<BalanceViewModel>(),
          getIt<AppStore>(),
        ),
      );

    case Routes.assetDetails:
      final cryptoCurrency = settings.arguments as CryptoCurrency;

      if (cryptoCurrency == CryptoCurrency.fps) {
        return MaterialPageRoute<void>(
            builder: (_) => FPSAssetDetailsPage(
                getIt<FPSAssetViewModel>(), getIt<BalanceViewModel>()));
      }

      if (cryptoCurrency == CryptoCurrency.savings) {
        return MaterialPageRoute<void>(
            builder: (_) => SavingsPage(
                getIt<SavingsViewModel>(), getIt<BalanceViewModel>()));
      }

      return MaterialPageRoute<void>(
          builder: (_) => AssetDetailsPage(cryptoCurrency,
              getIt<BalanceViewModel>(), getIt<SettingsStore>()));

    case Routes.moreAssets:
      return MaterialPageRoute<void>(
          builder: (_) => MoreAssetsPage(getIt<BalanceViewModel>(),
              getIt<CustomErc20TokenStore>()));

    case Routes.receive:
      return MaterialPageRoute<void>(
          builder: (_) => ReceivePage(getIt<AppStore>()));

    case Routes.receiveOpenCryptoPay:
      return MaterialPageRoute<void>(
          builder: (_) => OpenCryptoPayReceivePage(
              openCryptoPayService: getIt<OpenCryptoPayService>()));

    case Routes.send:
      final arguments = settings.arguments as List;

      return MaterialPageRoute<void>(
          builder: (_) => SendPage(
                getIt<SendViewModel>(),
                getIt<BottomSheetService>(),
                initialAddress: arguments[0] as String?,
                initialAmount: arguments[1] as String?,
                initialAsset: arguments[2] as CryptoCurrency?,
              ));

    case Routes.sendAsset:
      final arguments = settings.arguments as List;

      return MaterialPageRoute<void>(
          builder: (_) => SendAssetPage(
                getIt<SendAssetViewModel>(),
                getIt<BottomSheetService>(),
                sendCurrency: arguments[0] as CustomErc20Token,
                initialAddress: arguments[1] as String?,
                initialAmount: arguments[2] as String?,
              ));

    case Routes.sendOpenCryptoPay:
      final request = settings.arguments as OpenCryptoPayRequest;

      return MaterialPageRoute<void>(
          builder: (_) => SendOpenCryptoPayPage(
                getIt<SendOpenCryptoPayViewModel>(param1: request),
                getIt<BottomSheetService>(),
                getIt<DFXService>(),
                openCryptoPayRequest: request,
              ));

    // case Routes.send:
    //   final arguments = settings.arguments as List;
    //
    //   return MaterialPageRoute<void>(
    //       builder: (_) => SendZCHFPage(
    //             getIt<SendViewModel>(),
    //             getIt<BottomSheetService>(),
    //             initialAddress: arguments[0] as String?,
    //             initialAmount: arguments[1] as String?,
    //           ));

    case Routes.settings:
      return MaterialPageRoute<void>(
          builder: (_) => SettingsPage(getIt<WalletViewModel>(),
              getIt<BalanceViewModel>(), getIt<SettingsStore>()));

    case Routes.settingsCustomTokens:
      return MaterialPageRoute<void>(
          builder: (_) => ManageCustomTokensPage(
              getIt<CustomErc20TokenStore>(),
              getIt<BottomSheetService>()));

    case Routes.settingsCustomTokensEdit:
      final customErc20Token = settings.arguments as CustomErc20Token?;

      return MaterialPageRoute<void>(
          builder: (_) => EditCustomTokenPage(
                getIt<AppStore>(),
                getIt<CustomErc20TokenStore>(),
                getIt<BottomSheetService>(),
                customToken: customErc20Token,
              ));

    case Routes.settingsNodes:
      return MaterialPageRoute<void>(
          builder: (_) => ManageNodesPage(getIt<AppStore>()));

    case Routes.settingsNodesEdit:
      final chainId = settings.arguments as int;

      return MaterialPageRoute<void>(
          builder: (_) => EditNodePage(
                getIt<AppStore>(),
                chainId: chainId,
              ));

    case Routes.settingsWalletConnect:
      return MaterialPageRoute<void>(
          builder: (_) => WalletConnectPage(getIt<WalletConnectService>()));

    case Routes.settingsSeed:
      return MaterialPageRoute<void>(
          builder: (_) => ShowSeedPage(getIt<AppStore>()));

    case Routes.swap:
      return MaterialPageRoute<void>(
          builder: (_) => SwapPage(getIt<BalanceViewModel>(),
              getIt<SwapViewModel>(), getIt<BottomSheetService>()));

    case Routes.savingsEdit:
      return MaterialPageRoute<void>(
          builder: (_) =>
              EditSavingsPage(
                getIt<SavingsEditViewModel>(), getIt<BottomSheetService>()));

    case Routes.webView:
      final args = settings.arguments as List;
      final title = args.first as String;
      final url = args[1] as Uri;
      return CupertinoPageRoute<String?>(
          builder: (_) => WebViewPage(title, url));

    case Routes.addressBook:
      final isSelector = settings.arguments as bool?;

      return MaterialPageRoute<AddressBookEntry?>(
          builder: (_) => AddressBookPage(getIt<AddressBookViewModel>(),
              isSelector: isSelector ?? false));

    case Routes.addressBookAdd:
      return MaterialPageRoute<void>(
          builder: (_) => AddContactPage(getIt<AddressBookViewModel>()));

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
