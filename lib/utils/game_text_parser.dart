import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_tokenizer.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_tokens.dart';

/// # Game Text Syntax Documentation
///
/// This parser supports the following syntax for rich text formatting:
///
/// - **Bold Text**: `**text**` - Text within double asterisks becomes bold
///   Example: `**Rested and Ready:**` becomes bold
///
/// - **Italic Text**: `*text*` - Text within single asterisks becomes italic
///   Example: `*Reviving Ether*` becomes italic
///
/// - **Icons**: Uppercase words that match asset names in `asset_config.dart`
///   Example: `ATTACK`, `MOVE`, `HEAL`, `FIRE`, `ICE`
///
/// - **Attack Modifiers**: Signed numbers that match modifier assets
///   Example: `+1`, `+2`, `-1`, `+0`, `2x`, `NULL`
///   These render as the colored attack modifier card icons.
///
/// - **Action Icons with +1 Overlay**: Action icon followed by `+1` suffix
///   Example: `MOVE+1`, `ATTACK+1`, `RANGE+1`
///   These render the base icon with a small green +1 badge overlaid.
///   Note: This is different from standalone `+1` which renders as a modifier.
///
/// - **XP Values**: `xpN` where N is a number
///   Example: `xp8` renders as XP icon with "8" overlay
///
/// - **Stacked Elements**: `ELEMENT&ELEMENT`
///   Example: `FIRE&ICE` renders two element icons stacked diagonally
///
/// - **Text Replacements**: Special words converted to plain text symbols
///   - `plusone` → `+1` (as text, not icon)
///   - `plustwo` → `+2` (as text, not icon)
///   - `pluszero` → `+0` (as text, not icon)
///
/// - **Plain Text**: Any other text renders normally

// Re-export token types and tokenizer for consumers
export 'package:gloomhaven_enhancement_calc/utils/game_text_tokens.dart';
export 'package:gloomhaven_enhancement_calc/utils/game_text_tokenizer.dart'
    show ParsedWord, GameTextTokenizer;

// ============================================================================
// RENDERER
// ============================================================================

/// Converts tokens to Flutter InlineSpan widgets
class GameTextRenderer {
  /// Render a list of tokens to InlineSpans
  static List<InlineSpan> render(
    BuildContext context,
    List<GameTextToken> tokens,
    bool darkTheme,
  ) {
    return tokens.map((token) => token.toSpan(context, darkTheme)).toList();
  }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Main entry point for parsing game text
///
/// This is a facade that combines tokenization and rendering.
/// Use this class to convert game text strings to Flutter widgets.
class GameTextParser {
  /// Parse game text and return InlineSpans ready for display
  ///
  /// Example:
  /// ```dart
  /// final spans = GameTextParser.parse(
  ///   context,
  ///   '**Bold Text:** Normal text ATTACK xp8 *italic*',
  ///   darkTheme: true,
  /// );
  ///
  /// RichText(text: TextSpan(children: spans));
  /// ```
  static List<InlineSpan> parse(
    BuildContext context,
    String text,
    bool darkTheme,
  ) {
    final tokens = GameTextTokenizer.tokenize(text, darkTheme);
    return GameTextRenderer.render(context, tokens, darkTheme);
  }
}
