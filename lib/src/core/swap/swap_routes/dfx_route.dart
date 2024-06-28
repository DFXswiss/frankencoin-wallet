import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_swap_service.dart';
import 'package:frankencoin_wallet/src/core/swap/swap_routes/swap_route.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:web3dart/credentials.dart';

class DFX_SwapRoute extends SwapRoute {
  final DFXSwapService dfxSwapService;
  late final ERC20 _sendContract;

  DFX_SwapRoute(
    CustomErc20Token sendCurrency,
      CustomErc20Token receiveCurrency,
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
      EthereumAddress.fromHex(depositAddress),
      amount,
      transaction: getNewTransaction(credentials, _sendContract.self.address),
      credentials: credentials,
    );
  }
}
