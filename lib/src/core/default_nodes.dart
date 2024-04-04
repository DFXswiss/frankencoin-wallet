import 'package:frankencoin_wallet/src/entites/node.dart';

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
  )
};
