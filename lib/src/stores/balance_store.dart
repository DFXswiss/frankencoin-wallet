import 'dart:async';
import 'dart:developer';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/fiat_conversion_service.dart';
import 'package:frankencoin_wallet/src/entities/balance_info.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/fiat_conversion_rate.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/credentials.dart';

part 'balance_store.g.dart';

class BalanceStore = BalanceStoreBase with _$BalanceStore;

abstract class BalanceStoreBase with Store {
  final AppStore _appStore;
  final Isar _isar;
  final String nativeFiat = "CHF";

  BalanceStoreBase(this._appStore, this._isar);

  @observable
  ObservableMap<CryptoCurrency, BalanceInfo> balances = ObservableMap();

  Timer? _updateBalancesTimer;

  @action
  Future<void> updateBalances() async {
    final address = _appStore.wallet!.currentAccount.primaryAddress.address;

    log("[BalanceStore] Update Balances for $address");

    final nativeBalances = await _updateNativeBalances(address);
    final erc20Balances = await _updateERC20Balances(address);
    // final fiatBalance = await _updateFiatBalance("ETH.ETH");

    _isar.writeTxn(() async {
      _isar.balanceInfos.putAll(nativeBalances);
      _isar.balanceInfos.putAll(erc20Balances);
    });

    for (final nativeBalance in nativeBalances) {
      balances[Blockchain.getFromChainId(nativeBalance.chainId).nativeAsset] =
          nativeBalance;
    }

    for (final erc20Balance in erc20Balances) {
      balances[CryptoCurrency.getFromAddress(erc20Balance.contractAddress)!] =
          erc20Balance;
    }
  }

  @action
  void loadBalances() {
    final address = _appStore.wallet!.currentAccount.primaryAddress.address.hex;

    for (final chain in Blockchain.values) {
      final id = fastHash("${chain.chainId}:${chain.nativeSymbol}:$address");
      balances[chain.nativeAsset] = _isar.balanceInfos.getSync(id) ??
          BalanceInfo(
            chainId: chain.chainId,
            contractAddress: chain.nativeSymbol,
            address: address,
            balance: "0",
          );
    }

    for (final erc20Token in CryptoCurrency.erc20Tokens) {
      final id =
          fastHash("${erc20Token.chainId}:${erc20Token.address}:$address");
      balances[erc20Token] = _isar.balanceInfos.getSync(id) ??
          BalanceInfo(
            chainId: erc20Token.chainId,
            contractAddress: erc20Token.address,
            address: address,
            balance: "0",
          );
    }
  }

  Future<void> startSyncBalances() async {
    await updateBalances();

    _updateBalancesTimer = Timer.periodic(
        const Duration(seconds: 10), (_) async => await updateBalances());
  }

  void stopSyncBalances() => _updateBalancesTimer?.cancel();

  Future<List<BalanceInfo>> _updateERC20Balances(
      EthereumAddress address) async {
    final balances = <BalanceInfo>[];

    for (final erc20Token in CryptoCurrency.erc20Tokens) {
      final erc20 = ERC20(
        address: EthereumAddress.fromHex(erc20Token.address),
        client: _appStore.getClient(erc20Token.chainId),
      );
      final balance = await erc20.balanceOf(address);

      balances.add(BalanceInfo(
        chainId: erc20Token.chainId,
        contractAddress: erc20Token.address,
        address: address.hex,
        balance: balance.toString(),
      ));
    }

    return balances;
  }

  Future<List<BalanceInfo>> _updateNativeBalances(
      EthereumAddress address) async {
    final balances = <BalanceInfo>[];

    for (final chain in Blockchain.values) {
      final balance =
          await _appStore.getClient(chain.chainId).getBalance(address);
      balances.add(BalanceInfo(
          chainId: chain.chainId,
          contractAddress: chain.nativeSymbol,
          address: address.hex,
          balance: balance.getInWei.toString()));
    }

    return balances;
  }

  Future<FiatConversionRate> _updateFiatBalance(String crypto) async {
    final balance = await FiatConversionService.fetchPrice(
      crypto: crypto,
      fiat: nativeFiat,
      torOnly: false,
    );

    return FiatConversionRate(
      cryptoSymbol: crypto,
      fitaSymbol: nativeFiat,
      balance: balance,
    );
  }

  BigInt getBalance(CryptoCurrency currency) =>
      balances[currency]?.getBalance() ?? BigInt.zero;
}
