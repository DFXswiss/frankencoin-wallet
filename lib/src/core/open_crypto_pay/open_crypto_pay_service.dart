import 'dart:convert';
import 'dart:developer';

import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/exceptions.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/lnurl.dart';
import 'package:frankencoin_wallet/src/core/open_crypto_pay/models.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/open_crypto_pay_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';

class OpenCryptoPayService extends DFXAuthService {
  static const String defaultProvider = 'lightning.space';

  static bool isOpenCryptoPayQR(String value) =>
      value.toLowerCase().contains("lightning=lnurl") ||
      value.toLowerCase().startsWith("lnurl");

  static const CryptoCurrency defaultAsset = CryptoCurrency.polZCHF;

  final OpenCryptoPayStore _openCryptoPayStore;

  OpenCryptoPayService(super.appStore, this._openCryptoPayStore);

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
        _openCryptoPayStore.getLightningAddress(walletAddress)?.split("@");
    if (addressParts?.length == 2) return addressParts![1];
    return defaultProvider;
  }

  bool get isSetup =>
      _openCryptoPayStore.getLightningAddress(walletAddress) != null;

  String get lightningAddress =>
      _openCryptoPayStore.getLightningAddress(walletAddress)!;

  String get lightningAddressEncoded =>
      encodeLNURL(_lightningAddressToUrl(lightningAddress));

  Future<void> setupProvider([String provider = defaultProvider]) async {
    if (!isSetup) {
      final lightningAddress = await _getLightningAddress();
      await _openCryptoPayStore.setLightningAddress(
          walletAddress, lightningAddress);
      log('Set up Open CryptoPay with $provider and got $lightningAddress',
          name: runtimeType.toString());
    }
  }

  Future<String> getLightningInvoice(String amountRaw) async {
    final amount = amountRaw.replaceAll(",", ".");
    final addressParts =
        _openCryptoPayStore.getLightningAddress(walletAddress)!.split("@");

    final uri = Uri.https(currentProvider,
        '/.well-known/lnurlp/${addressParts.first}/cb', {'amount': '₣$amount'});

    final response = await appStore.httpClient
        .get(uri, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['pr'] as String;
    } else {
      throw Exception(
          'Failed to get sign message. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> commitOpenCryptoPayRequest(String txHex,
      {required String callbackUrl,
      required String blockchain,
      required String quote,
      required String asset}) async {
    final uri = Uri.parse(callbackUrl.replaceAll("/cb/", "/tx/"));

    final queryParams = Map.of(uri.queryParameters);

    queryParams['quote'] = quote;
    queryParams['asset'] = asset;
    queryParams['method'] = blockchain;
    queryParams['hex'] = "0x$txHex";

    final response = await appStore.httpClient
        .get(Uri.https(uri.authority, uri.path, queryParams));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body.keys.contains("txId")) return body["txId"];
      throw OpenCryptoPayException(body.toString());
    }
    throw OpenCryptoPayException(
        "Unexpected status code ${response.statusCode}");
  }

  Future<void> cancelOpenCryptoPayRequest(OpenCryptoPayRequest request) async {
    final uri = Uri.parse(request.callbackUrl.replaceAll("/cb/", "/cancel/"));

    await appStore.httpClient.delete(uri);
  }

  Future<OpenCryptoPayRequest> getOpenCryptoPayInvoice(String lnUrl) async {
    if (lnUrl.toLowerCase().startsWith("http")) {
      final uri = Uri.parse(lnUrl);
      final params = uri.queryParameters;
      if (!params.containsKey("lightning")) {
        throw OpenCryptoPayNotSupportedException(uri.authority);
      }

      lnUrl = params["lightning"] as String;
    }
    final url = decodeLNURL(lnUrl);

    log("Resolved URL: $url", name: runtimeType.toString());

    final params = await _getOpenCryptoPayParams(url);

    return OpenCryptoPayRequest(
        address: "",
        amount: parseFixed(
            params.$2[defaultAsset].toString(), defaultAsset.decimals),
        receiverName: params.$1.displayName ?? "Unknown",
        expiry: params.$1.expiration.difference(DateTime.now()).inSeconds,
        blockchains: params.$2.keys.map((e) => e.blockchain).toList(),
        callbackUrl: params.$1.callbackUrl,
        quote: params.$1.id);
  }

  Future<String> _getLightningAddress() async {
    final response = await getAuthResponse(false);
    return response['lightningAddress'] as String;
  }

  Future<(_OpenCryptoPayQuote, Map<CryptoCurrency, num>)>
      _getOpenCryptoPayParams(Uri uri) async {
    final response = await appStore.httpClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['callback', 'transferAmounts', 'quote']) {
        if (!responseBody.keys.contains(key)) {
          throw OpenCryptoPayNotSupportedException(uri.authority);
        }
      }

      final transferAmounts = <CryptoCurrency, num>{};
      for (final transferAmountRaw in responseBody['transferAmounts'] as List) {
        final transferAmount = transferAmountRaw as Map;
        final method = transferAmount['method'] as String;

        for (final asset in transferAmount['assets'] as List) {
          final assetTicker = asset['asset'] as String;
          final amount = asset['amount'] as num;
          if (assetTicker == 'ZCHF') {
            transferAmounts[_zchfFromBlockchain(method)] = amount;
          }
        }
      }

      final quote = _OpenCryptoPayQuote.fromJson(
          responseBody['callback'] as String,
          responseBody['displayName'] as String?,
          responseBody['quote'] as Map);

      return (quote, transferAmounts);
    } else {
      throw OpenCryptoPayException(
          'Failed to get Open CryptoPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getOpenCryptoPayAddress(
      String quoteId, String callbackUrl, CryptoCurrency asset) async {
    final uri = Uri.parse(callbackUrl);
    final queryParams = Map.of(uri.queryParameters);

    queryParams['quote'] = quoteId;
    queryParams['asset'] = asset.symbol;
    queryParams['method'] = asset.blockchain.name;

    final response = await appStore.httpClient
        .get(Uri.https(uri.authority, uri.path, queryParams));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['expiryDate', 'uri']) {
        if (!responseBody.keys.contains(key)) {
          throw OpenCryptoPayNotSupportedException(uri.authority);
        }
      }

      final paymentUri = ERC681URI.fromString(responseBody['uri']);
      return paymentUri.address;
    } else {
      throw OpenCryptoPayException(
          'Failed to create Open CryptoPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  String _lightningAddressToUrl(String lightningAddress) {
    final addressParts =
        _openCryptoPayStore.getLightningAddress(walletAddress)!.split("@");
    return 'https://${addressParts[1]}/.well-known/lnurlp/${addressParts[0]}';
  }

  CryptoCurrency _zchfFromBlockchain(String blockchain) {
    switch (blockchain.toUpperCase()) {
      case "ETHEREUM":
        return CryptoCurrency.zchf;
      case "POLYGON":
        return CryptoCurrency.polZCHF;
      case "ARBITRUM":
        return CryptoCurrency.arbZCHF;
      case "OPTIMISM":
        return CryptoCurrency.opZCHF;
      case "BASE":
        return CryptoCurrency.baseZCHF;
    }
    throw OpenCryptoPayException("Unsupported Blockchain");
  }
}

class _OpenCryptoPayQuote {
  final String callbackUrl;
  final String? displayName;
  final String id;
  final DateTime expiration;

  _OpenCryptoPayQuote(
      this.callbackUrl, this.displayName, this.id, this.expiration);

  _OpenCryptoPayQuote.fromJson(this.callbackUrl, this.displayName, Map json)
      : id = json['id'] as String,
        expiration = DateTime.parse(json['expiration']);
}
