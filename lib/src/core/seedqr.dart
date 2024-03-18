import 'package:bip39/src/wordlists/english.dart' as wordlist;

String getSeedFromSeedQr(String seedQRBytes) {
  if (seedQRBytes.length != 48 && seedQRBytes.length != 69) {
    throw Exception("Invalid SeedQR");
  }

  final indexes = RegExp(r'.{1,4}').allMatches(seedQRBytes).map((e) => int.parse(e.group(0)!));
  return indexes.map((e) => wordlist.WORDLIST[e]).join(" ");
}

String getSeedFromCompactSeedQr(List<int> seedQRBytes) {
  final seedQRBinary = seedQRBytes.map((e) => e.toString()).join();

  print(seedQRBytes.length);
  print(seedQRBinary);
  print(seedQRBinary.length);
  // final indexes = RegExp(r'.{1,11}').allMatches(seedQRBinary).map((e) => int.parse(e.group(0)!, radix: 2));
  //
  // print(indexes);
  //
  // print(indexes.map((e) => wordlist.WORDLIST[e]).join(" "));
  return "";
}
