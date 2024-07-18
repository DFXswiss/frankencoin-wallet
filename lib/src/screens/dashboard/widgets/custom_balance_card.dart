import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entities/balance_info.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/widgets/chain_asset_icon.dart';

class CustomBalanceCard extends StatelessWidget {
  final CustomErc20Token token;
  final BalanceInfo? balanceInfo;
  final BigInt? balance;
  final String? actionLabel;
  final void Function()? action;
  final void Function()? onTapSend;
  final Color backgroundColor;
  final bool showBlockchainIcon;
  final bool navigateToDetails;

  const CustomBalanceCard({
    super.key,
    required this.token,
    this.balanceInfo,
    this.balance,
    this.actionLabel,
    this.action,
    this.onTapSend,
    this.backgroundColor = FrankencoinColors.frLightDark,
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: InkWell(
                  onTap: onTapSend,
                  enableFeedback: false,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: FrankencoinColors.frRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          S.of(context).send,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        enabled: onTapSend != null,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (token.icon != null)
                        CustomTokenIcon(erc20token: token),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                token.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lato',
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                token.symbol,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Text(
                        formatFixed(
                            balanceInfo?.getBalance() ?? balance ?? BigInt.zero,
                            token.decimals,
                            fractionalDigits: 4,
                            trimZeros: false),
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lato',
                            color: Colors.white),
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
            )),
      ),
    );
  }
}
