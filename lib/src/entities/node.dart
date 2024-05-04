import 'package:isar/isar.dart';

part 'node.g.dart';

@collection
class Node {
  Node({
    required this.chainId,
    required this.name,
    required this.httpsUrl,
    required this.wssUrl,
  });

  Id get id => chainId;

  int chainId;

  String name;

  String httpsUrl;

  String? wssUrl;
}
