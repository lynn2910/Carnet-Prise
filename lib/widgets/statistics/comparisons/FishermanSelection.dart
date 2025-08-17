import 'package:carnet_prise/models/fisherman.dart';
import 'package:flutter/material.dart';

class FishermanSelection extends StatefulWidget {
  final List<Fisherman> selectableFisherman;
  final Function(Fisherman fisherman) onSelect;
  final Fisherman? selectedFisherman;

  const FishermanSelection({
    super.key,
    required this.selectedFisherman,
    required this.selectableFisherman,
    required this.onSelect,
  });

  @override
  State<FishermanSelection> createState() => _FishermanSelectionState();
}

class _FishermanSelectionState extends State<FishermanSelection> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Fisherman>(
      value: widget.selectedFisherman,
      onChanged: (fisherman) {
        if (fisherman == null) return;
        widget.onSelect(fisherman);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: widget.selectableFisherman.map<DropdownMenuItem<Fisherman>>((
        fisherman,
      ) {
        return DropdownMenuItem<Fisherman>(
          value: fisherman,
          child: Text(fisherman.name ?? 'Sans nom'),
        );
      }).toList(),
    );
  }
}
