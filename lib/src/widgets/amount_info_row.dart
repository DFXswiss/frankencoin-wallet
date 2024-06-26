import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';

class AmountInfoRow extends StatelessWidget {
  const AmountInfoRow({
    super.key,
    required this.title,
    required this.amount,
    required this.currencySymbol,
    this.decimals = 18,
    this.fractionDigits = 6,
  });

  final BigInt amount;
  final int decimals;
  final int fractionDigits;
  final String title;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          Text(
            formatFixed(amount, decimals, fractionalDigits: fractionDigits),
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
          Text(
            " $currencySymbol",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
