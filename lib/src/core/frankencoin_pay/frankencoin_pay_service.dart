import 'dart:convert';

import 'package:frankencoin_wallet/src/core/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/frankencoin_pay_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:http/http.dart' as http;

class FrankencoinPayService extends DFXAuthService {
  static const String defaultProvider = 'lightning.space';

  final AppStore appStore;
  final FrankencoinPayStore frankencoinPayStore;

  FrankencoinPayService(this.appStore, this.frankencoinPayStore);

  @override
  String get baseUrl => currentProvider;

  @override
  final String signMessagePath = '/v1/auth/sign-message';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  String get currentProvider {
    final addressParts =
        frankencoinPayStore.getLightningAddress(walletAddress)?.split("@");
    if (addressParts?.length == 2) return addressParts![1];
    return defaultProvider;
  }

  bool get isSetup =>
      frankencoinPayStore.getLightningAddress(walletAddress) != null;

  Future<void> setupProvider([String provider = defaultProvider]) async {
    if (!isSetup) {
      final lightningAddress = await _getLightningAddress();
      await frankencoinPayStore.setLightningAddress(
          walletAddress, lightningAddress);
    }
  }

  Future<String> _getLightningAddress() async {
    final response = await getAuthResponse(false);
    return response['lightningAddress'] as String;
  }

  Future<String> getLightningInvoice(String amount) async {
    final uri = Uri.https(baseUrl, signMessagePath, {'amount': '₣$amount'});

    final response =
        await http.get(uri, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['pr'] as String;
    } else {
      throw Exception(
          'Failed to get sign message. Status: ${response.statusCode} ${response.body}');
    }
  }
}
