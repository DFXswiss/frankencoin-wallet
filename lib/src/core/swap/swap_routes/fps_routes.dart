import 'package:frankencoin_wallet/src/core/contracts/Equity.g.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/credentials.dart';

class ZCHF_FPS_SwapRoute extends SwapRoute {
  late final Equity _fpsContract;

  ZCHF_FPS_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.zchf),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.fps),
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
      _fpsContract.invest(
        (amount: amount, expectedShares: expectedReturn),
        transaction: getNewTransaction(credentials, _fpsContract.self.address),
        credentials: credentials,
      );
}

class FPS_ZCHF_SwapRoute extends SwapRoute {
  late final Equity _fpsContract;

  FPS_ZCHF_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.fps),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.zchf),
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
      _fpsContract.redeemExpected(
        (
          expectedProceeds: expectedReturn,
          shares: amount,
          target: credentials.address
        ),
        transaction: getNewTransaction(credentials, _fpsContract.self.address),
        credentials: credentials,
      );
}
