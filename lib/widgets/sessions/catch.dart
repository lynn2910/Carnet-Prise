import 'package:carnet_prise/models/catch.dart';
import 'package:flutter/material.dart';

class SingleCatch extends StatelessWidget {
  final Catch catchItem;

  const SingleCatch({super.key, required this.catchItem});

  @override
  Widget build(BuildContext context) {
    return Text("${catchItem.fishType}");
  }
}
