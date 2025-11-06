import 'dart:ui';

import 'package:isar/isar.dart';

import 'catch.dart';

part "fisherman.g.dart";

@embedded
class Fisherman {
  String? name;
  String? spotNumber;
  int? colorSeed;

  @ignore
  List<Catch> catches = [];

  Fisherman();

  Color? getColor() {
    return colorSeed != null ? Color(colorSeed!) : null;
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'spotNumber': spotNumber, 'colorSeed': colorSeed};
  }

  factory Fisherman.fromJson(Map<String, dynamic> json) {
    return Fisherman()
      ..name = json['name'] as String?
      ..spotNumber = json['spotNumber'] as String?
      ..colorSeed = json['colorSeed'] as int?;
  }
}
