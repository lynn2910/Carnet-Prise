import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openIsar();
  }

  Future<Isar> openIsar() async {
    if (Isar.instanceNames.isNotEmpty) {
      return Future.value(Isar.getInstance());
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [SessionSchema, FishermanSchema, CatchSchema],
      directory: dir.path,
      inspector: true,
    );
    return isar;
  }
}
