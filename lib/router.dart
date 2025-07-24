import 'package:carnet_prise/pages/home_page.dart';
import 'package:carnet_prise/pages/sessions/add_session_screen.dart';
import 'package:carnet_prise/pages/sessions/session_details_screen.dart';
import 'package:carnet_prise/pages/statistics_page.dart';
import 'package:carnet_prise/pages/settings_page.dart';
import 'package:carnet_prise/widgets/navigation/bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
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
          routes: [
            GoRoute(
              path: "/session/create",
              name: "create_session",
              builder: (context, state) => const AddSessionScreen(),
            ),
            GoRoute(
              path: "/session/:id",
              builder: (context, state) {
                final sessionId = int.parse(state.pathParameters['id']!);
                return SessionDetailsScreen(sessionId: sessionId);
              },
            ),
          ],
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
