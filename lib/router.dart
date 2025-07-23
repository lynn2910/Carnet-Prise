import 'package:carnet_prise/pages/HomeScreen.dart';
import 'package:carnet_prise/pages/StatisticsScreen.dart';
import 'package:carnet_prise/pages/SettingsScreen.dart';
import 'package:carnet_prise/widgets/navigation/BottomNavigation.dart';
import 'package:flutter/material.dart';
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