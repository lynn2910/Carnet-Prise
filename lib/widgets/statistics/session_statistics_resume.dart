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
  final Map<int, int> _accidentsCounts = {};
  int _totalAccidentsCount = 0;

  final Map<String, int> _fishes = {};
  int _totalFishesCount = 0;

  bool _finishedLoading = false;
  String? _errorMessage;

  List<PieChartSectionData> _generatePieChartSections() {
    try {
      Map<String, int> fishCounts = {};

      if (widget.session?.fishermen != null) {
        for (var fisherman in widget.session!.fishermen) {
          for (var catchData in fisherman.catches) {
            if (catchData.accident == null ||
                catchData.accident == Accident.none) {
              String fishName;

              if (catchData.fishType == FishType.carp) {
                fishName = 'Carpe';
              } else if (catchData.fishType == FishType.other) {
                fishName = catchData.otherFishType ?? 'Autre';
              } else if (catchData.fishType != null) {
                try {
                  fishName = getFishTypeName(catchData.fishType!);
                } catch (e) {
                  fishName = catchData.otherFishType ?? 'Inconnu';
                }
              } else {
                fishName = catchData.otherFishType ?? 'Inconnu';
              }

              fishCounts[fishName] = (fishCounts[fishName] ?? 0) + 1;
            }
          }
        }
      }

      if (fishCounts.isEmpty) {
        return [
          PieChartSectionData(
            color: Colors.grey,
            value: 1,
            title: 'Aucune donnée',
            radius: 120,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ];
      }

      return fishCounts.entries.map((entry) {
        final title = '${entry.key} (${entry.value})';
        final color = Colors
            .primaries[entry.key.hashCode.abs() % Colors.primaries.length];

        return PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: title,
          radius: 120,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();
    } catch (e) {
      return [
        PieChartSectionData(
          color: Colors.red,
          value: 1,
          title: 'Erreur',
          radius: 120,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }
  }

  void _prepareStatistics() {
    try {
      if (widget.session?.fishermen == null) return;

      _accidentsCounts.clear();
      _fishes.clear();
      _totalAccidentsCount = 0;
      _totalFishesCount = 0;

      for (var fisherman in widget.session!.fishermen) {
        for (var catchItem in fisherman.catches) {
          if (catchItem.accident != null &&
              catchItem.accident != Accident.none) {
            _totalAccidentsCount++;
            int hashCode = catchItem.accident!.hashCode;
            _accidentsCounts[hashCode] = (_accidentsCounts[hashCode] ?? 0) + 1;
          } else {
            // Normal fish
            String name;

            if (catchItem.fishType == FishType.carp) {
              name = 'Carpe';
            } else if (catchItem.fishType == FishType.other) {
              name = catchItem.otherFishType ?? 'Autre';
            } else if (catchItem.fishType != null) {
              try {
                name = getFishTypeName(catchItem.fishType!);
              } catch (e) {
                name = catchItem.otherFishType ?? 'Inconnu';
              }
            } else {
              name = catchItem.otherFishType ?? 'Inconnu';
            }

            _totalFishesCount++;
            _fishes[name] = (_fishes[name] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques: $e';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _prepareStatistics();
      setState(() {
        _finishedLoading = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'initialisation: $e';
        _finishedLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gestion des erreurs
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erreur', style: Theme
                .of(context)
                .textTheme
                .headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (!_finishedLoading || widget.session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.session!.fishermen.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text("Pas de données de session disponibles."),
          ],
        ),
      );
    }

    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          // Graph
          const SizedBox(height: 20),

          if (_totalFishesCount > 0) ...[
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
          ] else
            ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Aucun poisson capturé dans cette session'),
                ),
              ),
            ],

          const SizedBox(height: 30),

          // Accidents section
          if (_totalAccidentsCount > 0) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
              child: Text(
                "Accidents",
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ...Accident.values.where((a) => a != Accident.none).map((accident) {
              final accidentCount = _accidentsCounts[accident.hashCode] ?? 0;
              if (accidentCount == 0) return const SizedBox.shrink();

              final accidentPercentage = _totalAccidentsCount > 0
                  ? (accidentCount / _totalAccidentsCount * 100).toInt()
                  : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        getAccidentName(accident),
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      "$accidentCount ($accidentPercentage%)",
                      style: theme.textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(thickness: 2),
          ],

          // Fishes section
          if (_totalFishesCount > 0) ...[
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

              final fishPercentage = _totalFishesCount > 0
                  ? (count / _totalFishesCount * 100).toInt()
                  : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      "$count ($fishPercentage%)",
                      style: theme.textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Message si aucune donnée
          if (_totalFishesCount == 0 && _totalAccidentsCount == 0) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucune statistique disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cette session ne contient pas encore de données de capture.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
