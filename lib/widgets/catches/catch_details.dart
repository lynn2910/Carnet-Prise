import 'package:carnet_prise/models/catch.dart';
import 'package:flutter/material.dart';

class CatchDetails extends StatefulWidget {
  final Catch catchItem;

  const CatchDetails({super.key, required this.catchItem});

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails> {
  void _deleteItem() {}

  void _editItem() {}

  void _shareItem() {}

  @override
  Widget build(BuildContext context) {
    final catchItem = widget.catchItem;

    var theme = Theme.of(context);

    var primaryColor = theme.colorScheme.primaryContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: ListView(
          children: [
            //
            //  TITLE
            //
            Text(
              catchItem.fishermenName ?? "Chargement...",
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),

            //
            //  DATA
            //

            //
            //  BUTTONS
            //
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                //  DELETE
                //
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _deleteItem();
                    },
                    label: Text(
                      "Supprimer",
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    icon: Icon(
                      Icons.delete,
                      color: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return theme.colorScheme.error;
                        }
                        return theme.colorScheme.error;
                      }),
                    ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return theme.colorScheme.errorContainer.withValues(
                            alpha: 0.8,
                          );
                        }
                        return theme.colorScheme.errorContainer;
                      }),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            topRight: Radius.circular(7),
                            bottomRight: Radius.circular(7),
                          ),
                        ),
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return theme.colorScheme.error.withValues(alpha: 0.1);
                        }
                        return null;
                      }),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 2),

                // Edit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: IconButton.filled(
                    onPressed: () {
                      _editItem();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return primaryColor.withValues(alpha: 0.8);
                        }
                        return primaryColor;
                      }),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)) {
                          return theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          );
                        }
                        return null;
                      }),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(48, 48),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 2),

                // Share Button
                IconButton.filled(
                  onPressed: () {
                    _shareItem();
                  },
                  icon: Icon(
                    Icons.share,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed)) {
                        return primaryColor.withValues(alpha: 0.8);
                      }
                      return primaryColor;
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed)) {
                        return theme.colorScheme.primary.withValues(alpha: 0.1);
                      }
                      return null;
                    }),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                    ),
                    minimumSize: WidgetStateProperty.all<Size>(
                      const Size(48, 48),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
