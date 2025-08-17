import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/catch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatchesComparisons extends StatefulWidget {
  final List<Fisherman> compared;

  const CatchesComparisons({super.key, required this.compared});

  @override
  State<CatchesComparisons> createState() => _CatchesComparisonsState();
}

class _CatchesComparisonsState extends State<CatchesComparisons> {
  @override
  Widget build(BuildContext context) {
    if (widget.compared.length != 2) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Veuillez sélectionner exactement 2 pêcheurs pour la comparaison',
          ),
        ),
      );
    }

    final fisherman1 = widget.compared[0];
    final fisherman2 = widget.compared[1];

    final catches1 = List<Catch>.from(fisherman1.catches)
      ..sort(
        (a, b) => (b.catchDate ?? DateTime.now()).compareTo(
          a.catchDate ?? DateTime.now(),
        ),
      );
    final catches2 = List<Catch>.from(fisherman2.catches)
      ..sort(
        (a, b) => (b.catchDate ?? DateTime.now()).compareTo(
          a.catchDate ?? DateTime.now(),
        ),
      );

    final maxRows = catches1.length > catches2.length
        ? catches1.length
        : catches2.length;

    if (maxRows == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Aucune capture à comparer'),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            minHeight: 100,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: maxRows,
            itemBuilder: (context, index) {
              final catch1 = index < catches1.length ? catches1[index] : null;
              final catch2 = index < catches2.length ? catches2[index] : null;

              return _buildComparisonRow(catch1, catch2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(Catch? catch1, Catch? catch2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildCatchCard(catch1, isLeft: true)),

          const SizedBox(width: 16),

          Expanded(child: _buildCatchCard(catch2, isLeft: false)),
        ],
      ),
    );
  }

  Widget _buildCatchCard(Catch? catchData, {required bool isLeft}) {
    var theme = Theme.of(context);

    if (catchData == null) {
      return Container(
        height: 60,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('--', style: theme.textTheme.labelMedium!)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getCatchColor(catchData),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(catchData.catchDate),
            style: theme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            _getCatchDisplayText(catchData),
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return DateFormat('HH\'h\'mm').format(dateTime);
  }

  String _getCatchDisplayText(Catch catchData) {
    if (catchData.accident != null && catchData.accident != Accident.none) {
      switch (catchData.accident!) {
        case Accident.snaggedLine:
          return 'décroche';
        case Accident.lineBreak:
          return 'ligne cassée';
        case Accident.none:
          break;
      }
    }

    String fishName = _getFishDisplayName(catchData);
    String weight = catchData.weight != null
        ? '${catchData.weight!.toStringAsFixed(2).replaceAll('.00', '')} Kg'
        : '-- Kg';

    return '$fishName - $weight';
  }

  String _getFishDisplayName(Catch catchData) {
    if (catchData.fishType == null) return 'Inconnu';

    switch (catchData.fishType!) {
      case FishType.carp:
        return 'Carpe';
      case FishType.other:
        return catchData.otherFishType ?? 'Autre';
    }
  }

  Color _getCatchColor(Catch catchData) {
    if (catchData.accident != null && catchData.accident != Accident.none) {
      return Colors.red.shade50;
    }
    return Colors.transparent;
  }
}
