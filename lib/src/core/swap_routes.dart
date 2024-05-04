import 'package:frankencoin_wallet/src/core/contracts/Equity.g.dart';
import 'package:frankencoin_wallet/src/core/contracts/FPSWrapper.g.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/web3dart.dart';

abstract class SwapRoute {
  final CryptoCurrency sendCurrency;
  final CryptoCurrency receiveCurrency;

  static List<SwapRoute> allRoutes = [
    ZCHF_FPS_SwapRoute(),
    FPS_ZCHF_SwapRoute(),
    FPS_WFPS_SwapRoute(),
    WFPS_FPS_SwapRoute()
  ];

  const SwapRoute(this.sendCurrency, this.receiveCurrency);

  void init(AppStore appStore);

  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials);

  Future<BigInt> estimateReturn(BigInt amount);

  Future<bool> isAvailable(BigInt amount, EthereumAddress address) async =>
      true;
}

class ZCHF_FPS_SwapRoute extends SwapRoute {
  late final Equity _fpsContract;

  ZCHF_FPS_SwapRoute() : super(CryptoCurrency.zchf, CryptoCurrency.fps);

  @override
  void init(AppStore appStore) => _fpsContract = Equity(
        address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
        client: appStore.getClient(CryptoCurrency.fps.chainId),
      );

  @override
  Future<BigInt> estimateReturn(BigInt amount) =>
      _fpsContract.calculateShares((investment: amount));

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _fpsContract.invest((amount: amount, expectedShares: expectedReturn),
          credentials: credentials);
}

class FPS_ZCHF_SwapRoute extends SwapRoute {
  late final Equity _fpsContract;

  FPS_ZCHF_SwapRoute() : super(CryptoCurrency.fps, CryptoCurrency.zchf);

  @override
  void init(AppStore appStore) => _fpsContract = Equity(
        address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
        client: appStore.getClient(CryptoCurrency.fps.chainId),
      );

  @override
  Future<BigInt> estimateReturn(BigInt amount) =>
      _fpsContract.calculateProceeds((shares: amount));

  @override
  Future<bool> isAvailable(BigInt amount, EthereumAddress address) =>
      _fpsContract.canRedeem((owner: address));

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _fpsContract.redeemExpected((
        expectedProceeds: expectedReturn,
        shares: amount,
        target: credentials.address
      ), credentials: credentials);
}

class FPS_WFPS_SwapRoute extends SwapRoute {
  late final FPSWrapper _fpsWrapperContract;

  FPS_WFPS_SwapRoute() : super(CryptoCurrency.fps, CryptoCurrency.wfps);

  @override
  void init(AppStore appStore) => _fpsWrapperContract = FPSWrapper(
        address: EthereumAddress.fromHex(CryptoCurrency.wfps.address),
        client: appStore.getClient(CryptoCurrency.wfps.chainId),
      );

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _fpsWrapperContract.depositFor(
          (account: credentials.address, amount: amount),
          credentials: credentials);
}

class WFPS_FPS_SwapRoute extends SwapRoute {
  late final FPSWrapper _fpsWrapperContract;

  WFPS_FPS_SwapRoute() : super(CryptoCurrency.wfps, CryptoCurrency.fps);

  @override
  void init(AppStore appStore) => _fpsWrapperContract = FPSWrapper(
        address: EthereumAddress.fromHex(CryptoCurrency.wfps.address),
        client: appStore.getClient(CryptoCurrency.wfps.chainId),
      );

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) async {
    // ToDo: (Konsti) increase allowance;
    return _fpsWrapperContract.withdrawTo(
        (account: credentials.address, amount: amount),
        credentials: credentials);
  }
}
