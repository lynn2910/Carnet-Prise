import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/pages/sessions/catch/add_catch_screen.dart';
import 'package:carnet_prise/repositories/isar_service.dart';
import 'package:isar/isar.dart';

class SessionRepository {
  final IsarService _isarService;

  SessionRepository(this._isarService);

  //
  // CREATE
  //

  Future<int> createSession(Session session) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.sessions.put(session);
    });
  }

  //
  // READ
  //

  Future<Session?> getSessionById(int id) async {
    final isar = await _isarService.db;
    final session = await isar.sessions.get(id);

    if (session == null) return null;

    final catches = await isar.catchs
        .filter()
        .session((q) => q.idEqualTo(id))
        .findAll();

    Map<String, Fisherman> fishermen = {};
    for (var fisherman in session.fishermen) {
      if (fisherman.name == null) continue;

      fisherman.catches = fisherman.catches.toList(growable: true);
      fishermen[cleanString(fisherman.name!)] = fisherman;
    }

    for (var singleCatch in catches) {
      if (singleCatch.fishermenName == null) continue;

      final fishermanName = cleanString(singleCatch.fishermenName!);
      if (fishermen[fishermanName] == null) continue;

      fishermen[fishermanName]!.catches.add(singleCatch);
    }

    return session;
  }

  Future<List<Session>> getAllSessions() async {
    final isar = await _isarService.db;
    return await isar.sessions.where().sortByEndDateDesc().findAll();
  }

  //
  // UPDATE
  //

  Future<bool> updateSession(Session session) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      if (session.id == Isar.autoIncrement ||
          await isar.sessions.get(session.id) == null) {
        return false;
      }
      return await isar.sessions.put(session) != 0;
    });
  }

  //
  // DELETE
  //

  Future<bool> deleteSession(int id) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.sessions.delete(id);
    });
  }

  Future<void> deleteAllSessions() async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.sessions.clear();
    });
  }

  //
  // HELPERS
  //

  /// Add or create a new fisherman to the given session
  Future<void> addOrUpdateFishermanToSession(
    int sessionId,
    Fisherman fisherman,
  ) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final session = await isar.sessions.get(sessionId);
      if (session != null) {
        Fisherman? alreadyExists = session.fishermen.firstWhereOrNull(
          (f) =>
              cleanString(f.name ?? '0') == cleanString(fisherman.name ?? '1'),
        );

        if (alreadyExists != null) {
          alreadyExists.spotNumber = fisherman.spotNumber;
        } else {
          session.fishermen = session.fishermen.toList(growable: true);
          session.fishermen.add(fisherman);
        }

        await isar.sessions.put(session);
      }
    });
  }

  /// Remove a fisherman from the given session, if the given fisherman ID exist in the session
  ///
  /// If no fisherman is in the list, it'll be ignored
  Future<void> removeFishermanFromSession(
    int sessionId,
    String fishermanName,
  ) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final session = await isar.sessions.get(sessionId);
      if (session != null) {
        session.fishermen.removeWhere(
          (f) =>
              f.name != null &&
              cleanString(f.name!) == cleanString(fishermanName),
        );
        await isar.sessions.put(session);
      }
    });
  }

  Future<List<Catch>> getFishermanCatches(
    int sessionId,
    String fishermenName,
  ) async {
    final isar = await _isarService.db;

    return await isar.catchs
        .filter()
        .fishermenNameEqualTo(fishermenName, caseSensitive: false)
        .findAll();
  }

  Future<Fisherman?> getFishermanByName(int sessionId, String name) async {
    final session = await getSessionById(sessionId);
    if (session == null) return null;

    return session.fishermen.firstWhereOrNull(
      (f) => f.name != null && cleanString(f.name!) == cleanString(name),
    );
  }
}

String cleanString(String s) {
  return s.toLowerCase().trim();
}
