import 'dart:async';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'balance_view_model.g.dart';

class BalanceViewModel = BalanceViewModelBase with _$BalanceViewModel;

abstract class BalanceViewModelBase with Store {
  final Isar _isar;
  final AppStore appStore;

  final String nativeTicker = "ETH";

  BalanceViewModelBase(this._isar, this.appStore) {
    loadBalances();
  }

  @observable
  ObservableMap<CryptoCurrency, BalanceInfo> balances = ObservableMap();

  @action
  Future<void> updateBalances() async {
    final address = appStore.wallet!.currentAccount.primaryAddress.address;

    final nativeBalance = await _updateBalance(address);
    final erc20Balances = await _updateERC20Balances(address);

    _isar.writeTxn(() async {
      _isar.balanceInfos.put(nativeBalance);
      balances[CryptoCurrency.eth] = nativeBalance;

      for (final erc20Balance in erc20Balances) {
        _isar.balanceInfos.put(erc20Balance);
        balances[CryptoCurrency.getFromAddress(erc20Balance.contractAddress)] =
            erc20Balance;
      }
    });
  }

  @action
  Future<void> loadBalances() async {
    final address = appStore.wallet!.currentAccount.primaryAddress.address.hex;
    final chainId = appStore.chainId;

    final id = fastHash("$chainId:$nativeTicker:$address");
    balances[CryptoCurrency.eth] = _isar.balanceInfos.getSync(id) ??
        BalanceInfo(
          chainId: chainId,
          contractAddress: nativeTicker,
          address: address,
          balance: "0",
        );

    for (final erc20Token in CryptoCurrency.erc20Tokens) {
      final id = fastHash("$chainId:${erc20Token.address}:$address");
      balances[erc20Token] = _isar.balanceInfos.getSync(id) ??
          BalanceInfo(
            chainId: chainId,
            contractAddress: erc20Token.address,
            address: address,
            balance: "0",
          );
    }
  }

  Timer? _updateBalancesTimer;

  Future<void> startSyncBalances() async {
    await updateBalances();

    _updateBalancesTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) async => await updateBalances());
  }

  void stopSyncBalances() {
    _updateBalancesTimer?.cancel();
  }

  Future<List<BalanceInfo>> _updateERC20Balances(
      EthereumAddress address) async {
    final balances = <BalanceInfo>[];
    final chainId = appStore.chainId;

    for (final erc20Token in CryptoCurrency.erc20Tokens) {
      final erc20 = ERC20(
        address: EthereumAddress.fromHex(erc20Token.address),
        client: appStore.client,
      );
      final balance = await erc20.balanceOf(address);

      balances.add(BalanceInfo(
        chainId: chainId,
        contractAddress: erc20Token.address,
        address: address.hex,
        balance: balance.toString(),
      ));
    }

    return balances;
  }

  Future<BalanceInfo> _updateBalance(EthereumAddress address) async {
    final balance = await appStore.client.getBalance(address);
    return BalanceInfo(
        chainId: appStore.chainId,
        contractAddress: nativeTicker,
        address: address.hex,
        balance: balance.getInWei.toString());
  }
}
