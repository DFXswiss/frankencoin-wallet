import 'package:frankencoin_wallet/src/entities/blockchain.dart';

enum CryptoCurrency {
  eth(1, "0x0", "ETH", "Ethereum", 18),
  zchf(1, "0xB58E61C3098d85632Df34EecfB899A1Ed80921cB", "ZCHF", "Frankencoin",
      18),
  fps(1, "0x1bA26788dfDe592fec8bcB0Eaff472a42BE341B2", "FPS",
      "Frankencoin Pool Share", 18),
  wfps(1, "0x5052D3Cc819f53116641e89b96Ff4cD1EE80B182", "WFPS",
      "Wrapped Frankencoin Pool Share", 18, fps),
  matic(137, "0x0", "MATIC", "Polygon", 18),
  maticZCHF(137, "0x02567e4b14b25549331fCEe2B56c647A8bAB16FD", "ZCHF",
      "Frankencoin (Polygon)", 18, zchf),
  maticWFPS(137, "0x54Cc50D5CC4914F0c5DA8b0581938dC590d29b3D", "WFPS",
      "Wrapped Frankencoin Pool Share (Polygon)", 18, fps),
  baseETH(8453, "0x0", "ETH", "Base Ethereum", 18, eth),
  baseZCHF(8453, "0x20D1c515e38aE9c345836853E2af98455F919637", "ZCHF",
      "Frankencoin (Base)", 18, zchf),
  opETH(10, "0x0", "ETH", "Optimistic Ethereum", 18, eth),
  opZCHF(10, "0x4F8a84C442F9675610c680990EdDb2CCDDB8aB6f", "ZCHF",
      "Frankencoin (Optimism)", 18, zchf),
  arbETH(42161, "0x0", "ETH", "Arbitrum Ethereum", 18, eth),
  arbZCHF(42161, "0xB33c4255938de7A6ec1200d397B2b2F329397F9B", "ZCHF",
      "Frankencoin (Arbitrum)", 18, zchf);

  const CryptoCurrency(
      this.chainId, this.address, this.symbol, this.name, this.decimals,
      [this.parentCryptoCurrency]);

  static CryptoCurrency? getFromAddress(String address) => CryptoCurrency.values
      .where((e) => e.address.toLowerCase() == address.toLowerCase())
      .firstOrNull;

  static const erc20Tokens = [
    fps,
    wfps,
    maticWFPS,
    zchf,
    maticZCHF,
    opZCHF,
    baseZCHF,
    arbZCHF,
  ];

  static const spendCurrencies = [
    zchf,
    maticZCHF,
    baseZCHF,
    opZCHF,
    arbZCHF,
    fps,
    wfps,
    maticWFPS,
    eth,
    matic,
  ];

  final int chainId;
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final CryptoCurrency? parentCryptoCurrency;

  List<CryptoCurrency> get childCryptoCurrencies => CryptoCurrency.values
      .where((e) => e.parentCryptoCurrency == this)
      .toList();

  Blockchain get blockchain => Blockchain.getFromChainId(chainId);

  String get balanceId => "$chainId:$address";
}
