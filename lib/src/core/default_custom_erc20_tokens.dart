import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';

final defaultCustomErc20Tokens = [
  CustomErc20Token(
    chainId: 1,
    address: '0xB4272071eCAdd69d933AdcD19cA99fe80664fc08',
    symbol: 'XCHF',
    name: 'CryptoFranc',
    decimals: 18,
    iconUrl: 'assets/images/crypto/xchf.png',
    editable: false,
  ),
  CustomErc20Token(
    chainId: 1,
    address: '0x8c1BEd5b9a0928467c9B1341Da1D7BD5e10b6549',
    symbol: 'LsETH',
    name: 'Liquid Staked ETH',
    decimals: 18,
    iconUrl: 'assets/images/crypto/lseth.png',
    editable: false,
  ),
  CustomErc20Token(
    chainId: 1,
    address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
    symbol: 'WBTC',
    name: 'Wrapped BTC',
    decimals: 18,
    iconUrl: 'assets/images/crypto/wbtc.png',
    editable: false,
  ),

];
