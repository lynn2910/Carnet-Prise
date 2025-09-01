import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';

class EditSessionScreen extends StatefulWidget {
  final int sessionId;

  const EditSessionScreen({super.key, required this.sessionId});

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  SessionRepository? _sessionRepository;

  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;

  Session? _existingSession;

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
    _loadSession();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final session = await _sessionRepository!.getSessionById(widget.sessionId);

    setState(() {
      _existingSession = session;

      if (session != null) {
        _locationController.text = session.spotName!;
        _startDateController.text = session.startDate != null
            ? _formatDate(session.startDate!)
            : '';
        _endDateController.text = session.endDate != null
            ? _formatDate(session.endDate!)
            : '';

        _selectedDateDebut = session.startDate;
        _selectedDateFin = session.endDate;
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedDateDebut : _selectedDateFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedDateDebut = pickedDate;
          _startDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(pickedDate);
        } else {
          _selectedDateFin = pickedDate;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String location = _locationController.text;
      final DateTime? startDate = _selectedDateDebut;
      final DateTime? endDate = _selectedDateFin;

      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner les dates de début et de fin.',
            ),
          ),
        );
        return;
      }

      if (_existingSession == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Les informations de la session n\'ont pas encore chargées.',
            ),
          ),
        );
        return;
      }

      _existingSession!
        ..spotName = location
        ..startDate = startDate
        ..endDate = endDate;

      if (_sessionRepository == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur: Le repository de session n\'est pas initialisé.',
            ),
          ),
        );
        return;
      }

      try {
        await _sessionRepository!.updateSession(_existingSession!);

        if (!mounted) return;

        context.push('/session/${_existingSession!.id}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session créée avec succès !')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la session: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Modification d\'une session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50),
        child: _existingSession != null
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du lieu de pêche
                    const Text(
                      'Nom du lieu de pêche',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Nom du lieu de pêche',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _locationController.clear(),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom pour le lieu de pêche.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Dates
                    const Text(
                      'Dates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Date de début
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, isStartDate: true);
                      },
                      decoration: InputDecoration(
                        labelText: 'Date de début',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une date de début.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date de fin
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, isStartDate: false);
                      },
                      decoration: InputDecoration(
                        labelText: 'Date de fin',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une date de fin.';
                        }
                        if (_selectedDateDebut != null &&
                            _selectedDateFin != null &&
                            _selectedDateFin!.isBefore(_selectedDateDebut!)) {
                          return 'La date de fin ne peut pas être antérieure à la date de début.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Sauvegarder'),
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
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat("dd/MM/y").format(date);
}
