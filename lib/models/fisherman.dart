import 'package:isar/isar.dart';

import 'catch.dart';

part "fisherman.g.dart";

@embedded
class Fisherman {
  String? name;
  String? spotNumber;

  @ignore
  List<Catch> catches = [];
}
