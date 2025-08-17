import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/pages/statistics/single_session_statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/isar/session_repository.dart';

class SessionStatisticsFisherman extends StatefulWidget {
  final Session? session;

  const SessionStatisticsFisherman({super.key, required this.session});

  @override
  State<SessionStatisticsFisherman> createState() =>
      _SessionStatisticsFishermanState();
}

class _SessionStatisticsFishermanState
    extends State<SessionStatisticsFisherman> {
  @override
  Widget build(BuildContext context) {
    return Text("pêcheur");
  }
}
