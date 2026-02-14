import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// A pair of filled +/− icon buttons used for incrementing and decrementing
/// values in edit mode (prosperity, reputation, donations, etc.).
class StepperButtons extends StatelessWidget {
  const StepperButtons({
    super.key,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// Called when the minus button is tapped. Pass null to disable.
  final VoidCallback? onDecrement;

  /// Called when the plus button is tapped. Pass null to disable.
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton.filled(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_rounded),
          iconSize: iconSizeSmall,
          visualDensity: VisualDensity.comfortable,
        ),
        const SizedBox(width: mediumPadding),
        IconButton.filled(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_rounded),
          iconSize: iconSizeSmall,
          visualDensity: VisualDensity.comfortable,
        ),
      ],
    );
  }
}
