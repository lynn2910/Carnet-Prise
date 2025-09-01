import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/catches/catch_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CatchItem extends StatefulWidget {
  final Catch catchItem;
  final VoidCallback onCatchDeleted;
  final VoidCallback onCatchEdited;

  const CatchItem({
    super.key,
    required this.catchItem,
    required this.onCatchDeleted,
    required this.onCatchEdited,
  });

  @override
  State<CatchItem> createState() => _CatchItemState();
}

class _CatchItemState extends State<CatchItem> {
  SessionRepository? _sessionRepository;
  Fisherman? _fisherman;

  void _onCatchEdited() {
    Navigator.of(context).pop();
    widget.onCatchEdited();
  }

  Color _getCatchColor(Catch catchData, int? colorSeed) {
    if (catchData.accident != null && catchData.accident != Accident.none) {
      return Colors.red.withValues(alpha: 0.15);
    }
    return Colors.transparent;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionRepository == null) {
      _sessionRepository ??= Provider.of<SessionRepository>(context);
      _loadFisherman();
    }
  }

  Future<void> _loadFisherman() async {
    if (widget.catchItem.session.value == null) {
      await widget.catchItem.session.load();
    }
    var fisherman = await _sessionRepository!.getFishermanByName(
      widget.catchItem.session.value!.id,
      widget.catchItem.fishermenName!,
    );

    setState(() {
      _fisherman = fisherman;
    });
  }

  TextStyle _getFontStyle() {
    var theme = Theme.of(context);
    var catchItem = widget.catchItem;

    if (catchItem.accident != Accident.none) {
      return TextStyle(color: theme.colorScheme.onSurface);
    } else {
      return TextStyle(
        color: _fisherman?.getColor(),
        fontWeight: FontWeight.bold,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var catchItem = widget.catchItem;

    if (_fisherman == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text("Chargement..."),
        ),
      );
    }

    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DefaultTextStyle(
        style: TextStyle(
          color: catchItem.accident != Accident.none
              ? theme.colorScheme.onSurface
              : _fisherman?.getColor(),
        ),
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: _getCatchColor(catchItem, _fisherman?.colorSeed),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet<bool>(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return Wrap(
                    children: [
                      CatchDetails(
                        catchItem: catchItem,
                        onCatchDeleted: widget.onCatchDeleted,
                        onCatchEdited: _onCatchEdited,
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  //
                  // Left
                  //
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${catchItem.catchDate != null ? _formatDatetime(catchItem.catchDate!) : "-- ERREUR --"} - ${catchItem.fishermenName ?? "-- ERREUR --"}",
                          style: theme.textTheme.labelMedium!.copyWith(
                            color: catchItem.accident != Accident.none
                                ? theme.colorScheme.onSurface
                                : _fisherman?.getColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          getCatchType(catchItem),
                          style: theme.textTheme.labelMedium!.copyWith(
                            color: catchItem.accident != Accident.none
                                ? theme.colorScheme.onSurface
                                : _fisherman?.getColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                  // Right
                  //
                  const SizedBox(width: 8),
                  Text(
                    _getWeight(catchItem),
                    style: theme.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
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
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDatetime(DateTime date) {
  return DateFormat(DateFormat.HOUR24_MINUTE).format(date);
}

String _getWeight(Catch c) {
  if (c.accident == null || c.accident! == Accident.none) {
    return "${c.weight?.toStringAsFixed(2)} Kg";
  } else {
    return getAccidentName(c.accident!);
  }
}

String getCatchType(Catch c) {
  switch (c.fishType) {
    case FishType.carp:
      return 'Carpe';
    case FishType.other:
    default:
      return c.otherFishType ?? "--";
  }
}
