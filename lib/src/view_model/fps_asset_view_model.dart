import 'dart:async';

import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/view_model/balance_view_model.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

import '../screens/pool/Equity.g.dart';

part 'fps_asset_view_model.g.dart';

class FPSAssetViewModel = FPSAssetViewModelBase with _$FPSAssetViewModel;

abstract class FPSAssetViewModelBase with Store {
  final AppStore appStore;
  final BalanceViewModel balanceVM;
  final Equity _equity;

  FPSAssetViewModelBase(this.appStore, this.balanceVM)
      : _equity = Equity(
            address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
            client: appStore.client);

  @observable
  BigInt sharePrice = BigInt.zero;

  @observable
  BigInt totalSupply = BigInt.zero;

  @computed
  BigInt get fpsBalance =>
      balanceVM.balances[CryptoCurrency.fps]?.getBalance() ?? BigInt.zero;

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
  Future<void> updateAll() async {
    await _updateSharePrice();
    await _updateTotalSupply();
  }

  Timer? _updateBalancesTimer;

  Future<void> startSync() async {
    await balanceVM.startSyncBalances();
    await updateAll();

    _updateBalancesTimer = Timer.periodic(
        const Duration(seconds: 30), (timer) async => await updateAll());
  }

  void stopSync() {
    balanceVM.stopSyncBalances();
    _updateBalancesTimer?.cancel();
  }
}
