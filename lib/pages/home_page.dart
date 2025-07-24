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
  late SessionRepository _sessionRepository;
  List<Session> _sessions = [];
  String _username = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadSessions();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString("username");
    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        _username = savedUsername;
      });
    }
  }

  Future<void> _loadSessions() async {
    final sessions = await _sessionRepository.getAllSessions();
    setState(() {
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
            // Number of sessions
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
              child: Text(
                "Vous avez ${_sessions.length} sessions",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // Sessions
            Expanded(child: SessionList(sessions: _sessions)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed("create_session");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
