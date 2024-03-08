import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widget/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage(this.balanceViewModel, {super.key});

  final BalanceViewModel balanceViewModel;

  @override
  Widget build(BuildContext context) {
    balanceViewModel.startSyncBalances();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(17, 24, 39, 1.0),
      body: PopScope(
        canPop: false,
        child: SizedBox(
          width: double.infinity,
          child: Observer(
            builder: (_) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.walletRestore),
                      icon: const Icon(CupertinoIcons.money_dollar_circle),
                      color: const Color.fromRGBO(251, 113, 133, 1.0),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.receive),
                      icon: const Icon(Icons.arrow_downward),
                      color: const Color.fromRGBO(251, 113, 133, 1.0),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.pool),
                      icon: const Icon(Icons.bar_chart),
                      color: const Color.fromRGBO(251, 113, 133, 1.0),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.send),
                      icon: const Icon(Icons.arrow_upward),
                      color: const Color.fromRGBO(251, 113, 133, 1.0),
                    ),
                  ],
                ),
                BalanceCard(
                  balanceInfo: balanceViewModel.balances[CryptoCurrency.zchf],
                  cryptoCurrency: CryptoCurrency.zchf,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: BalanceCard(
                    balanceInfo: balanceViewModel.balances[CryptoCurrency.fps],
                    cryptoCurrency: CryptoCurrency.fps,
                  ),
                ),
                BalanceCard(
                  balanceInfo: balanceViewModel.balances[CryptoCurrency.eth],
                  cryptoCurrency: CryptoCurrency.eth,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
