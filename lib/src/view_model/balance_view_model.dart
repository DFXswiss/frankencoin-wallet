import 'package:erc20/erc20.dart';
import 'package:frankencoin_wallet/src/entites/balance_info.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/utils/erc20_tokens.dart';
import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:http/http.dart';
import 'package:isar/isar.dart';
import 'package:mobx/mobx.dart';
import 'package:web3dart/web3dart.dart';

part 'balance_view_model.g.dart';

class BalanceViewModel = BalanceViewModelBase with _$BalanceViewModel;

abstract class BalanceViewModelBase with Store {
  final Isar _isar;
  final Web3Client _client = Web3Client(
      "https://eth-mainnet.g.alchemy.com/v2/0MudgAjBDrDwM7q55SdR13ggiukHg5xN",
      Client());
  final AppStore appStore;

  final int chainId = 1;
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

    final id = fastHash("$chainId:$nativeTicker:$address");
    balances[CryptoCurrency.eth] = _isar.balanceInfos.getSync(id) ??
        BalanceInfo(
          chainId: chainId,
          contractAddress: nativeTicker,
          address: address,
          balance: "0",
        );

    for (final erc20Token in erc20Tokens) {
      final id = fastHash("$chainId:${erc20Token.address}:$address");
      balances[erc20Token.selector] = _isar.balanceInfos.getSync(id) ??
          BalanceInfo(
            chainId: chainId,
            contractAddress: erc20Token.address,
            address: address,
            balance: "0",
          );
    }
  }

  Future<List<BalanceInfo>> _updateERC20Balances(
      EthereumAddress address) async {
    final balances = <BalanceInfo>[];
    for (final erc20Token in erc20Tokens) {
      final erc20 = ERC20(
        address: EthereumAddress.fromHex(erc20Token.address),
        client: _client,
      );
      final balance = await erc20.balanceOf(address);

      balances.add(BalanceInfo(
          chainId: chainId,
          contractAddress: erc20Token.address,
          address: address.hex,
          balance: balance.toString()));
    }

    return balances;
  }

  Future<BalanceInfo> _updateBalance(EthereumAddress address) async {
    final balance = await _client.getBalance(address);
    return BalanceInfo(
        chainId: chainId,
        contractAddress: nativeTicker,
        address: address.hex,
        balance: balance.getInWei.toString());
  }
}
