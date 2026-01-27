import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/app_theme_builder.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeConfig _config;
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;

  ThemeProvider({
    Color? initialSeedColor,
    bool? initialDarkMode,
    bool? initialDefaultFonts,
  }) : _config = ThemeConfig(
         seedColor: initialSeedColor ?? Color(SharedPrefs().primaryClassColor),
         useDarkMode: initialDarkMode ?? SharedPrefs().darkTheme,
         useDefaultFonts: initialDefaultFonts ?? SharedPrefs().useDefaultFonts,
       ) {
    _rebuildThemes();
    // Apply system UI after first frame to ensure it takes effect
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateSystemUI();
    });
  }

  ThemeData get lightTheme => _cachedLightTheme!;
  ThemeData get darkTheme => _cachedDarkTheme!;

  ThemeMode get themeMode =>
      _config.useDarkMode ? ThemeMode.dark : ThemeMode.light;

  Color get seedColor => _config.seedColor;
  bool get useDarkMode => _config.useDarkMode;
  bool get useDefaultFonts => _config.useDefaultFonts;

  void updateSeedColor(Color color) {
    if (_config.seedColor == color) return;

    _config = _config.copyWith(seedColor: color);
    SharedPrefs().primaryClassColor = color.toARGB32();
    _rebuildThemes();
    _updateSystemUI();
    notifyListeners();
  }

  void updateDarkMode(bool isDark) {
    if (_config.useDarkMode == isDark) return;

    _config = _config.copyWith(useDarkMode: isDark);
    SharedPrefs().darkTheme = isDark;
    _updateSystemUI();
    notifyListeners();
  }

  void updateDefaultFonts(bool useDefault) {
    if (_config.useDefaultFonts == useDefault) return;

    _config = _config.copyWith(useDefaultFonts: useDefault);
    SharedPrefs().useDefaultFonts = useDefault;
    _rebuildThemes();
    notifyListeners();
  }

  void updateThemeConfig(ThemeConfig config) {
    if (_config == config) return;

    _config = config;
    SharedPrefs().primaryClassColor = config.seedColor.toARGB32();
    SharedPrefs().darkTheme = config.useDarkMode;
    SharedPrefs().useDefaultFonts = config.useDefaultFonts;
    _rebuildThemes();
    _updateSystemUI();
    notifyListeners();
  }

  void _rebuildThemes() {
    _cachedLightTheme = AppThemeBuilder.buildLightTheme(_config);
    _cachedDarkTheme = AppThemeBuilder.buildDarkTheme(_config);
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: _config.useDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: _config.useDarkMode
            ? AppThemeBuilder.darkSurface
            : Colors.white,
      ),
    );
  }
}
