import 'package:carnet_prise/models/session.dart';
import 'package:carnet_prise/repositories/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionDetailsScreen extends StatefulWidget {
  final int sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  Session? _session;
  late SessionRepository _sessionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository = Provider.of<SessionRepository>(context);
    _loadSessionDetails();
  }

  Future<void> _loadSessionDetails() async {
    final session = await _sessionRepository.getSessionById(widget.sessionId);
    setState(() {
      _session = session;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la session')),
      body: _session == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lieu de pêche: ${_session!.spotName ?? 'Non spécifié'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Date de début: ${DateFormat('dd/MM/yyyy').format(_session!.startDate!)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Date de fin: ${DateFormat('dd/MM/yyyy').format(_session!.endDate!)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pêcheurs participants:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _session!.fishermen.isEmpty
                      ? const Text('Aucun pêcheur associé à cette session.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _session!.fishermen
                              .map((f) => Text('- ${f.name}'))
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
