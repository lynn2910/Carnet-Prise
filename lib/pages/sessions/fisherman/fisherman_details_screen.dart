import 'package:flutter/cupertino.dart';

class FishermanDetailsScreen extends StatefulWidget {
  const FishermanDetailsScreen({
    super.key,
    required this.sessionId,
    required this.fishermanId,
  });

  final int sessionId;
  final int fishermanId;

  @override
  State<FishermanDetailsScreen> createState() => _FishermanDetailsScreenState();
}

class _FishermanDetailsScreenState extends State<FishermanDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
