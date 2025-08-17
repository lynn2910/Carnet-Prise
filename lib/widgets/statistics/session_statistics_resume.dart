import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/catch.dart';
import '../../models/session.dart';

class SessionStatisticsResume extends StatefulWidget {
  final Session? session;

  const SessionStatisticsResume({super.key, required this.session});

  @override
  State<SessionStatisticsResume> createState() =>
      _SessionStatisticsResumeState();
}

class _SessionStatisticsResumeState extends State<SessionStatisticsResume> {
  List<PieChartSectionData> _generatePieChartSections() {
    Map<String, int> fishCounts = {};
    for (var fisherman in widget.session!.fishermen) {
      for (var catchData in fisherman.catches) {
        if (catchData.accident == Accident.none) {
          String fishName = catchData.fishType == FishType.carp
              ? 'Carpe'
              : (catchData.otherFishType ?? 'Autre');
          fishCounts[fishName] = (fishCounts[fishName] ?? 0) + 1;
        }
      }
    }

    return fishCounts.entries.map((entry) {
      final title = '${entry.key} (${entry.value})';
      final color =
          Colors.primaries[entry.key.hashCode % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: title,
        radius: 120,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  final Map<int, int> _accidentsCounts = {};
  int _totalAccidentsCount = 0;

  final Map<String, int> _fishes = {};
  int _totalFishesCount = 0;

  bool _finishedLoading = false;

  void _prepareStatistics() {
    for (var fisherman in widget.session!.fishermen) {
      for (var catchItem in fisherman.catches) {
        // Accident
        if (catchItem.accident != null && catchItem.accident != Accident.none) {
          _totalAccidentsCount++;
          int hashCode = catchItem.accident!.hashCode;
          if (_accidentsCounts[hashCode] == null) {
            _accidentsCounts[hashCode] = 1;
          } else {
            _accidentsCounts[hashCode] = _accidentsCounts[hashCode]! + 1;
          }
        } else {
          // Normal fish :)
          String name = catchItem.fishType != FishType.other
              ? getFishTypeName(catchItem.fishType!)
              : catchItem.otherFishType ?? "Inconnu";

          _totalFishesCount++;
          if (_fishes[name] == null) {
            _fishes[name] = 1;
          } else {
            _fishes[name] = _fishes[name]! + 1;
          }
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _prepareStatistics();

    setState(() {
      _finishedLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_finishedLoading || widget.session == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (widget.session!.fishermen.isEmpty) {
      return Center(child: Text("Pas de données de session disponibles."));
    }

    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          // Graph
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _generatePieChartSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 30),

          //
          // List
          //

          // Accidents
          for (var accident in Accident.values.where((a) => a != Accident.none))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getAccidentName(accident),
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${_accidentsCounts[accident.hashCode] ?? 0} (${(((_accidentsCounts[accident.hashCode] ?? 0) / _totalAccidentsCount) * 100).toInt()}%)",
                    style: theme.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

          Divider(thickness: 2),
          // Fishes
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
            child: Text(
              "Poissons",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ..._fishes.entries.map((entry) {
            final name = entry.key;
            final count = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "$count (${((count / _totalFishesCount) * 100).toInt()}%)",
                    style: theme.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
