import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/wc_paring_card.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';
import 'package:frankencoin_wallet/src/widgets/qr_scan_dialog.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectPage extends BasePage {
  WalletConnectPage(this.wcService, {super.key});

  @override
  String? get title => "WalletConnect";

  final WalletConnectService wcService;

  @override
  Widget body(BuildContext context) =>
      _WalletConnectPageBody(wcService: wcService);
}

class _WalletConnectPageBody extends StatefulWidget {
  final WalletConnectService wcService;

  const _WalletConnectPageBody({required this.wcService});

  @override
  State<StatefulWidget> createState() => _WalletConnectPageBodyState();
}

class _WalletConnectPageBodyState extends State<_WalletConnectPageBody> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => ListView(
        children: [
          if (DeviceInfo.instance.isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: FullwidthButton(
                onPressed: _newConnection,
                label: S.of(context).new_wallet_connect_connection,
              ),
            ),
          ...widget.wcService.pairings
              .where((e) => e.active)
              .map((element) => WCParingCard(
                    paringInfo: element,
                    actionLabel: S.of(context).disconnect,
                    action: () => _disconnect(element),
                  )),
        ],
      ),
    );
  }

  Future<void> _disconnect(PairingInfo paringInfo) async =>
      await widget.wcService.disconnectSession(paringInfo.topic);

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
