import 'dart:typed_data';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/contracts/RootChainManager.g.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/web3dart.dart';

class ZCHF_maticZCHF_SwapRoute extends SwapRoute {
  final _bridgeAddress =
      EthereumAddress.fromHex("0xA0c68C638235ee32657e8f720a23ceC1bFc77C77");
  late final ERC20 _zchfContract;
  late final RootChainManager _bridge;

  @override
  bool get requireApprove => true;

  ZCHF_maticZCHF_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.zchf),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.maticZCHF),
          SwapRouteProvider.maticBridge,
        );

  @override
  void init(AppStore appStore) {
    _zchfContract = ERC20(
      address: EthereumAddress.fromHex(sendCurrency.address),
      client: appStore.getClient(sendCurrency.chainId),
    );
    _bridge = RootChainManager(
      address: _bridgeAddress,
      client: appStore.getClient(sendCurrency.chainId),
    );
  }

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
          BigInt amount, BigInt expectedReturn, Credentials credentials) =>
      _bridge.depositFor(
        (
          user: credentials.address,
          rootToken: _zchfContract.self.address,
          depositData: encodeBigInt(amount)
        ),
        transaction: getNewTransaction(credentials, _bridgeAddress),
        credentials: credentials,
      );

  @override
  Future<String> approve(BigInt amount, Credentials credentials) =>
      _zchfContract.approve(
        _bridgeAddress,
        amount,
        transaction: getNewTransaction(credentials, _zchfContract.self.address),
        credentials: credentials,
      );

  @override
  Future<bool> isApproved(BigInt amount, Credentials credentials) async {
    final allowance =
        await _zchfContract.allowance(credentials.address, _bridgeAddress);
    return allowance.compareTo(amount) >= 0;
  }
}

Uint8List encodeBigInt(BigInt data) {
  final buffer = LengthTrackingByteSink();
  const UintType().encode(data, buffer);
  return buffer.asBytes();
}
