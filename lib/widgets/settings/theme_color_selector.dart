import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carnet_prise/stores/theme_manager.dart';

class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final List<Color> allowedColors = themeManager.allowedColors;
    final Color currentSeedColor = themeManager.seedColor;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allowedColors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 30.0,
        mainAxisSpacing: 30.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final Color color = allowedColors[index];
        final bool isSelected = color.toARGB32() == currentSeedColor.toARGB32();

        return GestureDetector(
          onTap: () {
            themeManager.setSeedColor(color);
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
    );
  }
}
