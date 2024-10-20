import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';

String getCryptoAssetImagePath(CryptoCurrency cryptoCurrency) {
  switch (cryptoCurrency) {
    case CryptoCurrency.eth:
    case CryptoCurrency.opETH:
    case CryptoCurrency.arbETH:
      return "assets/images/crypto/eth.png";
    case CryptoCurrency.pol:
      return "assets/images/crypto/pol.png";
    case CryptoCurrency.zchf:
    case CryptoCurrency.polZCHF:
    case CryptoCurrency.baseZCHF:
    case CryptoCurrency.opZCHF:
    case CryptoCurrency.arbZCHF:
      return "assets/images/crypto/zchf.png";
    case CryptoCurrency.fps:
    case CryptoCurrency.wfps:
    case CryptoCurrency.polWFPS:
      return "assets/images/crypto/fps.png";
    default:
      return "assets/images/frankencoin.png";
  }
}

String getChainAssetImagePath(int chainId) {
  switch (Blockchain.getFromChainId(chainId)) {
    case Blockchain.ethereum:
      return "assets/images/crypto/eth.png";
    case Blockchain.polygon:
      return "assets/images/crypto/pol.png";
    case Blockchain.base:
      return "assets/images/crypto/base.png";
    case Blockchain.optimism:
      return "assets/images/crypto/optimism.png";
    case Blockchain.arbitrum:
      return "assets/images/crypto/arbitrum.png";
  }
}
