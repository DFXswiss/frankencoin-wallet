import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/widgets/bottom_sheet_listener.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';

class WalletConnectPage extends BasePage {
  WalletConnectPage(this.wcService, {super.key});

  @override
  String? get title => "Wallet Connect";

  final WalletConnectWalletService wcService;

  @override
  Widget body(BuildContext context) =>
      _WalletConnectPageBody(wcService: wcService);
}

class _WalletConnectPageBody extends StatefulWidget {
  final WalletConnectWalletService wcService;

  const _WalletConnectPageBody({required this.wcService});

  @override
  State<StatefulWidget> createState() => _WalletConnectPageBodyState();
}

class _WalletConnectPageBodyState extends State<_WalletConnectPageBody> {
  final bottomSheetService = getIt.get<BottomSheetService>();

  @override
  Widget build(BuildContext context) {
    return BottomSheetListener(
      bottomSheetService: bottomSheetService,
      child: Column(
        children: [
          if (DeviceInfo.instance.isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: FullwidthButton(
                onPressed: _newConnection,
                label: S.of(context).new_wallet_connect_connection,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _newConnection() async {
    String uri = await showDialog(
      context: context,
      builder: (dialogContext) => QRScanDialog(
        validateQR: (code, _) => code?.startsWith("wc:") == true,
        onData: (code, _) =>
            Navigator.of(dialogContext, rootNavigator: true).pop(code),
      ),
    );

    await widget.wcService.pairWithUri(Uri.parse(uri));
  }
}
