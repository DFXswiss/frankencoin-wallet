abstract class PaymentURI {
  PaymentURI({required this.amount, required this.address});

  final String amount;
  final String address;
}

class EthereumURI extends PaymentURI {
  EthereumURI({required super.amount, required super.address});

  @override
  String toString() {
    var base = 'ethereum:$address';

    if (amount.isNotEmpty) {
      base += '?amount=${amount.replaceAll(',', '.')}';
    }

    return base;
  }
}
