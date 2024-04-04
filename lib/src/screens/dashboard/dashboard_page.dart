import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_section.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage(this.balanceVM, {super.key});

  final BalanceViewModel balanceVM;

  @override
  State<StatefulWidget> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    widget.balanceVM.startSyncBalances();
  }

  @override
  void dispose() {
    super.dispose();
    widget.balanceVM.stopSyncBalances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 23, 42, 1),
      body: WillPopScope(
        // PopScope(
        // canPop: false,
        onWillPop: () async => false,
        child: SafeArea(
          bottom: false,
          child: Container(
            color: const Color.fromRGBO(5, 8, 23, 1),
            width: double.infinity,
            child: Observer(
              builder: (_) => Column(
                children: [
                  BalanceSection(
                    balanceInfo: widget.balanceVM.balances[CryptoCurrency.zchf],
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
                    balanceInfo: widget.balanceVM.balances[CryptoCurrency.fps],
                    cryptoCurrency: CryptoCurrency.fps,
                    actionLabel: S.of(context).invest,
                    action: () => Navigator.of(context).pushNamed(Routes.pool),
                  ),
                  BalanceCard(
                    balanceInfo: widget.balanceVM.balances[CryptoCurrency.eth],
                    cryptoCurrency: CryptoCurrency.eth,
                  ),
                  BalanceCard(
                    balanceInfo: widget.balanceVM.balances[CryptoCurrency.matic],
                    cryptoCurrency: CryptoCurrency.matic,
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
