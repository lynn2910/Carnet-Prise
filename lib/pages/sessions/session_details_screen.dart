import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/catches_list.dart';
import 'package:carnet_prise/widgets/sessions/fisherman_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/catch.dart';

class SessionDetailsScreen extends StatefulWidget {
  final int sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
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

  // TODO Aller aux stats
  void _goToAnalytics() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Afficher les statistiques')));
  }

  void _editSession() {
    context.pushNamed(
      "edit_session",
      pathParameters: {"session_id": widget.sessionId.toString()},
    );
  }

  void _shareSession() {
    if (_session == null) return;

    var catches = _session!.fishermen
        .map((f) => f.catches.toList())
        .expand((e) => e)
        .toList();

    catches.sort((a, b) {
      if (a.catchDate == null && b.catchDate == null) return 0;
      if (a.catchDate == null) return 1;
      if (b.catchDate == null) return -1;
      return b.catchDate!.compareTo(a.catchDate!);
    });

    double totalWeight = catches.fold(0, (p, c) => p += c.weight ?? 0.0);

    String text = "";

    text += "Session de pêche à: ${_session!.spotName}";
    text += "\n\n";
    text += "Poids total: ${totalWeight.toStringAsFixed(2)} Kg\n";
    text += "Nombre de prises total: ${catches.length}";

    text += "\n\n";
    text += "Pêcheurs:\n";

    for (var fishermen in _session!.fishermen) {
      final caughtNumber = fishermen.catches.length;
      final double totalWeight = fishermen.catches.fold(
        0,
        (p, c) => p += c.weight ?? 0.0,
      );

      text +=
          "${fishermen.name} ($caughtNumber prises - ${totalWeight.toStringAsFixed(2)} Kg)\n";
    }

    text += "\n";
    text += "Historique des prises:\n";

    int i = 0;
    for (var catchItem in catches) {
      text += catchItem.shareSmall(showAuthor: true);
      if (i < catches.length - 1) {
        text += "\n";
      }
      i++;
    }

    SharePlus.instance.share(ShareParams(text: text));
  }

  void _onCatchDeleted() {
    _loadSessionDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              _goToAnalytics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _editSession();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareSession();
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
                    'Session n°${_session!.id}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _session!.spotName ?? "Lieu inconnu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ListView(
            children: [
              const SizedBox(height: 8.0),
              //
              //  Fisherman list
              //
              //
              // Fisherman Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Participants",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context
                          .pushNamed(
                            "add_fisherman",
                            pathParameters: {
                              "session_id": widget.sessionId.toString(),
                            },
                          )
                          .then((_) {
                            _loadSessionDetails();
                          });
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              // Fisherman list
              if (_session?.fishermen != null)
                FishermanList(
                  fishermen: _session!.fishermen.toList(),
                  sessionId: widget.sessionId,
                ),

              const SizedBox(height: 10),
              //
              //  Catch list
              //
              //
              CatchesList(
                catches: _session!.fishermen
                    .map((f) => f.catches.toList())
                    .expand((e) => e)
                    .toList(),
                onCatchDeleted: _onCatchDeleted,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context
              .pushNamed(
                "add_catch",
                pathParameters: {"session_id": widget.sessionId.toString()},
              )
              .then((_) {
                _loadSessionDetails();
              });
        },
      ),
    );
  }
}
