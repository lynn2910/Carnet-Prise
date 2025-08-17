import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/sessions/session_list.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  SessionRepository? _sessionRepository;

  bool _sessionsLoaded = false;
  List<Session> _sessions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionRepository == null) {
      _sessionRepository = Provider.of<SessionRepository>(context);
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    if (_sessionRepository == null) return;

    setState(() {
      _sessionsLoaded = false;
    });

    final sessions = await _sessionRepository!.getAllSessions();
    if (!mounted) {
      setState(() {
        _sessionsLoaded = false;
      });
      return;
    }

    sessions.sort((a, b) {
      return b.id.compareTo(a.id);
    });

    setState(() {
      _sessions = sessions;
      _sessionsLoaded = true;
    });
  }

  void _onItemClick(Session session) {
    context.pushNamed(
      "session_statistics",
      pathParameters: {"session_id": session.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques")),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_sessionsLoaded)
                    Center(child: LinearProgressIndicator()),

                  const SizedBox(height: 30),

                  if (_sessionsLoaded)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
                      child: Text(
                        "Vous avez ${_sessions.length} sessions",
                        style: theme.textTheme.titleMedium!,
                      ),
                    ),

                  if (_sessionsLoaded)
                    _sessions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Text(
                                "Aucune session enregistrée.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : SessionList(
                            sessions: _sessions,
                            onItemClick: _onItemClick,
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
