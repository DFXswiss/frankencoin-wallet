import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';

class EstimatedTxFee extends StatelessWidget {
  const EstimatedTxFee({
    super.key,
    required this.estimatedFee,
    required this.nativeSymbol,
  });

  final double estimatedFee;
  final String nativeSymbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${S.of(context).estimated_fee}:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          Text(
            estimatedFee.toStringAsFixed(6),
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
          Text(
            " $nativeSymbol",
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
