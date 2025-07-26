import 'package:carnet_prise/models/fisherman.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FishermanList extends StatefulWidget {
  final List<Fisherman> fishermen;

  const FishermanList({super.key, required this.fishermen});

  @override
  State<FishermanList> createState() => _FishermanListState();
}

class _FishermanListState extends State<FishermanList> {
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

    return Text("${widget.fishermen.length}");
  }
}
