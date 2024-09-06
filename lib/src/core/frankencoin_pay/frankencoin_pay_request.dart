import 'package:frankencoin_wallet/src/entities/blockchain.dart';

class FrankencoinPayRequest {
  final String address;
  final BigInt amount;
  final String receiverName;
  final List<Blockchain> blockchains;
  final int expiry;
  final String callbackUrl;
  final String quote;

  FrankencoinPayRequest({
    required this.address,
    required this.amount,
    required this.receiverName,
    required this.expiry,
    required this.callbackUrl,
    required this.quote,
    this.blockchains = Blockchain.values,
  });
}
