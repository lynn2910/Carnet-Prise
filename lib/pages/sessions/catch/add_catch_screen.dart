import 'package:flutter/cupertino.dart';

class AddCatchScreen extends StatefulWidget {
  final int? selectedFisherman;

  const AddCatchScreen({super.key, this.selectedFisherman});

  @override
  State<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends State<AddCatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Add catch screen"));
  }
}
