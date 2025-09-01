import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/catch_repository.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/catch.dart';
import '../../../models/session.dart';

class AddCatchScreen extends StatefulWidget {
  final String? selectedFisherman;
  final int selectedSessionId;

  const AddCatchScreen({
    super.key,
    this.selectedFisherman,
    required this.selectedSessionId,
  });

  @override
  State<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends State<AddCatchScreen> {
  final _formKey = GlobalKey<FormState>();

  late CatchRepository _catchRepository;
  late SessionRepository _sessionRepository;

  Fisherman? _selectedFisherman;
  Session? _currentSession;

  final TextEditingController _fishTypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime _catchDate = DateTime.now();
  Accident? _selectedAccident = Accident.none;
  String? _annotation;

  List<String> _autocompleteOptions = [];
  List<Fisherman> _allFishermen = [];

  @override
  void initState() {
    super.initState();

    _catchRepository = Provider.of<CatchRepository>(context, listen: false);
    _sessionRepository = Provider.of<SessionRepository>(context, listen: false);

    _loadAssociatedData().whenComplete(() {
      _loadAllFishermen();
    });
    _loadAutocompleteOptions();
  }

  Future<void> _loadAssociatedData() async {
    if (widget.selectedFisherman != null) {
      final fisherman = await _sessionRepository.getFishermanByName(
        widget.selectedSessionId,
        widget.selectedFisherman!,
      );
      setState(() {
        _selectedFisherman = fisherman;
      });
    }

    final session = await _sessionRepository.getSessionById(
      widget.selectedSessionId,
    );
    setState(() {
      _currentSession = session;
    });
  }

  Future<void> _loadAllFishermen() async {
    setState(() {
      _allFishermen = _currentSession!.fishermen.toList();
      if (widget.selectedFisherman != null) {
        _selectedFisherman = _allFishermen.firstWhereOrNull(
          (f) =>
              f.name?.toLowerCase().trim() ==
              widget.selectedFisherman?.toLowerCase().trim(),
        );
      }
    });
  }

  Future<void> _loadAutocompleteOptions() async {
    final options = await _catchRepository.getAllFishTypes();
    setState(() {
      _autocompleteOptions = options;
    });
  }

  FishType _getEnumType(String displayName) {
    switch (displayName) {
      case 'Carpe':
        return FishType.carp;
      case 'Autre':
        return FishType.other;
      default:
        return FishType.other;
    }
  }

  List<DropdownMenuItem<Accident>> _getAccidentDropdownItems() {
    return Accident.values.map((accident) {
      String text = getAccidentName(accident);
      return DropdownMenuItem(value: accident, child: Text(text));
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _catchDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_catchDate),
      );
      if (pickedTime != null) {
        setState(() {
          _catchDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validation de la dépendance poids/type vs accident
      if (_selectedAccident == Accident.none) {
        if (_weightController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez entrer le poids du poisson.'),
            ),
          );
          return;
        }
        if (_fishTypeController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez entrer le type de poisson.'),
            ),
          );
          return;
        }
      }

      if (_selectedFisherman == null || _currentSession == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur: Pêcheur ou Session non sélectionnés. Impossible d\'enregistrer la prise.',
            ),
          ),
        );
        return;
      }

      final newCatch = Catch();
      newCatch.catchDate = _catchDate;
      newCatch.accident = _selectedAccident;
      newCatch.annotations = _annotation;

      // Assigner les liens
      newCatch.fishermenName = _selectedFisherman!.name!;
      newCatch.session.value = _currentSession;

      // Logique pour le poids et le type de poisson si pas d'accident
      if (_selectedAccident == Accident.none) {
        newCatch.weight = double.tryParse(_weightController.text);

        if (newCatch.weight != null && newCatch.weight! < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur: Le poids ne peut pas être un nombre négatif.',
              ),
            ),
          );
          return;
        }

        final enteredFishType = _fishTypeController.text.trim();

        if (getPredefinedFishTypes().contains(enteredFishType)) {
          newCatch.fishType = _getEnumType(enteredFishType);
          newCatch.otherFishType = null;
        } else {
          newCatch.fishType = FishType.other;
          newCatch.otherFishType = enteredFishType;
        }
      } else {
        newCatch.weight = null;
        newCatch.fishType = null;
        newCatch.otherFishType = null;
      }

      try {
        await _catchRepository.createCatch(
          _currentSession!.id,
          _selectedFisherman!.name ?? "",
          newCatch,
        );

        if (mounted) {
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'enregistrement de la prise: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _fishTypeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle prise")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations générales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Champ de sélection du pêcheur
                      DropdownButtonFormField<Fisherman>(
                        value: _selectedFisherman,
                        items: _allFishermen.map((Fisherman fisherman) {
                          return DropdownMenuItem<Fisherman>(
                            value: fisherman,
                            child: Text(fisherman.name ?? 'Pêcheur sans nom'),
                          );
                        }).toList(),
                        onChanged: (Fisherman? newValue) {
                          setState(() {
                            _selectedFisherman = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nom du pêcheur',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un pêcheur.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Champ Date de prise
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date de prise',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(_catchDate),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Poisson',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Champ Poids du poisson
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        enabled: _selectedAccident == Accident.none,
                        decoration: InputDecoration(
                          labelText: 'Poids du poisson',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _weightController.clear(),
                          ),
                        ),
                        validator: (value) {
                          if (_selectedAccident == Accident.none) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le poids du poisson.';
                            }
                            double? d = double.tryParse(value);
                            if (d == null) {
                              return 'Veuillez entrer un nombre valide.';
                            }
                            if (d < 0) {
                              return "Veuillez entrer un nombre positif.";
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Champ Type de poisson (Autocomplete)
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty &&
                              _fishTypeController.text.isEmpty &&
                              _autocompleteOptions.isNotEmpty) {
                            return _autocompleteOptions;
                          }
                          return _autocompleteOptions.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          _fishTypeController.text = selection;
                          debugPrint('You just selected $selection');
                        },
                        displayStringForOption: (String option) => option,
                        fieldViewBuilder:
                            (
                              BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              if (_fishTypeController.text.isNotEmpty &&
                                  fieldTextEditingController.text.isEmpty) {
                                fieldTextEditingController.text =
                                    _fishTypeController.text;
                              }
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                enabled: _selectedAccident == Accident.none,
                                decoration: const InputDecoration(
                                  labelText: 'Type de poisson',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (_selectedAccident == Accident.none &&
                                      (value == null || value.isEmpty)) {
                                    return 'Veuillez entrer le type de poisson.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _fishTypeController.text = value;
                                },
                              );
                            },
                        optionsViewBuilder:
                            (
                              BuildContext context,
                              AutocompleteOnSelected<String> onSelected,
                              Iterable<String> options,
                            ) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 200,
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          100,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            final String option = options
                                                .elementAt(index);
                                            return InkWell(
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(option),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
                      const SizedBox(height: 16),
                      // Champ Accident
                      DropdownButtonFormField<Accident>(
                        value: _selectedAccident,
                        items: _getAccidentDropdownItems(),
                        onChanged: (Accident? newValue) {
                          setState(() {
                            _selectedAccident = newValue;
                            if (newValue != Accident.none) {
                              _weightController.clear();
                              _fishTypeController.clear();
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Accident',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un type d\'accident.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Informations supplémentaires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: null,
                        onChanged: (newAnnotation) {
                          setState(() {
                            _annotation = newAnnotation;
                          });
                        },
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.clear),
                          labelText: 'Annotation',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.add),
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
        ),
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
