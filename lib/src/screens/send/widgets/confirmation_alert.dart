import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class ConfirmationAlert extends StatelessWidget {
  final String amount;
  final String estimatedFee;
  final CustomErc20Token spendCurrency;
  final String? receiverAddress;

  final Function onConfirm;
  final Function onDecline;

  const ConfirmationAlert({
    super.key,
    required this.onConfirm,
    required this.onDecline,
    required this.amount,
    required this.estimatedFee,
    required this.spendCurrency,
    this.receiverAddress,
  });

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
              "${S.of(context).confirm_sending}:",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (receiverAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${S.of(context).wallet_address_receiver}:",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                  Text(
                    "${receiverAddress!.substring(0, 7)}...${receiverAddress!.substring(receiverAddress!.length - 10)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${S.of(context).amount}:",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Lato',
                  ),
                ),
                Text(
                  " ${spendCurrency.symbol}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${S.of(context).estimated_fee}:",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
                Text(
                  estimatedFee,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Lato',
                  ),
                ),
                Text(
                  " ${spendCurrency.blockchain.nativeSymbol}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  onDecline.call();
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              CupertinoButton(
                color: FrankencoinColors.frRed,
                onPressed: () {
                  onConfirm.call();
                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).confirm),
              )
            ],
          )
        ],
      ),
    );
  }
}
