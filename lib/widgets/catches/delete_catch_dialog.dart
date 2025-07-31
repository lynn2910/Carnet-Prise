import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/repositories/isar/catch_repository.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteCatchDialog extends StatefulWidget {
  final Catch catchItem;

  const DeleteCatchDialog({super.key, required this.catchItem});

  @override
  State<DeleteCatchDialog> createState() => _DeleteCatchDialogState();
}

class _DeleteCatchDialogState extends State<DeleteCatchDialog> {
  SessionRepository? _sessionRepository;
  CatchRepository? _catchRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
    _catchRepository ??= Provider.of<CatchRepository>(context);
  }

  Future<bool> _deleteCatch() async {
    if (_catchRepository == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Une erreur est survenue, veuillez réessayer."),
          ),
        );
      }
      return false;
    }

    try {
      bool success = await _catchRepository!.deleteCatch(widget.catchItem.id);

      if (!success) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Une erreur est survenue lors de la suppression. Veuillez réessayer.",
            ),
          ),
        );
      }
      return success;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Une erreur est survenue.")));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        "Supprimer une prise",
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Une fois supprimée, vous ne pourrez pas la restaurer.'),
            SizedBox(height: 16),
            Text('Êtes-vous sûr de vouloir cette entrée ?'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            bool success = await _deleteCatch();
            if (context.mounted) {
              Navigator.of(context).pop(success);
            }
          },
          child: const Text("Confirmer"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Annuler"),
        ),
      ],
    );
  }
}
