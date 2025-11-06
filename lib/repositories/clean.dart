import 'package:shared_preferences/shared_preferences.dart';

import 'isar_service.dart';
import '../models/catch.dart';
import '../models/session.dart';

Future<void> cleanDatabase(
  IsarService isarService, {
  bool? resetPreferences = false,
}) async {
  final isar = await isarService.db;

  await isar.writeTxn(() async {
    await isar.catchs.clear();
    await isar.sessions.clear();
  });

  if (resetPreferences ?? false) {
    final instance = await SharedPreferences.getInstance();
    instance.clear();
  }
}
