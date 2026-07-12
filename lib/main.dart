import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/diagnostic_error_view.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/home.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

void main() {
  // Diagnostics: replace the default grey/red ErrorWidget with a readable,
  // screenshot-able error screen. Any build-phase exception — which would
  // otherwise render as a blank grey rectangle in release, with no information —
  // now shows the actual error and stack trace on-screen. See
  // [DiagnosticErrorView].
  ErrorWidget.builder = (FlutterErrorDetails details) => DiagnosticErrorView(
    title: 'Something went wrong',
    error: details.exceptionAsString(),
    stackTrace: details.stack?.toString(),
  );

  runZonedGuarded<Future<void>>(
    () async {
      // Must be inside the same zone as runApp() to avoid a zone mismatch.
      WidgetsFlutterBinding.ensureInitialized();

      // Present framework errors to the console (retrievable via Console.app on
      // a release device) in addition to the on-screen ErrorWidget above.
      FlutterError.onError = FlutterError.presentError;
      // Catch otherwise-unhandled async errors raised by the platform.
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        debugPrint('Uncaught platform error: $error\n$stack');
        return true;
      };

      try {
        await SharedPrefs().init();

        if (SharedPrefs().clearSharedPrefs) {
          SharedPrefs().removeAll();
          SharedPrefs().clearSharedPrefs = false;
        }
        if (Platform.isAndroid) {
          // Gate the optional "Buy Me a Coffee" button by region. The device
          // locale is sufficient here; the old device_region plugin (SIM
          // country) is unmaintained, and SIM-country APIs are deprecated on
          // iOS anyway.
          final country = PlatformDispatcher.instance.locale.countryCode;
          SharedPrefs().isUSRegion = country?.toUpperCase() == 'US';
        }
      } catch (error, stack) {
        // A failure here (e.g. a plugin that isn't registered on this platform)
        // would otherwise stop runApp() from ever being called, leaving a blank
        // screen with zero diagnostics. Surface it on-screen instead.
        debugPrint('Startup initialization failed: $error\n$stack');
        runApp(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: DiagnosticErrorView(
              title: 'Startup failed',
              error: error.toString(),
              stackTrace: stack.toString(),
            ),
          ),
        );
        return;
      }

      runApp(const GloomhavenApp());
    },
    (Object error, StackTrace stack) {
      // Last-resort handler for anything thrown outside the widget lifecycle.
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}

/// Root application widget: wires up the five providers and the themed
/// [MaterialApp]. Extracted from [main] so that any exception thrown while a
/// provider is created (e.g. building the theme) happens during build and is
/// caught by [ErrorWidget.builder] rather than silently failing.
class GloomhavenApp extends StatelessWidget {
  const GloomhavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
    );
  }
}
