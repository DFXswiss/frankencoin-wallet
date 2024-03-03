import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/wallet_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void setupDependencyInjection(
    {required Isar isar, required SharedPreferences sharedPreferences}) {
  getIt.registerSingleton(isar);
  getIt.registerSingleton(sharedPreferences);
  getIt.registerSingleton(const FlutterSecureStorage());
  getIt.registerSingleton(AppStore());

  getIt.registerFactory<BalanceViewModel>(
      () => BalanceViewModel(getIt.get<Isar>(), getIt.get<AppStore>()));
  getIt.registerFactory<WalletViewModel>(() =>
      WalletViewModel(getIt.get<AppStore>(), getIt.get<SharedPreferences>()));
}
