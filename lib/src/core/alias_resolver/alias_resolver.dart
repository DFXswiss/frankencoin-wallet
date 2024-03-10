import 'package:frankencoin_wallet/src/core/alias_resolver/openalias_resolver.dart';

abstract class AliasResolver {
  Future<AliasRecord?> lookupAlias(String alias, String ticker,
      [String? tickerFallback]);

  static List<AliasResolver> all = [
    OpenAliasResolver()
  ];

  static Future<AliasRecord?> resolve(String alias, String ticker,
      [String? tickerFallback]) async {
    for (final resolver in all) {
      final result = await resolver.lookupAlias(alias, ticker, tickerFallback);
      if (result != null) return result;
    }
    return null;
  }
}

class AliasRecord {
  final String address;
  final String name;
  final String description;

  AliasRecord({
    required this.address,
    required this.name,
    required this.description,
  });
}
