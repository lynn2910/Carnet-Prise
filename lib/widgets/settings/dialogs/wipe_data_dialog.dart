import 'package:flutter/material.dart';

class WipeDataDialog extends StatefulWidget {
  const WipeDataDialog({super.key});

  @override
  State<WipeDataDialog> createState() => _WipeDataDialogState();
}

class _WipeDataDialogState extends State<WipeDataDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return AlertDialog(
      title: const Text("Êtes-vous sûr ?"),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'En supprimant toutes les données de l\'application, vous ne pourrez pas les restaurer.',
            ),
            SizedBox(height: 16),
            Text('Êtes-vous sûr de vouloir supprimer toutes les données ?'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            "Supprimer les données",
            style: theme.textTheme.labelMedium!.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text("Annuler"),
        ),
      ],
    );
  }
}
