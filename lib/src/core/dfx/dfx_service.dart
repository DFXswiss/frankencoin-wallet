import 'dart:convert';

import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:url_launcher/url_launcher.dart';

class DFXService extends DFXAuthService {
  DFXService(super.appStore);

  bool _isLoading = false;

  String get title => 'DFX.swiss';

  @override
  String get baseUrl => 'api.dfx.swiss';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  String get assetIn => 'CHF';

  String get assetOut => 'ZCHF';

  String get langCode => appStore.settingsStore.language.code;

  static List<String> supportedAssets = [
    'Ethereum/ZCHF',
    'Polygon/ZCHF',
    'Base/ZCHF',
    'Optimism/ZCHF',
    'Arbitrum/ZCHF',
    'Ethereum/ETH',
    'Base/ETH',
    'Optimism/ETH',
    'Arbitrum/ETH',
    'Polygon/MATIC',
    'Ethereum/FPS',
    'Ethereum/WFPS',
    'Polygon/WFPS',
    'Ethereum/WBTC'
  ];

  // List<String> supportedAssets = [
  //   'ZCHF',
  //   'ETH',
  //   'Polygon/MATIC',
  //   'FPS',
  //   'WFPS',
  //   'WBTC'
  // ];
  //
  // List<String> supportedBlockchains = [
  //   'Ethereum',
  //   'Polygon',
  //   'Base',
  //   'Optimism',
  //   'Arbitrum',
  // ];

  String get blockchain => 'Polygon';

  Future<void> launchProvider(BuildContext context, bool isBuyAction,
      {String? paymentMethod, Blockchain? blockchain, String? amount}) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final actionType = isBuyAction ? '/buy' : '/sell';

      final accessToken = await getAuthToken();

      final uri = Uri.https('services.dfx.swiss', actionType, {
        'session': accessToken,
        'lang': langCode,
        'asset-out': isBuyAction ? assetOut : assetIn,
        'blockchain': blockchain?.name ?? this.blockchain,
        'asset-in': isBuyAction ? assetIn : assetOut,
        // 'blockchains': supportedBlockchains.join(','),
        'assets': supportedAssets.join(','),
        if (amount != null) 'amount-out': amount,
        if (paymentMethod != null) 'payment-method': paymentMethod,
        if (DeviceInfo.instance.isMobile) 'headless': 'true',
        'redirect-uri': 'frankencoin-wallet://dfx/callback'
      });

      _isLoading = false;
      if (await canLaunchUrl(uri)) {
        if (DeviceInfo.instance.isMobile) {
          final response = await Navigator.of(context)
              .pushNamed(Routes.webView, arguments: [title, uri]);

          if (!isBuyAction && response != null) {
            _completeSell(context, response as String);
          }
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      _isLoading = false;

      appStore.bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(
            message: '${S.current.dfx_unavailable}: ${e.toString()}'),
      );
    }
  }

  Future<void> _completeSell(
      BuildContext context, String callbackResponse) async {
    final uri = Uri.parse(callbackResponse);
    final params = uri.queryParameters;
    final depositAddress =
        await _getSellDepositAddress(params['routeId'] as String);

    final asset = CryptoCurrency.values
        .where((element) =>
            element.symbol == params['asset'] &&
            element.blockchain.name == params['blockchain'])
        .firstOrNull;

    if(context.mounted) {
      Navigator.of(context).pushNamed(Routes.send,
          arguments: [depositAddress, params['amount'] as String, asset]);
    }
  }

  Future<String> _getSellDepositAddress(String routeId) async {
    final uri = Uri.https(baseUrl, 'v1/sell/$routeId');

    final authToken = await getAuthToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
    );

    return jsonDecode(response.body)['deposit']['address'];
  }
}
