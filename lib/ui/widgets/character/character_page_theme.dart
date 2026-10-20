import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/app_theme_builder.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Themes one character page with that character's own color.
///
/// The app-wide theme follows the current character and changes on every
/// swipe. Pages stay mounted across swipes, so without this every widget on
/// every visited page that reads `Theme.of` would rebuild on each swipe. A
/// page's own theme only changes with dark mode, fonts or the character
/// itself, and the incoming page shows its color while it slides in.
class CharacterPageTheme extends StatelessWidget {
  const CharacterPageTheme({
    required this.character,
    required this.child,
    super.key,
  });

  final Character character;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Retiring changes the character's color. Rebuilding here is cheap: the
    // theme cache returns the identical ThemeData when nothing changed, so
    // nothing below rebuilds.
    context.select<CharactersModel, int>((m) => m.revision);
    final (useDarkMode, useDefaultFonts) = context
        .select<ThemeProvider, (bool, bool)>(
          (p) => (p.useDarkMode, p.useDefaultFonts),
        );
    final config = ThemeConfig(
      seedColor: character.getEffectiveColor(
        useDarkMode ? Brightness.dark : Brightness.light,
      ),
      useDarkMode: useDarkMode,
      useDefaultFonts: useDefaultFonts,
    );
    final data = useDarkMode
        ? AppThemeBuilder.buildDarkTheme(config)
        : AppThemeBuilder.buildLightTheme(config);
    // Theme.of also depends on the nearest CupertinoTheme, and a Theme
    // copies its CupertinoTheme from above, which here is the app's and
    // changes color on every swipe. Providing this page's own stops that
    // from rebuilding every Theme.of reader on the page.
    return CupertinoTheme(
      data: MaterialBasedCupertinoThemeData(materialTheme: data),
      child: Theme(data: data, child: child),
    );
  }
}
