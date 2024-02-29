import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:mobx/mobx.dart';

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  // AppStoreBase({required this.settingsStore});


  @observable
  Wallet? wallet;

  // SettingsStore settingsStore;

  @action
  Future<void> changeCurrentWallet(wallet) async {

  }
}
