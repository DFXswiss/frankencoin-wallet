import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';

part 'custom_erc20_token.g.dart';

@collection
class CustomErc20Token {
  int chainId;
  String address;
  String symbol;
  String name;
  int decimals;
  String? iconUrl;
  final bool editable;

  CustomErc20Token({
    required this.chainId,
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    this.iconUrl,
    this.editable = true,
  });

  CustomErc20Token.fromCryptoCurrency(CryptoCurrency cryptoCurrency)
      : chainId = cryptoCurrency.chainId,
        address = cryptoCurrency.address,
        symbol = cryptoCurrency.symbol,
        name = cryptoCurrency.name,
        decimals = cryptoCurrency.decimals,
        editable = false;

  Id get id => fastHash("$chainId:$address");

  @ignore
  Blockchain get blockchain => Blockchain.getFromChainId(chainId);

  @ignore
  Image? get icon {
    if (iconUrl == null) {
      return Image.asset("assets/images/shrug.png", width: 40);
    }

    if (iconUrl!.startsWith("assets/images/")) {
      return Image.asset(iconUrl!, width: 40);
    }

    return Image.network(iconUrl!, width: 40);
  }

  @ignore
  String get balanceId => "$chainId:$address";
}
