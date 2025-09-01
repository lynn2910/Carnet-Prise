import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/fisherman/fisherman_color_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditFishermanScreen extends StatefulWidget {
  final int sessionId;
  final String fishermanId;

  const EditFishermanScreen({
    super.key,
    required this.sessionId,
    required this.fishermanId,
  });

  @override
  State<EditFishermanScreen> createState() => _EditFishermanScreenState();
}

class _EditFishermanScreenState extends State<EditFishermanScreen> {
  final _formKey = GlobalKey<FormState>();

  SessionRepository? _sessionRepository;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();

  Fisherman? _existingFisherman;
  String? _oldName;
  Color? _color;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String poste = _posteController.text;

      _existingFisherman!
        ..name = name
        ..spotNumber = poste
        ..colorSeed = _color?.toARGB32();

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
        await _sessionRepository!.addOrUpdateFishermanToSession(
          widget.sessionId,
          _existingFisherman!,
          oldName: _oldName,
        );

        if (!mounted) return;

        context.pop(_existingFisherman!.name);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pêcheur modifié avec succès !')),
        );
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
    _loadFisherman();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _posteController.dispose();

    super.dispose();
  }

  Future<void> _loadFisherman() async {
    final fisherman = await _sessionRepository!.getFishermanByName(
      widget.sessionId,
      widget.fishermanId,
    );

    setState(() {
      _existingFisherman = fisherman;

      if (fisherman != null) {
        _oldName = _existingFisherman!.name!;

        if (fisherman.colorSeed != null) {
          _color = Color(fisherman.colorSeed!);
        } else {
          _color = null;
        }

        _nameController.text = _existingFisherman!.name!;
        _posteController.text = _existingFisherman!.spotNumber!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Modification d'un participant")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50),
        child: _existingFisherman != null
            ? Column(
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

                            // Color
                            Text(
                              "Couleur du pêcheur",
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FishermanColorSelect(
                              actualColor: _color,
                              onChange: (color) {
                                setState(() {
                                  _color = color;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
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
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
