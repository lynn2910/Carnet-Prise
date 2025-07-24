import 'package:carnet_prise/repositories/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  SessionRepository? _sessionRepository;

  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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

      final newSession = Session()
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
        final sessionId = await _sessionRepository!.createSession(newSession);

        if (!mounted) return;

        context.push('/session/$sessionId');

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
    return Scaffold(
      appBar: AppBar(title: const Text('Création d\'une session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom du lieu de pêche
              const Text(
                'Nom du lieu de pêche',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Nom',
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Date de début
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date de début',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, isStartDate: true),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Date de fin',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, isStartDate: false),
                  ),
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
                  icon: const Icon(Icons.add),
                  label: const Text('Créer la session'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
