import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/catches_list.dart';
import 'package:carnet_prise/widgets/sessions/fisherman_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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

  void _goToAnalytics() {
    context.pushNamed(
      "session_statistics",
      pathParameters: {"session_id": widget.sessionId.toString()},
    );
  }

  void _editSession() {
    context.pushNamed(
      "edit_session",
      pathParameters: {"session_id": widget.sessionId.toString()},
    );
  }

  Future<void> _deleteFishermen() async {
    if (_session == null) {
      return;
    }

    bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var theme = Theme.of(context);

        return AlertDialog(
          title: Text(
            "Supprimer une session de pêche",
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  "Cette session, tout les pêcheurs et toutes les prises seront supprimés. Une fois supprimée, vous ne pourrez pas restaurer les données.",
                ),
                SizedBox(height: 16),
                Text('Êtes-vous sûr de vouloir supprimer cette session ?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _sessionRepository.deleteSession(_session!.id);
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(
                "Confirmer",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );

    if (success ?? false) {
      if (mounted) {
        context.pushNamed("home");
      }
    } else {
      _loadSessionDetails();
    }
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

  void _onCatchEdited() {
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
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareSession();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case "edit":
                  _editSession();
                case "delete":
                  _deleteFishermen();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Modifier'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Supprimer'),
              ),
            ],
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
      body: RefreshIndicator(
        onRefresh: () => _loadSessionDetails(),
        child: SafeArea(
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
                    InkWell(
                      child: Text(
                        "Participants",
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
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
                    ),
                  ],
                ),
                // Fisherman list
                if (_session?.fishermen != null)
                  FishermanList(
                    fishermen: _session!.fishermen.toList(),
                    sessionId: widget.sessionId,
                    requestReload: () {
                      _loadSessionDetails();
                    },
                  ),

                const SizedBox(height: 30),
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
                  onCatchEdited: _onCatchEdited,
                ),
              ],
            ),
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
