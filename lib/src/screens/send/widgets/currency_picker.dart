import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';

class CurrencyPicker extends StatelessWidget {
  final List<CryptoCurrency> availableCurrencies;
  final CryptoCurrency selectedCurrency;
  final Function(CryptoCurrency)? onSelect;
  final Color? textColor;

  const CurrencyPicker({
    super.key,
    required this.availableCurrencies,
    required this.selectedCurrency,
    this.onSelect,
    this.textColor,
  });

  String getCurrencyImagePath(CryptoCurrency cryptoCurrency) =>
      getCryptoAssetImagePath(cryptoCurrency);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            S.of(context).select_asset,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              color: textColor,
            ),
          ),
        ),
        ...availableCurrencies.map((cryptoCurrency) {
          return Column(children: [
            const Divider(),
            InkWell(
              onTap: () {
                onSelect?.call(cryptoCurrency);
                Navigator.of(context).pop(cryptoCurrency);
              },
              child: Row(
                children: [
                  Image.asset(
                    getCurrencyImagePath(cryptoCurrency),
                    width: 40,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cryptoCurrency.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: textColor,
                            ),
                          ),
                          Text(
                            cryptoCurrency.symbol,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: textColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (cryptoCurrency == selectedCurrency)
                    Icon(
                      Icons.check_circle,
                      color: textColor,
                    )
                ],
              ),
            ),
          ]);
        }),
      ],
    );
  }
}
