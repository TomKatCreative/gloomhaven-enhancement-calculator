import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';

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

// ============================================================================
// TOKEN DEFINITIONS
// ============================================================================

/// Base class for all game text tokens
abstract class GameTextToken {
  const GameTextToken();

  /// Convert this token to an InlineSpan for rendering
  InlineSpan toSpan(BuildContext context, bool darkTheme);
}

/// Token for bold text wrapped in square brackets [like this]
class BoldToken extends GameTextToken {
  final String text;

  const BoldToken(this.text);

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    return TextSpan(
      text: text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        letterSpacing: 0.7,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Token for game icons (ATTACK, MOVE, HEAL, etc.)
///
/// Icon coloring is controlled by [AssetConfig.themeMode]:
/// - [CurrentColorTheme]: Sets SVG's `currentColor` per theme (for icons with themed parts)
/// - [NoTheme]: No color modification
class IconToken extends GameTextToken {
  /// The original text element (e.g., 'ATTACK', 'MOVE+1')
  final String element;

  /// The asset configuration for this icon
  final AssetConfig config;

  /// Whether to show a +1 overlay badge (detected from "+1" suffix in element)
  final bool showPlusOneOverlay;

  const IconToken({
    required this.element,
    required this.config,
    this.showPlusOneOverlay = false,
  });

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    final baseSize = iconSize - 2.5;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Tooltip(
        message: _formatTooltipMessage(element),
        child: SizedBox(
          height: baseSize,
          width: baseSize * config.widthMultiplier,
          child: _buildIconContent(darkTheme),
        ),
      ),
    );
  }

