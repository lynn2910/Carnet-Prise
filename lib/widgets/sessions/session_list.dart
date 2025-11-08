import 'package:carnet_prise/models/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionList extends StatefulWidget {
  final List<Session> sessions;
  final Function(Session session) onItemClick;
  final Function(Session session)? onItemLongPress;
  final bool isSelectionMode;
  final Set<int> selectedSessionIds;

  const SessionList({
    super.key,
    required this.sessions,
    required this.onItemClick,
    this.onItemLongPress,
    this.isSelectionMode = false,
    this.selectedSessionIds = const {},
  });

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  String _formatDate(Session session) {
    if (session.startDate == null || session.endDate == null) return "";

    if (session.startDate!.month == session.endDate!.month) {
      return DateFormat("MMM yyyy", 'fr-FR').format(session.startDate!);
    } else {
      return "${DateFormat("MMM yyyy", 'fr-FR').format(session.startDate!)} - ${DateFormat("MMM yyyy", 'fr-FR').format(session.endDate!)}";
    }
  }

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
        final isSelected = widget.selectedSessionIds.contains(session.id);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {
                widget.onItemClick(session);
              },
              onLongPress: widget.onItemLongPress != null
                  ? () => widget.onItemLongPress!(session)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icône de sélection ou numéro de session
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: widget.isSelectionMode && isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.onPrimary,
                                size: 24,
                              )
                            : Text(
                                session.id.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : null,
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
                            _formatDate(session).capitalize(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.spotName ?? "Lieu inconnu",
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
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

extension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
