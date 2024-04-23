enum CryptoCurrency {
  eth(1, "0x0", "ETH", "Ethereum", 18),
  zchf(1, "0xB58E61C3098d85632Df34EecfB899A1Ed80921cB", "ZCHF", "Frankencoin",
      18),
  xchf(1, "0xB4272071eCAdd69d933AdcD19cA99fe80664fc08", "XCHF", "CryptoFranc",
      18),
  fps(1, "0x1bA26788dfDe592fec8bcB0Eaff472a42BE341B2", "FPS",
      "Frankencoin Pool Share", 18),
  lseth(1, "0x8c1BEd5b9a0928467c9B1341Da1D7BD5e10b6549", "LsETH",
      "Liquid Staked ETH", 18),
  wbtc(1, "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599", "WBTC", "Wrapped BTC",
      8),
  matic(137, "0x0", "MATIC", "Polygon", 18),
  maticZCHF(137, "0x02567e4b14b25549331fCEe2B56c647A8bAB16FD", "ZCHF",
      "Frankencoin (Polygon)", 18),
  baseETH(8453, "0x0", "ETH", "Base Ethereum", 18),
  baseZCHF(8453, "0x20D1c515e38aE9c345836853E2af98455F919637", "ZCHF",
      "Frankencoin (Base)", 18),
  opETH(10, "0x0", "ETH", "Optimistic Ethereum", 18),
  opZCHF(10, "0x4F8a84C442F9675610c680990EdDb2CCDDB8aB6f", "ZCHF",
      "Frankencoin (Optimism)", 18),
  arbETH(42161, "0x0", "ETH", "Arbitrum Ethereum", 18),
  arbZCHF(42161, "0xB33c4255938de7A6ec1200d397B2b2F329397F9B", "ZCHF",
      "Frankencoin (Arbitrum)", 18);

  const CryptoCurrency(
      this.chainId, this.address, this.symbol, this.name, this.decimals);

  static CryptoCurrency? getFromAddress(String address) => CryptoCurrency.values
      .where((e) => e.address.toLowerCase() == address.toLowerCase())
      .firstOrNull;

  static const erc20Tokens = [
    fps,
    zchf,
    maticZCHF,
    opZCHF,
    baseZCHF,
    arbZCHF,
    wbtc,
    xchf,
  ];

  static const spendCurrencies = [zchf, maticZCHF, fps, wbtc, eth, matic];

  final int chainId;
  final String address;
  final String symbol;
  final String name;
  final int decimals;
}
