import 'package:bip39/src/wordlists/english.dart' as wordlist;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

bool isSeedQr(String seedQRBytes) =>
    seedQRBytes.length == 48 || seedQRBytes.length == 96;

bool isCompactSeedQr(List<int> rawByteData) =>
    hex.encode(rawByteData).startsWith('410') ||
    hex.encode(rawByteData).startsWith('420');

String getSeedFromSeedQr(String seedQRBytes) {
  if (!isSeedQr(seedQRBytes)) {
    throw InvalidSeedQRException(seedQRBytes.length.toString());
  }

  final indexes = RegExp(r'.{1,4}')
      .allMatches(seedQRBytes)
      .map((e) => int.parse(e.group(0)!));
  return indexes.map((e) => wordlist.WORDLIST[e]).join(" ");
}

String getSeedFromCompactSeedQr(List<int> rawByteData) {
  if (!isCompactSeedQr(rawByteData)) {
    throw InvalidSeedQRException(rawByteData.length.toString());
  }

  final is12WordSeed = hex.encode(rawByteData).startsWith('410');
  final byteLength = is12WordSeed ? 19 : 34;

  final hexRaw = hex.encode(rawByteData.sublist(0, byteLength));

  final binaryLength = is12WordSeed ? 132 : 264;
  final truncateAt = is12WordSeed ? 3 : 1;
  final checksumLimit = is12WordSeed ? 1 : 2;

  final hexShort = hexRaw.substring(3, hexRaw.length - truncateAt);

  final checksum = hex
      .encode(sha256.convert(hex.decode(hexShort)).bytes)
      .substring(0, checksumLimit);

  final seedQRBytes = BigInt.parse("$hexShort$checksum", radix: 16)
      .toRadixString(2)
      .padLeft(binaryLength, "0");

  final indexes = RegExp(r'.{1,11}')
      .allMatches(seedQRBytes)
      .map((e) => int.parse(e.group(0)!, radix: 2));
  return indexes.map((e) => wordlist.WORDLIST[e]).join(" ");
}

class InvalidSeedQRException extends FormatException {
  InvalidSeedQRException([super.message]);
}
