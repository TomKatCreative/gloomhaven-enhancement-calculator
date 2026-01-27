import 'package:flutter/material.dart';

/// A text widget with a custom strikethrough line that sits at a configurable
/// vertical position, unlike the built-in [TextDecoration.lineThrough]
/// which can sit too high depending on the font.
class StrikethroughText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double lineThickness;

  /// Vertical position of the strikethrough line as a fraction (0.0 = top, 1.0 = bottom).
  /// Default is 0.6 (slightly below center) which tends to look better across fonts.
  final double verticalPositionFraction;

  const StrikethroughText(
    this.text, {
    super.key,
    this.style,
    this.lineThickness = 1.5,
    this.verticalPositionFraction = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final lineColor = effectiveStyle.color ?? Colors.black;

    // Convert fraction (0.0-1.0) to Alignment y value (-1.0 to 1.0)
    final alignmentY = (verticalPositionFraction - 0.5) * 2;

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(text, style: effectiveStyle),
        Positioned.fill(
          child: Align(
            alignment: Alignment(0, alignmentY),
            child: Container(height: lineThickness, color: lineColor),
          ),
        ),
      ],
    );
  }
}
