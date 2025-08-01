import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/widgets/catches/catch_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  void _onCatchEdited() {
    Navigator.of(context).pop();
    widget.onCatchEdited();
  }

  @override
  Widget build(BuildContext context) {
    var catchItem = widget.catchItem;

    var theme = Theme.of(context);

    return InkWell(
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
                  ),
                  Text(getCatchType(catchItem)),
                ],
              ),
            ),
            //
            // Right
            //
            const SizedBox(width: 8),
            Text(_getWeight(catchItem), style: theme.textTheme.labelMedium!),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_right,
              size: 26,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDatetime(DateTime date) {
  return DateFormat(DateFormat.HOUR24_MINUTE).format(date);
}

String _getWeight(Catch c) {
  switch (c.accident) {
    case Accident.lineBreak:
      return "ligne cassée";
    case Accident.snaggedLine:
      return "décroché";
    case Accident.none:
    default:
      return "${c.weight?.toStringAsFixed(2)} Kg";
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
