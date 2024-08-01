import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/address_book_entry.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/confirmation_alert.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/utils/format_fixed.dart';
import 'package:frankencoin_wallet/src/utils/parse_fixed.dart';
import 'package:frankencoin_wallet/src/view_model/send_asset_view_model.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/amount_info_row.dart';
import 'package:frankencoin_wallet/src/widgets/number_input_widget.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/successful_tx_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

class WithdrawAmountPage extends BasePage {
  WithdrawAmountPage(
      this.sendAssetVM,
      this.bottomSheetService, {
        super.key,
        required this.sendCurrency,
        this.initialAmount,
      });

  @override
  String? get title => S.current.sell;

  final SendAssetViewModel sendAssetVM;
  final BottomSheetService bottomSheetService;
  final String? initialAmount;
  final CustomErc20Token sendCurrency;

  @override
  Widget body(BuildContext context) => _WithdrawAmountPageBody(
    sendAssetVM: sendAssetVM,
    bottomSheetService: bottomSheetService,
    initialAmount: initialAmount,
    sendCurrency: sendCurrency,
  );
}

class _WithdrawAmountPageBody extends StatefulWidget {
  final SendAssetViewModel sendAssetVM;
  final String? initialAmount;
  final CustomErc20Token sendCurrency;
  final BottomSheetService bottomSheetService;

  const _WithdrawAmountPageBody({
    required this.sendAssetVM,
    required this.bottomSheetService,
    required this.sendCurrency,
    this.initialAmount,
  });

  @override
  State<StatefulWidget> createState() => _WithdrawAmountPageBodyState();
}

class _WithdrawAmountPageBodyState extends State<_WithdrawAmountPageBody> {

  @override
  void initState() {
    super.initState();
    widget.sendAssetVM.spendCurrency = widget.sendCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return NumberInputWidget(
      maxLength: 100,
      onChange: (_) {},
      onComplete: (String pin) {},
      buttonLabel: "Mit DFX ausbezahlen",
      inputSuffix: "ZCHF",
    );
  }
}
