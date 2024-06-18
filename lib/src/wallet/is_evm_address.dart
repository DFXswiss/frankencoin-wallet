extension IsEthereumAddress on String {
  bool get isEthereumAddress =>
      RegExp(r'^(0x)?[0-9a-f]{40}$', caseSensitive: false).hasMatch(this);
}
