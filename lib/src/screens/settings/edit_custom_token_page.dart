import 'package:erc20/erc20.dart';
import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/blockchain_selector.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class EditCustomTokenPage extends BasePage {
  EditCustomTokenPage(
      this.appStore, this.customErc20TokenStore, this.bottomSheetService,
      {required this.customToken, super.key});

  @override
  String? get title =>
      customToken != null ? S.current.edit_asset : S.current.new_asset;

  final AppStore appStore;
  final CustomErc20TokenStore customErc20TokenStore;
  final BottomSheetService bottomSheetService;
  final CustomErc20Token? customToken;

  @override
  Widget body(BuildContext context) => _EditCustomTokenPageBody(
        appStore: appStore,
        customErc20TokenStore: customErc20TokenStore,
        bottomSheetService: bottomSheetService,
        customToken: customToken ??
            CustomErc20Token(
              chainId: 1,
              address: '',
              symbol: '',
              name: '',
              decimals: 18,
            ),
      );
}

class _EditCustomTokenPageBody extends StatefulWidget {
  final AppStore appStore;
  final CustomErc20TokenStore customErc20TokenStore;
  final BottomSheetService bottomSheetService;
  final CustomErc20Token customToken;

  const _EditCustomTokenPageBody({
    required this.appStore,
    required this.customErc20TokenStore,
    required this.bottomSheetService,
    required this.customToken,
  });

  @override
  State<StatefulWidget> createState() => _EditCustomTokenPageBodyState();
}

class _EditCustomTokenPageBodyState extends State<_EditCustomTokenPageBody> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _decimalsController = TextEditingController();
  final TextEditingController _iconUrlController = TextEditingController();
  bool _isLoading = false;

  int _chainId = 1;

  @override
  void initState() {
    _addressController.text = widget.customToken.address;
    _nameController.text = widget.customToken.name;
    _symbolController.text = widget.customToken.symbol;
    _decimalsController.text = widget.customToken.decimals.toString();
    _iconUrlController.text = widget.customToken.iconUrl ?? "";

    _chainId = widget.customToken.chainId;

    _addressController.addListener(() {
      final address = _addressController.text;
      if (address.length == 42) _loadTokenInfos(address);
    });

    super.initState();
  }

  Future<void> _loadTokenInfos(String address) async {
    final erc20Token = ERC20(
      address: EthereumAddress.fromHex(address),
      client: widget.appStore.getClient(_chainId),
    );

    _nameController.text = await erc20Token.name();
    _symbolController.text = await erc20Token.symbol();
    _decimalsController.text = (await erc20Token.decimals()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(child: Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.only(left: 26, right: 26, top: 10),
          child: CupertinoTextField(
            controller: _addressController,
            placeholder: S.of(context).address,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 26, right: 26),
          child: BlockchainSelector(
            bottomSheetService: widget.bottomSheetService,
            blockchain: Blockchain.getFromChainId(_chainId),
            onSelect: (blockchain) =>
                setState(() => _chainId = blockchain.chainId),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 26, right: 26, top: 20, bottom: 10),
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
            controller: _symbolController,
            placeholder: S.of(context).token_symbol,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _decimalsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            placeholder: S.of(context).token_decimals,
            suffix: const SizedBox(height: 52),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 10),
          child: CupertinoTextField(
            controller: _iconUrlController,
            placeholder: S.of(context).token_icon_url,
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
    ),));
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    widget.customToken.address = _addressController.text.trim();
    widget.customToken.name = _nameController.text.trim();
    widget.customToken.symbol = _symbolController.text.trim();
    widget.customToken.decimals = int.parse(_decimalsController.text.trim());

    if (_iconUrlController.text.trim().isNotEmpty) {
      widget.customToken.iconUrl = _iconUrlController.text;
    }

    await widget.customErc20TokenStore.updateToken(widget.customToken);
    setState(() => _isLoading = false);
  }
}
