import 'package:isar/isar.dart';

import 'fisherman.dart';

part "session.g.dart";

@collection
class Session {
  Id id = Isar.autoIncrement;

  @Index(unique: false, replace: false, type: IndexType.value)
  String? spotName;

  DateTime? startDate;
  DateTime? endDate;

  List<Fisherman> fishermen = <Fisherman>[];

  Session();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spotName': spotName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'fishermen': fishermen.map((f) => f.toJson()).toList(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session()
      ..id = json['id'] as int
      ..spotName = json['spotName'] as String?
      ..startDate = json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null
      ..endDate = json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null
      ..fishermen =
          (json['fishermen'] as List<dynamic>?)
              ?.map((f) => Fisherman.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [];
  }
}
