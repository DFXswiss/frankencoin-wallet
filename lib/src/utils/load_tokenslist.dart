import 'dart:convert';
import 'dart:developer';

import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:http/http.dart' as http;

const trustedTokenListUrl =
    'https://raw.githubusercontent.com/konstantinullrich/konstantinullrich/trunk/public/frankencoin_assets.json';

Future<List<CustomErc20Token>> loadTrustedTokenList() async {
  try {
    final response = await http.get(Uri.parse(trustedTokenListUrl));
    final tokenList = jsonDecode(response.body) as List;

    final result = <CustomErc20Token>[];
    for (final token in tokenList) {
      result.add(CustomErc20Token(
        chainId: token['chainId'] ?? 1,
        address: token['address'] ?? "",
        symbol: token['symbol'] ?? "",
        name: token['name'] ?? "",
        decimals: token['decimals'] ?? 18,
        iconUrl: token['iconUrl'] ?? "",
        editable: false,
      ));
    }

    return result;
  } catch (e) {
    log(e.toString());
    return [];
  }
}
