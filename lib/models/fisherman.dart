import 'package:isar/isar.dart';

import 'catch.dart';

part "fisherman.g.dart";

@embedded
class Fisherman {
  String? name;
  String? spotNumber;

  @ignore
  List<Catch> catches = [];

  Fisherman();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'spotNumber': spotNumber,
      'catches': catches.map((c) => c.toJson()).toList(),
    };
  }

  factory Fisherman.fromJson(Map<String, dynamic> json) {
    return Fisherman()
      ..name = json['name'] as String?
      ..spotNumber = json['spotNumber'] as String?
      ..catches =
          (json['catches'] as List<dynamic>?)
              ?.map((c) => Catch.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [];
  }
}
