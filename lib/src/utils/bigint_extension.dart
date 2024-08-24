import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

Uint8List encodeBigInt(BigInt data) {
  final buffer = LengthTrackingByteSink();
  const UintType().encode(data, buffer);
  return buffer.asBytes();
}
