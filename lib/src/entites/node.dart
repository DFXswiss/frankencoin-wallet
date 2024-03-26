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

  Id id = Isar.autoIncrement;

  int chainId;

  String name;

  String httpsUrl;

  String? wssUrl;
}
