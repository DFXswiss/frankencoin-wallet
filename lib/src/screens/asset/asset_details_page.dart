import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';

class AssetDetailsPage extends BasePage {
  AssetDetailsPage(this.cryptoCurrency, {super.key});

  final CryptoCurrency cryptoCurrency;

  @override
  String get title => cryptoCurrency.name;

  @override
  Widget body(BuildContext context) => Container();
}
