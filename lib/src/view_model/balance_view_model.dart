import 'package:frankencoin_wallet/src/entities/balance_info.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/balance_store.dart';
import 'package:mobx/mobx.dart';

part 'balance_view_model.g.dart';

class BalanceViewModel = BalanceViewModelBase with _$BalanceViewModel;

abstract class BalanceViewModelBase with Store {
  final BalanceStore _balanceStore;

  BalanceViewModelBase(this._balanceStore);

  @computed
  ObservableMap<String, BalanceInfo> get balances => _balanceStore.balances;

  @computed
  BigInt get zchfBalanceAggregated {
    var balance =
        _balanceStore.balances[CryptoCurrency.zchf.balanceId]?.getBalance() ??
            BigInt.zero;

    balance += _balanceStore.getBalance(CryptoCurrency.maticZCHF);
    balance += _balanceStore.getBalance(CryptoCurrency.baseZCHF);
    balance += _balanceStore.getBalance(CryptoCurrency.arbZCHF);
    balance += _balanceStore.getBalance(CryptoCurrency.opZCHF);
    return balance;
  }

  @computed
  BigInt get fpsBalanceAggregated {
    var balance =
        _balanceStore.balances[CryptoCurrency.fps.balanceId]?.getBalance() ??
            BigInt.zero;

    balance += _balanceStore.getBalance(CryptoCurrency.wfps);
    balance += _balanceStore.getBalance(CryptoCurrency.maticWFPS);
    return balance;
  }

  @computed
  BigInt get ethBalanceAggregated {
    var balance =
        _balanceStore.balances[CryptoCurrency.eth.balanceId]?.getBalance() ??
            BigInt.zero;

    balance += _balanceStore.getBalance(CryptoCurrency.baseETH);
    balance += _balanceStore.getBalance(CryptoCurrency.opETH);
    balance += _balanceStore.getBalance(CryptoCurrency.arbETH);
    return balance;
  }

  BigInt getAggregatedBalance(CryptoCurrency parentCurrency) {
    switch (parentCurrency) {
      case CryptoCurrency.eth:
        return ethBalanceAggregated;
      case CryptoCurrency.zchf:
        return zchfBalanceAggregated;
      case CryptoCurrency.fps:
        return fpsBalanceAggregated;
      default:
        return _balanceStore.getBalance(parentCurrency);
    }
  }
}
