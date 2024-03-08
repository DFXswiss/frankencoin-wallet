import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:web3dart/web3dart.dart';

class PoolPage extends BasePage {
  final BalanceViewModel balanceVM;

  PoolPage(this.balanceVM, {super.key});

  @override
  Widget body(BuildContext context) => _PoolPageBody(balanceVM);
}

class _PoolPageBody extends StatefulWidget {
  final BalanceViewModel balanceVM;

  const _PoolPageBody(this.balanceVM);

  @override
  State<StatefulWidget> createState() => _PoolPageBodyState();
}

class _PoolPageBodyState extends State<_PoolPageBody> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiveController = TextEditingController();

  CryptoCurrency sendCurrency = CryptoCurrency.zchf;

  CryptoCurrency get reverseCurrency => sendCurrency == CryptoCurrency.zchf
      ? CryptoCurrency.fps
      : CryptoCurrency.zchf;

  String getLeadingImagePath(CryptoCurrency cryptoCurrency) {
    switch (cryptoCurrency) {
      case CryptoCurrency.zchf:
        return "assets/images/crypto/zchf.png";
      case CryptoCurrency.fps:
        return "assets/images/crypto/fps.png";
      default:
        return "assets/images/frankencoin.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 26, right: 26, top: 26, bottom: 10),
          child: CupertinoTextField(
            prefix: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(getLeadingImagePath(sendCurrency), width: 40),
            ),
            placeholder: "0.0000",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: Observer(builder: (_) {
              final rawBalanceAmount = EtherAmount.inWei(BigInt.parse(
                      widget.balanceVM.balances[sendCurrency]!.balance))
                  .getValueInUnit(EtherUnit.ether)
                  .toString();
              return TextButton(
                onPressed: () => _amountController.text = rawBalanceAmount,
                child: Text(
                  rawBalanceAmount,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
          ),
        ),
        IconButton(
            onPressed: () => setState(() => sendCurrency = reverseCurrency),
            iconSize: 25,
            icon: const Icon(
              CupertinoIcons.arrow_up_arrow_down,
              color: Color.fromRGBO(251, 113, 133, 1.0),
            )),
        Padding(
          padding: const EdgeInsets.only(left: 26, right: 26, top: 10),
          child: CupertinoTextField(
            prefix: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(getLeadingImagePath(reverseCurrency), width: 40),
            ),
            placeholder: "0.0000",
            controller: _receiveController,
            enabled: false,
          ),
        ),
        Row(
          children: [],
        )
      ],
    );
  }
}
