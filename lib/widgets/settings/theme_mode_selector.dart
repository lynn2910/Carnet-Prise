import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carnet_prise/stores/theme_manager.dart';

class ThemeModeSelector extends StatefulWidget {
  const ThemeModeSelector({super.key});

  @override
  State<ThemeModeSelector> createState() => _ThemeModeSelectorState();
}

class _ThemeModeSelectorState extends State<ThemeModeSelector> {
  Set<ThemeMode> _selectedMode = {ThemeMode.system};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedModeFromManager();
  }

  void _updateSelectedModeFromManager() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    setState(() {
      _selectedMode = {themeManager.themeMode};
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    if (!_selectedMode.contains(themeManager.themeMode)) {
      _selectedMode = {themeManager.themeMode};
    }

    return SegmentedButton<ThemeMode>(
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: true,
      segments: [
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text("Clair"),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          icon: Icon(Icons.settings),
          label: Text("Système"),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text("Sombre"),
        ),
      ],
      selected: _selectedMode,
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        if (newSelection.isNotEmpty) {
          final selectedMode = newSelection.first;
          themeManager.setThemeMode(selectedMode);
          setState(() {
            _selectedMode = newSelection;
          });
        }
      },
    );
  }
}
