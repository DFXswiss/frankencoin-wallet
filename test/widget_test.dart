

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

main() {
  print(hex.encode(encodeBigInt(BigInt.parse("1000000000000000000"))));
}

Uint8List encodeBigInt(BigInt data) {
  final buffer = LengthTrackingByteSink();
  const UintType().encode(data, buffer);
  return buffer.asBytes();
}
