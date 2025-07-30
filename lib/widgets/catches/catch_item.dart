import 'package:carnet_prise/models/catch.dart';
import 'package:flutter/material.dart';

class CatchItem extends StatefulWidget {
  final Catch catchItem;

  const CatchItem({super.key, required this.catchItem});

  @override
  State<CatchItem> createState() => _CatchItemState();
}

class _CatchItemState extends State<CatchItem> {
  @override
  Widget build(BuildContext context) {
    var catchItem = widget.catchItem;

    var theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // TODO show details of catch
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
                children: [Text("Heure - "), Text(getCatchType(catchItem))],
              ),
            ),
            //
            // Right
            //
            const SizedBox(width: 8),
            Text(getWeight(catchItem), style: theme.textTheme.labelMedium!),
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

String getWeight(Catch c) {
  switch (c.accident) {
    case Accident.snaggedLine:
      return "ligne cassée";
    case Accident.lineBreak:
      return "décroché";
    case Accident.none:
    default:
      return "${c.weight} Kg";
  }
}

String getCatchType(Catch c) {
  switch (c.fishType) {
    case FishType.commonCarp:
      return 'Carpe commune';
    case FishType.mirrorCarp:
      return 'Carpe miroir';
    case FishType.grassCarp:
      return 'Carpe amour';
    case FishType.other:
    default:
      return c.otherFishType ?? "-- Erreur --";
  }
}
