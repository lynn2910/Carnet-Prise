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
      bool needsUpdate = false;
      try {
        final currentUuid = session.uuid;
        if (!_isValidUuid(currentUuid)) {
          needsUpdate = true;
        }
      } catch (e) {
        needsUpdate = true;
      }

      if (needsUpdate) {
        session.uuid = const Uuid().v4();
        await isar.sessions.put(session);
      }
    }
  });
}

bool _isValidUuid(String uuid) {
  final uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  return uuidRegex.hasMatch(uuid);
}

Future<void> migrateCatchesToUUID(IsarService isarService) async {
  final isar = await isarService.db;

  await isar.writeTxn(() async {
    final catches = await isar.catchs.where().findAll();

    for (final catch_ in catches) {
      bool needsUpdate = false;
      try {
        final currentUuid = catch_.uuid;
        if (!_isValidUuid(currentUuid)) {
          needsUpdate = true;
        }
      } catch (e) {
        needsUpdate = true;
      }

      if (needsUpdate) {
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
