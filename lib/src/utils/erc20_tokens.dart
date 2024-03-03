import 'package:frankencoin_wallet/src/entites/erc20_token_info.dart';

final erc20Tokens = [
  ERC20TokenInfo("0xB58E61C3098d85632Df34EecfB899A1Ed80921cB",
      selector: CryptoCurrency.zchf,
      symbol: "ZCHF",
      name: "Frankencoin",
      decimals: 18),
  ERC20TokenInfo("0xB4272071eCAdd69d933AdcD19cA99fe80664fc08",
      selector: CryptoCurrency.xchf,
      symbol: "XCHF",
      name: "CryptoFranc",
      decimals: 18),
  ERC20TokenInfo("0x1bA26788dfDe592fec8bcB0Eaff472a42BE341B2",
      selector: CryptoCurrency.fps,
      symbol: "FPS",
      name: "Frankencoin Pool Share",
      decimals: 18),
];

enum CryptoCurrency {
  eth,
  zchf,
  xchf,
  fps;

  static CryptoCurrency getFromAddress(String address) =>
      getERC20TokenInfoFromAddress(address).selector;
}

ERC20TokenInfo getERC20TokenInfoFromAddress(String address) => erc20Tokens
    .firstWhere((e) => e.address.toLowerCase() == address.toLowerCase());

ERC20TokenInfo getERC20TokenInfoFromCryptoCurrency(
    CryptoCurrency cryptoCurrency) {
  if (cryptoCurrency != CryptoCurrency.eth) {
    return erc20Tokens.firstWhere((e) => e.selector == cryptoCurrency);
  }
  return ERC20TokenInfo(
    "0x0",
    selector: CryptoCurrency.eth,
    symbol: "ETH",
    name: "Ethereum",
    decimals: 18,
  );
}
