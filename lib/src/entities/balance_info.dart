import 'package:frankencoin_wallet/src/utils/fast_hash.dart';
import 'package:isar/isar.dart';


part 'balance_info.g.dart';

@collection
class BalanceInfo {
  BalanceInfo({
    required this.chainId,
    required this.contractAddress,
    required this.address,
    required this.balance,
  });

  Id get id => fastHash("$chainId:$contractAddress:$address");

  int chainId;

  String contractAddress;

  String address;

  String balance; // This has to be a String, because BigInt is not supported

  BigInt getBalance() => BigInt.parse(balance);
}
