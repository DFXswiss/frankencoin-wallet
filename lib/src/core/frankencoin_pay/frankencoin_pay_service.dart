import 'dart:convert';
import 'dart:developer';

import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_exception.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/lnurl.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/frankencoin_pay_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:http/http.dart' as http;

class FrankencoinPayService extends DFXAuthService {
  static const String defaultProvider = 'lightning.space';

  static bool isFrankencoinPayQR(String value) =>
      value.toLowerCase().contains("lightning=lnurl") ||
      value.toLowerCase().startsWith("lnurl");

  final FrankencoinPayStore frankencoinPayStore;

  FrankencoinPayService(super.appStore, this.frankencoinPayStore);

  @override
  String get baseUrl => currentProvider;

  @override
  String get signMessagePath => '/v1/auth/sign-message';

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

  String get lightningAddress =>
      frankencoinPayStore.getLightningAddress(walletAddress)!;

  String get lightningAddressEncoded =>
      encodeLNURL(_lightningAddressToUrl(lightningAddress));

  Future<void> setupProvider([String provider = defaultProvider]) async {
    if (!isSetup) {
      final lightningAddress = await _getLightningAddress();
      await frankencoinPayStore.setLightningAddress(
          walletAddress, lightningAddress);
      log('Set up Frankencoin Pay with $provider and got $lightningAddress',
          name: runtimeType.toString());
    }
  }

  Future<String> getLightningInvoice(String amountRaw) async {
    final amount = amountRaw.replaceAll(",", ".");
    final addressParts =
        frankencoinPayStore.getLightningAddress(walletAddress)!.split("@");

    final uri = Uri.https(currentProvider,
        '/.well-known/lnurlp/${addressParts.first}/cb', {'amount': '₣$amount'});

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

  Future<FrankencoinPayRequest> getFrankencoinPayRequest(
          String payload) async =>
      getPaymentUri(payload);

  Future<FrankencoinPayRequest> getPaymentUri(String lnUrl) async {
    if (lnUrl.toLowerCase().startsWith("http")) {
      final uri = Uri.parse(lnUrl);
      final params = uri.queryParameters;
      if (!params.containsKey("lightning")) {
        throw FrankencoinPayNotSupportedException(uri.authority);
      }

      lnUrl = params["lightning"] as String;
    }
    final url = decodeLNURL(lnUrl);

    log("Resolved URL: $url", name: runtimeType.toString());

    final params = await _getFrankencoinPayParams(url);

    return await _getFrankencoinPayRequest(params);
  }

  Future<String> _getLightningAddress() async {
    final response = await getAuthResponse(false);
    return response['lightningAddress'] as String;
  }

  Future<(String, Map<CryptoCurrency, num>)> _getFrankencoinPayParams(
      Uri uri) async {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['callback', 'transferAmounts']) {
        if (!responseBody.keys.contains(key)) {
          throw FrankencoinPayNotSupportedException(uri.authority);
        }
      }

      final transferAmounts = <CryptoCurrency, num>{};
      for (final transferAmountRaw in responseBody['transferAmounts'] as List) {
        final transferAmount = transferAmountRaw as Map;
        final amount = transferAmount['amount'] as num;
        final asset = transferAmount['asset'] as String;
        final method = transferAmount['method'] as String;
        if (asset == 'ZCHF') {
          transferAmounts[_zchfFromBlockchain(method)] = amount;
        }
      }

      return (responseBody['callback'] as String, transferAmounts);
    } else {
      throw FrankencoinPayException(
          'Failed to get FrankencoinPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<FrankencoinPayRequest> _getFrankencoinPayRequest(
      (String, Map<CryptoCurrency, num>) params) async {
    final uri = Uri.parse(params.$1);
    final asset = params.$2.keys.first;
    final amount = params.$2[asset];

    final queryParams = Map.of(uri.queryParameters);
    queryParams['amount'] = amount!.toString();
    queryParams['asset'] = asset.symbol;
    queryParams['method'] = asset.blockchain.name;

    final response =
        await http.get(Uri.https(uri.authority, uri.path, queryParams));
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['expiryDate', 'uri']) {
        if (!responseBody.keys.contains(key)) {
          throw FrankencoinPayNotSupportedException(uri.authority);
        }
      }

      final paymentUri = ERC681URI.fromString(responseBody['uri']);
      final expiry = DateTime.now()
          .difference(DateTime.parse(responseBody['expiryDate']))
          .inSeconds;
      return FrankencoinPayRequest(
          address: paymentUri.address,
          amount: parseFixed(paymentUri.amount, asset.decimals),
          receiverName: uri.pathSegments[uri.pathSegments.length - 1],
          expiry: expiry < 0 ? 0 : expiry,
          blockchains: params.$2.keys.map((e) => e.blockchain).toList());
    } else {
      throw FrankencoinPayException(
          'Failed to create FrankencoinPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  String _lightningAddressToUrl(String lightningAddress) {
    final addressParts =
        frankencoinPayStore.getLightningAddress(walletAddress)!.split("@");
    return 'https://${addressParts[1]}/.well-known/lnurlp/${addressParts[0]}';
  }

  CryptoCurrency _zchfFromBlockchain(String blockchain) {
    switch (blockchain.toUpperCase()) {
      case "ETHEREUM":
        return CryptoCurrency.zchf;
      case "POLYGON":
        return CryptoCurrency.maticZCHF;
      case "ARBITRUM":
        return CryptoCurrency.arbZCHF;
      case "OPTIMISM":
        return CryptoCurrency.opZCHF;
      case "BASE":
        return CryptoCurrency.baseZCHF;
    }
    throw FrankencoinPayException("Unsupported Blockchain");
  }
}
