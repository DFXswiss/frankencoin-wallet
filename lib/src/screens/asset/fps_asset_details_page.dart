import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/asset/widgets/info_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class FPSAssetDetailsPage extends BasePage {
  FPSAssetDetailsPage(this.assetVM, this.balanceVM, {super.key});

  final FPSAssetViewModel assetVM;
  final BalanceViewModelBase balanceVM;

  @override
  String get title => CryptoCurrency.fps.name;

  @override
  Widget body(BuildContext context) =>
      _FPSAssetDetailsPageBody(assetVM, balanceVM);
}

class _FPSAssetDetailsPageBody extends StatefulWidget {
  final FPSAssetViewModel assetVM;
  final BalanceViewModelBase balanceVM;

  const _FPSAssetDetailsPageBody(this.assetVM, this.balanceVM);

  @override
  State<StatefulWidget> createState() => _FPSAssetDetailsPageBodyState();
}

class _FPSAssetDetailsPageBodyState extends State<_FPSAssetDetailsPageBody> {
  @override
  void initState() {
    super.initState();
    widget.assetVM.startSync();
  }

  @override
  void dispose() {
    super.dispose();
    widget.assetVM.stopSync();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,###.00", "de");

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            S.of(context).balance,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Observer(
                  builder: (_) => Text(
                    "${formatFixed(widget.balanceVM.fpsBalanceAggregated, 18)} FPS",
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Lato',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Observer(
              builder: (_) => Text(
                "≈ ${widget.assetVM.fpsBalanceValue.toStringAsFixed(2)} ZCHF",
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Lato',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (widget.assetVM.fpsBalance != BigInt.zero)
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Observer(
                builder: (_) => InfoCard(
                  centred: true,
                  label: S.of(context).holding_duration,
                  value:
                      "${widget.assetVM.holdingPeriod.toString()} ${S.of(context).days}",
                ),
              ),
            ),
          BalanceCard(
            balanceInfo: widget.balanceVM.balances[CryptoCurrency.fps],
            cryptoCurrency: CryptoCurrency.fps,
            backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
            actionLabel: S.of(context).trade,
            action: () => Navigator.of(context).pushNamed(Routes.swap),
            navigateToDetails: false,
          ),
          // ToDo: (Konsti) Make dynamic using childCurrencies
          if (widget.assetVM.wfpsBalance != BigInt.zero)
            BalanceCard(
              balance: widget.assetVM.wfpsBalance,
              cryptoCurrency: CryptoCurrency.wfps,
              backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
            ),
          if (widget.assetVM.maticWFPSBalance != BigInt.zero)
            BalanceCard(
              balance: widget.assetVM.maticWFPSBalance,
              cryptoCurrency: CryptoCurrency.maticWFPS,
              backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
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
                      label: S.of(context).total_supply,
                      asset: CryptoCurrency.fps,
                      value: numberFormat.format(
                          EtherAmount.inWei(widget.assetVM.totalSupply)
                              .getValueInUnit(EtherUnit.ether)),
                    ),
                  ),
                ),
                Expanded(
                  child: Observer(
                    builder: (_) => InfoCard(
                        label: S.of(context).fps_price,
                        asset: CryptoCurrency.zchf,
                        value: numberFormat.format(
                            EtherAmount.inWei(widget.assetVM.sharePrice)
                                .getValueInUnit(EtherUnit.ether))),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Observer(
              builder: (_) => InfoCard(
                label: S.of(context).marketcap,
                asset: CryptoCurrency.zchf,
                value: numberFormat.format(widget.assetVM.marketCap),
              ),
            ),
          )
        ],
      ),
    );
  }
}
