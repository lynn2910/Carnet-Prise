import 'package:isar/isar.dart';
import 'fisherman.dart';
import 'package:uuid/uuid.dart';

part 'session.g.dart';

@collection
class Session {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: false)
  late String uuid;

  @Index(unique: false, replace: false, type: IndexType.value)
  String? spotName;

  DateTime? startDate;
  DateTime? endDate;
  DateTime? lastModified;

  List<Fisherman> fishermen = <Fisherman>[];

  Session() {
    uuid = const Uuid().v4();
    lastModified = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'spotName': spotName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'fishermen': fishermen.map((f) => f.toJson()).toList(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session()
      ..id = json['id'] as int
      ..uuid = json['uuid'] as String? ?? const Uuid().v4()
      ..spotName = json['spotName'] as String?
      ..startDate = json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null
      ..endDate = json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null
      ..lastModified = json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null
      ..fishermen =
          (json['fishermen'] as List<dynamic>?)
              ?.map((f) => Fisherman.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [];
  }
}
