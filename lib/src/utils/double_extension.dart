import 'dart:math';

extension TruncateDoubles on double {
  double truncateTo(int fractionalDigits) =>
      (this * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);

  String toStringTruncated(int fractionalDigits) =>
      truncateTo(fractionalDigits).toStringAsFixed(fractionalDigits);
}
