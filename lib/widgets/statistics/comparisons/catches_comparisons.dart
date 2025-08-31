import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/models/catch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ComparisonRow {
  final Catch? catch1;
  final Catch? catch2;
  final DateTime sortDate;

  _ComparisonRow({this.catch1, this.catch2, required this.sortDate});
}

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

    final catches1 = List<Catch>.from(fisherman1.catches);
    final catches2 = List<Catch>.from(fisherman2.catches);

    if (catches1.isEmpty && catches2.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [SizedBox(height: 16), Text('Aucune capture à comparer')],
      );
    }

    final items = _buildComparisonList(catches1, catches2);

    return Column(mainAxisSize: MainAxisSize.min, children: items);
  }

  List<Widget> _buildComparisonList(
    List<Catch> catches1,
    List<Catch> catches2,
  ) {
    final margin = const Duration(minutes: 10);
    final items = <Widget>[];

    final unpaired1 = catches1.where((c) => c.catchDate != null).toList()
      ..sort((a, b) => b.catchDate!.compareTo(a.catchDate!));
    final unpaired2 = catches2.where((c) => c.catchDate != null).toList()
      ..sort((a, b) => b.catchDate!.compareTo(a.catchDate!));

    final rows = <_ComparisonRow>[];

    while (unpaired1.isNotEmpty || unpaired2.isNotEmpty) {
      Catch primaryCatch;
      List<Catch> listToSearch;
      bool primaryIsFromList1;

      if (unpaired1.isEmpty) {
        primaryCatch = unpaired2.removeAt(0);
        listToSearch = unpaired1;
        primaryIsFromList1 = false;
      } else if (unpaired2.isEmpty) {
        primaryCatch = unpaired1.removeAt(0);
        listToSearch = unpaired2;
        primaryIsFromList1 = true;
      } else {
        if (unpaired1.first.catchDate!.isAfter(unpaired2.first.catchDate!)) {
          primaryCatch = unpaired1.removeAt(0);
          listToSearch = unpaired2;
          primaryIsFromList1 = true;
        } else {
          primaryCatch = unpaired2.removeAt(0);
          listToSearch = unpaired1;
          primaryIsFromList1 = false;
        }
      }

      Catch? bestMatch;
      int bestMatchIndex = -1;
      Duration minDifference = const Duration(days: 999);

      for (int i = 0; i < listToSearch.length; i++) {
        final potentialMatch = listToSearch[i];
        final difference = primaryCatch.catchDate!
            .difference(potentialMatch.catchDate!)
            .abs();

        if (difference <= margin && difference < minDifference) {
          minDifference = difference;
          bestMatch = potentialMatch;
          bestMatchIndex = i;
        }
      }

      if (bestMatch != null) {
        listToSearch.removeAt(bestMatchIndex);
        rows.add(
          _ComparisonRow(
            catch1: primaryIsFromList1 ? primaryCatch : bestMatch,
            catch2: primaryIsFromList1 ? bestMatch : primaryCatch,
            sortDate:
                primaryCatch.catchDate!.compareTo(bestMatch.catchDate!) > 0
                ? primaryCatch.catchDate!
                : bestMatch.catchDate!,
          ),
        );
      } else {
        rows.add(
          _ComparisonRow(
            catch1: primaryIsFromList1 ? primaryCatch : null,
            catch2: primaryIsFromList1 ? null : primaryCatch,
            sortDate: primaryCatch.catchDate!,
          ),
        );
      }
    }

    String? lastDateKey;
    for (final row in rows) {
      final currentDateKey = _getDateKey(row.sortDate);
      if (currentDateKey != lastDateKey) {
        items.add(_buildDateSeparator(row.sortDate));
        lastDateKey = currentDateKey;
      }
      items.add(_buildComparisonRow(row.catch1, row.catch2));
    }

    return items;
  }

  String _getDateKey(DateTime? date) {
    if (date == null) return 'unknown';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildDateSeparator(DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
        ],
      ),
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
      return getAccidentName(catchData.accident!);
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
      return Colors.red.withValues(alpha: 0.15);
    }
    return Colors.transparent;
  }
}
