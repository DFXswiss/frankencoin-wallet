class PreferencesKey {
  static const String currentLanguageCode = "currentLanguageCode";
  static const String enableExperimentalFeatures = "enableExperimentalFeatures";
  static const String enableAdvancedMode = "enableAdvancedMode";
  static const String fankencoinPayAddress = "fankencoinPayAddress";

  static String getFrankencoinPayAddressKey(String address) =>
      "$fankencoinPayAddress:$address";
}
