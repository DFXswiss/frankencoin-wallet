import 'package:frankencoin_wallet/src/core/swap/swap_routes/fps_routes.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/wfps_routes.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/zchf_basezchf_route.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/zchf_polzchf_route.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/zchf_opzchf_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:web3dart/web3dart.dart';

enum SwapRouteProvider {
  fpsContract,
  wfpsContract,
  baseBridge,
  opBridge,
  polBridge,
  dfx;

  String get icon {
    switch (this) {
      case fpsContract:
        return "assets/images/frankencoin_wallet.png";
      case wfpsContract:
        return "assets/images/frankencoin_wallet.png";
      case baseBridge:
        return "assets/images/crypto/base.png";
      case opBridge:
        return "assets/images/crypto/optimism.png";
      case polBridge:
        return "assets/images/crypto/pol.png";
      case dfx:
        return "assets/images/dfx_logo_small.png";
    }
  }

  String get name {
    switch (this) {
      case fpsContract:
        return "FPS Smart Contract";
      case wfpsContract:
        return "WFPS Smart Contract";
      case baseBridge:
        return "Base Bridge";
      case opBridge:
        return "Optimism Bridge";
      case polBridge:
        return "Polygon Bridge";
      case dfx:
        return "DFX Swap";
    }
  }
}

abstract class SwapRoute {
  final CustomErc20Token sendCurrency;
  final CustomErc20Token receiveCurrency;
  final SwapRouteProvider provider;

  bool get requireApprove => false;

  static List<SwapRoute> allRoutes = [
    ZCHF_baseZCHF_SwapRoute(),
    ZCHF_opZCHF_SwapRoute(),
    ZCHF_polZCHF_SwapRoute(),
    ZCHF_FPS_SwapRoute(),
    FPS_ZCHF_SwapRoute(),
    FPS_WFPS_SwapRoute(),
    WFPS_FPS_SwapRoute(),
    WFPS_ZCHF_SwapRoute(),
  ];

  const SwapRoute(this.sendCurrency, this.receiveCurrency, this.provider);

  void init(AppStore appStore);

  Future<String> approve(BigInt amount, Credentials credentials) =>
      throw UnimplementedError();

  Future<bool> isApproved(BigInt amount, Credentials credentials) =>
      throw UnimplementedError();

  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials);

  Future<BigInt> estimateReturn(BigInt amount);

  Future<bool> isAvailable(BigInt amount, EthereumAddress address) async =>
      true;

  Transaction getNewTransaction(Credentials credentials, EthereumAddress to,
      [BigInt? amount,
      TransactionPriority priority = TransactionPriority.medium]) {
    final isErc20Token = CryptoCurrency.erc20Tokens.contains(sendCurrency);

    return Transaction(
      from: credentials.address,
      to: to,
      maxPriorityFeePerGas: sendCurrency.chainId == 1
          ? EtherAmount.fromInt(EtherUnit.gwei, priority.tip)
          : null,
      value: isErc20Token
          ? EtherAmount.zero()
          : EtherAmount.inWei(amount ?? BigInt.zero),
    );
  }
}
