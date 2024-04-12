import 'package:flutter_test/flutter_test.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';

void main() {
  group('formatFixed', () {
    group('formatFixed with 18 decimals', () {
      test('Format 1.000000000000000000', () {
        final value = formatFixed(BigInt.parse("1000000000000000000"), 18, trimZeros: false);
        expect(value, "1.000000000000000000");
      });

      test('Format 1', () {
        final value = formatFixed(BigInt.parse("1000000000000000000"), 18);
        expect(value, "1");
      });

      test('Parse 0.100000000000000000', () {
        final value = formatFixed(BigInt.parse("100000000000000000"), 18, trimZeros: false);
        expect(value, "0.100000000000000000");
      });

      test('Parse 0.1', () {
        final value = formatFixed(BigInt.parse("100000000000000000"), 18);
        expect(value, "0.1");
      });

      test('Parse 0.1 with 1 fractional digest', () {
        final value = formatFixed(BigInt.parse("100000000000000000"), 18, fractionalDigits: 1);
        expect(value, "0.1");
      });

      test('Parse 1.0 with -1 fractional digest', () {
        final value = formatFixed(BigInt.parse("1000000000000000000"), 18, fractionalDigits: -1);
        expect(value, "1");
      });

      test('Parse 0.000000000000000001', () {
        final value = formatFixed(BigInt.one, 18);
        expect(value, "0.000000000000000001");
      });
    });

    group('parseFixed with 8 decimals', () {
      test('Parse 1 ', () {
        final value = formatFixed(BigInt.parse("100000001"), 8, fractionalDigits: 0);
        expect(value, "1");
      });

      test('Parse 1.0', () {
        final value = formatFixed(BigInt.parse("100000000"), 8, trimZeros: false);
        expect(value, "1.00000000");
      });

      test('Parse 0.1', () {
        final value = formatFixed(BigInt.parse("10000000"), 8, fractionalDigits: 1);
        expect(value, "0.1");
      });

      test('Parse 0.00000001', () {
        final value = formatFixed(BigInt.parse("1"), 8);
        expect(value, "0.00000001");
      });
    });
  });
}
