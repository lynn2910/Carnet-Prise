import 'package:carnet_prise/widgets/settings/UsernameInput.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          title: Text("Paramètres"),
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
              Text("Nom utilisateur", style: titleTheme),
              SizedBox(height: 20),
              UsernameInput(),
            ],
          ),
        ),
      ),
    );
  }
}
