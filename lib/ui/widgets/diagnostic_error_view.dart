import 'package:flutter/material.dart';

/// A dependency-free, full-screen error view for surfacing otherwise-invisible
/// failures (the blank/grey "Flutter error screen") to end users and developers.
///
/// This is a deliberate exception to the project's design-constant and theming
/// rules: it depends on NOTHING from the app — no [Theme], no localization, no
/// providers, and crucially no [MediaQuery]/[SafeArea] — because any of those
/// may be the very thing that failed. It is used in two places:
///
///  1. [ErrorWidget.builder] in `main.dart`, replacing the default grey/red box
///     shown when a widget's `build()` throws (invisible in release).
///  2. The startup guard in `main()`, when initialization fails before
///     `runApp()` can run the real app (would otherwise be a blank screen).
///
/// Colors, sizes, and the top inset are hardcoded on purpose so the view still
/// renders when the theme system and media query are unavailable.
class DiagnosticErrorView extends StatelessWidget {
  const DiagnosticErrorView({
    super.key,
    required this.title,
    required this.error,
    this.stackTrace,
  });

  final String title;
  final String error;
  final String? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF1B1B1B),
        // Fixed top inset avoids depending on MediaQuery/SafeArea, which may be
        // absent when this replaces a widget above MaterialApp.
        padding: const EdgeInsets.fromLTRB(16, 64, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please take a screenshot of this screen and send it to the '
              'developer so this can be fixed.',
              style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 15),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(
                        color: Color(0xFFFFCDD2),
                        fontSize: 13,
                        height: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (stackTrace != null &&
                        stackTrace!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Stack trace:',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stackTrace!,
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 11,
                          height: 1.35,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
