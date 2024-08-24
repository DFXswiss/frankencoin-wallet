import 'package:erc20/erc20.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:frankencoin_wallet/src/core/contracts/L1GatewayRouter.g.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:web3dart/credentials.dart';

class ZCHF_arbZCHF_SwapRoute extends SwapRoute {
  final _bridgeAddress =
      EthereumAddress.fromHex("0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef");
  late final ERC20 _zchfContract;
  late final L1GatewayRouter _bridge;

  @override
  bool get requireApprove => true;

  ZCHF_arbZCHF_SwapRoute()
      : super(
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.zchf),
          CustomErc20Token.fromCryptoCurrency(CryptoCurrency.arbZCHF),
          SwapRouteProvider.opBridge,
        );

  @override
  void init(AppStore appStore) {
    _zchfContract = ERC20(
      address: EthereumAddress.fromHex(sendCurrency.address),
      client: appStore.getClient(sendCurrency.chainId),
    );
    _bridge = L1GatewayRouter(
      address: _bridgeAddress,
      client: appStore.getClient(sendCurrency.chainId),
    );
  }

  @override
  Future<BigInt> estimateReturn(BigInt amount) async => amount;

  @override
  Future<String> routeAction(
      BigInt amount, BigInt expectedReturn, Credentials credentials) {
    final maxSubmissionCost = BigInt.one; //ToDo

    return _bridge.outboundTransfer(
      (
        token: EthereumAddress.fromHex(sendCurrency.address),
        to: credentials.address,
        amount: amount,
        maxGas: BigInt.from(200000), //ToDo
        gasPriceBid: BigInt.from(60000000),
        data: AbiUtil.rawEncode([
          'uint256',
          'bytes'
        ], [
          // maxSubmissionCost
          maxSubmissionCost,
          // callHookData
          '0x',
        ]),
      ),
      transaction: getNewTransaction(credentials, _bridgeAddress),
      credentials: credentials,
    );
  }

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
