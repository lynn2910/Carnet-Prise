import 'package:carnet_prise/models/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class SessionList extends StatefulWidget {
  final List<Session> sessions;
  final Function(Session session) onItemClick;

  const SessionList({
    super.key,
    required this.sessions,
    required this.onItemClick,
  });

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    var theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.sessions.length,
      itemBuilder: (context, index) {
        final session = widget.sessions[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: theme.colorScheme.surfaceContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {
                widget.onItemClick(session);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          session.id.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // Le texte du nom du lieu et des dates
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.spotName ?? "Lieu inconnu",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.startDate != null && session.endDate != null
                                ? "${DateFormat("d/MM/y").format(session.startDate!)} - ${DateFormat("d/MM/y").format(session.endDate!)}"
                                : "",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // Vous pouvez ajouter une icône ou une flèche ici si vous voulez
                    // const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
