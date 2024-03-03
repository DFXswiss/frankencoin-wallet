import 'package:frankencoin_wallet/src/utils/erc20_tokens.dart';

class ERC20TokenInfo {
  final String address;
  final String symbol;
  final String name;
  final int decimals;

  final CryptoCurrency selector;

  ERC20TokenInfo(this.address,{
    required this.selector,
    required this.symbol,
    required this.name,
    required this.decimals,
  });
}
