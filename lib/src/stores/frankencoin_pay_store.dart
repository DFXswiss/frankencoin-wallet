import 'package:frankencoin_wallet/src/entities/preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrankencoinPayStore {
  final SharedPreferences _sharedPreferences;

  FrankencoinPayStore(this._sharedPreferences);

  Future<void> setLightningAddress(
          String walletAddress, String lightningAddress) =>
      _sharedPreferences.setString(
          PreferencesKey.getFrankencoinPayAddressKey(walletAddress),
          lightningAddress);

  String? getLightningAddress(String walletAddress) => _sharedPreferences
      .getString(PreferencesKey.getFrankencoinPayAddressKey(walletAddress));
}
