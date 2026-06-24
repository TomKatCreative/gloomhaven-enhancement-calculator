import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/home.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();

  if (SharedPrefs().clearSharedPrefs) {
    SharedPrefs().removeAll();
    SharedPrefs().clearSharedPrefs = false;
  }
  if (Platform.isAndroid) {
    // Gate the optional "Buy Me a Coffee" button by region. The device locale
    // is sufficient here; the old device_region plugin (SIM country) is
    // unmaintained, and SIM-country APIs are deprecated on iOS anyway.
    final country = PlatformDispatcher.instance.locale.countryCode;
    SharedPrefs().isUSRegion = country?.toUpperCase() == 'US';
  }

  runApp(
    MultiProvider(
      providers: [
        // ThemeProvider must come first
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            initialSeedColor: Color(SharedPrefs().primaryClassColor),
            initialDarkMode: SharedPrefs().darkTheme,
            initialDefaultFonts: SharedPrefs().useDefaultFonts,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppModel()),
        ChangeNotifierProvider(create: (_) => EnhancementCalculatorModel()),
        ChangeNotifierProvider(
          create: (_) => TownModel(databaseHelper: DatabaseHelper.instance),
        ),
        ChangeNotifierProxyProvider<ThemeProvider, CharactersModel>(
          create: (context) => CharactersModel(
            showRetired: SharedPrefs().showRetiredCharacters,
            databaseHelper: DatabaseHelper.instance,
            themeProvider: context.read<ThemeProvider>(),
          ),
          update: (context, themeProvider, previousCharactersModel) {
            return previousCharactersModel!;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          return AnimatedBuilder(
            animation: themeProvider,
            builder: (context, child) {
              return MaterialApp(
                title: Platform.isIOS
                    ? 'Gloomhaven Utility'
                    : 'Gloomhaven Companion',
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Home(),
                themeMode: themeProvider.themeMode,
                darkTheme: themeProvider.darkTheme,
                theme: themeProvider.lightTheme,
                themeAnimationDuration: const Duration(milliseconds: 500),
                themeAnimationCurve: Curves.easeInOut,
              );
            },
          );
        },
      ),
    ),
  );
}
