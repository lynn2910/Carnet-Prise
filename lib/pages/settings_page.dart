import 'package:carnet_prise/repositories/isar/catch_repository.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/repositories/isar_service.dart';
import 'package:carnet_prise/widgets/settings/dialogs/import_data_dialog.dart';
import 'package:carnet_prise/widgets/settings/dialogs/wipe_data_dialog.dart';
import 'package:carnet_prise/widgets/settings/theme_mode_selector.dart';
import 'package:carnet_prise/widgets/settings/username_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../repositories/clean.dart';
import '../repositories/import.dart';
import '../widgets/settings/theme_color_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SessionRepository? _sessionRepository;
  CatchRepository? _catchRepository;
  IsarService? _isarService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catchRepository ??= Provider.of<CatchRepository>(context);
    _sessionRepository ??= Provider.of<SessionRepository>(context);
    _isarService ??= Provider.of<IsarService>(context);
  }

  Future<void> _clearData() async {
    if (_isarService == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("Veuillez réessayer.")));
    }

    bool? acceptedToDelete = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WipeDataDialog();
      },
    );

    if (acceptedToDelete ?? false) {
      cleanDatabase(_isarService!, resetPreferences: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Les données ont été supprimées.")),
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Redémarrage nécessaire"),
              content: const Text("L'application va devoir redémarrer."),
              actions: [
                TextButton(
                  onPressed: () {
                    Restart.restartApp(
                      notificationTitle: "Redémarrage de l'application...",
                      notificationBody:
                          "L'application est en train de redémarrer. Veuillez patienter",
                    );
                  },
                  child: const Text("Redémarrer"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _importData() async {
    if (_isarService == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("Veuillez réessayer.")));
    }

    bool? wipeDataBefore = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ImportDataDialog();
      },
    );

    if (wipeDataBefore == null) return;

    importData(replaceExisting: wipeDataBefore);
  }

  Future<void> _exportData() async {
    if (_isarService == null || _sessionRepository == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("Veuillez réessayer.")));
    }

    exportData(_isarService!, _sessionRepository!);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var titleTheme = theme.textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
              //
              Text("Données", style: titleTheme),

              SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _importData();
                    },
                    label: const Text("Importer depuis un fichier"),
                    icon: const Icon(Icons.file_download_outlined),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _exportData();
                    },
                    label: const Text("Exporter vers un fichier"),
                    icon: const Icon(Icons.file_upload_outlined),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _clearData();
                    },
                    label: const Text("Supprimer toutes les données"),
                    icon: const Icon(Icons.delete_forever),
                    style: TextButton.styleFrom(
                      iconColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Text(
                "Application développée par Cédric COLIN",
                style: theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
