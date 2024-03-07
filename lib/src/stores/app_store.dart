import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {

  @observable
  int chainId = 1;

  @observable
  web3dart.Web3Client client = web3dart.Web3Client(
    "https://eth-mainnet.g.alchemy.com/v2/0MudgAjBDrDwM7q55SdR13ggiukHg5xN",
    Client(),
  );

  @observable
  Wallet? wallet;

  // SettingsStore settingsStore;

  @action
  Future<void> changeCurrentWallet(wallet) async {}
}
