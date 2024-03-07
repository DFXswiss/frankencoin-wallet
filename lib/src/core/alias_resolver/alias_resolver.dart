abstract class AliasResolver {
  Future<AliasRecord?> lookupAlias(String alias, String ticker,
      [String? tickerFallback]);
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
