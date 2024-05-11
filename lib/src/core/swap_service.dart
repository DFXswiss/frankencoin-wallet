import 'package:frankencoin_wallet/src/core/dfx/dfx_swap_service.dart';
import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';

class SwapService {
  final AppStore appStore;
  final DFXSwapService dfxSwapService;

  SwapService(this.appStore, this.dfxSwapService) {
    for (final route in SwapRoute.allRoutes) {
      route.init(appStore);
    }
  }

  final List<CryptoCurrency> swappableAssets = [
    CryptoCurrency.zchf,
    CryptoCurrency.maticZCHF,
    CryptoCurrency.baseZCHF,
    CryptoCurrency.opZCHF,
    CryptoCurrency.arbZCHF,
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

    if (result == null) {
      return DFX_SwapRoute(spendCurrency, receiveCurrency, dfxSwapService);
    }

    return result;
  }
}
