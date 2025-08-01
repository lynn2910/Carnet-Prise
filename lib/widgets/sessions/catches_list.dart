import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/widgets/catches/catch_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatchesList extends StatefulWidget {
  final List<Catch> catches;
  final VoidCallback onCatchDeleted;
  final VoidCallback onCatchEdited;

  const CatchesList({
    super.key,
    required this.catches,
    required this.onCatchDeleted,
    required this.onCatchEdited,
  });

  @override
  State<CatchesList> createState() => _CatchesListState();
}

class _CatchesListState extends State<CatchesList> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var catches = List<Catch>.from(widget.catches);

    catches.sort((a, b) {
      if (a.catchDate == null && b.catchDate == null) return 0;
      if (a.catchDate == null) return 1;
      if (b.catchDate == null) return -1;
      return b.catchDate!.compareTo(a.catchDate!);
    });

    var totalWeight = catches
        .map((c) => c.weight ?? 0.0)
        .fold(0.0, (p, c) => p + c);

    List<Widget> children = [];
    DateTime? lastDate;

    for (int i = 0; i < catches.length; i++) {
      final catchItem = catches[i];
      final currentCatchDate = catchItem.catchDate;

      if (currentCatchDate != null) {
        if (lastDate == null || !isSameDay(currentCatchDate, lastDate)) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(currentCatchDate),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          );
          children.add(
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          );
        }
        lastDate = currentCatchDate;
      }

      children.add(
        CatchItem(
          catchItem: catchItem,
          onCatchDeleted: widget.onCatchDeleted,
          onCatchEdited: widget.onCatchEdited,
        ),
      );

      if (i < catches.length - 1) {
        final nextCatchDate = catches[i + 1].catchDate;
        if (currentCatchDate == null ||
            nextCatchDate == null ||
            isSameDay(currentCatchDate, nextCatchDate)) {
          children.add(
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Historique des prises",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${totalWeight.toStringAsFixed(2)} Kg",
              style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "${catches.length} prises",
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(children: children),
        const SizedBox(height: 100),
      ],
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
