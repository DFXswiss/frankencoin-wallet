import 'package:flutter_test/flutter_test.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';

void main() {
  group('payment_uri', () {
    const receiverAddress = '0xCf99569890771d869BfC28C776D07F59b0636D72';
    const rawAmount = '1100000000000000000';
    const sendCurrency = CryptoCurrency.zchf;

    group('EthereumURI', () {});
    group('ERC681URI', () {
      test('Parse transfer with amount', () {
        final uri = ERC681URI
            .fromString('ethereum:$receiverAddress@1?value=$rawAmount');

        expect(uri.asset, null);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "1.1");
      });

      test('Parse transfer with amount and no chainId', () {
        final uri =
            ERC681URI.fromString('ethereum:$receiverAddress?value=$rawAmount');

        expect(uri.asset, null);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "1.1");
      });

      test('Parse transfer with no amount', () {
        final uri = ERC681URI.fromString('ethereum:$receiverAddress');

        expect(uri.asset, null);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "");
      });

      test('Parse transfer with no amount', () {
        final uri = ERC681URI.fromString(
            'ethereum:${sendCurrency.address}/transfer?address=$receiverAddress');

        expect(uri.asset, sendCurrency);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "");
      });

      test('Parse erc20-transfer with amount', () {
        final uri = ERC681URI.fromString(
            'ethereum:${sendCurrency.address}@1/transfer?address=$receiverAddress&uint256=$rawAmount');

        expect(uri.asset, sendCurrency);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "1.1");
      });

      test('Parse erc20-transfer with amount and no chainId', () {
        final uri = ERC681URI.fromString(
            'ethereum:${sendCurrency.address}/transfer?address=$receiverAddress&uint256=$rawAmount');

        expect(uri.asset, sendCurrency);
        expect(uri.address, receiverAddress);
        expect(uri.chainId, 1);
        expect(uri.amount, "1.1");
      });
    });
  });
}
