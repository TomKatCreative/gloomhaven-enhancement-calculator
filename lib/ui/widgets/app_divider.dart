import 'package:flutter/material.dart';

/// Standard horizontal divider using the app's divider theme.
///
/// Use this instead of [Divider] to ensure consistent styling throughout the app.
/// Matches the style used in perk rows (CheckRowDivider).
class AppDivider extends StatelessWidget {
  /// The height of the divider widget (total space including the line).
  final double height;

  /// Optional indent from the start edge.
  final double? indent;

  /// Optional indent from the end edge.
  final double? endIndent;

  const AppDivider({
    super.key,
    this.height = 1,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      indent: indent,
      endIndent: endIndent,
      color: Theme.of(context).dividerTheme.color,
    );
  }
}

/// Standard vertical divider using the app's divider theme.
///
/// Use this instead of [VerticalDivider] or manual [Container] to ensure
/// consistent styling throughout the app.
class AppVerticalDivider extends StatelessWidget {
  /// The height of the divider line.
  final double height;

  /// Optional horizontal margin on each side.
  final double? horizontalMargin;

  const AppVerticalDivider({
    super.key,
    required this.height,
    this.horizontalMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      margin: horizontalMargin != null
          ? EdgeInsets.symmetric(horizontal: horizontalMargin!)
          : null,
      color: Theme.of(context).dividerTheme.color,
    );
  }
}
