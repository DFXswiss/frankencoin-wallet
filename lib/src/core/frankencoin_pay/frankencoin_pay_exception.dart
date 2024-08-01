class FrankencoinPayException implements Exception {
  final String message;

  FrankencoinPayException([this.message = '']);

  @override
  String toString() =>
      'FrankencoinPayException${message.isNotEmpty ? ': $message' : ''}';
}

class FrankencoinPayNotSupportedException extends FrankencoinPayException {}
