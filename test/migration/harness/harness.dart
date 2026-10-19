import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// App version that migrations write into MetaData during tests.
const String kTestAppVersion = '9.9.9-test';
const String kTestBuildNumber = '999';

/// Common setup for every migration/backup test file.
void initMigrationHarness() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PackageInfo.setMockInitialValues(
    appName: 'Gloomhaven Companion',
    packageName: 'test',
    version: kTestAppVersion,
    buildNumber: kTestBuildNumber,
    buildSignature: '',
  );
}

/// A fresh, empty temp directory for database files, deleted on teardown.
Directory createTempDbDir() {
  final dir = Directory.systemTemp.createTempSync('ghc_migration_');
  addTearDown(() async {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dir;
}

String tempDbPath(Directory dir, [String name = 'GloomhavenCompanion.db']) =>
    p.join(dir.path, name);

/// Opens [path] without a version or callbacks: no migration runs.
Future<Database> rawOpen(String path) => openDatabase(path);

/// Opens [path] through the app's real open path ([DatabaseHelper]), running
/// whatever create/upgrade/downgrade the app would run on launch.
Future<Database> openThroughApp(String path) =>
    DatabaseHelper.instance.openForTesting(path);

Future<void> closeApp() => DatabaseHelper.instance.closeForTesting();

Future<int> userVersion(Database db) async =>
    (await db.rawQuery('PRAGMA user_version')).first.values.first as int;
