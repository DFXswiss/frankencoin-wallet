import 'package:flutter_test/flutter_test.dart';
import 'package:frankencoin_wallet/src/utils/lnurl.dart';

void main() {
  group('FrankencoinPayService', () {
    test('Format 1.000000000000000000', () {
      final res = decodeLnUrl('LNURL1DP68GURN8GHJ7CTSDYHXGENC9EEHW6TNWVHHVVF0D3H82UNVWQHHQMZLX4JNXEFJX52MH43H');
      print(res);
    });
  });
}
