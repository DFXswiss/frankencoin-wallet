import 'package:isar/isar.dart';

import '../utils/fast_hash.dart';

part 'fiat_conversion_rate.g.dart';

@collection
class FiatConversionRate {
  FiatConversionRate({
    required this.cryptoSymbol,
    required this.fitaSymbol,
    required this.balance,
  });

  Id get id => fastHash("$cryptoSymbol:$fitaSymbol");

  String cryptoSymbol;

  String fitaSymbol;

  double balance;
}
