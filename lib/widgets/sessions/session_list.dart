import 'package:carnet_prise/models/session.dart';
import 'package:flutter/material.dart';

class SessionList extends StatefulWidget {
  // Déclarez la variable 'sessions' comme 'final'
  final List<Session> sessions;

  // Ajoutez un constructeur qui prend 'sessions' en paramètre
  const SessionList({super.key, required this.sessions});

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.sessions.length,
      itemBuilder: (context, index) {
        final session = widget.sessions[index];
        return ListTile(title: Text(session.id.toString()));
      },
    );
  }
}
