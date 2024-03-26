import 'package:frankencoin_wallet/src/entites/node.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  AppStoreBase(this.settingsStore) {
    client = web3dart.Web3Client(settingsStore.node.httpsUrl, Client());

    reaction((_) => settingsStore.node,
        (Node node) => client = web3dart.Web3Client(node.httpsUrl, Client()));
  }

  final SettingsStore settingsStore;

  @observable
  int chainId = 1;

  @observable
  late web3dart.Web3Client client;

  @observable
  Wallet? wallet;

  @action
  Future<void> changeCurrentWallet(wallet) async {}
}
