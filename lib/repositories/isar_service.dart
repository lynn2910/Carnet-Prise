import 'dart:convert';
import 'dart:io';

import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SessionRepository sessionRepository,
) async {
  final isar = await isarService.db;

  final sessions = await sessionRepository.getAllSessions();

  final allCatches = await isar.catchs.where().findAll();
  final catchesBySessionId = <int, List<Catch>>{};

  for (final singleCatch in allCatches) {
    if (singleCatch.session.value != null) {
      final sessionId = singleCatch.session.value!.id;
      if (!catchesBySessionId.containsKey(sessionId)) {
        catchesBySessionId[sessionId] = [];
      }
      catchesBySessionId[sessionId]!.add(singleCatch);
    }
  }

  final exportData = [];

  for (final session in sessions) {
    final sessionData = session.toJson();
    final sessionCatches = catchesBySessionId[session.id] ?? [];
    sessionData['catches'] = sessionCatches.map((c) => c.toJson()).toList();
    exportData.add(sessionData);
  }

  final jsonString = jsonEncode(exportData);

  final directory = await getApplicationDocumentsDirectory();
  final filePath =
      '${directory.path}/carnet_prise${DateTime.now().toIso8601String()}.json';
  final file = File(filePath);

  await file.writeAsString(jsonString);

  await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
}

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
      final session = Session.fromJson(sessionJson);
      session.id = Isar.autoIncrement;
      await isar.sessions.put(session);

      final catchesJson = sessionJson['catches'] as List<dynamic>;
      for (final catchJson in catchesJson) {
        final newCatch = Catch.fromJson(catchJson);
        newCatch.id = Isar.autoIncrement;
        newCatch.session.value = session;
        await isar.catchs.put(newCatch);
        await newCatch.session.save();
      }
    }
  });
}

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
