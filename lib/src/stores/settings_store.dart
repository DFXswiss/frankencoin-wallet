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
    required Node initialNode,
  }) {
    language = initialLanguage;
    node = initialNode;

    reaction(
        (_) => language,
        (Language language) => _sharedPreferences.setString(
            PreferencesKey.currentLanguageCode, language.code));

    reaction(
        (_) => node,
        (Node node) =>
            _sharedPreferences.setInt(PreferencesKey.currentNodeId, node.id));
  }

  static SettingsStore load(SharedPreferences sharedPreferences, Isar isar) {
    final initialLanguage = Language.fromCode(
        sharedPreferences.getString(PreferencesKey.currentLanguageCode) ??
            "de");

    final initialNodeId =
        sharedPreferences.getInt(PreferencesKey.currentNodeId) ?? 0;
    final initialNode = isar.nodes.getSync(initialNodeId) ??
        Node(
          chainId: 1,
          name: 'publicnode.com',
          httpsUrl: 'https://ethereum-rpc.publicnode.com',
          wssUrl: null,
        );

    return SettingsStore(
      sharedPreferences,
      isar,
      initialLanguage: initialLanguage,
      initialNode: initialNode,
    );
  }

  final SharedPreferences _sharedPreferences;
  final Isar _isar;

  @observable
  late Language language;

  @observable
  late Node node;

  @computed
  List<Node> get nodes => _isar.nodes.where().findAllSync();
}
