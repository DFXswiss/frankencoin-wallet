import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/contracts/Equity.g.dart';
import 'package:frankencoin_wallet/src/core/contracts/FPSWrapper.g.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_swap_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:web3dart/web3dart.dart';

enum SwapRouteProvider {
  fpsContract,
  wfpsContract,
  dfx;

  String get icon {
    switch (this) {
      case fpsContract:
        return "assets/images/frankencoin_wallet.png";
      case wfpsContract:
        return "assets/images/frankencoin_wallet.png";
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
      case dfx:
        return "DFX Swap";
    }
  }
}

abstract class SwapRoute {
  final CryptoCurrency sendCurrency;
  final CryptoCurrency receiveCurrency;
  final SwapRouteProvider provider;

  static List<SwapRoute> allRoutes = [
    ZCHF_FPS_SwapRoute(),
    FPS_ZCHF_SwapRoute(),
    FPS_WFPS_SwapRoute(),
    WFPS_FPS_SwapRoute()
  ];

  const SwapRoute(this.sendCurrency, this.receiveCurrency, this.provider);

  void init(AppStore appStore);

  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials);

  Future<BigInt> estimateReturn(BigInt amount);

  Future<bool> isAvailable(BigInt amount, EthereumAddress address) async =>
      true;
}

class ZCHF_FPS_SwapRoute extends SwapRoute {
  late final Equity _fpsContract;

  ZCHF_FPS_SwapRoute()
      : super(
          CryptoCurrency.zchf,
          CryptoCurrency.fps,
          SwapRouteProvider.fpsContract,
        );

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

  FPS_ZCHF_SwapRoute()
      : super(
          CryptoCurrency.fps,
          CryptoCurrency.zchf,
          SwapRouteProvider.fpsContract,
        );

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
  late final Equity _fpsContract;

  FPS_WFPS_SwapRoute()
      : super(
          CryptoCurrency.fps,
          CryptoCurrency.wfps,
          SwapRouteProvider.wfpsContract,
        );

  @override
  void init(AppStore appStore) {
    _fpsWrapperContract = FPSWrapper(
      address: EthereumAddress.fromHex(CryptoCurrency.wfps.address),
      client: appStore.getClient(CryptoCurrency.wfps.chainId),
    );
    _fpsContract = Equity(
      address: EthereumAddress.fromHex(CryptoCurrency.wfps.address),
      client: appStore.getClient(CryptoCurrency.wfps.chainId),
    );
  }

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials) async {
    await _fpsContract.approve(
        (spender: _fpsWrapperContract.self.address, value: amount),
        credentials: credentials);
    return _fpsWrapperContract.depositFor(
        (account: credentials.address, amount: amount),
        credentials: credentials);
  }
}

class WFPS_FPS_SwapRoute extends SwapRoute {
  late final FPSWrapper _fpsWrapperContract;

  WFPS_FPS_SwapRoute()
      : super(
          CryptoCurrency.wfps,
          CryptoCurrency.fps,
          SwapRouteProvider.wfpsContract,
        );

  @override
  void init(AppStore appStore) {
    _fpsWrapperContract = FPSWrapper(
      address: EthereumAddress.fromHex(CryptoCurrency.wfps.address),
      client: appStore.getClient(CryptoCurrency.wfps.chainId),
    );
  }

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _fpsWrapperContract.withdrawTo(
          (account: credentials.address, amount: amount),
          credentials: credentials);
}

class DFX_SwapRoute extends SwapRoute {
  final DFXSwapService dfxSwapService;
  late final ERC20 _sendContract;

  DFX_SwapRoute(
    CryptoCurrency sendCurrency,
    CryptoCurrency receiveCurrency,
    this.dfxSwapService,
  ) : super(sendCurrency, receiveCurrency, SwapRouteProvider.dfx);

  @override
  void init(AppStore appStore) => _sendContract = ERC20(
        address: EthereumAddress.fromHex(sendCurrency.address),
        client: appStore.getClient(sendCurrency.chainId),
      );

  @override
  Future<BigInt> estimateReturn(BigInt amount) async {
    final estimatedReturn = await dfxSwapService.getEstimatedReturn(
        sendCurrency, receiveCurrency, amount);
    return parseFixed(estimatedReturn.toString(), receiveCurrency.decimals);
  }

  @override
  Future<bool> isAvailable(BigInt amount, EthereumAddress address) =>
      dfxSwapService.getIsAvailable(sendCurrency, receiveCurrency, amount);

  @override
  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials) async {
    final depositAddress = await dfxSwapService.getDepositAddress(
        sendCurrency, receiveCurrency, amount);
    return _sendContract.transfer(
        EthereumAddress.fromHex(depositAddress), amount,
        credentials: credentials);
  }
}
