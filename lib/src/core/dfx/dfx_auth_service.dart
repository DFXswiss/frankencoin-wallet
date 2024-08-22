import 'dart:convert';

import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';

abstract class DFXAuthService {
  static const walletName = 'FrankencoinWallet';

  final String signMessagePath = '/v1/auth/signMessage';
  final String authPath = '/v1/auth';
  final AppStore appStore;

  DFXAuthService(this.appStore);

  String get baseUrl;

  WalletAccount get wallet;

  String get walletAddress;

  Future<String> getSignMessage() async {
    final uri = Uri.https(baseUrl, signMessagePath, {'address': walletAddress});

    final response = await appStore.httpClient
        .get(uri, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['message'] as String;
    } else {
      throw Exception(
          'Failed to get sign message. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getSignature(String message) => wallet.signMessage(message);

  Future<Map<String, dynamic>> getAuthResponse(
      [bool sendWalletName = true]) async {
    final signMessage = await getSignature(await getSignMessage());

    final requestBody = jsonEncode(sendWalletName
        ? {
            'wallet': walletName,
            'address': walletAddress,
            'signature': signMessage,
          }
        : {
            'address': walletAddress,
            'signature': signMessage,
          });

    final uri = Uri.https(baseUrl, authPath);
    final response = await appStore.httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody as Map<String, dynamic>;
    } else if (response.statusCode == 403) {
      final responseBody = jsonDecode(response.body);
      final message =
          responseBody['message'] ?? 'Service unavailable in your country';
      throw Exception(message);
    } else {
      throw Exception(
          'Failed to sign up. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getAuthToken() async {
    if (appStore.dfxAuthToken == null) {
      final response = await getAuthResponse();
      appStore.dfxAuthToken = response['accessToken'] as String;
    }
    return appStore.dfxAuthToken!;
  }
}
