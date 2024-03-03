import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';

class Wallet {
  final String seed;

  /// The Primary account is the account derived from the account index 0
  late final WalletAccount primaryAccount;
  late final BIP32 _bip32;

  late WalletAccount _currentAccount;

  WalletAccount get currentAccount => _currentAccount;

  Wallet(this.seed) {
    final seedBytes = mnemonicToSeed(seed);
    _bip32 = BIP32.fromSeed(seedBytes);
    primaryAccount = WalletAccount(_bip32, 0);
    _currentAccount = primaryAccount;
  }

  factory Wallet.random() {
    final mnemonic = generateMnemonic();
    return Wallet(mnemonic);
  }

  static Future<Wallet> load() async {
    const secureStorage = FlutterSecureStorage();
    final seed = await secureStorage.read(key: "wallet_seed");
    if (seed == null) throw Exception("Missing Seed");
    return Wallet(seed);
  }

  void selectAccount(int index) =>
      _currentAccount = WalletAccount(_bip32, index);

  Future<void> save() async {
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: "wallet_seed", value: seed);
  }

}
