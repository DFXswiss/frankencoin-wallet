import 'package:frankencoin_wallet/src/core/language.dart';
import 'package:frankencoin_wallet/src/entites/preferences_key.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  SettingsStoreBase(
    this.sharedPreferences, {
    required Language initialLanguage,
  }) {
    language = initialLanguage;

    reaction(
        (_) => language,
        (Language language) => sharedPreferences.setString(
            PreferencesKey.currentLanguageCode, language.code));
  }

  static SettingsStore load(SharedPreferences sharedPreferences) {
    final initialLanguage = Language.fromCode(
        sharedPreferences.getString(PreferencesKey.currentLanguageCode) ??
            "de");

    return SettingsStore(sharedPreferences, initialLanguage: initialLanguage);
  }

  final SharedPreferences sharedPreferences;

  @observable
  late Language language;
}
