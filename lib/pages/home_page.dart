import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/session_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionRepository? _sessionRepository;
  List<Session> _sessions = [];
  String _username = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionRepository == null) {
      _sessionRepository = Provider.of<SessionRepository>(context);
      _loadSessions();
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString("username");
    if (!mounted) return;

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        _username = savedUsername;
      });
    }
  }

  Future<void> _loadSessions() async {
    if (_sessionRepository == null) return;

    final sessions = await _sessionRepository!.getAllSessions();
    if (!mounted) return;

    sessions.sort((a, b) {
      return b.id.compareTo(a.id);
    });

    setState(() {
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text(
                        "Bonjour, $_username !",
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Number of sessions indicator
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                    child: Text(
                      "Vous avez ${_sessions.length} sessions",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Sessions
                  _sessions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Text(
                              "Aucune session enregistrée.\nAppuyez sur '+' pour en créer une.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        )
                      : SessionList(sessions: _sessions),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamed("create_session");
          if (!mounted) return;
          _loadSessions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
