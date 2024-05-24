import 'dart:typed_data';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/contracts/L1StandardBridge.g.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/credentials.dart';

class ZCHF_opZCHF_SwapRoute extends SwapRoute {
  final _bridgeAddress =
  EthereumAddress.fromHex("0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1");
  late final ERC20 _zchfContract;
  late final L1StandardBridge _bridge;

  ZCHF_opZCHF_SwapRoute()
      : super(
    CryptoCurrency.zchf,
    CryptoCurrency.opZCHF,
    SwapRouteProvider.opBridge,
  );

  @override
  void init(AppStore appStore) {
    _zchfContract = ERC20(
      address: EthereumAddress.fromHex(sendCurrency.address),
      client: appStore.getClient(sendCurrency.chainId),
    );
    _bridge = L1StandardBridge(
      address: _bridgeAddress,
      client: appStore.getClient(sendCurrency.chainId),
    );
  }

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials) async {
    await _zchfContract.approve(
      _bridgeAddress,
      amount,
      transaction: getNewTransaction(credentials, _zchfContract.self.address),
      credentials: credentials,
    );
    return _bridge.depositERC20(
      (
      l1Token: EthereumAddress.fromHex(sendCurrency.address),
      l2Token: EthereumAddress.fromHex(receiveCurrency.address),
      amount: amount,
      extraData: Uint8List(0),
      minGasLimit: BigInt.from(200000)
      ),
      transaction: getNewTransaction(credentials, _bridgeAddress),
      credentials: credentials,
    );
  }
}
