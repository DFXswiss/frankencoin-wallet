import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/asset/widgets/info_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/dashboard/widgets/balance_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class FPSAssetDetailsPage extends BasePage {
  FPSAssetDetailsPage(this.assetVM, {super.key});

  final FPSAssetViewModel assetVM;

  @override
  String get title => CryptoCurrency.fps.name;

  @override
  Widget body(BuildContext context) => _FPSAssetDetailsPageBody(assetVM);
}

class _FPSAssetDetailsPageBody extends StatefulWidget {
  final FPSAssetViewModel assetVM;

  const _FPSAssetDetailsPageBody(this.assetVM);

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
                    "${formatFixed(widget.assetVM.aggregatedFPSBalance, 18)} FPS",
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
          if (widget.assetVM.fpsBalance != BigInt.zero)
            Padding(
              padding: EdgeInsets.zero,
              child: BalanceCard(
                balanceInfo:
                    widget.assetVM.balanceVM.balances[CryptoCurrency.fps],
                cryptoCurrency: CryptoCurrency.fps,
                backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
              ),
            ),
          if (widget.assetVM.wfpsBalance != BigInt.zero)
            Padding(
              padding: EdgeInsets.zero,
              child: BalanceCard(
                balanceInfo:
                    widget.assetVM.balanceVM.balances[CryptoCurrency.wfps],
                cryptoCurrency: CryptoCurrency.wfps,
                backgroundColor: const Color.fromRGBO(5, 8, 23, 1),
              ),
            ),
          if (widget.assetVM.maticWFPSBalance != BigInt.zero)
            Padding(
              padding: EdgeInsets.zero,
              child: BalanceCard(
                  balanceInfo: widget
                      .assetVM.balanceVM.balances[CryptoCurrency.maticWFPS],
                  cryptoCurrency: CryptoCurrency.maticWFPS,
                  backgroundColor: const Color.fromRGBO(5, 8, 23, 1)),
            ),
          FullwidthButton(
            label: S.of(context).trade,
            onPressed: () => Navigator.of(context).pushNamed(Routes.pool),
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
