import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/double_extension.dart';
import 'package:web3dart/web3dart.dart';

class BalanceSection extends StatelessWidget {
  final CryptoCurrency cryptoCurrency;
  final BigInt balance;

  const BalanceSection({
    super.key,
    required this.balance,
    required this.cryptoCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      color: const Color.fromRGBO(15, 23, 42, 1),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.settings),
                  icon: const Icon(
                    Icons.settings,
                    color: FrankencoinColors.frRed,
                  ),
                ),
              ),
            ],
          ),
          Text(
            S.of(context).balance,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                getCryptoAssetImagePath(CryptoCurrency.zchf),
                width: 35,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  EtherAmount.inWei(balance)
                      .getValueInUnit(EtherUnit.ether)
                      .toStringTruncated(4),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
