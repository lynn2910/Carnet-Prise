import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/widgets/statistics/session_statistics_fishermans.dart';
import 'package:carnet_prise/widgets/statistics/session_statistics_resume.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/isar/session_repository.dart';

class SingleSessionStatistics extends StatefulWidget {
  final int sessionId;

  const SingleSessionStatistics({super.key, required this.sessionId});

  @override
  State<SingleSessionStatistics> createState() =>
      _SingleSessionStatisticsState();
}

class _SingleSessionStatisticsState extends State<SingleSessionStatistics> {
  Session? _session;
  late SessionRepository _sessionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository = Provider.of<SessionRepository>(context);
    _loadSessionDetails();
  }

  Future<void> _loadSessionDetails() async {
    final session = await _sessionRepository.getSessionById(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _session = session;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return Center(child: CircularProgressIndicator());
    }

    var theme = Theme.of(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(140.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Session n°${_session?.id}: ${_session?.spotName ?? "Lieu inconnu"}",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const TabBar(
                      tabs: [
                        Tab(text: "Résumé"),
                        Tab(text: "Pêcheurs"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SessionStatisticsResume(session: _session),
            SessionStatisticsFisherman(session: _session),
          ],
        ),
      ),
    );
  }
}
