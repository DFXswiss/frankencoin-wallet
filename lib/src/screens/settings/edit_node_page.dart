import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entites/node.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';

class EditNodePage extends BasePage {
  EditNodePage(this.appStore, {required this.chainId, super.key});

  @override
  String? get title => S.current.node;

  final AppStore appStore;
  final int chainId;

  @override
  Widget body(BuildContext context) =>
      _EditNodePageBody(appStore: appStore, chainId: chainId);
}

class _EditNodePageBody extends StatefulWidget {
  final AppStore appStore;
  final int chainId;

  const _EditNodePageBody({required this.appStore, required this.chainId});

  @override
  State<StatefulWidget> createState() => _EditNodePageBodyState();
}

class _EditNodePageBodyState extends State<_EditNodePageBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rpcUrlController = TextEditingController();
  late final Node node;

  bool _isLoading = false;

  @override
  void initState() {
    node = widget.appStore.settingsStore.getNode(widget.chainId);

    _nameController.text = node.name;
    _rpcUrlController.text = node.httpsUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _nameController,
            placeholder: S.of(context).name,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _rpcUrlController,
            placeholder: S.of(context).rpc_url,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: CupertinoButton(
            onPressed: _isLoading ? null : _save,
            color: FrankencoinColors.frRed,
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : Text(
                    S.of(context).save,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    node.name = _nameController.text;
    node.httpsUrl = _rpcUrlController.text;

    await widget.appStore.settingsStore.updateNode(node);
    setState(() => _isLoading = false);
  }
}
