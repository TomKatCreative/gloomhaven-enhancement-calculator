import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';

/// A dialog for selecting between different variants/editions of a player class.
///
/// Some classes have multiple versions across game editions (e.g., Brute in base
/// game vs Bruiser in Gloomhaven 2e). This dialog shows all available variants
/// as action buttons.
///
/// ## Example Usage
///
/// ```dart
/// final variant = await VariantSelectorDialog.show(
///   context: context,
///   playerClass: selectedClass,
/// );
///
/// if (variant != null) {
///   // User selected a variant
/// }
/// ```
class VariantSelectorDialog extends StatelessWidget {
  const VariantSelectorDialog({super.key, required this.playerClass});

  /// The player class to show variants for.
  final PlayerClass playerClass;

  /// Shows the variant selector dialog.
  ///
  /// Returns:
  /// - The selected [Variant] if the user chose one
  /// - `null` if the user cancelled or dismissed the dialog
  static Future<Variant?> show({
    required BuildContext context,
    required PlayerClass playerClass,
  }) {
    return showDialog<Variant?>(
      context: context,
      builder: (_) => VariantSelectorDialog(playerClass: playerClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perkLists = PlayerClass.perkListByClassCode(playerClass.classCode)!;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClassIconSvg(
            playerClass: playerClass,
            width: iconSizeXL,
            height: iconSizeXL,
          ),
          const SizedBox(width: largePadding),
          Text(playerClass.name, style: theme.textTheme.headlineLarge),
        ],
      ),
      content: const Text('Version', textAlign: TextAlign.center),
      actions: [
        // Create a button for each variant
        ...perkLists.map((perkList) {
          return TextButton(
            onPressed: () {
              Navigator.of(context).pop(perkList.variant);
            },
            child: Text(
              ClassVariants.classVariants[perkList.variant]!,
              textAlign: TextAlign.end,
              style: TextStyle(color: theme.contrastedPrimary),
            ),
          );
        }),
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.contrastedPrimary),
          ),
        ),
      ],
    );
  }
}
