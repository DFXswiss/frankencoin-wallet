import 'package:frankencoin_wallet/src/core/default_nodes.dart';
import 'package:frankencoin_wallet/src/entites/language.dart';
import 'package:frankencoin_wallet/src/entites/node.dart';
import 'package:frankencoin_wallet/src/entites/preferences_key.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  SettingsStoreBase(
    this._sharedPreferences,
    this._isar, {
    required Language initialLanguage,
  }) {
    language = initialLanguage;
    nodes = _isar.nodes.where().findAllSync();

    reaction(
        (_) => language,
        (Language language) => _sharedPreferences.setString(
            PreferencesKey.currentLanguageCode, language.code));
  }

  static SettingsStore load(SharedPreferences sharedPreferences, Isar isar) {
    final initialLanguage = Language.fromCode(
        sharedPreferences.getString(PreferencesKey.currentLanguageCode) ??
            "de");

    return SettingsStore(
      sharedPreferences,
      isar,
      initialLanguage: initialLanguage,
    );
  }

  final SharedPreferences _sharedPreferences;
  final Isar _isar;

  @observable
  late Language language;

  @observable
  late List<Node> nodes;

  Node getNode(int chainId) => _isar.nodes.getSync(chainId) ?? defaultNodes[chainId]!;

  @action
  Future<void> updateNode(Node node) async {
    await _isar.writeTxn(() async => _isar.nodes.put(node));
    nodes = await _isar.nodes.where().findAll();
  }
}
