import 'dart:async';

import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

import '../core/contracts/Equity.g.dart';

part 'fps_asset_view_model.g.dart';

class FPSAssetViewModel = FPSAssetViewModelBase with _$FPSAssetViewModel;

abstract class FPSAssetViewModelBase with Store {
  final AppStore appStore;
  final BalanceStore _balanceStore;
  final Equity _equity;

  FPSAssetViewModelBase(this.appStore, this._balanceStore)
      : _equity = Equity(
          address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
          client: appStore.getClient(CryptoCurrency.fps.chainId),
        );

  @observable
  BigInt sharePrice = BigInt.zero;

  @observable
  BigInt totalSupply = BigInt.zero;

  @observable
  BigInt fpsHoldingSince = BigInt.zero;

  @computed
  int get holdingPeriod => (fpsHoldingSince.toInt() / 86400).floor();

  @computed
  BigInt get fpsBalance =>
      _balanceStore.balances[CryptoCurrency.fps.balanceId]?.getBalance() ??
      BigInt.zero;

  @computed
  BigInt get wfpsBalance =>
      _balanceStore.balances[CryptoCurrency.wfps.balanceId]?.getBalance() ??
      BigInt.zero;

  @computed
  BigInt get maticWFPSBalance =>
      _balanceStore.balances[CryptoCurrency.maticWFPS.balanceId]
          ?.getBalance() ??
      BigInt.zero;

  @computed
  double get marketCap =>
      EtherAmount.inWei(totalSupply).getValueInUnit(EtherUnit.ether) *
      EtherAmount.inWei(sharePrice).getValueInUnit(EtherUnit.ether);

  @computed
  double get fpsBalanceValue =>
      EtherAmount.inWei(fpsBalance).getValueInUnit(EtherUnit.ether) *
      EtherAmount.inWei(sharePrice).getValueInUnit(EtherUnit.ether);

  @action
  Future<void> _updateSharePrice() async => sharePrice = await _equity.price();

  @action
  Future<void> _updateTotalSupply() async =>
      totalSupply = await _equity.totalSupply();

  @action
  Future<void> _updateHoldingSince() async =>
      fpsHoldingSince = await _equity.holdingDuration(
          (holder: appStore.wallet!.currentAccount.primaryAddress.address));

  @action
  Future<void> updateAll() async {
    await _updateSharePrice();
    await _updateTotalSupply();
    await _updateHoldingSince();
  }

  Timer? _updateBalancesTimer;

  Future<void> startSync() async {
    await updateAll();

    _updateBalancesTimer = Timer.periodic(
        const Duration(seconds: 30), (timer) async => await updateAll());
  }

  void stopSync() => _updateBalancesTimer?.cancel();
}
