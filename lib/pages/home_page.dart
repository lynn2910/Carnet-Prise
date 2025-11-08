import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/session_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/isar_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionRepository? _sessionRepository;
  bool _sessionsLoaded = false;
  List<Session> _sessions = [];
  String _username = "";

  // Mode sélection
  bool _isSelectionMode = false;
  final Set<int> _selectedSessionIds = {};

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
    if (_isSelectionMode) {
      _toggleSelection(session.id);
    } else {
      context.push('/session/${session.id}');
    }
  }

  void _onItemLongPress(Session session) {
    setState(() {
      _isSelectionMode = true;
      _selectedSessionIds.add(session.id);
    });
  }

  void _toggleSelection(int sessionId) {
    setState(() {
      if (_selectedSessionIds.contains(sessionId)) {
        _selectedSessionIds.remove(sessionId);
        if (_selectedSessionIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedSessionIds.add(sessionId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedSessionIds.clear();
    });
  }

  void _shareSelectedSessions() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final sessionRepository = Provider.of<SessionRepository>(
        context,
        listen: false,
      );

      final success = await exportDataWithFeedback(
        isarService,
        sessionRepository,
        selectedSessionIds: _selectedSessionIds,
        onError: (reason) {
          if (mounted) Navigator.of(context).pop();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(reason),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        onSuccess: (message) {
          if (mounted) Navigator.of(context).pop();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            _cancelSelection();
          }
        },
      );

      if (!success && mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) context.pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue : $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelection,
              ),
              title: Text("${_selectedSessionIds.length} sélectionnée(s)"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _shareSelectedSessions,
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  (_isSelectionMode ? kToolbarHeight : 0),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (!_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                        child: Text(
                          _username.isNotEmpty
                              ? "Bonjour, $_username !"
                              : "Bonjour !",
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (!_sessionsLoaded)
                    const Center(child: LinearProgressIndicator()),
                  // Number of sessions indicator
                  if (_sessionsLoaded && !_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                      child: Text(
                        "Vous avez ${_sessions.length} sessions",
                        style: theme.textTheme.titleMedium!,
                      ),
                    ),
                  // Sessions
                  if (_sessionsLoaded)
                    _sessions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 50.0,
                              ),
                              child: Text(
                                "Aucune session enregistrée.\nAppuyez sur '+' pour en créer une.",
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
                            onItemLongPress: _onItemLongPress,
                            isSelectionMode: _isSelectionMode,
                            selectedSessionIds: _selectedSessionIds,
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
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
