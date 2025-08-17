import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/widgets/sessions/fisherman_list.dart';
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
                  onPressed: () {
                    // TODO
                  },
                  icon: Icon(
                    Icons.highlight_remove,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}
