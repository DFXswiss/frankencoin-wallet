
import 'dart:convert';

import 'package:bech32/bech32.dart';

String encodeLNURL(String url) {
  final raw =_convertBits(utf8.encode(url), 8, 5, true);
  final data = Bech32('lnurl', raw);
  return const Bech32Codec().encode(data, 255);
}

List<int> _convertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  final result = <int>[];
  final maxv = (1 << to) - 1;

  for (final v in data) {
    if (v < 0 || (v >> from) != 0) throw Exception();

    acc = (acc << from) | v;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  }

  if (pad) {
    if (bits > 0) result.add((acc << (to - bits)) & maxv);
  } else if (bits >= from) {
    throw InvalidPadding('illegal zero padding');
  } else if (((acc << (to - bits)) & maxv) != 0) {
    throw InvalidPadding('non zero');
  }

  return result;
}
