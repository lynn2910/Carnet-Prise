import 'package:flutter/material.dart';

class FishermanColorSelect extends StatefulWidget {
  final void Function(Color) onChange;
  final Color? actualColor;

  const FishermanColorSelect({
    super.key,
    required this.onChange,
    required this.actualColor,
  });

  @override
  State<FishermanColorSelect> createState() => _FishermanColorSelectState();
}

class _FishermanColorSelectState extends State<FishermanColorSelect> {
  final List<Color> allowedColors = [
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.green,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.orange,
    Colors.pinkAccent,
    Colors.pink,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allowedColors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final Color color = allowedColors[index];
          bool isSelected = false;
          if (widget.actualColor != null) {
            isSelected = color.toARGB32() == widget.actualColor!.toARGB32();
          }

          return GestureDetector(
            onTap: () {
              widget.onChange(color);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[400]!,
                  width: isSelected ? 3.0 : 2.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
