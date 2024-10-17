import 'package:frankencoin_wallet/src/core/dfx/dfx_swap_service.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/dfx_route.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
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
    CryptoCurrency.polZCHF,
    CryptoCurrency.baseZCHF,
    CryptoCurrency.opZCHF,
    CryptoCurrency.arbZCHF,
    CryptoCurrency.fps,
    CryptoCurrency.wfps,
  ];

  /// Get the correct initialized [SwapRoute] for the selected pair
  SwapRoute getRoute(
      CustomErc20Token spendCurrency, CustomErc20Token receiveCurrency) {
    final result = SwapRoute.allRoutes
        .where((route) =>
            route.sendCurrency.balanceId.toLowerCase() ==
                spendCurrency.balanceId.toLowerCase() &&
            route.receiveCurrency.balanceId.toLowerCase() ==
                receiveCurrency.balanceId.toLowerCase())
        .firstOrNull;

    if (result == null) {
      return DFX_SwapRoute(spendCurrency, receiveCurrency, dfxSwapService)
        ..init(appStore);
    }

    return result;
  }
}
