class PreferencesKey {
  static const String currentLanguageCode = "currentLanguageCode";
  static const String fankencoinPayAddress = "fankencoinPayAddress";

  static String getFrankencoinPayAddressKey(String address) =>
      "$fankencoinPayAddress:$address";
}
