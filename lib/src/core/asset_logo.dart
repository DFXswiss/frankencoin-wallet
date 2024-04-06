import 'package:frankencoin_wallet/src/entites/blockchain.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';

String getCryptoAssetImagePath(CryptoCurrency cryptoCurrency) {
  switch (cryptoCurrency) {
    case CryptoCurrency.eth:
      return "assets/images/crypto/eth.png";
    case CryptoCurrency.matic:
      return "assets/images/crypto/matic.png";
    case CryptoCurrency.xchf:
      return "assets/images/crypto/xchf.png";
    case CryptoCurrency.maticZCHF:
    case CryptoCurrency.zchf:
      return "assets/images/crypto/zchf.png";
    case CryptoCurrency.fps:
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
      return "assets/images/crypto/matic.png";
  }
}
