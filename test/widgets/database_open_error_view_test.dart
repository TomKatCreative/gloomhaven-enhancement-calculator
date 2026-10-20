import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_too_new_exception.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/database_open_error_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_helpers.dart';

/// Tests for [DatabaseOpenErrorView], the Characters page shown when the
/// database can't be opened.
void main() {
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  const urlChannel = MethodChannel('plugins.flutter.io/url_launcher');
  const fakePath = '/docs/GloomhavenCompanion.db';

  late List<MethodCall> shareCalls;
  late List<String> launchedUrls;

  setUp(() async {
    await setupSharedPreferences();
    PackageInfo.setMockInitialValues(
      appName: 'GHC',
      packageName: 'ghc',
      version: '9.9.9',
      buildNumber: '999',
      buildSignature: '',
    );
    shareCalls = [];
    launchedUrls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlChannel, (call) async {
          if (call.method == 'launch') {
            launchedUrls.add((call.arguments as Map)['url'] as String);
          }
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, (call) async {
          shareCalls.add(call);
          return 'dev.fluttercommunity.plus/share/success';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(shareChannel, null)
      ..setMockMethodCallHandler(urlChannel, null);
  });

  Future<void> pumpView(WidgetTester tester, Object error) async {
    await tester.pumpWidget(
      wrapWithProviders(
        withLocalization: true,
        child: Scaffold(
          body: DatabaseOpenErrorView(
            error: error,
            databasePath: () async => fakePath,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DatabaseOpenErrorView', () {
    testWidgets('a newer database asks the user to update the app', (
      tester,
    ) async {
      await pumpView(
        tester,
        const DatabaseTooNewException(found: 21, supported: 20),
      );

      expect(find.text('Update required'), findsOneWidget);
      expect(find.text('Export database'), findsOneWidget);
      expect(find.text('Contact developer'), findsOneWidget);
      // The cause is known, so there are no raw error details to show.
      expect(find.text('Error details'), findsNothing);
    });

    testWidgets('any other error shows a generic message and its details', (
      tester,
    ) async {
      await pumpView(tester, StateError('upgrade failed'));

      expect(find.text("Couldn't load your characters"), findsOneWidget);
      expect(find.text('Export database'), findsOneWidget);
      expect(find.text('Contact developer'), findsOneWidget);

      await tester.tap(find.text('Error details'));
      await tester.pumpAndSettle();
      expect(find.textContaining('upgrade failed'), findsOneWidget);
    });

    testWidgets('Export database shares the database file', (tester) async {
      await pumpView(tester, StateError('upgrade failed'));

      await tester.tap(find.text('Export database'));
      await tester.pumpAndSettle();

      expect(shareCalls, hasLength(1));
      final args = shareCalls.single.arguments as Map;
      expect(args['paths'], [fakePath]);
    });

    testWidgets('a failed export shows an error instead of doing nothing', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, (call) async {
            throw PlatformException(code: 'share_failed');
          });
      await pumpView(tester, StateError('upgrade failed'));

      await tester.tap(find.text('Export database'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't export the database. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets('Contact developer emails the error and app version', (
      tester,
    ) async {
      const error = DatabaseTooNewException(found: 21, supported: 20);
      await pumpView(tester, error);

      await tester.tap(find.text('Contact developer'));
      await tester.pumpAndSettle();

      expect(launchedUrls, hasLength(1));
      final uri = Uri.parse(launchedUrls.single);
      expect(uri.scheme, 'mailto');
      final body = uri.queryParameters['body']!;
      expect(body, contains('Error: $error'));
      expect(body, contains('App Version: 9.9.9+999'));
    });
  });
}
