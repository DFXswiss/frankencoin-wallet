import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/action_bar.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_section.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/bottom_sheet_listener.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage(this.balanceVM, {super.key});

  final BalanceViewModel balanceVM;

  @override
  State<StatefulWidget> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final bottomSheetService = getIt.get<BottomSheetService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 23, 42, 1),
      body: PopScope(
        canPop: false,
        child: BottomSheetListener(
          bottomSheetService: bottomSheetService,
          child: SafeArea(
            bottom: false,
            child: Container(
              color: const Color.fromRGBO(5, 8, 23, 1),
              width: double.infinity,
              child: Observer(
                builder: (_) => Column(
                  children: [
                    BalanceSection(
                      balance: widget.balanceVM.zchfBalanceAggregated,
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
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  children: <Widget>[
                                    BalanceCard(
                                      balance: widget
                                          .balanceVM.zchfBalanceAggregated,
                                      cryptoCurrency: CryptoCurrency.zchf,
                                    ),
                                    BalanceCard(
                                      balance: widget.balanceVM
                                          .getAggregatedBalance(
                                              CryptoCurrency.eth),
                                      cryptoCurrency: CryptoCurrency.eth,
                                    ),
                                    BalanceCard(
                                      balanceInfo: widget.balanceVM.balances[
                                          CryptoCurrency.matic.balanceId],
                                      cryptoCurrency: CryptoCurrency.matic,
                                    ),
                                    BalanceCard(
                                      balance:
                                          widget.balanceVM.fpsBalanceAggregated,
                                      cryptoCurrency: CryptoCurrency.fps,
                                    ),
                                    FullwidthButton(
                                      label: S.of(context).more_assets,
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed(Routes.moreAssets),
                                    ),
                                    const SizedBox(
                                      height: 110,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const ActionBar()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
