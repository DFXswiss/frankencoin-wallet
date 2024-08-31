import 'package:frankencoin_wallet/src/core/default_nodes.dart';
import 'package:frankencoin_wallet/src/entities/language.dart';
import 'package:frankencoin_wallet/src/entities/node.dart';
import 'package:frankencoin_wallet/src/entities/preferences_key.dart';
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
    required bool initialEnableExperimentalFeatures,
    required bool initialEnableAdvancedMode,
  }) {
    language = initialLanguage;
    enableExperimentalFeatures = initialEnableExperimentalFeatures;
    enableAdvancedMode = initialEnableAdvancedMode;
    nodes = _isar.nodes.where().findAllSync();

    reaction(
        (_) => language,
        (Language language) => _sharedPreferences.setString(
            PreferencesKey.currentLanguageCode, language.code));

    reaction(
        (_) => enableExperimentalFeatures,
        (bool enableExperimentalFeatures) => _sharedPreferences.setBool(
            PreferencesKey.enableExperimentalFeatures,
            enableExperimentalFeatures));

    reaction(
        (_) => enableAdvancedMode,
        (bool enableAdvancedMode) => _sharedPreferences.setBool(
            PreferencesKey.enableAdvancedMode, enableAdvancedMode));
  }

  static SettingsStore load(SharedPreferences sharedPreferences, Isar isar) {
    final initialLanguage = Language.fromCode(
        sharedPreferences.getString(PreferencesKey.currentLanguageCode) ??
            "de");

    final initialEnableExperimentalFeatures =
        sharedPreferences.getBool(PreferencesKey.enableExperimentalFeatures) ??
            false;

    final initialEnableAdvancedMode =
        sharedPreferences.getBool(PreferencesKey.enableAdvancedMode) ?? false;

    return SettingsStore(
      sharedPreferences,
      isar,
      initialLanguage: initialLanguage,
      initialEnableExperimentalFeatures: initialEnableExperimentalFeatures,
      initialEnableAdvancedMode: initialEnableAdvancedMode,
    );
  }

  final SharedPreferences _sharedPreferences;
  final Isar _isar;

  @observable
  late Language language;

  @observable
  late List<Node> nodes;

  @observable
  late bool enableExperimentalFeatures;

  @observable
  late bool enableAdvancedMode;

  Node getNode(int chainId) =>
      _isar.nodes.getSync(chainId) ?? defaultNodes[chainId]!;

  @action
  Future<void> updateNode(Node node) async {
    await _isar.writeTxn(() async => _isar.nodes.put(node));
    nodes = await _isar.nodes.where().findAll();
  }
}
