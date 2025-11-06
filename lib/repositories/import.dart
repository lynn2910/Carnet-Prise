import 'dart:convert';
import 'dart:io';

import 'package:carnet_prise/models/session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';

import '../models/catch.dart';
import 'clean.dart';
import 'isar_service.dart';

Future<void> importData({required bool replaceExisting}) async {
  final isarService = IsarService();
  final isar = await isarService.db;

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result == null) {
    return;
  }

  final filePath = result.files.single.path!;
  final file = File(filePath);
  final jsonString = await file.readAsString();

  final List<dynamic> jsonData = jsonDecode(jsonString);

  if (replaceExisting) {
    await cleanDatabase(isarService);
  }

  await isar.writeTxn(() async {
    for (final sessionJson in jsonData) {
      final importedSession = Session.fromJson(sessionJson);

      final existingSession = await isar.sessions
          .filter()
          .uuidEqualTo(importedSession.uuid)
          .findFirst();

      if (existingSession != null && !replaceExisting) {
        await _overwriteSession(
          isar,
          existingSession,
          importedSession,
          sessionJson,
        );
      } else {
        importedSession.id = Isar.autoIncrement;
        await isar.sessions.put(importedSession);

        final catchesJson = sessionJson['catches'] as List<dynamic>;
        for (final catchJson in catchesJson) {
          final newCatch = Catch.fromJson(catchJson);
          newCatch.id = Isar.autoIncrement;
          newCatch.session.value = importedSession;
          await isar.catchs.put(newCatch);
          await newCatch.session.save();
        }
      }
    }
  });
}

/// Écrase une session existante et toutes ses prises associées
/// avec les données d'une session importée.
///
/// J'ai abusé sur la doc car j'en ai marre de la logique de DB, c'est long, chiant, et ca me fait perdre mes cheveux à 20 ans
Future<void> _overwriteSession(
  Isar isar,
  Session existingSession,
  Session importedSession,
  Map<String, dynamic> sessionJson,
) async {
  // 1. Écraser les propriétés de la session existante
  existingSession.spotName = importedSession.spotName;
  existingSession.startDate = importedSession.startDate;
  existingSession.endDate = importedSession.endDate;
  // On garde la date de modification importée pour la cohérence
  existingSession.lastModified = importedSession.lastModified;
  existingSession.fishermen = importedSession.fishermen; // Remplace la liste

  await isar.sessions.put(existingSession);

  // 2. Supprimer TOUTES les anciennes prises (catches) liées à cette session
  final existingCatches = await isar.catchs
      .filter()
      .session((q) => q.idEqualTo(existingSession.id))
      .findAll();

  await isar.catchs.deleteAll(existingCatches.map((c) => c.id).toList());

  final importedCatchesJson = sessionJson['catches'] as List<dynamic>;
  for (final catchJson in importedCatchesJson) {
    final newCatch = Catch.fromJson(catchJson);
    newCatch.id = Isar.autoIncrement;
    newCatch.session.value = existingSession;
    await isar.catchs.put(newCatch);
    await newCatch.session.save();
  }
}
