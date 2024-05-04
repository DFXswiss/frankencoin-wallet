import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/wc_evm_chain_service.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/session_proposal_modal.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/web3request_modal.dart';
import 'package:mobx/mobx.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:frankencoin_wallet/secrets.g.dart' as secrets;

part 'walletconnect_service.g.dart';

class WalletConnectWalletService = WalletConnectWalletServiceBase
    with _$WalletConnectWalletService;

abstract class WalletConnectWalletServiceBase with Store {
  final AppStore appStore;
  final BottomSheetService _bottomSheetHandler;

  late Web3Wallet _web3Wallet;

  @observable
  bool isInitialized;

  @observable
  ObservableList<PairingInfo> pairings;

  @observable
  ObservableList<SessionData> sessions;

  @observable
  ObservableList<StoredCacao> auth;

  WalletConnectWalletServiceBase(this._bottomSheetHandler, this.appStore)
      : pairings = ObservableList<PairingInfo>(),
        sessions = ObservableList<SessionData>(),
        auth = ObservableList<StoredCacao>(),
        isInitialized = false;

  @action
  void create() {
    // Create the web3wallet client
    _web3Wallet = Web3Wallet(
      core: Core(projectId: secrets.walletConnectProjectId),
      metadata: const PairingMetadata(
        name: 'Frankencoin Wallet',
        description: 'Frankencoin Wallet',
        url: 'https://frankencoin.app',
        icons: ['https://frankencoin.com/coin/zchf.svg'],
      ),
    );

    // Setup our accounts
    for (final chain in Blockchain.values) {
      _web3Wallet.registerAccount(
        chainId: 'eip155:${chain.chainId}',
        accountAddress:
            appStore.wallet!.currentAccount.primaryAddress.address.hexEip55,
      );

      CWEvmChainService(
        blockchain: chain,
        appStore: appStore,
        bottomSheetService: _bottomSheetHandler,
        wallet: _web3Wallet,
      );
    }

    // Setup our listeners
    _web3Wallet.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _web3Wallet.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _web3Wallet.core.pairing.onPairingDelete.subscribe(_onPairingDelete);
    _web3Wallet.core.pairing.onPairingExpire.subscribe(_onPairingDelete);
    _web3Wallet.pairings.onSync.subscribe(_onPairingsSync);
    _web3Wallet.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet.onSessionProposalError.subscribe(_onSessionProposalError);
    _web3Wallet.onSessionConnect.subscribe(_onSessionConnect);
  }

  @action
  Future<void> init() async {
    if (!isInitialized) {
      try {
        await _web3Wallet.init();
        isInitialized = true;
      } catch (e) {
        isInitialized = false;
      }
    }

    _refreshPairings();

    final newSessions = _web3Wallet.sessions.getAll();
    sessions.addAll(newSessions);

    final newAuthRequests = _web3Wallet.completeRequests.getAll();
    auth.addAll(newAuthRequests);
  }

  @action
  void onDispose() {
    if (!isInitialized) return;

    _web3Wallet.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    _web3Wallet.core.pairing.onPairingCreate.unsubscribe(_onPairingCreate);
    _web3Wallet.core.pairing.onPairingDelete.unsubscribe(_onPairingDelete);
    _web3Wallet.core.pairing.onPairingExpire.unsubscribe(_onPairingDelete);
    _web3Wallet.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet.onSessionConnect.unsubscribe(_onSessionConnect);

    isInitialized = false;
  }

  void _onPairingsSync(StoreSyncEvent? args) {
    if (args != null) _refreshPairings();
  }

  void _onPairingDelete(PairingEvent? event) => _refreshPairings();

  @action
  void _refreshPairings() {
    pairings.clear();
    final allPairings = _web3Wallet.pairings.getAll();
    pairings.addAll(allPairings);
  }

  Future<void> _onSessionProposalError(SessionProposalErrorEvent? args) async {
    log(args.toString());
  }

  Future<void> _onSessionProposal(SessionProposalEvent? args) async {
    if (args != null) {
      final metadata = args.params.proposer.metadata;
      final namespace = args.params.requiredNamespaces['eip155'];
      final Widget modalWidget = Web3RequestModal(
        child: SessionProposalModal(
          icon: metadata.icons.firstOrNull,
          metadata: metadata,
          chains: namespace?.chains,
          methods: namespace?.methods ?? [],
          events: namespace?.events ?? [],
        ),
      );
      // show the bottom sheet
      final bool? isApproved = await _bottomSheetHandler.queueBottomSheet(
        widget: modalWidget,
      ) as bool?;

      if (isApproved != null && isApproved) {
        _web3Wallet.approveSession(
          id: args.id,
          namespaces: args.params.generatedNamespaces!,
        );
      } else {
        _web3Wallet.rejectSession(
          id: args.id,
          reason: Errors.getSdkError(
            Errors.USER_REJECTED,
          ),
        );
      }
    }
  }

  @action
  void _onPairingInvalid(PairingInvalidEvent? args) {
    log('Pairing Invalid Event: $args');
    _bottomSheetHandler.queueBottomSheet(
      isModalDismissible: true,
      widget: BottomSheetMessageDisplayWidget(message: 'Invalid Paring: $args'),
    );
  }

  @action
  Future<void> pairWithUri(Uri uri) async {
    try {
      log('Pairing with URI: $uri');
      await _web3Wallet.core.pairing.pair(uri: uri);
    } on WalletConnectError catch (e) {
      _bottomSheetHandler.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(message: e.message),
      );
    } catch (e) {
      _bottomSheetHandler.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(message: e.toString()),
      );
    }
  }

  void _onPairingCreate(PairingEvent? args) {
    log('Pairing Create Event: $args');
  }

  @action
  void _onSessionConnect(SessionConnect? args) {
    if (args != null) sessions.add(args.session);
  }

  @action
  Future<void> disconnectSession(String topic) async {
    final session =
        sessions.where((element) => element.pairingTopic == topic).firstOrNull;

    await _web3Wallet.core.pairing.disconnect(topic: topic);
    if (session != null) {
      await _web3Wallet.disconnectSession(
          topic: session.topic,
          reason: Errors.getSdkError(Errors.USER_DISCONNECTED));
    }
  }

  @action
  List<SessionData> getSessionsForPairingInfo(PairingInfo pairing) => sessions
      .where((element) => element.pairingTopic == pairing.topic)
      .toList();
}
