import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/contracts/Equity.g.dart';
import 'package:frankencoin_wallet/src/entites/crypto_currency.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/view_model/send_view_model.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/credentials.dart';

part 'equity_view_model.g.dart';

class EquityViewModel = EquityViewModelBase with _$EquityViewModel;

abstract class EquityViewModelBase with Store {
  final AppStore appStore;
  final SendViewModel sendVM;
  final Equity _equity;

  EquityViewModelBase(this.appStore, this.sendVM)
      : _equity = Equity(
          address: EthereumAddress.fromHex(CryptoCurrency.fps.address),
          client: appStore.getClient(CryptoCurrency.fps.chainId),
        );

  @observable
  BigInt investAmount = BigInt.zero;

  @observable
  BigInt expectedReturn = BigInt.zero;

  @observable
  CryptoCurrency sendCurrency = CryptoCurrency.zchf;

  @computed
  CryptoCurrency get reverseCurrency => sendCurrency == CryptoCurrency.zchf
      ? CryptoCurrency.fps
      : CryptoCurrency.zchf;

  @observable
  ExecutionState state = InitialExecutionState();

  @computed
  bool get isReadyToCreate =>
      state is InitialExecutionState && investAmount > BigInt.zero;

  @action
  Future<void> updateExpectedReturn() async {
    if (sendCurrency == CryptoCurrency.zchf) {
      expectedReturn = await estimateShares(investAmount);
    } else if (sendCurrency == CryptoCurrency.fps) {
      expectedReturn = await estimateProceeds(investAmount);
    }
  }

  Future<BigInt> estimateProceeds(BigInt shares) =>
      _equity.calculateProceeds((shares: shares));

  Future<BigInt> estimateShares(BigInt investment) =>
      _equity.calculateShares((investment: investment));

  Future<String> Function()? _sendTransaction;

  Future<void> createTradeTransaction() async {
    state = CreatingExecutionState();

    final currentAccount = appStore.wallet!.currentAccount.primaryAddress;

    if (sendCurrency == CryptoCurrency.zchf) {
      _sendTransaction = () async => await _equity.invest(
          (amount: investAmount, expectedShares: expectedReturn),
          credentials: currentAccount);
    } else if (sendCurrency == CryptoCurrency.fps) {
      final canRedeem =
          await _equity.canRedeem((owner: currentAccount.address));

      if (!canRedeem) {
        state = FailureState(S.current.fps_cannot_redeem_yet);
        return;
      }

      _sendTransaction = () async => await _equity.redeemExpected((
            target: currentAccount.address,
            shares: investAmount,
            expectedProceeds: expectedReturn
          ), credentials: currentAccount);
    }

    state = AwaitingConfirmationExecutionState();
  }

  @action
  Future<void> commitTransaction() async {
    if (_sendTransaction == null) throw Exception("No pending transaction");
    state = CommittingExecutionState();
    try {
      final txId = await _sendTransaction!.call();
      state = ExecutedSuccessfullyState(payload: txId);
    } catch (e) {
      print("Failed ${e.toString()}");
      state = FailureState(e.toString());
    }
  }
}
