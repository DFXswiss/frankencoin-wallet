import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/core/dfx_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/widgets/vertical_icon_button.dart';
import 'package:web3dart/web3dart.dart';

class BalanceSection extends StatelessWidget {
  final CryptoCurrency cryptoCurrency;

  final BalanceInfo? balanceInfo;

  const BalanceSection({
    super.key,
    required this.balanceInfo,
    required this.cryptoCurrency,
  });

  final String leadingImagePath = 'assets/images/crypto/zchf.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      color: const Color.fromRGBO(15, 23, 42, 1),
      child: Column(
        children: [
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
                leadingImagePath,
                width: 35,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    balanceInfo != null
                        ? EtherAmount.inWei(BigInt.parse(balanceInfo!.balance))
                            .getValueInUnit(EtherUnit.ether)
                            .toStringAsFixed(4)
                        : '0.0000',
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Lato',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              VerticalIconButton(
                onPressed: () =>
                    getIt.get<DFXService>().launchProvider(context, true),
                icon: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(251, 113, 133, 1.0),
                ),
                label: S.of(context).buy,
              ),
              const Spacer(),
              VerticalIconButton(
                onPressed: () =>
                    getIt.get<DFXService>().launchProvider(context, false),
                icon: const Icon(
                  Icons.remove,
                  color: Color.fromRGBO(251, 113, 133, 1.0),
                ),
                label: S.of(context).sell,
              ),
              const Spacer(),
              VerticalIconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.receive),
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Color.fromRGBO(251, 113, 133, 1.0),
                ),
                label: S.of(context).receive,
              ),
              const Spacer(),
              VerticalIconButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.send),
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Color.fromRGBO(251, 113, 133, 1.0),
                ),
                label: S.of(context).send,
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
