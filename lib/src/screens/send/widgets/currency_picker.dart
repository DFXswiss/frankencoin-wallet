import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class CurrencyPicker extends StatelessWidget {
  final List<CryptoCurrency> availableCurrencies;
  final CryptoCurrency selectedCurrency;
  final Function(CryptoCurrency) onSelect;

  const CurrencyPicker({
    super.key,
    required this.availableCurrencies,
    required this.selectedCurrency,
    required this.onSelect,
  });

  String getCurrencyImagePath(CryptoCurrency cryptoCurrency) =>
      getCryptoAssetImagePath(cryptoCurrency);

  @override
  Widget build(BuildContext context) {
    return AlertBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              S.of(context).select_asset,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          ...availableCurrencies.map((cryptoCurrency) {
            return Column(children: [
              const Divider(),
              InkWell(
                onTap: () {
                  onSelect.call(cryptoCurrency);
                  Navigator.of(context).pop();
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                              ),
                            ),
                            Text(
                              cryptoCurrency.symbol,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (cryptoCurrency == selectedCurrency)
                      const Icon(Icons.check_circle)
                  ],
                ),
              ),
            ]);
          }),
        ],
      ),
    );
  }
}
