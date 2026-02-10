import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';

/// Utility class for generating UI elements from game text
class Utils {
  /// Generate rich text from game perk descriptions
  ///
  /// This method parses game text with special formatting and converts it
  /// to Flutter InlineSpans that can be displayed in RichText widgets.
  ///
  /// Supported syntax:
  /// - [Bold text in brackets]
  /// - UPPERCASE words for icons (ATTACK, MOVE, HEAL, etc.)
  /// - xpN for XP values (xp8 shows XP icon with "8")
  /// - ELEMENT&ELEMENT for stacked elements (FIRE&ICE)
  /// - ~text for italic text
  /// - plusone/plustwo/pluszero converts to +1/+2/+0
  ///
  /// Example:
  /// ```dart
  /// final spans = Utils.generateCheckRowDetails(
  ///   context,
  ///   '[Rested and Ready:] Whenever you long rest, add +1 MOVE',
  ///   darkTheme: true,
  /// );
  /// ```
  static List<InlineSpan> generateCheckRowDetails(
    BuildContext context,
    String details,
    bool darkTheme,
  ) {
    return GameTextParser.parse(context, details, darkTheme);
  }
}

/// Extension for string casing utilities
extension StringCasingExtension on String {
  /// Capitalize the first letter of a string
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';

  /// Convert string to title case (capitalize each word)
  String get toTitleCase => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(" ").map((str) => str.toCapitalized()).join(" ");
}

/// Widget that provides its size to a callback
class SizeProviderWidget extends StatefulWidget {
  final Widget child;
  final Function(Size?) onChildSize;

  const SizeProviderWidget({
    super.key,
    required this.onChildSize,
    required this.child,
  });

  @override
  SizeProviderWidgetState createState() => SizeProviderWidgetState();
}

class SizeProviderWidgetState extends State<SizeProviderWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        widget.onChildSize(context.size);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
