import 'package:frankencoin_wallet/src/core/crypto_currency.dart';
import 'package:frankencoin_wallet/src/screens/pool/equity.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/credentials.dart';

part 'equity_view_model.g.dart';

class EquityViewModel = EquityViewModelBase with _$EquityViewModel;

abstract class EquityViewModelBase with Store {
  final AppStore appStore;
  final Equity _equity;

  EquityViewModelBase(this.appStore)
      : _equity = Equity(
            address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
            client: appStore.client);

  @observable
  BigInt sharePrice = BigInt.zero;

  @observable
  BigInt totalSupply = BigInt.zero;

  @action
  Future<void> updateSharePrice() async => sharePrice = await _equity.price();

  @action
  Future<void> updateTotalSupply() async =>
      sharePrice = await _equity.totalSupply();

  Future<BigInt> estimateProceeds(BigInt shares) =>
      _equity.calculateProceeds(shares);

  Future<BigInt> estimateShares(BigInt investment) =>
      _equity.calculateShares(investment);
}
