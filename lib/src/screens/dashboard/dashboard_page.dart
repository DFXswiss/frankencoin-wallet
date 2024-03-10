import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widget/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widget/balance_section.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage(this.balanceViewModel, {super.key});

  final BalanceViewModel balanceViewModel;

  @override
  Widget build(BuildContext context) {
    balanceViewModel.startSyncBalances();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 23, 42, 1),
      body: PopScope(
        canPop: false,
        child: SafeArea(
          bottom: false,
          child: Container(
            color: const Color.fromRGBO(5, 8, 23, 1),
            width: double.infinity,
            child: Observer(
              builder: (_) => Column(
                children: [
                  BalanceSection(
                    balanceInfo: balanceViewModel.balances[CryptoCurrency.zchf],
                    cryptoCurrency: CryptoCurrency.zchf,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 1],
                        colors: [
                          Color.fromRGBO(15, 23, 42, 1),
                          Color.fromRGBO(5, 8, 23, 1),
                        ],
                      ),
                    ),
                    height: 8,
                  ),
                  BalanceCard(
                    balanceInfo: balanceViewModel.balances[CryptoCurrency.fps],
                    cryptoCurrency: CryptoCurrency.fps,
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
      ),
    );
  }
}
