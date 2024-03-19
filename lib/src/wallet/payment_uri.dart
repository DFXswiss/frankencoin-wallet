abstract class PaymentURI {
  PaymentURI({required this.amount, required this.address});

  final String amount;
  final String address;
}

class EthereumURI extends PaymentURI {
  EthereumURI({required super.amount, required super.address});

  factory EthereumURI.fromString(String uriString) {
    final uri = Uri.parse(uriString);

    if (uri.scheme.toLowerCase() != "ethereum") {
      throw PaymentURIParseException();
    }

    final address = uri.path;
    final amount = uri.queryParameters["amount"] ?? "";
    return EthereumURI(address: address, amount: amount);
  }

  @override
  String toString() {
    var base = 'ethereum:$address';

    if (amount.isNotEmpty) {
      base += '?amount=${amount.replaceAll(',', '.')}';
    }

    return base;
  }
}

class PaymentURIParseException extends FormatException {}
