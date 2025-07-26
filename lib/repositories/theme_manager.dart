import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get themeMode => _themeMode;

  Color get seedColor => _seedColor;

  List<Color> get allowedColors => [
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.green,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.orange,
    Colors.pinkAccent,
    Colors.pink,
    Colors.red,
  ];

  ThemeManager() {
    _loadThemePreferences();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      _saveThemePreferences();
    }
  }

  void setSeedColor(Color color) {
    if (_seedColor != color) {
      _seedColor = color;
      notifyListeners();
      _saveThemePreferences();
    }
  }

  ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      brightness: Brightness.light,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt("themeMode") ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    final seedColorValue =
        prefs.getInt("seedColor") ?? Colors.deepPurple.toARGB32();
    _seedColor = Color(seedColorValue);

    notifyListeners();
  }

  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("themeMode", _themeMode.index);
    await prefs.setInt("seedColor", _seedColor.toARGB32());
  }
}
