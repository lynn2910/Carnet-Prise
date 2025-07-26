import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar_service.dart';
import 'package:isar/isar.dart';

import '../../models/catch.dart';

class FishermanRepository {
  final IsarService _isarService;

  FishermanRepository(this._isarService);

  //
  // CREATE
  //

  Future<int> createFisherman(Fisherman fisherman) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.fishermans.put(fisherman);
    });
  }

  //
  // READ
  //

  Future<Fisherman?> getFishermanById(int id) async {
    final isar = await _isarService.db;
    return await isar.fishermans.get(id);
  }

  //
  // UPDATE
  //

  Future<bool> updateFisherman(Fisherman fisherman) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      if (fisherman.id == Isar.autoIncrement ||
          await isar.fishermans.get(fisherman.id) == null) {
        return false;
      }
      return await isar.fishermans.put(fisherman) != 0;
    });
  }

  //
  // DELETE
  //

  Future<bool> deleteFisherman(int id) async {
    final isar = await _isarService.db;
    return await isar.writeTxn(() async {
      return await isar.fishermans.delete(id);
    });
  }

  //
  // HELPERS
  //

  Future<List<Catch>> getCatchesByFisherman(int fishermanId) async {
    final isar = await _isarService.db;
    final fisherman = await isar.fishermans.get(fishermanId);
    if (fisherman != null) {
      await fisherman.catches.load();
      return fisherman.catches.toList();
    }
    return [];
  }
}
