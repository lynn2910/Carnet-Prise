import 'package:carnet_prise/repositories/isar/catch_repository.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/router.dart';
import 'package:carnet_prise/repositories/isar_service.dart';
import 'package:carnet_prise/repositories/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        Provider<IsarService>(create: (context) => isarService),
        Provider<SessionRepository>(
          create: (context) => SessionRepository(context.read<IsarService>()),
        ),
        Provider<CatchRepository>(
          create: (context) => CatchRepository(context.read<IsarService>()),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: themeManager.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        systemNavigationBarColor: themeManager.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        systemNavigationBarIconBrightness:
            themeManager.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Carnet de Prise',
      debugShowCheckedModeBanner: false,
      theme: themeManager.lightTheme(),
      darkTheme: themeManager.darkTheme(),
      themeMode: themeManager.themeMode,
      locale: const Locale("fr"),
    );
  }
}
