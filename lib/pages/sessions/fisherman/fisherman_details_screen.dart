import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/catches_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/session.dart';

class FishermanDetailsScreen extends StatefulWidget {
  const FishermanDetailsScreen({
    super.key,
    required this.sessionId,
    required this.fishermanId,
  });

  final int sessionId;
  final String fishermanId;

  @override
  State<FishermanDetailsScreen> createState() => _FishermanDetailsScreenState();
}

class _FishermanDetailsScreenState extends State<FishermanDetailsScreen> {
  Session? _session;
  Fisherman? _fisherman;
  bool _loaded = false;

  SessionRepository? _sessionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_sessionRepository == null) return;

    setState(() {
      _loaded = false;
    });

    final session = await _sessionRepository!.getSessionById(widget.sessionId);
    final fisherman = await _sessionRepository!.getFishermanByName(
      widget.sessionId,
      widget.fishermanId,
    );

    setState(() {
      _session = session;
      _fisherman = fisherman;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Afficher les statistiques')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Éditer la session')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partager la session')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loaded ? '${_fisherman!.name}' : "Chargement",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_loaded)
                    Text(
                      "Session n°${_session?.id} : ${_session?.spotName ?? "Lieu inconnu"}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (!_loaded) LinearProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _loaded
              ? ListView(
                  children: [
                    //
                    // Spot number
                    //
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Poste",
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _fisherman?.spotNumber ?? "?",
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 25.0),

                    //
                    //  Catches list
                    //
                    CatchesList(catches: _fisherman?.catches ?? []),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context
              .pushNamed(
                "add_catch_from_fisherman",
                pathParameters: {
                  "session_id": widget.sessionId.toString(),
                  "fisherman_id": widget.fishermanId.toString(),
                },
              )
              .then((_) {
                _loadData();
              });
        },
      ),
    );
  }
}
