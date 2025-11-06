import 'package:carnet_prise/models/session.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../widgets/catches/catch_item.dart';

part "catch.g.dart";

@collection
class Catch {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: false)
  late String uuid;

  @Enumerated(EnumType.name)
  FishType? fishType;
  @Enumerated(EnumType.name)
  Accident? accident;

  String? otherFishType;
  double? weight;
  String? fishermenName;
  DateTime? catchDate;
  String? annotations;

  final session = IsarLink<Session>();

  Catch() {
    uuid = const Uuid().v4();
  }

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
          throw UnimplementedError("You shouldn't have this value");
      }
    }
    text += " le ";
    text += DateFormat("dd/MM/y à HH:mm").format(catchDate!);
    if (spotNumber != null) {
      text += " au poste $spotNumber";
    }

    if (annotations != null) {
      text += "(notes: $annotations)";
    }
    return text;
  }

  String shareSmall({bool showAuthor = false}) {
    String text = "";

    text += DateFormat("dd/MM/y HH:mm").format(catchDate!);
    if (showAuthor) {
      text += " ($fishermenName)";
    }
    text += ": ";

    if (accident == Accident.none) {
      text += getCatchType(this);
    } else {
      text += accident != null ? getAccidentName(accident!) : 'ERROR';
    }

    return text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'fishType': fishType?.name,
      'accident': accident?.name,
      'otherFishType': otherFishType,
      'weight': weight,
      'fishermenName': fishermenName,
      'catchDate': catchDate?.toIso8601String(),
      'annotations': annotations,
    };
  }

  factory Catch.fromJson(Map<String, dynamic> json) {
    return Catch()
      ..id = json['id'] as int
      ..uuid = json['uuid'] as String? ?? const Uuid().v4()
      ..fishType = json['fishType'] != null
          ? FishType.values.byName(json['fishType'])
          : null
      ..accident = json['accident'] != null
          ? Accident.values.byName(json['accident'])
          : null
      ..annotations = json['annotations'] as String?
      ..otherFishType = json['otherFishType'] as String?
      ..weight = json['weight'] as double?
      ..fishermenName = json['fishermenName'] as String?
      ..catchDate = json['catchDate'] != null
          ? DateTime.parse(json['catchDate'])
          : null;
  }
}

enum Accident {
  /// Décrochage
  snaggedLine,

  /// Cassage de la ligne
  lineBreak,
  none,
}

String getAccidentName(Accident accident) {
  switch (accident) {
    case Accident.snaggedLine:
      return "Décrochage";
    case Accident.lineBreak:
      return "Cassée";
    default:
      return "Inconnu";
  }
}

enum FishType { carp, other }

List<String> getPredefinedFishTypes() {
  return FishType.values.map((e) {
    switch (e) {
      case FishType.carp:
        return 'Carpe';
      case FishType.other:
        return 'Autre';
    }
  }).toList();
}

String getFishTypeName(FishType fishType) {
  switch (fishType) {
    case FishType.carp:
      return 'Carpe';
    case FishType.other:
      return 'Autre';
  }
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
  allTypes.addAll(customOthers..sort());

  return allTypes.toList();
}
