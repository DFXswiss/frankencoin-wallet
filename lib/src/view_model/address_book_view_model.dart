import 'package:frankencoin_wallet/src/entites/address_book_entry.dart';
import 'package:frankencoin_wallet/src/stores/address_book_store.dart';
import 'package:mobx/mobx.dart';

part 'address_book_view_model.g.dart';

class AddressBookViewModel = AddressBookViewModelBase
    with _$AddressBookViewModel;

abstract class AddressBookViewModelBase with Store {
  final AddressBookStore _addressBookStore;

  AddressBookViewModelBase(this._addressBookStore);

  @observable
  bool isLoading = false;

  @computed
  ObservableList<AddressBookEntry> get entries => _addressBookStore.entries;

  @action
  Future<void> loadEntries() async {
    if (isLoading) return; // To avoid parallel double execution

    isLoading = true;
    await _addressBookStore.loadEntries();
    isLoading = false;
  }

  @action
  Future<void> saveEntry(AddressBookEntry entry) async =>
      _addressBookStore.saveEntry(entry);

  @action
  Future<void> deleteEntry(AddressBookEntry entry) async =>
      _addressBookStore.deleteEntry(entry);
}
