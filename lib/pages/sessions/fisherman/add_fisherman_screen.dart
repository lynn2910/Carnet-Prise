import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddFishermanScreen extends StatefulWidget {
  final int sessionId;

  const AddFishermanScreen({super.key, required this.sessionId});

  @override
  State<AddFishermanScreen> createState() => _AddFishermanScreenState();
}

class _AddFishermanScreenState extends State<AddFishermanScreen> {
  final _formKey = GlobalKey<FormState>();

  SessionRepository? _sessionRepository;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String poste = _posteController.text;

      final newFisherman = Fisherman()
        ..name = name
        ..spotNumber = poste;

      if (_sessionRepository == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Erreur: Le repository de session n'est pas initialisé",
            ),
          ),
        );
        return;
      }

      try {
        final fishermanId = await _sessionRepository!.addFishermanToSession(
          widget.sessionId,
          newFisherman,
        );

        if (!mounted) return;

        if (fishermanId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Une erreur est survenue. Veuillez relancer l\'application',
              ),
            ),
          );
        } else {
          context.pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pêcheur enregistré avec succès !')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'enregistrement du pêcheur: $e"),
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _posteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajout d'un participant")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom du pêcheur",
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Prénom du pêcheur",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _nameController.clear(),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer le nom du pêcheur.";
                            }
                            return null;
                          },
                        ),
                      ),
                      // Poste
                      Text(
                        "Poste de pêche",
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: TextFormField(
                          controller: _posteController,
                          decoration: InputDecoration(
                            hintText: "Numéro du poste de pêche",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _posteController.clear(),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer le poste du pêcheur.";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.add),
                label: const Text('Créer la session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
