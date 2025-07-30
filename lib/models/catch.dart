import 'package:carnet_prise/models/session.dart';
import 'package:isar/isar.dart';

import 'fisherman.dart';

part "catch.g.dart";

@collection
class Catch {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  FishType? fishType;
  @Enumerated(EnumType.name)
  Accident? accident;

  String? otherFishType;

  double? weight;

  String? fishermenName;

  DateTime? catchDate;

  final session = IsarLink<Session>();
}

enum Accident {
  /// Décrochage
  snaggedLine,

  /// Cassage de la ligne
  lineBreak,
  none,
}

enum FishType { commonCarp, mirrorCarp, grassCarp, other }

List<String> getPredefinedFishTypes() {
  return FishType.values.map((e) {
    switch (e) {
      case FishType.commonCarp:
        return 'Carpe commune';
      case FishType.mirrorCarp:
        return 'Carpe miroir';
      case FishType.grassCarp:
        return 'Carpe amour';
      case FishType.other:
        return 'Autre';
    }
  }).toList();
}

Future<List<String>> _getCustomOtherFishTypes(Isar isar) async {
  final customTypes = await isar.catchs
      .filter()
      .fishTypeEqualTo(FishType.other)
      .otherFishTypeIsNotNull()
      .otherFishTypeIsNotEmpty()
      .distinctByOtherFishType(caseSensitive: false)
      .otherFishTypeProperty()
      .findAll();

  return customTypes.whereType<String>().toList();
}

Future<List<String>> getAllAvailableFishTypes(Isar isar) async {
  List<String> predefined = getPredefinedFishTypes()
      .where((s) => s.toLowerCase() != 'autre')
      .toList();

  List<String> customOthers = await _getCustomOtherFishTypes(isar);

  Set<String> allTypes = Set.from(predefined);
  allTypes.addAll(customOthers);

  return allTypes.toList()..sort();
}
