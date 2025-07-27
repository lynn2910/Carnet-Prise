import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar_service.dart';
import 'package:isar/isar.dart';

class CatchRepository {
  final IsarService _isarService;

  CatchRepository(this._isarService);

  //
  // CREATE
  //

  Future<int> createCatch(
    int sessionId,
    int fishermanId,
    Catch newCatch,
  ) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      final fisherman = await isar.fishermans.get(fishermanId);
      if (fisherman == null) {
        throw Exception("Fisherman with ID $fishermanId not found");
      }
      newCatch.author.value = fisherman;

      final session = await isar.sessions.get(sessionId);
      newCatch.session.value = session;

      final catchId = await isar.catchs.put(newCatch);
      await newCatch.author.save();
      await newCatch.session.save();

      return catchId;
    });
  }

  //
  // READ
  //

  Future<Catch?> getCatchById(int id) async {
    final isar = await _isarService.db;
    return await isar.catchs.get(id);
  }

  Future<List<Catch>> getCatchesForSession(int sessionId) async {
    final isar = await _isarService.db;
    return await isar.catchs
        .filter()
        .session((q) => q.idEqualTo(sessionId))
        .findAll();
  }

  //
  // UPDATE
  //

  Future<bool> updateCatch(Catch updatedCatch) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      if (updatedCatch.id == Isar.autoIncrement ||
          await isar.catchs.get(updatedCatch.id) == null) {
        return false;
      }

      await updatedCatch.author.save();
      await updatedCatch.session.save();

      return await isar.catchs.put(updatedCatch) != 0;
    });
  }

  //
  // DELETE
  //

  Future<void> deleteAllCatches() async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.catchs.clear();
    });
  }

  //
  // HELPER
  //

  Future<List<String>> getAllFishTypes() async {
    return await getAllAvailableFishTypes(await _isarService.db);
  }
}
