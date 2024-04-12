import 'package:flutter_test/flutter_test.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';

void main() {
  group('parseFixed', () {
    group('parseFixed with 18 decimals', () {
      test('Parse 1', () {
        final value = parseFixed("1", 18);
        expect(value, BigInt.parse("1000000000000000000"));
      });

      test('Parse 1.0', () {
        final value = parseFixed("1.0", 18);
        expect(value, BigInt.parse("1000000000000000000"));
      });

      test('Parse 0.1', () {
        final value = parseFixed("0.1", 18);
        expect(value, BigInt.parse("100000000000000000"));
      });

      test('Parse 0.000000000000000001', () {
        final value = parseFixed("0.000000000000000001", 18);
        expect(value, BigInt.parse("1"));
      });

      test('Parse 0.0000000000000000001', () {
        expect(() => parseFixed("0.0000000000000000001", 18),
            throwsA(isA<Exception>()));
      });
    });

    group('parseFixed with 8 decimals', () {
      test('Parse 1', () {
        final value = parseFixed("1", 8);
        expect(value, BigInt.parse("100000000"));
      });

      test('Parse 1.0', () {
        final value = parseFixed("1.0", 8);
        expect(value, BigInt.parse("100000000"));
      });

      test('Parse 0.1', () {
        final value = parseFixed("0.1", 8);
        expect(value, BigInt.parse("10000000"));
      });

      test('Parse 0.000000000000000001', () {
        final value = parseFixed("0.00000001", 8);
        expect(value, BigInt.parse("1"));
      });

      test('Parse 0.0000000000000000001', () {
        expect(() => parseFixed("0.0000000000000000001", 8),
            throwsA(isA<Exception>()));
      });
    });
  });
}
