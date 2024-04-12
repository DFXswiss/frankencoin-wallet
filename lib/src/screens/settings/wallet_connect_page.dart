import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/walletconnect_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/widgets/bottom_sheet_listener.dart';

class WalletConnectPage extends BasePage {
  WalletConnectPage(this.wcService, {super.key});

  @override
  String? get title => S.current.node;

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
  final TextEditingController _uriController = TextEditingController();

  final bottomSheetService = getIt.get<BottomSheetService>();

  @override
  Widget build(BuildContext context) {
    return BottomSheetListener(
      bottomSheetService: bottomSheetService,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
            child: CupertinoTextField(
              controller: _uriController,
              placeholder: S.of(context).name,
              suffix: const SizedBox(height: 52),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: CupertinoButton(
              onPressed: () => widget.wcService.create(),
              color: FrankencoinColors.frRed,
              child: Text(
                "Create",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: CupertinoButton(
              onPressed: () => widget.wcService.init(),
              color: FrankencoinColors.frRed,
              child: Text(
                "Init",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: CupertinoButton(
              onPressed: _save,
              color: FrankencoinColors.frRed,
              child: Text(
                S.of(context).save,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await widget.wcService.pairWithUri(Uri.parse(_uriController.text));
  }
}
