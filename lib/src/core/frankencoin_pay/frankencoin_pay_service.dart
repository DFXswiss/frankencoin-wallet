import 'dart:convert';
import 'dart:developer';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_request.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/lnurl.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/frankencoin_pay_store.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:http/http.dart' as http;

class FrankencoinPayService extends DFXAuthService {
  static const String defaultProvider = 'lightning.space';

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
      log('Set up Frankencoin Pay with $provider and got $lightningAddress');
    }
  }

  Future<String> _getLightningAddress() async {
    final response = await getAuthResponse(false);
    return response['lightningAddress'] as String;
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

  FrankencoinPayRequest getLightningInvoiceDetails(String rawInvoice) {
    final res = Bolt11PaymentRequest(rawInvoice);

    // ToDo: Parse less primitive and move to separate class
    // Primitive description parsing
    final description = res.tags
        .firstWhere((element) => element.type == "description")
        .data as String?;

    if (description?.startsWith("Pay this Lightning bill to transfer") == true) {
      final expiry = res.tags
          .firstWhere((element) => element.type == "expiry")
          .data as int;

      final receiverName = RegExp(r'(?<=CHF to )(.*)(?=. Alternatively)')
          .firstMatch(description!)!
          .group(0)!;

      final dataPart = description.split("send ")[1];

      log(dataPart, name: "Fankencoin Pay");

      final address = RegExp(r'(0x)?[0-9a-f]{40}', caseSensitive: false)
          .firstMatch(dataPart)!
          .group(0)!;
      final rawAmount = dataPart.split(" ZCHF")[0];
      final amount = parseFixed(rawAmount, CryptoCurrency.zchf.decimals);

      return FrankencoinPayRequest(
          address: address,
          amount: amount,
          receiverName: receiverName,
          expiry: expiry);
    } else {
      throw Exception('Not a FrankencoinPay invoice');
    }
  }

  String _lightningAddressToUrl(String lightningAddress) {
    final addressParts =
        frankencoinPayStore.getLightningAddress(walletAddress)!.split("@");
    return 'https://${addressParts[1]}/.well-known/lnurlp/${addressParts[0]}';
  }
}
