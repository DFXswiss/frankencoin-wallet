import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection(Isar isar) async {
  getIt.registerSingleton(isar);
  getIt.registerSingleton(const FlutterSecureStorage());
}
