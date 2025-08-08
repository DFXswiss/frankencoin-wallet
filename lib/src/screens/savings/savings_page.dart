import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/asset/widgets/info_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/savings_view_model.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class SavingsPage extends BasePage {
  SavingsPage(this.savingsVM, this.balanceVM, {super.key});

  final SavingsViewModel savingsVM;
  final BalanceViewModelBase balanceVM;

  @override
  String get title => CryptoCurrency.savings.name;

  @override
  Widget body(BuildContext context) => _SavingsPageBody(savingsVM, balanceVM);
}

class _SavingsPageBody extends StatefulWidget {
  final SavingsViewModel savingsVM;
  final BalanceViewModelBase balanceVM;

  const _SavingsPageBody(this.savingsVM, this.balanceVM);

  @override
  State<StatefulWidget> createState() => _SavingsPageBodyState();
}

class _SavingsPageBodyState extends State<_SavingsPageBody> {
  @override
  void initState() {
    super.initState();
    widget.savingsVM.startSync();
  }

  @override
  void dispose() {
    super.dispose();
    widget.savingsVM.stopSync();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0.00", "de");

    return SingleChildScrollView(
      child: Column(
        children: [
          BalanceCard(
            balanceInfo:
                widget.balanceVM.balances[CryptoCurrency.savings.balanceId],
            cryptoCurrency: CryptoCurrency.savings,
            backgroundColor: FrankencoinColors.frDark,
            action: () => Navigator.of(context).pushNamed(Routes.savingsEdit),
            actionLabel: S.of(context).savings_edit,
          ),
          Observer(
            builder: (_) => Offstage(
              offstage: widget.savingsVM.accruedInterest == BigInt.zero,
              child: InfoCard(
                label: S.of(context).savings_accrued_interest,
                asset: CryptoCurrency.zchf,
                value: numberFormat.format(
                    EtherAmount.inWei(widget.savingsVM.accruedInterest)
                        .getValueInUnit(EtherUnit.ether)),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(10), child: Divider()),
          Text(
            S.of(context).market_stats,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Lato',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: [
                Expanded(
                  child: Observer(
                    builder: (_) => InfoCard(
                      label: S.of(context).savings_interest_rate,
                      value: "${widget.savingsVM.currentInterestRate}%",
                    ),
                  ),
                ),
                Expanded(
                  child: Observer(
                    builder: (_) => InfoCard(
                        label: S.of(context).savings_total_savings,
                        asset: CryptoCurrency.zchf,
                        value: numberFormat.format(
                            EtherAmount.inWei(widget.savingsVM.totalSavings)
                                .getValueInUnit(EtherUnit.ether))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
