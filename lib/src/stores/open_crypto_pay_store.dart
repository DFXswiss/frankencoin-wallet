import 'package:frankencoin_wallet/src/entities/preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenCryptoPayStore {
  final SharedPreferences _sharedPreferences;

  OpenCryptoPayStore(this._sharedPreferences);

  Future<void> setLightningAddress(
          String walletAddress, String lightningAddress) =>
      _sharedPreferences.setString(
          PreferencesKey.getOpenCryptoPayAddressKey(walletAddress),
          lightningAddress);

  String? getLightningAddress(String walletAddress) => _sharedPreferences
      .getString(PreferencesKey.getOpenCryptoPayAddressKey(walletAddress));
}
