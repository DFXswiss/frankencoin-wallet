import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';

enum Blockchain {
  ethereum(1,  "Ethereum", "ETH", CryptoCurrency.eth),
  polygon(137, "Polygon", "MATIC", CryptoCurrency.matic),
  base(8453, "Base", "ETH", CryptoCurrency.baseETH),
  optimism(10, "Optimism", "ETH", CryptoCurrency.opETH),
  arbitrum(42161, "Arbitrum One", "ETH", CryptoCurrency.arbETH);

  const Blockchain(this.chainId, this.name, this.nativeSymbol, this.nativeAsset);

  static Blockchain getFromChainId(int chainId) =>
      Blockchain.values.firstWhere((e) => e.chainId == chainId);

  final int chainId;
  final String nativeSymbol;
  final String name;
  final CryptoCurrency nativeAsset;
}
