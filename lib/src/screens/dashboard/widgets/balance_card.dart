import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/double_extension.dart';
import 'package:web3dart/web3dart.dart';

class BalanceCard extends StatelessWidget {
  final CryptoCurrency cryptoCurrency;
  final BalanceInfo? balanceInfo;
  final String? actionLabel;
  final void Function()? action;

  const BalanceCard({
    super.key,
    required this.balanceInfo,
    required this.cryptoCurrency,
    this.actionLabel,
    this.action,
  });

  String get leadingImagePath => getCryptoAssetImagePath(cryptoCurrency);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cryptoCurrency == CryptoCurrency.fps ? () => Navigator.of(context)
          .pushNamed(Routes.assetDetails, arguments: cryptoCurrency) : null,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(15, 23, 42, 1.0),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
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
                                  color: Colors.white),
                            ),
                            Text(
                              cryptoCurrency.symbol,
                              style: const TextStyle(
                                  fontFamily: 'Lato', color: Colors.white),
                            )
                          ],
                        ))),
                Text(
                  balanceInfo != null
                      ? EtherAmount.inWei(balanceInfo!.getBalance())
                          .getValueInUnit(EtherUnit.ether)
                          .toStringTruncated(4)
                      : "0.0000",
                  style: const TextStyle(
                      fontSize: 16, fontFamily: 'Lato', color: Colors.white),
                )
              ],
            ),
            if (actionLabel != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: FrankencoinColors.frRed,
                    onPressed: action,
                    child: Text(actionLabel!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
