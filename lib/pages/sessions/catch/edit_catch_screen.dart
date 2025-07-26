import 'package:flutter/cupertino.dart';

class EditCatchScreen extends StatefulWidget {
  final int catchId;

  const EditCatchScreen({super.key, required this.catchId});

  @override
  State<EditCatchScreen> createState() => _EditCatchScreenState();
}

class _EditCatchScreenState extends State<EditCatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Edit catch screen"));
  }
}
