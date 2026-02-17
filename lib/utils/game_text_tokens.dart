import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

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
    final baseSize = iconSizeMedium;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Tooltip(
        message: _formatTooltipMessage(element),
        child: SizedBox(
          height: baseSize,
          width: baseSize * config.widthMultiplier,
          child: _buildIconContent(darkTheme, onSurface),
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

  Widget _buildIconContent(bool darkTheme, Color onSurface) {
    final assetPath = config.pathForTheme(darkTheme);

    // Handle XP icons
    if (assetPath == 'ui/xp.svg') {
      final xpNumber = RegExp(r'\d+').firstMatch(element)?.group(0) ?? '';
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildSvgPicture(assetPath, onSurface),
          Positioned(
            bottom: -1,
            child: Text(
              xpNumber,
              style: TextStyle(
                fontFamily: pirataOne,
                fontSize: fontSizeBodyMedium,
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
          _buildSvgPicture(assetPath, onSurface),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              height: 12,
              width: 12,
              child: SvgPicture(
                SvgAssetLoader(
                  'images/${assets['CONSUME']!.path}',
                  theme: SvgTheme(currentColor: onSurface),
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
          _buildSvgPicture(assetPath, onSurface),
          SvgPicture.asset(
            'images/ui/plus_one.svg',
            width: iconSizeTiny,
            height: iconSizeTiny,
          ),
        ],
      );
    }

    return _buildSvgPicture(assetPath, onSurface);
  }

  /// Builds an [SvgPicture] with appropriate color handling based on theme.
  ///
  /// Color behavior is determined by [config.themeMode]:
  /// - [CurrentColorTheme]: Sets `currentColor` to [onSurface] from the theme
  /// - [NoTheme]: Renders SVG as-is with no color modification
  SvgPicture _buildSvgPicture(String assetPath, Color onSurface) {
    final fullPath = 'images/$assetPath';

    return switch (config.themeMode) {
      CurrentColorTheme() => SvgPicture(
        SvgAssetLoader(fullPath, theme: SvgTheme(currentColor: onSurface)),
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
        height: iconSizeLarge,
        width: iconSizeLarge,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: ThemedSvg(
                assetKey: element1,
                width: iconSizeSmall,
                height: iconSizeSmall,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ThemedSvg(
                assetKey: element2,
                width: iconSizeSmall,
                height: iconSizeSmall,
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
