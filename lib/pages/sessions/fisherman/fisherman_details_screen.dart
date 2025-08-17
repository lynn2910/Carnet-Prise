import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/sessions/catches_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/catch.dart';
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

  late String _fishermanId;

  SessionRepository? _sessionRepository;

  @override
  void initState() {
    super.initState();
    _fishermanId = widget.fishermanId;
  }

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
      _fishermanId,
    );

    setState(() {
      _session = session;
      _fisherman = fisherman;
      _loaded = true;
    });
  }

  void _share() {
    if (_fisherman == null || _session == null) return;

    int fishCaught = _fisherman!.catches
        .where((c) => c.accident == Accident.none)
        .length;

    double totalWeight = _fisherman!.catches.fold(
      0,
      (p, c) => p += c.weight ?? 0.0,
    );

    String text = "";

    text +=
        "${_fisherman!.name} a pêché $fishCaught poisson${fishCaught > 1 ? 's' : ''}";
    text += ", pour un total de ${totalWeight.toStringAsFixed(2)} Kg.";

    text += "\n\n";

    text += "Lieu: ${_session!.spotName}\n";
    text += "Poste: ${_fisherman!.spotNumber}";

    text += "\n\n";

    text += "Historique des prises:\n";

    int i = 0;
    for (var catchItem in _fisherman!.catches) {
      text += catchItem.shareSmall(showAuthor: false);
      if (i < _fisherman!.catches.length - 1) {
        text += "\n";
      }
      i++;
    }

    SharePlus.instance.share(ShareParams(text: text));
  }

  void _onCatchDeleted() {
    _loadData();
  }

  void _onCatchEdited() {
    _loadData();
  }

  Future<void> _deleteFishermen() async {
    if (_session == null || _fisherman == null) {
      return;
    }

    bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var theme = Theme.of(context);

        return AlertDialog(
          title: Text(
            "Supprimer un pêcheur",
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Le pêcheur est toute ses prises seront supprimés. Une fois supprimée, vous ne pourrez pas restaurer les données.',
                ),
                SizedBox(height: 16),
                Text('Êtes-vous sûr de vouloir supprimer ce pêcheur ?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _sessionRepository!.removeFishermanFromSession(
                  _session!.id,
                  _fisherman!.name!,
                );
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text("Confirmer"),
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
        Navigator.of(context).pop();
      }
    } else {
      _loadData();
    }
  }

  void _editFishermen() {
    if (_session == null || _fisherman == null) return;
    context
        .pushNamed(
          "edit_fisherman",
          pathParameters: {
            "session_id": _session!.id.toString(),
            "fisherman_id": _fisherman!.name.toString(),
          },
        )
        .then((result) {
          if (result is String) {
            setState(() {
              _fishermanId = result;
            });
          }
          _loadData();
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
            icon: const Icon(Icons.share),
            onPressed: () {
              _share();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case "edit":
                  _editFishermen();
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
                    _loaded && _fisherman != null
                        ? '${_fisherman!.name}'
                        : "Chargement",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_loaded && _fisherman != null)
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
              ? RefreshIndicator(
                  onRefresh: () => _loadData(),
                  child: ListView(
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

                      const SizedBox(height: 30),

                      //
                      //  Catches list
                      //
                      CatchesList(
                        catches: _fisherman?.catches ?? [],
                        onCatchDeleted: _onCatchDeleted,
                        onCatchEdited: _onCatchEdited,
                      ),
                    ],
                  ),
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
