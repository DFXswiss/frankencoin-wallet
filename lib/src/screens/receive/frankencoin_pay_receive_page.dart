import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/widgets/qr_address_widget.dart';

class FrankencoinPayReceivePage extends BasePage {
  final FrankencoinPayService frankencoinPayService;

  FrankencoinPayReceivePage({super.key, required this.frankencoinPayService});

  @override
  String get title => S.current.frankencoin_pay;

  @override
  Widget body(BuildContext context) =>
      _FrankencoinPayReceivePageBody(frankencoinPayService);
}

class _FrankencoinPayReceivePageBody extends StatefulWidget {
  final FrankencoinPayService frankencoinPayService;

  const _FrankencoinPayReceivePageBody(this.frankencoinPayService);

  @override
  State<StatefulWidget> createState() => _FrankencoinPayReceivePageBodyState();
}

class _FrankencoinPayReceivePageBodyState
    extends State<_FrankencoinPayReceivePageBody> {
  bool _isLoading = false;
  String _qrValue = "";

  final TextEditingController _cryptoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEffects(context);
    _qrValue = widget.frankencoinPayService.lightningAddressEncoded;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          _isLoading
              ? const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                      child: CupertinoActivityIndicator(
                          color: FrankencoinColors.frRed)),
                )
              : QRAddressWidget(
                  address: _qrValue,
                  subtitle: widget.frankencoinPayService.lightningAddress,
                ),
          SizedBox(
            width: 500,
            child: CupertinoTextField(
              controller: _cryptoAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              placeholder: S.of(context).amount,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r"^\d*[.,]?\d{0,2}$")),
              ],
              prefix: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(Icons.currency_franc)),
            ),
          )
        ],
      ),
    );
  }

  bool _effectsInstalled = false;
  CancelableOperation? _completer;

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;

    _cryptoAmountController.addListener(() async {
      setState(() => _isLoading = true);

      final amount = _cryptoAmountController.text;

      await _completer?.cancel();

      if (amount.isEmpty) {
        setState(() {
          _isLoading = false;
          _qrValue = widget.frankencoinPayService.lightningAddressEncoded;
        });
        return;
      }

      _completer = CancelableOperation.fromFuture(
        widget.frankencoinPayService.getLightningInvoice(amount),
        onCancel: () {},
      );

      _completer?.then((qrVal) => setState(() {
            _isLoading = false;
            _qrValue = qrVal;
          }));
    });

    _effectsInstalled = true;
  }
}
