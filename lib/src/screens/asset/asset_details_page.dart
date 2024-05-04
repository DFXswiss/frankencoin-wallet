import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';

class AssetDetailsPage extends BasePage {
  AssetDetailsPage(this.cryptoCurrency, this.balanceVM, {super.key});

  final CryptoCurrency cryptoCurrency;
  final BalanceViewModel balanceVM;

  @override
  String get title => cryptoCurrency.name;

  @override
  Widget body(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            Text(
              S.of(context).balance_total,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  getCryptoAssetImagePath(cryptoCurrency),
                  width: 35,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    formatFixed(balanceVM.getAggregatedBalance(cryptoCurrency),
                        cryptoCurrency.decimals,
                        fractionalDigits: 6, trimZeros: false),
                    style: const TextStyle(
                      fontSize: 35,
                      fontFamily: 'Lato',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  S.of(context).blockchains,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Lato',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            BalanceCard(
              balanceInfo: balanceVM.balances[cryptoCurrency],
              cryptoCurrency: cryptoCurrency,
              backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
              showBlockchainIcon: true,
              navigateToDetails: false,
            ),
            ...cryptoCurrency.childCryptoCurrencies.map(
              (cryptoCurrency) => BalanceCard(
                balanceInfo: balanceVM.balances[cryptoCurrency],
                cryptoCurrency: cryptoCurrency,
                backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
                showBlockchainIcon: true,
              ),
            ),
          ],
        ),
      );
}
