import 'dart:async';

import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/core/contracts/ReferredSavings.g.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_view_model.g.dart';

class SavingsViewModel = SavingsViewModelBase with _$SavingsViewModel;

abstract class SavingsViewModelBase with Store {
  final AppStore appStore;
  final ReferredSavings _savings;
  final ERC20 _zchf;

  SavingsViewModelBase(this.appStore)
      : _savings = ReferredSavings(
          address: EthereumAddress.fromHex(CryptoCurrency.savings.address),
          client: appStore.getClient(CryptoCurrency.savings.chainId),
        ),
        _zchf = ERC20(
          address: EthereumAddress.fromHex(CryptoCurrency.zchf.address),
          client: appStore.getClient(CryptoCurrency.zchf.chainId),
        );

  @observable
  double currentInterestRate = 0;

  @observable
  BigInt totalSavings = BigInt.zero;

  @observable
  BigInt accruedInterest = BigInt.zero;

  @action
  Future<void> _updateInterestRate() async => currentInterestRate =
      (await _savings.currentRatePPM()) / BigInt.from(10000);

  @action
  Future<void> _updateTotalSavings() async => totalSavings = await _zchf
      .balanceOf(EthereumAddress.fromHex(CryptoCurrency.savings.address));

  @action
  Future<void> _updateAccruedInterest() async =>
      accruedInterest = await _savings.accruedInterest((
        accountOwner: appStore.wallet!.currentAccount.primaryAddress.address
      ));

  @action
  Future<void> updateAll() async {
    await _updateInterestRate();
    await _updateTotalSavings();
    await _updateAccruedInterest();
  }

  Timer? _updateBalancesTimer;

  Future<void> startSync() async {
    await updateAll();

    _updateBalancesTimer = Timer.periodic(
        const Duration(seconds: 30), (timer) async => await updateAll());
  }

  void stopSync() => _updateBalancesTimer?.cancel();
}
