import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';

part 'address_book_entry.g.dart';

@collection
class AddressBookEntry {
  AddressBookEntry({
    this.chainId,
    required this.address,
    required this.name,
  });

  Id get id => fastHash("$address${chainId != null ? "@$chainId" : ""}");

  int? chainId;

  String address;

  String name;
}
