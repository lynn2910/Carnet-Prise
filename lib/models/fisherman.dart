import 'package:carnet_prise/models/session.dart';
import 'package:isar/isar.dart';

import 'catch.dart';

part "fisherman.g.dart";

@collection
class Fisherman {
  Id id = Isar.autoIncrement;

  @Index(unique: false, replace: false, type: IndexType.value)
  String? name;

  String? spotNumber;

  @Backlink(to: 'fishermen')
  final sessions = IsarLinks<Session>();

  final catches = IsarLinks<Catch>();
}
