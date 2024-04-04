import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';

enum Blockchain {
  ethereum(1,  "Ethereum", "ETH", CryptoCurrency.eth),
  polygon(137, "Polygon", "MATIC", CryptoCurrency.matic);

  const Blockchain(this.chainId, this.name, this.nativeSymbol, this.nativeAsset);

  static Blockchain getFromChainId(int chainId) =>
      Blockchain.values.firstWhere((e) => e.chainId == chainId);

  final int chainId;
  final String nativeSymbol;
  final String name;
  final CryptoCurrency nativeAsset;
}
