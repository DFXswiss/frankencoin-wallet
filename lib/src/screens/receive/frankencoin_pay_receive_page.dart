import 'package:flutter/cupertino.dart';
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
              ? const CupertinoActivityIndicator(color: FrankencoinColors.frRed)
              : QRAddressWidget(
                  address: _qrValue,
                  subtitle: widget.frankencoinPayService.lightningAddress,
                ),
          SizedBox(
            width: 500,
            child: CupertinoTextField(
              controller: _cryptoAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              placeholder: S.of(context).amount,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool _effectsInstalled = false;

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) return;

    _cryptoAmountController.addListener(() async {
      setState(() => _isLoading = true);

      final amount = _cryptoAmountController.text;

      if (amount.isEmpty) {
        setState(() {
          _isLoading = false;
          _qrValue = widget.frankencoinPayService.lightningAddressEncoded;
        });
        return;
      }

      final newQRVal =
          await widget.frankencoinPayService.getLightningInvoice(amount);
      setState(() {
        _isLoading = false;
        _qrValue = newQRVal;
      });
    });

    _effectsInstalled = true;
  }
}
