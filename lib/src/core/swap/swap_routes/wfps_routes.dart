import 'package:frankencoin_wallet/src/core/contracts/Equity.g.dart';
import 'package:frankencoin_wallet/src/core/contracts/FPSWrapper.g.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/credentials.dart';

class FPS_WFPS_SwapRoute extends SwapRoute {
  late final FPSWrapper _fpsWrapperContract;
  late final Equity _fpsContract;

  @override
  bool get requireApprove => true;

  FPS_WFPS_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.fps),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.wfps),
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
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _fpsWrapperContract.depositFor(
        (account: credentials.address, amount: amount),
        transaction:
            getNewTransaction(credentials, _fpsWrapperContract.self.address),
        credentials: credentials,
      );

  @override
  Future<String> approve(BigInt amount, Credentials credentials) =>
      _fpsContract.approve(
        (spender: _fpsWrapperContract.self.address, value: amount),
        transaction: getNewTransaction(credentials, _fpsContract.self.address),
        credentials: credentials,
      );

  @override
  Future<bool> isApproved(BigInt amount, Credentials credentials) async {
    final allowance = await _fpsContract.allowance((
      owner: credentials.address,
      spender: _fpsWrapperContract.self.address
    ));
    return allowance.compareTo(amount) >= 0;
  }
}

class WFPS_FPS_SwapRoute extends SwapRoute {
  late final FPSWrapper _fpsWrapperContract;

  WFPS_FPS_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.wfps),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.fps),
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
        transaction:
            getNewTransaction(credentials, _fpsWrapperContract.self.address),
        credentials: credentials,
      );
}
