import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/widgets/catches/catch_item.dart';
import 'package:flutter/material.dart';

class CatchesList extends StatefulWidget {
  final List<Catch> catches;

  const CatchesList({super.key, required this.catches});

  @override
  State<CatchesList> createState() => _CatchesListState();
}

class _CatchesListState extends State<CatchesList> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var catches = widget.catches;

    var totalWeight = catches
        .map((c) => c.weight ?? 0.0)
        .fold(0.0, (p, c) => p + c);

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
        // Total count
        Text("${catches.length} prises"),

        //
        //    LIST
        //
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: catches.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final catchItem = catches[index];
            return CatchItem(catchItem: catchItem);
          },
        ),
      ],
    );
  }
}
