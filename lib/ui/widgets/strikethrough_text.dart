import 'package:flutter/material.dart';

/// A text widget with a strikethrough line using [TextDecoration.lineThrough].
/// Supports multi-line text.
class StrikethroughText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double lineThickness;

  const StrikethroughText(
    this.text, {
    super.key,
    this.style,
    this.lineThickness = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final lineColor = effectiveStyle.color ?? Colors.black;

    return Text(
      text,
      style: effectiveStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: lineColor,
        decorationThickness: lineThickness,
      ),
    );
  }
}
