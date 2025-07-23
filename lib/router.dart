import 'package:carnet_prise/pages/home_page.dart';
import 'package:carnet_prise/pages/statistics_page.dart';
import 'package:carnet_prise/pages/settings_page.dart';
import 'package:carnet_prise/widgets/navigation/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: "home",
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/statistics',
          name: "statistics",
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: "settings",
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
