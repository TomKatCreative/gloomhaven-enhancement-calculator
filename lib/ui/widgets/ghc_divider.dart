import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// A thin horizontal divider styled with the app's theme divider color.
///
/// Use [indent] to add horizontal padding (e.g., within cards where the
/// divider should not span the full width).
class GHCDivider extends StatelessWidget {
  /// When true, adds horizontal [largePadding] on both sides.
  final bool indent;

  const GHCDivider({super.key, this.indent = false});

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: Theme.of(context).dividerTheme.color,
    );
    if (indent) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: largePadding),
        child: divider,
      );
    }
    return divider;
  }
}
