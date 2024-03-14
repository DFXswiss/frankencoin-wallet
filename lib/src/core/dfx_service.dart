import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DFXService {
  final AppStore appStore;

  static const _baseUrl = 'api.dfx.swiss';
  static const _authPath = '/v1/auth/signMessage';
  static const _signUpPath = '/v1/auth/signUp';
  static const _signInPath = '/v1/auth/signIn';
  static const walletName = 'FrankencoinWallet';

  DFXService(this.appStore);

  bool _isLoading = false;

  WalletAccount get wallet => appStore.wallet!.currentAccount;

  String get title => 'DFX Connect';

  String get walletAddress => wallet.primaryAddress.address.hex;

  String get assetOut => 'ZCHF'; // 'ETH';

  String get blockchain => 'Ethereum';

  Future<String> getSignMessage() async {
    final uri = Uri.https(_baseUrl, _authPath, {'address': walletAddress});

    var response = await http.get(uri, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['message'] as String;
    } else {
      throw Exception(
          'Failed to get sign message. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> signUp() async {
    final signMessage = await getSignature(await getSignMessage());

    final requestBody = jsonEncode({
      'wallet': walletName,
      'address': walletAddress,
      'signature': signMessage,
    });

    final uri = Uri.https(_baseUrl, _signUpPath);
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody['accessToken'] as String;
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

  Future<String> signIn() async {
    final signMessage = await getSignature(await getSignMessage());

    final requestBody = jsonEncode({
      'address': walletAddress,
      'signature': signMessage,
    });

    final uri = Uri.https(_baseUrl, _signInPath);
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody['accessToken'] as String;
    } else if (response.statusCode == 403) {
      final responseBody = jsonDecode(response.body);
      final message =
          responseBody['message'] ?? 'Service unavailable in your country';
      throw Exception(message);
    } else {
      throw Exception(
          'Failed to sign in. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getSignature(String message) => wallet.signMessage(message);

  Future<void> launchProvider(BuildContext context, bool? isBuyAction) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final assetOut = this.assetOut;
      final blockchain = this.blockchain;
      final actionType = isBuyAction == true ? '/buy' : '/sell';

      String accessToken;

      try {
        accessToken = await signIn();
      } on Exception catch (e) {
        if (e.toString().contains('409')) {
          accessToken = await signUp();
        } else {
          rethrow;
        }
      }

      final uri = Uri.https('services.dfx.swiss', actionType, {
        'session': accessToken,
        'lang': 'en',
        'asset-out': assetOut,
        'blockchain': blockchain,
        'asset-in': 'EUR',
      });

      _isLoading = false;
      if (await canLaunchUrl(uri)) {
        if (DeviceInfo.instance.isMobile) {
          Navigator.of(context)
              .pushNamed(Routes.webView, arguments: [title, uri]);
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      _isLoading = false;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            errorMessage: '${S.of(context).dfx_unavailable}: $e',
          );
        },
      );
    }
  }
}
