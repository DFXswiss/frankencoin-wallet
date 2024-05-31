import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/core/refresh_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/stores/settings_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  AppStoreBase(this.settingsStore, this.bottomSheetService) {
    reaction((_) => wallet, (wallet) async {
      if (wallet != null) {
        final walletConnectService = getIt.get<WalletConnectService>()
          ..onDispose()
          ..create();
        await walletConnectService.init();

        await getIt.get<FrankencoinPayService>().setupProvider();
        await setupRefreshServices();
      }
    });
  }

  final SettingsStore settingsStore;
  final BottomSheetService bottomSheetService;

  @observable
  Wallet? wallet;

  @observable
  String? dfxAuthToken;

  @action
  Future<void> changeCurrentWallet(wallet) async {}

  web3dart.Web3Client getClient(int chainId) {
    final node = settingsStore.getNode(chainId);
    return web3dart.Web3Client(node.httpsUrl, Client());
  }
}
