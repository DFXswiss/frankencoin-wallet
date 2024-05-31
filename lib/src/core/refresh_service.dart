import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';

Future<void> setupRefreshServices() async {
  getIt.get<BalanceStore>().loadBalances();
  await getIt.get<BalanceStore>().startSyncBalances();
}
