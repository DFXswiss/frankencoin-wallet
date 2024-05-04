import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';

class SwapService {
  final AppStore appStore;

  SwapService(this.appStore) {
    for (final route in SwapRoute.allRoutes) {
      route.init(appStore);
    }
  }

  final List<CryptoCurrency> swappableAssets = [
    CryptoCurrency.zchf,
    CryptoCurrency.fps,
    CryptoCurrency.wfps,
  ];

  /// Get the correct initialized [SwapRoute] for the selected pair
  SwapRoute getRoute(
      CryptoCurrency spendCurrency, CryptoCurrency receiveCurrency) {
    final result = SwapRoute.allRoutes
        .where((route) =>
            route.sendCurrency == spendCurrency &&
            route.receiveCurrency == receiveCurrency)
        .firstOrNull;
    if (result == null) throw Exception("No Route found");

    return result;
  }
}
