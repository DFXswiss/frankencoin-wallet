enum CryptoCurrency {
  eth("0x0", "ETH", "Ethereum", 18),
  zchf("0xB58E61C3098d85632Df34EecfB899A1Ed80921cB", "ZCHF", "Frankencoin", 18),
  xchf("0xB4272071eCAdd69d933AdcD19cA99fe80664fc08", "XCHF", "CryptoFranc", 18),
  fps("0x1bA26788dfDe592fec8bcB0Eaff472a42BE341B2", "FPS",
      "Frankencoin Pool Share", 18),
  usdc("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", "USDC",
      "USD Coin", 6);

  const CryptoCurrency(this.address, this.symbol, this.name, this.decimals);

  static CryptoCurrency getFromAddress(String address) => CryptoCurrency.values
      .firstWhere((e) => e.address.toLowerCase() == address.toLowerCase());

  static const erc20Tokens = [zchf, xchf, fps, usdc];

  final String address;
  final String symbol;
  final String name;
  final int decimals;
}

