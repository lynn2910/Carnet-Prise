import 'package:carnet_prise/models/catch.dart';
import 'package:carnet_prise/models/fisherman.dart';
import 'package:carnet_prise/repositories/isar/session_repository.dart';
import 'package:carnet_prise/widgets/catches/catch_item.dart';
import 'package:carnet_prise/widgets/catches/delete_catch_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CatchDetails extends StatefulWidget {
  final Catch catchItem;
  final VoidCallback onCatchDeleted;
  final VoidCallback onCatchEdited;

  const CatchDetails({
    super.key,
    required this.catchItem,
    required this.onCatchDeleted,
    required this.onCatchEdited,
  });

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails> {
  SessionRepository? _sessionRepository;

  Fisherman? _fishermen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionRepository ??= Provider.of<SessionRepository>(context);
    _loadFishermen();
  }

  Future<void> _loadFishermen() async {
    await widget.catchItem.session.load();
    var fishermen = await _sessionRepository!.getFishermanByName(
      widget.catchItem.session.value!.id,
      widget.catchItem.fishermenName!,
    );

    if (fishermen != null) {
      setState(() {
        _fishermen = fishermen;
      });
    }
  }

  void _deleteItem() async {
    final bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DeleteCatchDialog(catchItem: widget.catchItem);
      },
    );

    if (mounted && success != null) {
      Navigator.of(context).pop();

      if (success == true) {
        widget.onCatchDeleted();
      }
    }
  }

  Future<void> _editItem() async {
    await widget.catchItem.session.load();
    if (!mounted) return;

    context
        .pushNamed(
          "edit_catch",
          pathParameters: {
            "session_id": widget.catchItem.session.value!.id.toString(),
            "catch_id": widget.catchItem.id.toString(),
          },
        )
        .then((_) => widget.onCatchEdited());
  }

  Future<void> _shareItem() async {
    await _loadFishermen();
    SharePlus.instance.share(
      ShareParams(text: widget.catchItem.shareSingle(_fishermen?.spotNumber)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var primaryColor = theme.colorScheme.primaryContainer;

    final catchItem = widget.catchItem;
    final bool wasCatchSuccessful = catchItem.accident == Accident.none;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            //  TITLE
            //
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16.0),
              child: Text(
                catchItem.fishermenName ?? "Chargement...",
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            //
            //  DATA
            //

            // catch date
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Date de prise",
                          style: theme.textTheme.titleMedium!,
                        ),
                      ),

                      Text(
                        formatDate(catchItem.catchDate!),
                        style: theme.textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        formatHour(catchItem.catchDate!),
                        style: theme.textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: theme.colorScheme.outlineVariant),

                const SizedBox(height: 8),
              ],
            ),

            // weight
            if (wasCatchSuccessful)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Poids",
                            style: theme.textTheme.titleMedium!,
                          ),
                        ),

                        Text(
                          "${catchItem.weight!.toStringAsFixed(2)} Kg",
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: theme.colorScheme.outlineVariant),

                  const SizedBox(height: 8),
                ],
              ),

            // fish type
            if (wasCatchSuccessful)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Type",
                            style: theme.textTheme.titleMedium!,
                          ),
                        ),

                        Text(
                          getCatchType(catchItem),
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: theme.colorScheme.outlineVariant),

                  const SizedBox(height: 8),
                ],
              ),

            // Accident
            if (!wasCatchSuccessful)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Accident",
                            style: theme.textTheme.titleMedium!,
                          ),
                        ),
                        Text(
                          formatAccident(catchItem.accident!),
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: theme.colorScheme.outlineVariant),

                  const SizedBox(height: 8),
                ],
              ),

            // spot number
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text("Poste", style: theme.textTheme.titleMedium!),
                  ),

                  Text(
                    _fishermen?.spotNumber != null
                        ? _fishermen!.spotNumber!
                        : "Chargement...",
                    style: theme.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),

            if (catchItem.annotations != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Annotation",
                            style: theme.textTheme.titleMedium!,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          catchItem.annotations!,
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                ],
              ),

            const SizedBox(height: 8),

            //
            //  BUTTONS
            //
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                //  DELETE
                //
                IconButton(
                  onPressed: () {
                    _deleteItem();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: theme.textTheme.titleLarge!.fontSize,
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
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
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
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 2),

                // Edit Button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: FilledButton.icon(
                      onPressed: () {
                        _editItem();
                      },
                      label: Text(
                        "Modifier",
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      icon: Icon(
                        Icons.edit,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: theme.textTheme.titleLarge!.fontSize,
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered) ||
                                states.contains(WidgetState.pressed)) {
                              return primaryColor.withValues(alpha: 0.8);
                            }
                            return primaryColor;
                          },
                        ),
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
                ),

                SizedBox(width: 2),

                // Share Button
                IconButton.filled(
                  onPressed: () {
                    _shareItem();
                  },
                  icon: Icon(
                    Icons.share,
                    size: theme.textTheme.titleLarge!.fontSize,
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
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
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

String formatAccident(Accident accident) {
  return getAccidentName(accident);
}

String formatDate(DateTime date) {
  return DateFormat("dd/MM/yy").format(date);
}

String formatHour(DateTime date) {
  return DateFormat(DateFormat.HOUR24_MINUTE).format(date);
}
