import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/entites/erc20_token_info.dart';
import 'package:frankencoin_wallet/src/utils/erc20_tokens.dart';
import 'package:web3dart/web3dart.dart';

class BalanceCard extends StatelessWidget {
  final CryptoCurrency cryptoCurrency;

  final BalanceInfo? balanceInfo;

  late final ERC20TokenInfo tokenInfo;

  BalanceCard({
    super.key,
    required this.balanceInfo,
    required this.cryptoCurrency,
  }) {
    tokenInfo = getERC20TokenInfoFromCryptoCurrency(cryptoCurrency);
  }

  String get leadingImagePath {
    switch (cryptoCurrency) {
      case CryptoCurrency.eth:
        return "assets/images/crypto/eth.png";
      case CryptoCurrency.xchf:
        return "assets/images/crypto/xchf.png";
      case CryptoCurrency.zchf:
        return "assets/images/crypto/zchf.png";
      default:
        return "assets/images/frankencoin.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
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
                        tokenInfo.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                        ),
                      ),
                      Text(
                        tokenInfo.symbol,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                        ),
                      )
                    ],
                  ))),
          Text(
            balanceInfo != null
                ? EtherAmount.inWei(BigInt.parse(balanceInfo!.balance))
                    .getValueInUnit(EtherUnit.ether)
                    .toString()
                : "0.0",
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Lato',
            ),
          )
        ],
      ),
    );
  }
}
