import 'package:flutter/cupertino.dart';

class EditFishermanScreen extends StatefulWidget {
  final int sessionId;
  final String fishermanId;

  const EditFishermanScreen({
    super.key,
    required this.sessionId,
    required this.fishermanId,
  });

  @override
  State<EditFishermanScreen> createState() => _EditFishermanScreenState();
}

class _EditFishermanScreenState extends State<EditFishermanScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Edit fisherman screen"));
  }
}
