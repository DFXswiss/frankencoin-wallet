import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:web3dart/web3dart.dart';

class BalanceCard extends StatelessWidget {
  final CryptoCurrency cryptoCurrency;

  final BalanceInfo? balanceInfo;

  const BalanceCard({
    super.key,
    required this.balanceInfo,
    required this.cryptoCurrency,
  });

  String get leadingImagePath {
    switch (cryptoCurrency) {
      case CryptoCurrency.eth:
        return "assets/images/crypto/eth.png";
      case CryptoCurrency.xchf:
        return "assets/images/crypto/xchf.png";
      case CryptoCurrency.zchf:
        return "assets/images/crypto/zchf.png";
      case CryptoCurrency.fps:
        return "assets/images/crypto/fps.png";
      default:
        return "assets/images/frankencoin.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromRGBO(15, 23, 42, 1.0),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(leadingImagePath, width: 40),
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
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                          color: Colors.white
                        ),
                      ),
                      Text(
                        cryptoCurrency.symbol,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.white
                        ),
                      )
                    ],
                  ))),
          Text(
            balanceInfo != null
                ? EtherAmount.inWei(BigInt.parse(balanceInfo!.balance))
                    .getValueInUnit(EtherUnit.ether)
                    .toStringAsFixed(4)
                : "0.0000",
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Lato',
              color: Colors.white
            ),
          )
        ],
      ),
    );
  }
}
