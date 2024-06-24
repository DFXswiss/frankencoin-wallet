import 'package:frankencoin_wallet/src/entities/blockchain.dart';

class FrankencoinPayRequest {
  final String address;
  final BigInt amount;
  final String receiverName;
  final List<Blockchain> blockchains;
  final int expiry;

  FrankencoinPayRequest({
    required this.address,
    required this.amount,
    required this.receiverName,
    required this.expiry,
    this.blockchains = Blockchain.values,
  });
}
