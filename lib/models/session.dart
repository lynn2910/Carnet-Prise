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

  final fishermen = IsarLinks<Fisherman>();
}
