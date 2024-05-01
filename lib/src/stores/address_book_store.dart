import 'package:frankencoin_wallet/src/entites/address_book_entry.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';

part 'address_book_store.g.dart';

class AddressBookStore = AddressBookStoreBase
    with _$AddressBookStore;

abstract class AddressBookStoreBase with Store {
  final Isar _isar;

  AddressBookStoreBase(this._isar);

  @observable
  ObservableList<AddressBookEntry> entries = ObservableList();

  @action
  Future<void> loadEntries() async {
    entries.clear();
    entries.addAll(await _isar.addressBookEntrys.where().findAll());
  }

  @action
  Future<void> saveEntry(AddressBookEntry entry) async {
    await _isar.writeTxn(() async => await _isar.addressBookEntrys.put(entry));
    entries.add(entry);
  }

  @action
  Future<void> deleteEntry(AddressBookEntry entry) async {
    await _isar.writeTxn(() async => await _isar.addressBookEntrys.delete(entry.id));
    entries.remove(entry);
  }
}
