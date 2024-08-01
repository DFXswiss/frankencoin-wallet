import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/dfx/dfx_service.dart';
import 'package:frankencoin_wallet/src/core/frankencoin_pay/frankencoin_pay_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/vertical_icon_button.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color: FrankencoinColors.frRed,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => getIt
                              .get<DFXService>()
                              .launchProvider(context, true),
                          icon: const Icon(
                            Icons.attach_money,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).buy,
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.receive),
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).receive,
                        ),
                      ),
                      if (DeviceInfo.instance.isMobile)
                        Expanded(
                          child: VerticalIconButton(
                            onPressed: () => _presentQRReader(context),
                            icon: const Icon(
                              Icons.qr_code,
                              color: FrankencoinColors.frRed,
                            ),
                            label: S.of(context).scan,
                          ),
                        ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              Routes.send,
                              arguments: [null, null, null]),
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).send,
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => getIt
                              .get<DFXService>()
                              .launchProvider(context, false),
                          icon: const Icon(
                            Icons.money_off,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).sell,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _presentQRReader(BuildContext context) async {
    String result = await showDialog(
      context: context,
      builder: (dialogContext) => QRScanDialog(
        validateQR: (code, _) =>
            RegExp(r'(\b0x[a-fA-F0-9]{40}\b)').hasMatch(code!) ||
            code.toLowerCase().startsWith("wc:") ||
            code.toLowerCase().startsWith("lnurl")||
            code.toLowerCase().startsWith("lnbc"),
        onData: (code, _) =>
            Navigator.of(dialogContext, rootNavigator: true).pop(code),
      ),
    );

    if (result.toLowerCase().startsWith("wc:")) {
      getIt.get<WalletConnectService>().pairWithUri(Uri.parse(result));
    } else if (result.toLowerCase().startsWith("lnurl")) {
      final res = await getIt
          .get<FrankencoinPayService>()
          .getPaymentUri(result);
      await Navigator.of(context)
          .pushNamed(Routes.sendFrankencoinPay, arguments: res);
    } else if (result.toLowerCase().startsWith("lnbc")) {
      try {
        final res = getIt
            .get<FrankencoinPayService>()
            .getLightningInvoiceDetails(result);
        await Navigator.of(context)
            .pushNamed(Routes.sendFrankencoinPay, arguments: res);
      } catch (e) {
        getIt.get<BottomSheetService>().queueBottomSheet(
            isModalDismissible: true,
            widget: BottomSheetMessageDisplayWidget(
              message: e.toString(),
            ));
      }
    } else if (result.startsWith("0x")) {
      await Navigator.of(context)
          .pushNamed(Routes.send, arguments: [result, null, null]);
    } else {
      final uri = ERC681URI.fromString(result);
      await Navigator.of(context).pushNamed(Routes.send,
          arguments: [uri.address, uri.amount, uri.asset]);
    }
  }
}
