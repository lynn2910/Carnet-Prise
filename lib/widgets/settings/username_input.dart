import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameInput extends StatefulWidget {
  const UsernameInput({super.key});

  @override
  State<UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends State<UsernameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadUsername();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString("username");
    if (savedUsername != null) {
      setState(() {
        _controller.text = savedUsername;
      });
    }
  }

  Future<void> _saveNewName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", name);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nom mis à jour : $name"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: false,
      minLines: 1,
      maxLength: 20,
      onSubmitted: (String newName) {
        _saveNewName(newName);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Entrez votre nom ici",
      ),
    );
  }
}
