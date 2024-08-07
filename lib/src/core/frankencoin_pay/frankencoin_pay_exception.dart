import 'package:frankencoin_wallet/generated/i18n.dart';

class FrankencoinPayException implements Exception {
  final String message;

  FrankencoinPayException([this.message = '']);

  @override
  String toString() =>
      'FrankencoinPayException${message.isNotEmpty ? ': $message' : ''}';
}

class FrankencoinPayNotSupportedException extends FrankencoinPayException {
  final String provider;

  FrankencoinPayNotSupportedException(this.provider);

  @override
  String get message => S.current.frankencoin_pay_not_supported(provider);
}
