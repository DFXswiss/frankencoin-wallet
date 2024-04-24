import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet.dart';

Future<void> loadCurrentWallet() async {
  final appStore = getIt.get<AppStore>();
  final wallet = await Wallet.load();

  appStore.wallet = wallet;

  await getIt.get<FrankencoinPayService>().setupProvider();
}
