import 'dart:convert';

import 'package:frankencoin_wallet/src/core/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:http/http.dart' as http;

class FrankencoinPayService extends DFXAuthService {
  final AppStore appStore;

  static const _baseUrl = 'lightning.space';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  FrankencoinPayService(this.appStore) : super(_baseUrl);

  Future<String> getLightningAddress() async =>
      (await getAuthResponse())['lightningAddress'] as String;

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
