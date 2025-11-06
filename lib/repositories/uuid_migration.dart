import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/models/catch.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'isar_service.dart';

Future<void> migrateSessionsToUUID(IsarService isarService) async {
  final isar = await isarService.db;

  await isar.writeTxn(() async {
    final sessions = await isar.sessions.where().findAll();

    for (final session in sessions) {
      if (session.uuid.isEmpty) {
        session.uuid = const Uuid().v4();
        await isar.sessions.put(session);
      }
    }
  });
}

Future<void> migrateCatchesToUUID(IsarService isarService) async {
  final isar = await isarService.db;

  await isar.writeTxn(() async {
    final catches = await isar.catchs.where().findAll();

    for (final catch_ in catches) {
      if (catch_.uuid.isEmpty) {
        catch_.uuid = const Uuid().v4();
        await isar.catchs.put(catch_);
      }
    }
  });
}

Future<void> migrateAllToUUID(IsarService isarService) async {
  await migrateSessionsToUUID(isarService);
  await migrateCatchesToUUID(isarService);
}
