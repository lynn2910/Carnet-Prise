import 'package:flutter/cupertino.dart';

import '../../models/session.dart';

class SessionStatisticsResume extends StatefulWidget {
  final Session? session;

  const SessionStatisticsResume({super.key, required this.session});

  @override
  State<SessionStatisticsResume> createState() =>
      _SessionStatisticsResumeState();
}

class _SessionStatisticsResumeState extends State<SessionStatisticsResume> {
  @override
  Widget build(BuildContext context) {
    return Text("résumé");
  }
}
