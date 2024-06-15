import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    this.backgroundColor = const Color.fromRGBO(15, 23, 42, 1),
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (token.icon != null) CustomTokenIcon(erc20token: token),
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
