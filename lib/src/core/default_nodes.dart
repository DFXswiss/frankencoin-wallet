import 'package:frankencoin_wallet/src/entities/node.dart';

final defaultNodes = {
  1: Node(
    chainId: 1,
    name: 'Ethereum',
    httpsUrl: 'https://ethereum-rpc.publicnode.com',
    wssUrl: null,
  ),
  137: Node (
    chainId: 137,
    name: 'Polygon',
    httpsUrl: 'https://polygon-bor-rpc.publicnode.com',
    wssUrl: null,
  ),
  8453: Node (
    chainId: 8453,
    name: 'Base',
    httpsUrl: 'https://mainnet.base.org',
    wssUrl: null,
  ),
  10: Node (
    chainId: 10,
    name: 'Optimism',
    httpsUrl: 'https://mainnet.optimism.io',
    wssUrl: null,
  ),
  42161: Node (
    chainId: 42161,
    name: 'Arbitrum One',
    httpsUrl: 'https://arb1.arbitrum.io/rpc',
    wssUrl: null,
  )
};
