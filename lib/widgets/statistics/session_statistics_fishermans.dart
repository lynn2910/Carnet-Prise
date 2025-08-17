import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/widgets/sessions/fisherman_list.dart';
import 'package:carnet_prise/widgets/statistics/comparisons/FishermanSelection.dart';
import 'package:flutter/material.dart';

class SessionStatisticsFisherman extends StatefulWidget {
  final Session? session;

  const SessionStatisticsFisherman({super.key, required this.session});

  @override
  State<SessionStatisticsFisherman> createState() =>
      _SessionStatisticsFishermanState();
}

class _SessionStatisticsFishermanState
    extends State<SessionStatisticsFisherman> {
  Fisherman? _firstFisherman;
  Fisherman? _secondFisherman;

  List<Fisherman> _getSelectableFishermanForFirst() {
    if (widget.session == null) return [];
    return widget.session!.fishermen
        .where((f) => f != _secondFisherman)
        .toList();
  }

  List<Fisherman> _getSelectableFishermanForSecond() {
    if (widget.session == null) return [];
    return widget.session!.fishermen
        .where((f) => f != _firstFisherman)
        .toList();
  }

  void _clearSelection() {
    setState(() {
      _firstFisherman = null;
      _secondFisherman = null;
    });
  }

  void _onSelectChange(Fisherman fisherman, {required bool isFirst}) {
    setState(() {
      if (isFirst) {
        _firstFisherman = fisherman;
      } else {
        _secondFisherman = fisherman;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session == null) {
      return Center(child: CircularProgressIndicator());
    }

    var session = widget.session!;
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          // Fishermen list
          FishermanList(fishermen: session.fishermen, sessionId: session.id),

          //
          // Comparison
          //
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Comparaison",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: _clearSelection,
                  icon: Icon(
                    Icons.highlight_remove,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          if (session.fishermen.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text("Il doit y avoir au moins 2 pêcheurs"),
            ),

          // Selection
          if (session.fishermen.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FishermanSelection(
                        selectedFisherman: _firstFisherman,
                        selectableFisherman: _getSelectableFishermanForFirst(),
                        onSelect: (fisherman) {
                          _onSelectChange(fisherman, isFirst: true);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FishermanSelection(
                        selectedFisherman: _secondFisherman,
                        selectableFisherman: _getSelectableFishermanForSecond(),
                        onSelect: (fisherman) {
                          _onSelectChange(fisherman, isFirst: false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // List
          if ((_firstFisherman == null || _secondFisherman == null) &&
              session.fishermen.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Text("Sélectionnez deux pêcheurs pour les comparer."),
              ),
            ),

          if (_firstFisherman != null &&
              _secondFisherman != null &&
              session.fishermen.length > 1)
            Text("hello world!"),
        ],
      ),
    );
  }
}
