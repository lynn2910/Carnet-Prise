import 'package:isar/isar.dart';

part "session_entry.g.dart";

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;

  late String localisation;
  late DateTime start_date;
  late DateTime end_date;
}
