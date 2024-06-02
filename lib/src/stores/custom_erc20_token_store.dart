import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';

part 'custom_erc20_token_store.g.dart';

class CustomErc20TokenStore = CustomErc20TokenStoreBase
    with _$CustomErc20TokenStore;

abstract class CustomErc20TokenStoreBase with Store {
  final Isar _isar;

  CustomErc20TokenStoreBase(this._isar) {
    erc20Tokens = _isar.customErc20Tokens.where().findAllSync();
  }

  @observable
  late List<CustomErc20Token> erc20Tokens;

  @action
  Future<void> updateToken(CustomErc20Token token) async {
    await _isar.writeTxn(() async => _isar.customErc20Tokens.put(token));
    erc20Tokens = await _isar.customErc20Tokens.where().findAll();
  }
}
