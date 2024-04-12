import 'dart:convert';
import 'dart:developer';

import 'package:convert/convert.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/wallet_connect/wc_ethereum_transaction_model.dart';
import 'package:frankencoin_wallet/src/entites/blockchain.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/web3request_modal.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class CWEvmChainService {
  final Blockchain blockchain;
  final AppStore appStore;
  final BottomSheetService bottomSheetService;
  final Web3Wallet wallet;

  static const namespace = 'eip155';
  static const pSign = 'personal_sign';
  static const eSign = 'eth_sign';

  // static const eSignTransaction = 'eth_signTransaction';
  static const eSignTypedData = 'eth_signTypedData_v4';
  static const eSendTransaction = 'eth_sendTransaction';

  CWEvmChainService({
    required this.blockchain,
    required this.appStore,
    required this.bottomSheetService,
    required this.wallet,
    Web3Client? web3Client,
  }) {
    for (final String event in getEvents()) {
      wallet.registerEventEmitter(chainId: getChainId(), event: event);
    }
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: pSign,
      handler: personalSign,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSign,
      handler: ethSign,
    );
    // wallet.registerRequestHandler(
    //   chainId: getChainId(),
    //   method: eSignTransaction,
    //   handler: ethSignTransaction,
    // );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSendTransaction,
      handler: ethSendTransaction,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSignTypedData,
      handler: ethSignTypedData,
    );
  }

  String getNamespace() => namespace;

  String getChainId() => "eip155:${blockchain.chainId}";

  List<String> getEvents() => ['chainChanged', 'accountsChanged'];

  Future<void> _reject(String topic, int id) => wallet.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: id,
          jsonrpc: '2.0',
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        ),
      );

  SessionRequest _getRequest(String topic, dynamic parameters) =>
      wallet.pendingRequests.getAll().firstWhere(
          (element) => element.topic == topic && element.params == parameters);

  Future<bool> requestAuthorization(String action, String? text) async {
    // Show the bottom sheet
    final bool? isApproved = await bottomSheetService.queueBottomSheet(
      widget: Web3RequestModal(
        child: Text(
          action,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ) as bool?;

    return isApproved == true;
  }

  Future<void> personalSign(String topic, dynamic parameters) async {
    final id = _getRequest(topic, parameters);

    final String message = parameters[0]?.toString() ?? '';

    final bool isApproved =
        await requestAuthorization(S.current.sign_message, message);

    if (!isApproved) return _reject(topic, id.id);

    try {
      final sigMessage = utf8.decode(hex.decode(message.substring(2)));
      final String signature =
          await appStore.wallet!.currentAccount.signMessage(sigMessage);

      return wallet.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: id.id,
          jsonrpc: '2.0',
          result: signature,
        ),
      );
    } catch (e) {
      log(e.toString());
      bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(
          message: '${S.current.error}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> ethSign(String topic, dynamic parameters) async {
    final id = _getRequest(topic, parameters);

    final String message = parameters[1]?.toString() ?? '';

    final bool isApproved =
        await requestAuthorization(S.current.sign_message, message);
    if (!isApproved) return _reject(topic, id.id);

    try {
      final sigMessage = utf8.decode(hex.decode(message.substring(2)));
      final String signature =
          await appStore.wallet!.currentAccount.signMessage(sigMessage);

      return wallet.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: id.id,
          jsonrpc: '2.0',
          result: signature,
        ),
      );
    } catch (e) {
      log('error: ${e.toString()}');
      bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(
            message: '${S.current.error}: ${e.toString()}'),
      );
      return;
    }
  }

  Future<void> ethSendTransaction(String topic, dynamic parameters) async {
    final id = _getRequest(topic, parameters);

    final paramsData = parameters[0] as Map<String, dynamic>;

    final message = ""; //_convertToReadable(paramsData);

    final bool isApproved =
        await requestAuthorization(S.current.sign_transaction, message);

    if (!isApproved) return _reject(topic, id.id);

    final Credentials credentials =
        appStore.wallet!.currentAccount.primaryAddress;

    WCEthereumTransactionModel ethTransaction =
        WCEthereumTransactionModel.fromJson(paramsData);

    final transaction = Transaction(
      from: EthereumAddress.fromHex(ethTransaction.from),
      to: EthereumAddress.fromHex(ethTransaction.to),
      maxGas: ethTransaction.gasLimit != null
          ? int.tryParse(ethTransaction.gasLimit ?? "")
          : null,
      gasPrice: ethTransaction.gasPrice != null
          ? EtherAmount.inWei(BigInt.parse(ethTransaction.gasPrice ?? ""))
          : null,
      value: EtherAmount.inWei(BigInt.parse(ethTransaction.value ?? "0")),
      data: hexToBytes(ethTransaction.data ?? ""),
      nonce: ethTransaction.nonce != null
          ? int.tryParse(ethTransaction.nonce ?? "")
          : null,
    );

    try {
      final result =
          await appStore.getClient(blockchain.chainId).sendTransaction(
                credentials,
                transaction,
                chainId: blockchain.chainId,
              );

      return wallet.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: id.id,
          jsonrpc: '2.0',
          result: result,
        ),
      );
    } catch (e) {
      log('An error has occurred while signing transaction: ${e.toString()}');
      bottomSheetService.queueBottomSheet(
        isModalDismissible: true,
        widget: BottomSheetMessageDisplayWidget(
          message: '${S.current.error}: ${e.toString()}',
        ),
      );
      return;
    }
  }

  Future<void> ethSignTypedData(String topic, dynamic parameters) async {
    final id = _getRequest(topic, parameters);

    final String? data = parameters[1] as String?;

    final bool isApproved =
        await requestAuthorization(S.current.sign_message, data);

    if (!isApproved) return _reject(topic, id.id);

    final Credentials credentials =
        appStore.wallet!.currentAccount.primaryAddress;

    final signature = EthSigUtil.signTypedData(
      privateKeyInBytes: (credentials as EthPrivateKey).privateKey,
      jsonData: data ?? '',
      version: TypedDataVersion.V4,
    );

    return wallet.respondSessionRequest(
      topic: topic,
      response: JsonRpcResponse(
        id: id.id,
        jsonrpc: '2.0',
        result: signature,
      ),
    );
  }

//  String _convertToReadable(Map<String, dynamic> data) {
//    // final tokenName = getTokenNameBasedOnWalletType(appStore.wallet!.type);
//    final tokenName = "lol";
//    String gas =
//        int.parse((data['gas'] as String).substring(2), radix: 16).toString();
//    String value = data['value'] != null
//        ? (int.parse((data['value'] as String).substring(2), radix: 16) / 1e18)
//                .toString() +
//            ' $tokenName'
//        : '0 $tokenName';
//    String from = data['from'] as String;
//    String to = data['to'] as String;
//
//    return '''
// Gas: $gas\n
// Value: $value\n
// From: $from\n
// To: $to
//             ''';
//  }
}
