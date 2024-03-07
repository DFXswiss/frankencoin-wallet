import 'dart:async';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/evm_chain_formatter.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:frankencoin_wallet/src/wallet/transaction_priority.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'send_view_model.g.dart';

class SendViewModel = SendViewModelBase with _$SendViewModel;

abstract class SendViewModelBase with Store {
  final BalanceViewModel balanceVM;
  final AppStore appStore;

  SendViewModelBase(this.balanceVM, this.appStore);

  @observable
  String rawCryptoAmount = '';

  @observable
  String address = '';

  @observable
  int _gasPrice = 0;

  @observable
  int _estimatedGas = 0;

  @observable
  TransactionPriority priority = TransactionPriority.medium;

  @computed
  bool get isReadyToCreate => status == SendTransactionStatus.none && rawCryptoAmount.isNotEmpty && address.isNotEmpty;

  @observable
  SendTransactionStatus status = SendTransactionStatus.none;

  @observable
  CryptoCurrency spendCurrency = CryptoCurrency.zchf;

  @computed
  int get estimatedFee {
    final priorityFee =
        EtherAmount.fromInt(EtherUnit.gwei, priority.tip).getInWei.toInt();
    return (_gasPrice + priorityFee) * _estimatedGas;
  }

  @action
  Future<void> updateGasPrice() async =>
      _gasPrice = (await appStore.client.getGasPrice()).getInWei.toInt();

  @action
  Future<void> estimateGas() async =>
      _estimatedGas = (await appStore.client.estimateGas()).toInt();


  Timer? _updateGasPriceTimer;
  Timer? _estimateGasTimer;

  Future<void> syncFee() async {
    await updateGasPrice();
    await estimateGas();

    _updateGasPriceTimer = Timer.periodic(const Duration(seconds: 10), (timer) async => await updateGasPrice());
    _estimateGasTimer = Timer.periodic(const Duration(seconds: 10), (timer) async => await estimateGas());
  }

  void stopSyncFee() {
    _updateGasPriceTimer?.cancel();
    _estimateGasTimer?.cancel();
  }

  Future<String> Function()? _sendTransaction;

  @action
  Future<void> createTransaction() async {
    print(RegExp(r'(\b0x[a-fA-F0-9]{40}\b)').hasMatch(address));
    final cryptoAmountString = EVMChainFormatter.parseEVMChainAmount(
        rawCryptoAmount.replaceAll(",", "."));

    final cryptoAmount = EtherAmount.fromInt(EtherUnit.wei, cryptoAmountString);

    final isErc20Token = CryptoCurrency.erc20Tokens.contains(spendCurrency);

    final currentAccount = appStore.wallet!.currentAccount.primaryAddress;
    final currentAddress = currentAccount.address;
    final chainId = appStore.chainId;

    // ToDo: Balance Check
    status = SendTransactionStatus.creating;

    final transaction = Transaction(
      from: currentAddress,
      to: EthereumAddress.fromHex(address),
      maxPriorityFeePerGas: EtherAmount.fromInt(EtherUnit.gwei, priority.tip),
      value: isErc20Token ? EtherAmount.zero() : cryptoAmount,
    );

    if (!isErc20Token) {
      final signedTransaction = await appStore.client
          .signTransaction(currentAccount, transaction, chainId: chainId);

      _sendTransaction = () async =>
          await appStore.client.sendRawTransaction(signedTransaction);
    } else {
      final erc20 = ERC20(
        client: appStore.client,
        address: EthereumAddress.fromHex(spendCurrency.address),
        chainId: chainId,
      );

      _sendTransaction = () async => await erc20.transfer(
            EthereumAddress.fromHex(address),
            cryptoAmount.getInWei,
            credentials: currentAccount,
            transaction: transaction,
          );
    }
    status = SendTransactionStatus.awaitingConfirmation;
  }

  @action
  Future<void> commitTransaction() async {
    if (_sendTransaction == null) throw Exception("No pending transaction");
    await _sendTransaction!.call();
  }
}

enum SendTransactionStatus {
  none,
  creating,
  awaitingConfirmation,
  committing,
  committed,
  error;
}
