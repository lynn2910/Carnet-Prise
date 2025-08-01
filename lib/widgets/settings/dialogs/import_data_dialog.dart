import 'package:flutter/material.dart';

class ImportDataDialog extends StatelessWidget {
  const ImportDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Importation de données"),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'Souhaitez-vous nettoyer les données de l\'application au préalable ?',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text("Garder les données existantes"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Supprimer les données existantes"),
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
