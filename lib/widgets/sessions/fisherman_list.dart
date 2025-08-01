import 'package:carnet_prise/models/fisherman.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../repositories/isar/session_repository.dart';

class FishermanList extends StatefulWidget {
  final List<Fisherman> fishermen;
  final int sessionId;

  const FishermanList({
    super.key,
    required this.fishermen,
    required this.sessionId,
  });

  @override
  State<FishermanList> createState() => _FishermanListState();
}

class _FishermanListState extends State<FishermanList> {
  SessionRepository? _sessionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
  }

  double _getTotalWeight(Fisherman fisherman) {
    double totalWeight = 0.0;
    for (var catchItem in fisherman.catches) {
      totalWeight += catchItem.weight ?? 0.0;
    }
    return totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    if (widget.fishermen.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            "Aucun pêcheur enregistrée.\nAppuyez sur '+' pour en ajouter un.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.fishermen.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
      itemBuilder: (context, index) {
        final fisherman = widget.fishermen[index];
        final totalCatches = fisherman.catches.length;
        final totalWeight = _getTotalWeight(fisherman);

        return InkWell(
          onTap: () {
            context.pushNamed(
              "fisherman_details",
              pathParameters: {
                "session_id": widget.sessionId.toString(),
                "fisherman_id": cleanString(fisherman.name.toString()),
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 32,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Poste ${fisherman.spotNumber ?? 'N/A'}',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        fisherman.name ?? 'Nom inconnu',
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCatches prises - ${totalWeight.toStringAsFixed(1)} Kg',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_right,
                      size: 26,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
