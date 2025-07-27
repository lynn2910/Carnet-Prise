import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
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
    return await isar.sessions.get(id);
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
  Future<int?> addFishermanToSession(int sessionId, Fisherman fisherman) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      final session = await isar.sessions.get(sessionId);
      if (session != null) {
        final existingFisherman = await isar.fishermans.get(fisherman.id);
        if (existingFisherman != null) {
          session.fishermen.add(existingFisherman);
          await session.fishermen.save();
          return existingFisherman.id;
        } else {
          final fishermanId = await isar.fishermans.put(fisherman);
          fisherman.id = fishermanId;
          session.fishermen.add(fisherman);
          await session.fishermen.save();
          return fishermanId;
        }
      }
    });
  }

  /// Remove a fisherman from the given session, if the given fisherman ID exist in the session
  ///
  /// If no fisherman is in the list, it'll be ignored
  Future<void> removeFishermanFromSession(
    int sessionId,
    int fishermanId,
  ) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final session = await isar.sessions.get(sessionId);
      if (session != null) {
        session.fishermen.removeWhere((f) => f.id == fishermanId);
        await session.fishermen.save();
      }
    });
  }
}
