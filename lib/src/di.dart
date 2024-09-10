import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_swap_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/stores/address_book_store.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/stores/frankencoin_pay_store.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/frankencoin_pay/send_frankencoin_pay_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/swap_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bottom_sheet_service.dart';

final getIt = GetIt.instance;

void setupDependencyInjection(
    {required Isar isar, required SharedPreferences sharedPreferences}) {
  getIt.registerSingleton(isar);
  getIt.registerSingleton(sharedPreferences);
  getIt.registerSingleton(const FlutterSecureStorage());
  getIt.registerSingleton(SettingsStoreBase.load(sharedPreferences, isar));

  getIt.registerSingleton<BottomSheetService>(BottomSheetServiceImpl());

  getIt.registerSingleton(
      AppStore(getIt.get<SettingsStore>(), getIt.get<BottomSheetService>()));
  getIt.registerSingleton(FrankencoinPayStore(sharedPreferences));
  getIt.registerSingleton(AddressBookStore(getIt.get<Isar>()));
  getIt.registerSingleton(CustomErc20TokenStore(getIt.get<Isar>()));
  getIt.registerSingleton(BalanceStore(getIt.get<AppStore>(),
      getIt.get<CustomErc20TokenStore>(), getIt.get<Isar>()));

  getIt.registerSingleton(DFXService(getIt.get<AppStore>()));
  getIt.registerSingleton(DFXSwapService(getIt.get<AppStore>()));
  getIt.registerSingleton(
      SwapService(getIt.get<AppStore>(), getIt.get<DFXSwapService>()));

  getIt.registerSingleton(WalletConnectService(getIt.get<AppStore>()));
  getIt.registerSingleton(FrankencoinPayService(
      getIt.get<AppStore>(), getIt.get<FrankencoinPayStore>()));

  getIt.registerFactory<BalanceViewModel>(
      () => BalanceViewModel(getIt.get<BalanceStore>()));
  getIt.registerFactory<WalletViewModel>(() =>
      WalletViewModel(getIt.get<AppStore>(), getIt.get<SharedPreferences>()));
  getIt.registerFactory<SendViewModel>(
      () => SendViewModel(getIt.get<BalanceStore>(), getIt.get<AppStore>()));
  getIt.registerFactory<SendAssetViewModel>(() =>
      SendAssetViewModel(getIt.get<BalanceStore>(), getIt.get<AppStore>()));
  getIt.registerFactory<SwapViewModel>(() => SwapViewModel(
        getIt.get<AppStore>(),
        getIt.get<SendViewModel>(),
        getIt.get<SwapService>(),
      ));
  getIt.registerFactory<FPSAssetViewModel>(() =>
      FPSAssetViewModel(getIt.get<AppStore>(), getIt.get<BalanceStore>()));
  getIt.registerFactory<AddressBookViewModel>(
      () => AddressBookViewModel(getIt.get<AddressBookStore>()));

  getIt.registerFactoryParam<
          SendFrankencoinPayViewModel, FrankencoinPayRequest, void>(
      (request, _) => SendFrankencoinPayViewModel(
            getIt.get<AppStore>(),
            getIt.get<FrankencoinPayService>(),
            getIt.get<BalanceStore>(),
            request: request,
          ));
}
