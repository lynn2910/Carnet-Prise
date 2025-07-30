import 'package:carnet_prise/pages/home_page.dart';
import 'package:carnet_prise/pages/sessions/add_session_screen.dart';
import 'package:carnet_prise/pages/sessions/catch/add_catch_screen.dart';
import 'package:carnet_prise/pages/sessions/catch/edit_catch_screen.dart';
import 'package:carnet_prise/pages/sessions/fisherman/add_fisherman_screen.dart';
import 'package:carnet_prise/pages/sessions/fisherman/edit_fisherman_screen.dart';
import 'package:carnet_prise/pages/sessions/fisherman/fisherman_details_screen.dart';
import 'package:carnet_prise/pages/sessions/session_details_screen.dart';
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
          routes: [
            GoRoute(
              path: "/session/create",
              name: "create_session",
              builder: (context, state) => const AddSessionScreen(),
            ),
            GoRoute(
              path: "/session/:session_id",
              name: "session_details",
              builder: (context, state) {
                final sessionId = int.parse(
                  state.pathParameters['session_id']!,
                );
                return SessionDetailsScreen(sessionId: sessionId);
              },
              routes: [
                // Add catch
                GoRoute(
                  path: "/catch/add",
                  name: "add_catch",
                  builder: (context, state) {
                    final sessionId = int.parse(
                      state.pathParameters['session_id']!,
                    );
                    return AddCatchScreen(selectedSessionId: sessionId);
                  },
                ),
                // Edit catch
                GoRoute(
                  path: "/catch/:catch_id/edit",
                  name: "edit_catch",
                  builder: (context, state) {
                    final catchId = int.parse(
                      state.pathParameters['catch_id']!,
                    );
                    return EditCatchScreen(catchId: catchId);
                  },
                ),
                // Add fisherman
                GoRoute(
                  path: "/fisherman/add",
                  name: "add_fisherman",
                  builder: (context, state) {
                    final sessionId = int.parse(
                      state.pathParameters['session_id']!,
                    );
                    return AddFishermanScreen(sessionId: sessionId);
                  },
                ),
                // Fisherman details
                GoRoute(
                  path: "/fisherman/:fisherman_id",
                  name: "fisherman_details",
                  builder: (context, state) {
                    final sessionId = int.parse(
                      state.pathParameters['session_id']!,
                    );
                    return FishermanDetailsScreen(
                      sessionId: sessionId,
                      fishermanId: state.pathParameters['fisherman_id']!,
                    );
                  },
                  routes: [
                    // Add catch
                    GoRoute(
                      path: "/catch/add",
                      name: "add_catch_from_fisherman",
                      builder: (context, state) {
                        final sessionId = int.parse(
                          state.pathParameters['session_id']!,
                        );
                        return AddCatchScreen(
                          selectedFisherman:
                              state.pathParameters['fisherman_id']!,
                          selectedSessionId: sessionId,
                        );
                      },
                    ),
                    // Edit fisherman
                    GoRoute(
                      path: "/edit",
                      name: "edit_fisherman",
                      builder: (context, state) {
                        final sessionId = int.parse(
                          state.pathParameters['session_id']!,
                        );
                        return EditFishermanScreen(
                          sessionId: sessionId,
                          fishermanId: state.pathParameters['fisherman_id']!,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // TODO implémenter le système de statistiques
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
