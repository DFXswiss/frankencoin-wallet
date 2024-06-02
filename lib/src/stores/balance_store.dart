import 'dart:async';
import 'dart:developer';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/fiat_conversion_service.dart';
import 'package:frankencoin_wallet/src/entities/balance_info.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/entities/fiat_conversion_rate.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/custom_erc20_token_store.dart';
import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/credentials.dart';

part 'balance_store.g.dart';

class BalanceStore = BalanceStoreBase with _$BalanceStore;

abstract class BalanceStoreBase with Store {
  final AppStore _appStore;
  final CustomErc20TokenStore _erc20tokenStore;
  final Isar _isar;
  final String nativeFiat = "CHF";

  BalanceStoreBase(this._appStore, this._erc20tokenStore, this._isar);

  @observable
  ObservableMap<String, BalanceInfo> balances = ObservableMap();

  Timer? _updateBalancesTimer;

  @action
  Future<void> updateBalances() async {
    final address = _appStore.wallet!.currentAccount.primaryAddress.address;

    log("[BalanceStore] Update Balances for $address");

    final nativeBalances = await _updateNativeBalances(address);
    for (final nativeBalance in nativeBalances) {
      balances[_getBalanceId(
              nativeBalance.chainId, nativeBalance.contractAddress)] =
          nativeBalance;
    }

    final erc20Balances = await _updateERC20Balances(address);
    for (final erc20Balance in erc20Balances) {
      balances[_getBalanceId(
          erc20Balance.chainId, erc20Balance.contractAddress)] = erc20Balance;
    }

    final customERC20Balances = await _updateCustomERC20Balances(address);
    for (final erc20Balance in customERC20Balances) {
      balances[_getBalanceId(
          erc20Balance.chainId, erc20Balance.contractAddress)] = erc20Balance;
    }

    // final fiatBalance = await _updateFiatBalance("ETH.ETH");

    _isar.writeTxn(() async {
      _isar.balanceInfos.putAll(nativeBalances);
      _isar.balanceInfos.putAll(erc20Balances);
      _isar.balanceInfos.putAll(customERC20Balances);
    });
  }

  @action
  void loadBalances() {
    final address = _appStore.wallet!.currentAccount.primaryAddress.address.hex;

    for (final chain in Blockchain.values) {
      balances[chain.nativeAsset.balanceId] =
          _loadBalanceInfo(chain.chainId, chain.nativeSymbol, address);
    }

    for (final erc20Token in CryptoCurrency.erc20Tokens) {
      balances[erc20Token.balanceId] =
          _loadBalanceInfo(erc20Token.chainId, erc20Token.address, address);
    }

    for (final erc20Token in _erc20tokenStore.erc20Tokens) {
      balances[_getBalanceId(erc20Token.chainId, erc20Token.address)] =
          _loadBalanceInfo(erc20Token.chainId, erc20Token.address, address);
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

  Future<List<BalanceInfo>> _updateCustomERC20Balances(
      EthereumAddress address) async {
    final balances = <BalanceInfo>[];

    for (final erc20Token in _erc20tokenStore.erc20Tokens) {
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
      balances[currency.balanceId]?.getBalance() ?? BigInt.zero;

  BalanceInfo _loadBalanceInfo(
      int chainId, String contractAddress, String address) {
    final id = fastHash("$chainId:$contractAddress:$address");
    return _isar.balanceInfos.getSync(id) ??
        BalanceInfo(
          chainId: chainId,
          contractAddress: contractAddress,
          address: address,
          balance: "0",
        );
  }

  String _getBalanceId(int chainId, String address) => "$chainId:$address";
}
