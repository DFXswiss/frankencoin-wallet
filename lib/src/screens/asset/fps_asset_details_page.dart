import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/asset/widgets/info_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/view_model/fps_asset_view_model.dart';
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Observer(
                builder: (_) => Text(
                  "${EtherAmount.inWei(widget.assetVM.fpsBalance).getValueInUnit(EtherUnit.ether).toStringAsFixed(4)} FPS",
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
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
          children: [
            Expanded(
              child: Observer(
                builder: (_) => InfoCard(
                  label: 'Total Supply',
                  value: EtherAmount.inWei(widget.assetVM.totalSupply)
                      .getValueInUnit(EtherUnit.ether)
                      .toStringAsFixed(2),
                ),
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) => InfoCard(
                  label: 'FPS Price in ZCHF',
                  value: EtherAmount.inWei(widget.assetVM.sharePrice)
                      .getValueInUnit(EtherUnit.ether)
                      .toStringAsFixed(2),
                ),
              ),
            ),
          ],
        ),
    ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Expanded(
            child: Observer(
              builder: (_) => InfoCard(
                label: "Marktecap",
                value: "${widget.assetVM.marketCap.toStringAsFixed(2)} ZCHF",
              ),
            ),
          ),
        )
      ],
    );
  }
}
