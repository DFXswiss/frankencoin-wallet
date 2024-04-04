import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  AppStoreBase(this.settingsStore);

  final SettingsStore settingsStore;

  @observable
  Wallet? wallet;

  @action
  Future<void> changeCurrentWallet(wallet) async {}

  web3dart.Web3Client getClient(int chainId) {
    final node = settingsStore.getNode(chainId);
    return web3dart.Web3Client(node.httpsUrl, Client());
  }
}
