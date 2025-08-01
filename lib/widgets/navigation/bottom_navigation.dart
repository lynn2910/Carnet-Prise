import 'package:carnet_prise/widgets/wrappers/keyboard_dismiss_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Accueil",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.analytics),
            icon: Icon(Icons.analytics_outlined),
            label: "Statistiques",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: "Paramètres",
          ),
        ],
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int idx) {
          _onItemTapped(idx, context);
        },
      ),
      body: KeyboardDismissWrapper(child: child),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String location = state.uri.toString();

    if (location.startsWith('/statistics')) {
      return 1;
    } else if (location.startsWith('/settings')) {
      return 2;
    } else {
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.pushNamed('home');
        break;
      case 1:
        context.pushNamed('statistics');
        break;
      case 2:
        context.pushNamed('settings');
        break;
    }
  }
}
