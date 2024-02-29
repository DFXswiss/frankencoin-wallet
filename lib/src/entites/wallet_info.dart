import 'package:isar/isar.dart';

part 'wallet_info.g.dart';

@collection
class WalletInfo {
  WalletInfo({
    required this.name,
    required this.address,
  });

  Id id = Isar.autoIncrement;

  String name;

  String address;

  // Map<String, String>? addresses;
}
