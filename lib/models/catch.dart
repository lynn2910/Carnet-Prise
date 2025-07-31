import 'package:carnet_prise/models/session.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../widgets/catches/catch_item.dart';
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

  String shareSingle(String? spotNumber) {
    String text;
    if (accident == Accident.none) {
      text = "$fishermenName a pêché un(e) ";
      text += getCatchType(this);
      text += " de ";
      text += weight.toString();
      text += " Kg";
    } else {
      text = "$fishermenName ";
      switch (accident) {
        case Accident.lineBreak:
          text += "a cassé sa ligne";
        case Accident.snaggedLine:
          text += "a eu une touche, qui a malheureusement décroché";
        default:
          throw UnimplementedError("You should have this value");
      }
    }
    text += " le ";
    text += DateFormat("dd/MM/y à HH:mm").format(catchDate!);
    if (spotNumber != null) {
      text += " au poste $spotNumber";
    }
    return text;
  }

  String shareSmall() {
    String text = "($fishermenName) ";

    if (accident == Accident.none) {
      text += getCatchType(this);
    } else {
      switch (accident) {
        case Accident.lineBreak:
          text += "Ligne cassée";
        case Accident.snaggedLine:
          text += "Décroché";
        default:
          throw UnimplementedError("You should have this value");
      }
    }
    text += ": ";
    text += DateFormat("dd/MM/y à HH:mm").format(catchDate!);

    return text;
  }
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
