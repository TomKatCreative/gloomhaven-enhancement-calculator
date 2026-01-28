import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';

/// Utility for building RichText widgets from markdown-formatted strings.
///
/// This separates the presentation layer from content, making strings easier
/// to maintain and test. Use in conjunction with [Strings] class which provides
/// the raw content.
class RichTextBuilder {
  /// Build a [RichText] widget from markdown-formatted string.
  ///
  /// Uses [GameTextParser] to convert markdown syntax (**bold**, *italic*,
  /// icons, etc.) into properly formatted [InlineSpan]s.
  ///
  /// Parameters:
  /// - [context]: BuildContext for accessing theme
  /// - [content]: Markdown-formatted string
  /// - [darkMode]: Whether app is in dark mode (affects icon theming)
  static RichText build(BuildContext context, String content, bool darkMode) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: GameTextParser.parse(context, content, darkMode),
      ),
    );
  }
}
