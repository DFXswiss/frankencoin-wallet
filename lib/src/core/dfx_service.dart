import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/dfx_auth_service.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/device_info.dart';
import 'package:frankencoin_wallet/src/wallet/wallet_account.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DFXService extends DFXAuthService {
  final AppStore appStore;

  DFXService(this.appStore);

  bool _isLoading = false;

  String get title => 'DFX.swiss';

  @override
  String get baseUrl => 'api.dfx.swiss';

  @override
  WalletAccount get wallet => appStore.wallet!.currentAccount;

  @override
  String get walletAddress => wallet.primaryAddress.address.hexEip55;

  String get assetIn => 'CHF';

  String get assetOut => 'ZCHF';

  String get langCode => appStore.settingsStore.language.code;

  List<String> supportedAssets = [
    'Ethereum/ZCHF',
    'Polygon/ZCHF',
    'Base/ZCHF',
    'Optimism/ZCHF',
    'Arbitrum/ZCHF',
    'Ethereum/ETH',
    'Base/ETH',
    'Optimism/ETH',
    'Arbitrum/ETH',
    'Polygon/MATIC',
    'Ethereum/FPS',
    'Ethereum/WFPS',
    'Polygon/WFPS',
    'Ethereum/WBTC'
  ];

  // List<String> supportedAssets = [
  //   'ZCHF',
  //   'ETH',
  //   'Polygon/MATIC',
  //   'FPS',
  //   'WFPS',
  //   'WBTC'
  // ];
  //
  // List<String> supportedBlockchains = [
  //   'Ethereum',
  //   'Polygon',
  //   'Base',
  //   'Optimism',
  //   'Arbitrum',
  // ];

  String get blockchain => 'Ethereum';

  Future<void> launchProvider(BuildContext context, bool? isBuyAction,
      [String? paymentMethod]) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final assetOut = this.assetOut;
      final blockchain = this.blockchain;
      final actionType = isBuyAction == true ? '/buy' : '/sell';

      final accessToken = await getAuthToken();

      final uri = Uri.https('services.dfx.swiss', actionType, {
        'session': accessToken,
        'lang': langCode,
        'asset-out': assetOut,
        'blockchain': blockchain,
        'asset-in': assetIn,
        // 'blockchains': supportedBlockchains.join(','),
        'assets': supportedAssets.join(','),
        if (paymentMethod != null) 'payment-method': paymentMethod
      });

      _isLoading = false;
      if (await canLaunchUrl(uri)) {
        if (DeviceInfo.instance.isMobile) {
          Navigator.of(context)
              .pushNamed(Routes.webView, arguments: [title, uri]);
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      _isLoading = false;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            errorMessage: '${S.of(context).dfx_unavailable}: $e',
          );
        },
      );
    }
  }
}
