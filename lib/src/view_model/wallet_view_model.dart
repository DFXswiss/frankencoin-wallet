import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletViewModel {
  final AppStore appStore;
  final SharedPreferences sharedPreferences;

  WalletViewModel(this.appStore, this.sharedPreferences);

  bool get isCreated => sharedPreferences.getBool("walletCreated") ?? false;

  Future<Wallet> createNewWallet() async {
    final wallet = Wallet.random()..save();

    appStore.wallet = wallet;
    await sharedPreferences.setBool("walletCreated", true);

    return wallet;
  }

  Future<Wallet> restoreWallet(String seed) async {
    final wallet = Wallet(seed)..save();

    appStore.wallet = wallet;
    await sharedPreferences.setBool("walletCreated", true);

    return wallet;
  }

  Future<bool> deleteWallet() async {

    appStore.wallet?.delete();

    appStore.wallet = null;
    await sharedPreferences.setBool("walletCreated", false);

    return true;
  }
}
