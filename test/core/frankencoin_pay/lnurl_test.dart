import 'package:flutter_test/flutter_test.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/lnurl.dart';

void main() {
  group('LNURL', () {
    test('Decode LNURL', () {
      final actual = decodeLNURL(
          'LNURL1DP68GURN8GHJ7CTSDYHXGENC9EEHW6TNWVHHVVF0D3H82UNVWQHHQMZLX4JNXEFJX52MH43H');

      expect(actual.toString(), 'https://api.dfx.swiss/v1/lnurlp/pl_5e3e25');
    });

    test('Encode LNURL', () {
      final actual = encodeLNURL('https://api.dfx.swiss/v1/lnurlp/pl_5e3e25');

      expect(actual,
          'lnurl1dp68gurn8ghj7ctsdyhxgenc9eehw6tnwvhhvvf0d3h82unvwqhhqmzlx4jnxefjx52mh43h');
    });
  });
}
