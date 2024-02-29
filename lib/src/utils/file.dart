import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;

const ivEncodedStringLength = 12;

void write(
    {required String path, required String password, required String data}) {
  final encrypted = encode(password: password, data: data);
  final f = File(path);
  f.writeAsStringSync(encrypted);
}

String read({required String path, required String password}) {
  final file = File(path);

  if (!file.existsSync()) {
    file.createSync();
  }

  final encrypted = file.readAsStringSync();

  return decode(password: password, data: encrypted);
}

String generateKey() {
  final key = encrypt.Key.fromSecureRandom(512);
  final iv = encrypt.IV.fromSecureRandom(8);

  return key.base64 + iv.base64;
}

(String, String) _extractKeys(String password) {
  final key = password.substring(0, password.length - ivEncodedStringLength);
  final iv = password.substring(password.length - ivEncodedStringLength);

  return (key, iv);
}

String encode({required String password, required String data}) {
  final keys = _extractKeys(password);
  final key = encrypt.Key.fromBase64(keys.$1);
  final iv = encrypt.IV.fromBase64(keys.$2);

  final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));
  final encrypted = encrypter.encrypt(data, iv: iv);

  return encrypted.base64;
}

String decode({required String password, required String data}) {
  final keys = _extractKeys(password);
  final key = encrypt.Key.fromBase64(keys.$1);
  final iv = encrypt.IV.fromBase64(keys.$2);
  final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));
  final encrypted = encrypter.decrypt64(data, iv: iv);

  return encrypted;
}
