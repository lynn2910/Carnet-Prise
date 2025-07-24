import 'package:carnet_prise/widgets/settings/theme_mode_selector.dart';
import 'package:carnet_prise/widgets/settings/username_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/settings/theme_color_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var titleTheme = theme.textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 1,
          title: const Text("Paramètres"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pushNamed("home");
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              //
              //  USERNAME
              //
              Text("Nom utilisateur", style: titleTheme),
              SizedBox(height: 20),
              const UsernameInput(),
              SizedBox(height: 20),

              //
              //  INTERFACE
              //
              Text("Interface", style: titleTheme),
              SizedBox(height: 20),
              const ThemeModeSelector(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Couleur de l'interface",
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const ThemeColorSelector(),
              SizedBox(height: 20),

              //
              //  DATA
              // TODO Ajouter la modif des data
              //
              Text("Données", style: titleTheme),
            ],
          ),
        ),
      ),
    );
  }
}
