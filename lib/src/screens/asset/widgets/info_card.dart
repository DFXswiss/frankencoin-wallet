import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final CryptoCurrency? asset;
  final bool centred;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.asset,
    this.centred = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, top: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: FrankencoinColors.frDark,
      ),
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
      child: Column(
        crossAxisAlignment:
            centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lato',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment:
                centred ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (asset != null)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child:
                      Image.asset(getCryptoAssetImagePath(asset!), width: 28),
                ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Lato',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
