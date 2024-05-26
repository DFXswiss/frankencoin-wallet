import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_asset_ids.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/models/dfx_swap_payment_infos_data.dart';
import 'package:frankencoin_wallet/src/core/dfx_service.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DFXSwapService extends DFXAuthService {
  DFXSwapService(super.appStore);

  @override
  String get baseUrl => 'api.dfx.swiss';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  String get title => "DFX Swap";

  DFXSwapPaymentInfosData? _storedSwapPaymentInfosData;

  Future<bool> getIsAvailable(CryptoCurrency spendCurrency,
          CryptoCurrency receiveCurrency, BigInt amount) async =>
      _isErrorHandled(
        (await _sendRequest(spendCurrency, receiveCurrency, amount)).error,
      );

  Future<double> getEstimatedReturn(CryptoCurrency spendCurrency,
          CryptoCurrency receiveCurrency, BigInt amount) async =>
      (await _sendRequest(spendCurrency, receiveCurrency, amount))
          .estimatedAmount
          .toDouble();

  Future<String> getDepositAddress(CryptoCurrency spendCurrency,
      CryptoCurrency receiveCurrency, BigInt amount) async {
    final result = await _sendRequest(spendCurrency, receiveCurrency, amount);

    if (result.error != null) {
      throw Exception(
        _getErrorMessage(
          result.error,
          sendSymbol: spendCurrency.symbol,
          minAmount: result.minVolume,
          maxAmount: result.maxVolume,
        ),
      );
    }

    return result.depositAddress;
  }

  Future<DFXSwapPaymentInfosData> _sendRequest(CryptoCurrency spendCurrency,
      CryptoCurrency receiveCurrency, BigInt amount) async {
    final sourceAssetId = dfxAssetIds[spendCurrency];
    final targetAssetId = dfxAssetIds[receiveCurrency];
    final parsedAmount =
        double.parse(formatFixed(amount, spendCurrency.decimals));

    if (_storedSwapPaymentInfosData != null &&
        _storedSwapPaymentInfosData?.sourceAsset.id == sourceAssetId &&
        _storedSwapPaymentInfosData?.targetAsset.id == targetAssetId &&
        _storedSwapPaymentInfosData?.amount == parsedAmount) {
      return _storedSwapPaymentInfosData!;
    }

    final uri = Uri.https(baseUrl, '/v1/swap/paymentInfos');

    final authToken = await getAuthToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode({
        "sourceAsset": {"id": sourceAssetId},
        "amount": parsedAmount,
        "targetAsset": {"id": targetAssetId},
        "exactPrice": true
      }),
    );

    if (response.statusCode == 200) {
      return DFXSwapPaymentInfosData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> launchProvider(
      BuildContext context,
      CryptoCurrency spendCurrency,
      CryptoCurrency receiveCurrency,
      BigInt amount) async {
    try {
      final blockchain = spendCurrency.blockchain.name;

      final accessToken = await getAuthToken();

      final uri = Uri.https('services.dfx.swiss', '/swap', {
        'session': accessToken,
        'lang': "de",
        'asset-out': receiveCurrency.symbol,
        'blockchain': blockchain,
        'asset-in': spendCurrency.symbol,
        'assets': DFXService.supportedAssets.join(','),
      });

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

  bool _isErrorHandled(String? errorKey) => [
        null,
        "AmountTooHigh",
        "AmountTooLow",
        "LimitExceeded"
      ].contains(errorKey);

  String? _getErrorMessage(String? errorKey,
      {num? minAmount, num? maxAmount, String? sendSymbol}) {
    switch (errorKey) {
      case "AmountTooHigh":
        return S.current.dfx_error_amount_too_high(
            (maxAmount ?? 0.0).toString(), sendSymbol ?? "");
      case "AmountTooLow":
        return S.current.dfx_error_amount_too_low(
            (minAmount ?? 0.0).toString(), sendSymbol ?? "");
      case "LimitExceeded":
        return S.current.dfx_error_limit_exceeded;
      default:
        return null;
    }
  }
}
