import 'dart:convert';

import 'package:frankencoin_wallet/src/core/dfx/dfx_asset_ids.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/models/dfx_swap_payment_infos_data.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:http/http.dart' as http;

class DFXSwapService extends DFXAuthService {
  DFXSwapService(super.appStore);

  @override
  String get baseUrl => 'api.dfx.swiss';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  Future<double> getEstimatedReturn(CryptoCurrency spendCurrency,
          CryptoCurrency receiveCurrency, BigInt amount) async =>
      (await _sendRequest(spendCurrency, receiveCurrency,
              double.parse(formatFixed(amount, spendCurrency.decimals))))
          .estimatedAmount
          .toDouble();

  Future<String> getDepositAddress(
          CryptoCurrency spendCurrency, CryptoCurrency receiveCurrency) async =>
      (await _sendRequest(spendCurrency, receiveCurrency)).depositAddress;

  Future<DFXSwapPaymentInfosData> _sendRequest(
      CryptoCurrency spendCurrency, CryptoCurrency receiveCurrency,
      [double amount = 10]) async {
    final uri = Uri.https(baseUrl, '/v1/swap/paymentInfos');

    final authToken = await getAuthToken();
    final sourceAssetId = dfxAssetIds[spendCurrency];
    final targetAssetId = dfxAssetIds[receiveCurrency];

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode({
        "sourceAsset": {"id": sourceAssetId},
        "amount": amount,
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
}