  String _formatTooltipMessage(String element) {
    return element
        .toLowerCase()
        .replaceAll(RegExp(r'["|,]'), '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Widget _buildIconContent(bool darkTheme) {
    final assetPath = config.pathForTheme(darkTheme);

    // Handle XP icons
    if (assetPath == 'ui/xp.svg') {
      final xpNumber = RegExp(r'\d+').firstMatch(element)?.group(0) ?? '';
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildSvgPicture(assetPath, darkTheme),
          Positioned(
            bottom: -1,
            child: Text(
              xpNumber,
              style: TextStyle(
                fontFamily: pirataOne,
                fontSize: 20,
                color: darkTheme ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // Handle consume icons
    if (element.toLowerCase().contains('consume')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildSvgPicture(assetPath, darkTheme),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              height: 12,
              width: 12,
              child: SvgPicture(
                SvgAssetLoader(
                  'images/${assets['CONSUME']!.path}',
                  theme: SvgTheme(
                    currentColor: darkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Handle +1 overlay icons (detected from element suffix)
    if (showPlusOneOverlay) {
      return Stack(
        alignment: const Alignment(1.75, -1.75),
        children: [
          _buildSvgPicture(assetPath, darkTheme),
          SvgPicture.asset(
            'images/ui/plus_one.svg',
            width: iconSize * 0.5,
            height: iconSize * 0.5,
          ),
        ],
      );
    }

    return _buildSvgPicture(assetPath, darkTheme);
  }

  /// Builds an [SvgPicture] with appropriate color handling based on theme.
  ///
  /// Color behavior is determined by [config.themeMode]:
  /// - [CurrentColorTheme]: Sets `currentColor` to white/black based on theme
  /// - [NoTheme]: Renders SVG as-is with no color modification
  SvgPicture _buildSvgPicture(String assetPath, bool darkTheme) {
    final fullPath = 'images/$assetPath';

    return switch (config.themeMode) {
      CurrentColorTheme() => SvgPicture(
        SvgAssetLoader(
          fullPath,
          theme: SvgTheme(
            currentColor: darkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
      _ => SvgPicture.asset(fullPath),
    };
  }
}

/// Token for stacked element icons (FIRE&ICE)
class StackedElementToken extends GameTextToken {
  final String element1;
  final String element2;

  const StackedElementToken(this.element1, this.element2);

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: SizedBox(
        height: iconSize,
        width: iconSize,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                'images/elements/elem_${element1.toLowerCase()}.svg',
                width: iconSize * 0.7,
                height: iconSize * 0.7,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                'images/elements/elem_${element2.toLowerCase()}.svg',
                width: iconSize * 0.7,
                height: iconSize * 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Token for italic text prefixed with *
class ItalicToken extends GameTextToken {
  final String text;

  const ItalicToken(this.text);

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    return TextSpan(
      text: text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
    );
  }
}

/// Token for plain text
class PlainTextToken extends GameTextToken {
  final String text;

  const PlainTextToken(this.text);

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    return TextSpan(text: text);
  }
}

/// Token for punctuation (preserved separately for proper spacing)
class PunctuationToken extends GameTextToken {
  final String punctuation;

  const PunctuationToken(this.punctuation);

  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    return TextSpan(text: punctuation);
  }
}

// ============================================================================
// WORD PARSING
// ============================================================================

/// Result of parsing a raw word into its components.
///
/// Handles extraction of:
/// - Leading punctuation (e.g., quotes, parentheses)
/// - Trailing punctuation (e.g., commas, periods)
/// - +1 overlay suffix detection for compound icons (e.g., "MOVE+1")
/// - Clean asset key for lookup in the assets map
///
/// ## Important: +1 Handling
///
/// There are TWO different uses of "+1" in game text:
///
/// 1. **Standalone attack modifier icons**: `+1`, `+2`, `-1`, etc.
///    These are complete asset keys that map to `attack_modifiers/plus_1.svg`.
///    The word "+1" should be looked up directly in the assets map.
///
/// 2. **Overlay suffix on action icons**: `MOVE+1`, `ATTACK+1`, etc.
///    These render the base icon (MOVE) with a small "+1" badge overlaid.
///    The "+1" suffix is stripped, and [hasPlusOneOverlay] is set to true.
///
/// The parsing logic must distinguish between these cases:
/// - "+1" alone → assetKey: "+1", hasPlusOneOverlay: false
/// - "MOVE+1" → assetKey: "MOVE", hasPlusOneOverlay: true
class ParsedWord {
  static const _leadingPunctuation = ['"', "'", '('];
  static const _trailingPunctuation = ['"', "'", ',', ')', '.'];

  /// The cleaned asset key (no punctuation, +1 suffix stripped only if overlay)
  ///
  /// For standalone modifiers like "+1", this contains the full "+1".
  /// For overlay cases like "MOVE+1", this contains just "MOVE".
  final String assetKey;

  /// Leading punctuation character, if any
  final String? leadingPunct;

  /// Trailing punctuation character, if any
  final String? trailingPunct;

  /// Whether the word had a +1 suffix that should be rendered as an overlay.
  ///
  /// Only true for compound icons like "MOVE+1" where we render the MOVE icon
  /// with a small +1 badge. NOT true for standalone "+1" attack modifiers.
  final bool hasPlusOneOverlay;

  const ParsedWord({
    required this.assetKey,
    this.leadingPunct,
    this.trailingPunct,
    this.hasPlusOneOverlay = false,
  });

  /// Parse a raw word into its components.
  ///
  /// ## Examples
  ///
  /// Compound icon with overlay:
  /// ```
  /// "MOVE+1," -> ParsedWord(
  ///   assetKey: 'MOVE',
  ///   leadingPunct: '"',
  ///   trailingPunct: ',',
  ///   hasPlusOneOverlay: true,
  /// )
  /// ```
  ///
  /// Standalone attack modifier (no overlay):
  /// ```
  /// "+1" -> ParsedWord(
  ///   assetKey: '+1',
  ///   hasPlusOneOverlay: false,
  /// )
  /// ```
  factory ParsedWord.from(String word) {
    String working = word;
    String? leading;
    String? trailing;

    // Strip leading punctuation (quotes, parentheses)
    if (working.isNotEmpty && _leadingPunctuation.contains(working[0])) {
      leading = working[0];
      working = working.substring(1);
    }

    // Strip trailing punctuation (quotes, commas, parentheses, periods)
    if (working.isNotEmpty &&
        _trailingPunctuation.contains(working[working.length - 1])) {
      trailing = working[working.length - 1];
      working = working.substring(0, working.length - 1);
    }

    // Detect and strip +1 suffix for OVERLAY icons only.
    //
    // CRITICAL: Only strip if something remains after stripping (length > 2).
    // This distinguishes between:
    //   - "MOVE+1" (length 7) → strip to "MOVE", overlay = true
    //   - "+1" (length 2) → keep as "+1", overlay = false
    //
    // Without the length check, "+1" would become "" with overlay = true,
    // causing tryGetAssetConfig("") to return null and the attack modifier
    // icon would not render.
    bool plusOne = false;
    if (working.endsWith('+1') && working.length > 2) {
      working = working.substring(0, working.length - 2);
      plusOne = true;
    }

    return ParsedWord(
      assetKey: working,
      leadingPunct: leading,
      trailingPunct: trailing,
      hasPlusOneOverlay: plusOne,
    );
  }
}

// ============================================================================
// TOKENIZER
// ============================================================================

/// Converts raw game text strings into a list of tokens
class GameTextTokenizer {
  /// Tokenize a complete game text string
  static List<GameTextToken> tokenize(String text, bool darkTheme) {
    final List<GameTextToken> tokens = [];

    // First pass: handle formatted text sections (bold and italic)
    final segments = _splitByFormattedSections(text);

    for (final segment in segments) {
      if (segment.format == _TextFormat.bold) {
        tokens.add(BoldToken(segment.text));
      } else if (segment.format == _TextFormat.italic) {
        tokens.add(ItalicToken(segment.text));
      } else {
        // Plain text: tokenize by words
        tokens.addAll(_tokenizeWords(segment.text, darkTheme));
      }
    }

    return tokens;
  }

  /// Split text into formatted sections (bold, italic, plain)
  static List<_TextSegment> _splitByFormattedSections(String text) {
    final segments = <_TextSegment>[];

    // Match **bold** or *italic* - IMPORTANT: **bold** must come first!
    final formatRegex = RegExp(r'\*\*([^*]+)\*\*|\*([^*]+)\*');
    int lastIndex = 0;

    for (final match in formatRegex.allMatches(text)) {
      // Add text before match as plain
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          segments.add(_TextSegment(beforeText, format: _TextFormat.plain));
        }
      }

      // Determine if this is bold or italic based on which group matched
      if (match.group(1) != null) {
        // Group 1 = **bold**
        segments.add(_TextSegment(match.group(1)!, format: _TextFormat.bold));
      } else if (match.group(2) != null) {
        // Group 2 = *italic*
        segments.add(_TextSegment(match.group(2)!, format: _TextFormat.italic));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      final remaining = text.substring(lastIndex);
      if (remaining.isNotEmpty) {
        segments.add(_TextSegment(remaining, format: _TextFormat.plain));
      }
    }

    return segments;
  }

  /// Tokenize a text segment into word-level tokens
  static List<GameTextToken> _tokenizeWords(String text, bool darkTheme) {
    final tokens = <GameTextToken>[];

    // Preserve leading spaces
    if (text.startsWith(' ')) {
      tokens.add(const PlainTextToken(' '));
      text = text.trimLeft();
    }

    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      // Handle stacked elements (FIRE&ICE)
      if (word.contains('&') && !word.startsWith('&') && !word.endsWith('&')) {
        final parts = word.split('&');
        if (parts.length == 2) {
          tokens.add(StackedElementToken(parts[0], parts[1]));
          if (i < words.length - 1) tokens.add(const PlainTextToken(' '));
          continue;
        }
      }

      // Handle text replacements (plusone -> +1)
      final replacement = _getTextReplacement(word);
      if (replacement != null) {
        tokens.add(PlainTextToken(replacement));
        if (i < words.length - 1) tokens.add(const PlainTextToken(' '));
        continue;
      }

      // Parse word to extract punctuation and +1 overlay
      final parsed = ParsedWord.from(word);

      // Try to get asset config for the cleaned asset key
      final config = tryGetAssetConfig(parsed.assetKey);

      if (config != null) {
        // This is an icon token - add with punctuation
        _addIconToken(tokens, parsed, config);
      } else {
        // Plain text token
        tokens.add(PlainTextToken(word));
      }

      // Add space between words (but not after last word)
      if (i < words.length - 1) {
        tokens.add(const PlainTextToken(' '));
      }
    }

    return tokens;
  }

  /// Add icon token with punctuation from parsed word
  static void _addIconToken(
    List<GameTextToken> tokens,
    ParsedWord parsed,
    AssetConfig config,
  ) {
    // Add leading punctuation if present
    if (parsed.leadingPunct != null) {
      tokens.add(PunctuationToken(parsed.leadingPunct!));
    }

    // Add the icon
    tokens.add(
      IconToken(
        element: parsed.assetKey,
        config: config,
        showPlusOneOverlay: parsed.hasPlusOneOverlay,
      ),
    );

    // Add trailing punctuation if present
    if (parsed.trailingPunct != null) {
      tokens.add(PunctuationToken(parsed.trailingPunct!));
    }
  }

  /// Get text replacement for special words
  static String? _getTextReplacement(String word) {
    // Remove punctuation to check core word
    final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    String? replacement;
    switch (cleanWord) {
      case 'plusone':
        replacement = '+1';
        break;
      case 'plustwo':
        replacement = '+2';
        break;
      case 'pluszero':
        replacement = '+0';
        break;
      default:
        return null;
    }

    // Preserve punctuation
    if (cleanWord != word) {
      final leadingPunct = word.substring(0, word.indexOf(cleanWord));
      final trailingPunct = word.substring(
        word.indexOf(cleanWord) + cleanWord.length,
      );
      return '$leadingPunct$replacement$trailingPunct';
    }

    return replacement;
  }
}

/// Helper enum for text formatting types
enum _TextFormat { plain, bold, italic }

/// Helper class for text segments with formatting
class _TextSegment {
  final String text;
  final _TextFormat format;

  const _TextSegment(this.text, {required this.format});
}

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
