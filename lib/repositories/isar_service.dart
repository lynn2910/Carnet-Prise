import 'dart:convert';
import 'dart:io';

import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openIsar();
  }

  Future<Isar> openIsar() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [CatchSchema, SessionSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}

Future<void> exportData(
  IsarService isarService,
  SessionRepository sessionRepository, {
  Set<int>? selectedSessionIds,
}) async {
  try {
    final isar = await isarService.db;

    List<Session> sessions = await sessionRepository.getAllSessions();

    if (selectedSessionIds != null && selectedSessionIds.isNotEmpty) {
      sessions = sessions
          .where((s) => selectedSessionIds.contains(s.id))
          .toList();
    }

    if (sessions.isEmpty) {
      throw Exception("Aucune session à exporter");
    }

    final allCatches = await isar.catchs.where().findAll();

    final catchesBySessionId = <int, List<Catch>>{};
    for (final singleCatch in allCatches) {
      final sessionId = singleCatch.session.value?.id;
      if (sessionId != null) {
        catchesBySessionId.putIfAbsent(sessionId, () => []).add(singleCatch);
      }
    }

    final exportData = sessions.map((session) {
      final sessionData = session.toJson();
      final sessionCatches = catchesBySessionId[session.id] ?? [];
      sessionData['catches'] = sessionCatches.map((c) => c.toJson()).toList();
      return sessionData;
    }).toList();

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];

    final sessionCount = sessions.length;
    final fileName = 'carnet_prise_${sessionCount}_sessions_$timestamp.json';

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    final bytes = utf8.encode(jsonString);

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Exporter les sessions',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputPath == null) {
      return;
    }

    print(
      'Export réussi : ${sessions.length} session(s) exportée(s) vers $outputPath',
    );
  } catch (e) {
    print('Erreur lors de l\'export : $e');
    rethrow;
  }
}

Future<bool> exportDataWithFeedback(
  IsarService isarService,
  SessionRepository sessionRepository, {
  Set<int>? selectedSessionIds,
  Function(String message)? onSuccess,
  Function(String error)? onError,
}) async {
  try {
    final isar = await isarService.db;

    List<Session> sessions = await sessionRepository.getAllSessions();

    if (selectedSessionIds != null && selectedSessionIds.isNotEmpty) {
      sessions = sessions
          .where((s) => selectedSessionIds.contains(s.id))
          .toList();
    }

    if (sessions.isEmpty) {
      onError?.call("Aucune session à exporter");
      return false;
    }

    final allCatches = await isar.catchs.where().findAll();

    final catchesBySessionId = <int, List<Catch>>{};
    for (final singleCatch in allCatches) {
      final sessionId = singleCatch.session.value?.id;
      if (sessionId != null) {
        catchesBySessionId.putIfAbsent(sessionId, () => []).add(singleCatch);
      }
    }

    final exportData = sessions.map((session) {
      final sessionData = session.toJson();
      final sessionCatches = catchesBySessionId[session.id] ?? [];
      sessionData['catches'] = sessionCatches.map((c) => c.toJson()).toList();
      return sessionData;
    }).toList();

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];

    final sessionCount = sessions.length;
    final fileName = 'carnet_prise_${sessionCount}_sessions_$timestamp.json';

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final bytes = utf8.encode(jsonString);

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Exporter les sessions',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputPath == null) {
      return false;
    }

    onSuccess?.call('${sessions.length} session(s) exportée(s) avec succès');
    return true;
  } catch (e) {
    onError?.call('Erreur lors de l\'export : $e');
    return false;
  }
}
