import 'dart:convert';
import 'dart:io';

import 'package:carnet_prise/models/session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';

import '../models/catch.dart';
import '../models/fisherman.dart';
import 'isar_service.dart';

Future<void> importData({
  required bool replaceExisting,
  MergeStrategy mergeStrategy = MergeStrategy.keepNewer,
}) async {
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
        await _mergeSession(
          isar,
          existingSession,
          importedSession,
          sessionJson,
          mergeStrategy,
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

// Future<void> _mergeSession(
//   Isar isar,
//   Session existingSession,
//   Session importedSession,
//   Map<String, dynamic> sessionJson,
//   MergeStrategy strategy,
// ) async {
//   bool sessionUpdated = false;
//
//   switch (strategy) {
//     case MergeStrategy.keepNewer:
//       final existingDate = existingSession.endDate ?? existingSession.startDate;
//       final importedDate = importedSession.endDate ?? importedSession.startDate;
//
//       if (importedDate != null && existingDate != null) {
//         if (importedDate.isAfter(existingDate)) {
//           existingSession.spotName = importedSession.spotName;
//           existingSession.startDate = importedSession.startDate;
//           existingSession.endDate = importedSession.endDate;
//           sessionUpdated = true;
//         }
//       }
//       break;
//
//     case MergeStrategy.keepExisting:
//       break;
//
//     case MergeStrategy.overwrite:
//       existingSession.spotName = importedSession.spotName;
//       existingSession.startDate = importedSession.startDate;
//       existingSession.endDate = importedSession.endDate;
//       sessionUpdated = true;
//       break;
//   }
//
//   final mergedFishermen = _mergeFishermen(
//     existingSession.fishermen,
//     importedSession.fishermen,
//   );
//
//   if (mergedFishermen.length != existingSession.fishermen.length ||
//       !_areFishermenEqual(existingSession.fishermen, mergedFishermen)) {
//     existingSession.fishermen = mergedFishermen;
//     sessionUpdated = true;
//   }
//
//   if (sessionUpdated) {
//     await isar.sessions.put(existingSession);
//   }
//
//   await _mergeCatches(
//     isar,
//     existingSession,
//     sessionJson['catches'] as List<dynamic>,
//     strategy,
//   );
// }

Future<void> _mergeSession(
  Isar isar,
  Session existingSession,
  Session importedSession,
  Map<String, dynamic> sessionJson,
  MergeStrategy strategy,
) async {
  bool sessionUpdated = false;

  switch (strategy) {
    case MergeStrategy.keepNewer:
      // Utiliser lastModified pour déterminer quelle version est plus récente
      final existingModified = existingSession.lastModified;
      final importedModified = importedSession.lastModified;

      if (importedModified != null && existingModified != null) {
        if (importedModified.isAfter(existingModified)) {
          // Les données importées sont plus récentes
          existingSession.spotName = importedSession.spotName;
          existingSession.startDate = importedSession.startDate;
          existingSession.endDate = importedSession.endDate;
          existingSession.lastModified = importedSession.lastModified;
          sessionUpdated = true;
        }
      } else if (importedModified != null) {
        // Seulement l'importée a une date
        existingSession.spotName = importedSession.spotName;
        existingSession.startDate = importedSession.startDate;
        existingSession.endDate = importedSession.endDate;
        existingSession.lastModified = importedSession.lastModified;
        sessionUpdated = true;
      }
      break;

    case MergeStrategy.keepExisting:
      // Ne rien faire
      break;

    case MergeStrategy.overwrite:
      existingSession.spotName = importedSession.spotName;
      existingSession.startDate = importedSession.startDate;
      existingSession.endDate = importedSession.endDate;
      existingSession.lastModified = DateTime.now();
      sessionUpdated = true;
      break;
  }

  // Le reste du code de merge...
  final mergedFishermen = _mergeFishermen(
    existingSession.fishermen,
    importedSession.fishermen,
  );

  if (mergedFishermen.length != existingSession.fishermen.length ||
      !_areFishermenEqual(existingSession.fishermen, mergedFishermen)) {
    existingSession.fishermen = mergedFishermen;
    existingSession.lastModified = DateTime.now();
    sessionUpdated = true;
  }

  if (sessionUpdated) {
    await isar.sessions.put(existingSession);
  }

  await _mergeCatches(
    isar,
    existingSession,
    sessionJson['catches'] as List<dynamic>,
    strategy,
  );
}

List<Fisherman> _mergeFishermen(
  List<Fisherman> existing,
  List<Fisherman> imported,
) {
  final mergedMap = <String, Fisherman>{};

  // Ajouter tous les fishermen existants
  for (final fisherman in existing) {
    if (fisherman.name != null) {
      mergedMap[fisherman.name!.toLowerCase()] = fisherman;
    }
  }

  // Merger avec les fishermen importés
  for (final fisherman in imported) {
    if (fisherman.name != null) {
      final key = fisherman.name!.toLowerCase();

      if (mergedMap.containsKey(key)) {
        // Fisherman existe déjà, mettre à jour si nécessaire
        final existing = mergedMap[key]!;

        // Garder le spot number s'il n'existait pas
        if (existing.spotNumber == null && fisherman.spotNumber != null) {
          existing.spotNumber = fisherman.spotNumber;
        }

        // Garder la couleur si elle n'existait pas
        if (existing.colorSeed == null && fisherman.colorSeed != null) {
          existing.colorSeed = fisherman.colorSeed;
        }
      } else {
        // Nouveau fisherman
        mergedMap[key] = fisherman;
      }
    }
  }

  return mergedMap.values.toList();
}

bool _areFishermenEqual(List<Fisherman> a, List<Fisherman> b) {
  if (a.length != b.length) return false;

  final aNames = a.map((f) => f.name?.toLowerCase()).toSet();
  final bNames = b.map((f) => f.name?.toLowerCase()).toSet();

  return aNames.difference(bNames).isEmpty;
}

Future<void> _mergeCatches(
  Isar isar,
  Session existingSession,
  List<dynamic> importedCatchesJson,
  MergeStrategy strategy,
) async {
  final existingCatches = await isar.catchs
      .filter()
      .session((q) => q.idEqualTo(existingSession.id))
      .findAll();

  final existingCatchesMap = <String, Catch>{};
  for (final catch_ in existingCatches) {
    existingCatchesMap[catch_.uuid] = catch_;
  }

  for (final catchJson in importedCatchesJson) {
    final importedCatch = Catch.fromJson(catchJson);

    if (existingCatchesMap.containsKey(importedCatch.uuid)) {
      final existingCatch = existingCatchesMap[importedCatch.uuid]!;

      switch (strategy) {
        case MergeStrategy.keepNewer:
          bool needsUpdate = false;

          if (importedCatch.annotations != null &&
              (existingCatch.annotations == null ||
                  importedCatch.annotations!.length >
                      existingCatch.annotations!.length)) {
            existingCatch.annotations = importedCatch.annotations;
            needsUpdate = true;
          }

          if (importedCatch.weight != null &&
              (existingCatch.weight == null ||
                  importedCatch.weight != existingCatch.weight)) {
            existingCatch.weight = importedCatch.weight;
            needsUpdate = true;
          }

          if (importedCatch.fishType != null &&
              existingCatch.fishType == null) {
            existingCatch.fishType = importedCatch.fishType;
            needsUpdate = true;
          }

          if (importedCatch.otherFishType != null &&
              existingCatch.otherFishType == null) {
            existingCatch.otherFishType = importedCatch.otherFishType;
            needsUpdate = true;
          }

          if (needsUpdate) {
            await isar.catchs.put(existingCatch);
          }
          break;

        case MergeStrategy.keepExisting:
          break;

        case MergeStrategy.overwrite:
          existingCatch.fishType = importedCatch.fishType;
          existingCatch.accident = importedCatch.accident;
          existingCatch.otherFishType = importedCatch.otherFishType;
          existingCatch.weight = importedCatch.weight;
          existingCatch.annotations = importedCatch.annotations;
          existingCatch.fishermenName = importedCatch.fishermenName;
          existingCatch.catchDate = importedCatch.catchDate;
          await isar.catchs.put(existingCatch);
          break;
      }
    } else {
      importedCatch.id = Isar.autoIncrement;
      importedCatch.session.value = existingSession;
      await isar.catchs.put(importedCatch);
      await importedCatch.session.save();
    }
  }
}

enum MergeStrategy { keepNewer, keepExisting, overwrite }
