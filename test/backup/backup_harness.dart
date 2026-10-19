import 'dart:convert';
import 'dart:io';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/test_helpers.dart';
import '../migration/harness/harness.dart';

/// A real backup file exported by a shipped app version.
class BackupFixture {
  const BackupFixture(
    this.path, {
    required this.databaseVersion,
    required this.appVersion,
    required this.characters,
    required this.hasPrefs,
  });

  final String path;

  /// Values recorded in the file's MetaData row. A backup made after a
  /// restore carries the restored backup's MetaData (BUG-007), so these are
  /// not always the exporting app's schema.
  final int databaseVersion;
  final String appVersion;
  final int characters;
  final bool hasPrefs;

  String get name => path.split('/').last;
  String read() => File(path).readAsStringSync();
  List<dynamic> decode() => jsonDecode(read()) as List<dynamic>;
}

/// Manifest of committed real-world backups (faker-generated names).
const backupFixtures = [
  BackupFixture(
    'test/helpers/fake_backup_v420.txt',
    databaseVersion: 8,
    appVersion: '4.2.0',
    characters: 2,
    hasPrefs: false,
  ),
  BackupFixture(
    'test/fixtures/backups/db08_app420_ghc_2025-02-03.txt',
    databaseVersion: 8,
    appVersion: '4.2.0',
    characters: 1,
    hasPrefs: false,
  ),
  BackupFixture(
    'test/fixtures/backups/db10_app421_july_22.txt',
    databaseVersion: 10,
    appVersion: '4.2.1',
    characters: 5,
    hasPrefs: false,
  ),
  BackupFixture(
    'test/helpers/fake_backup_v432.txt',
    databaseVersion: 16,
    appVersion: '4.3.2',
    characters: 3,
    hasPrefs: false,
  ),
  BackupFixture(
    'test/fixtures/backups/db16_app432_version_440.json',
    databaseVersion: 16,
    appVersion: '4.3.2',
    characters: 3,
    hasPrefs: true,
  ),
  BackupFixture(
    'test/fixtures/backups/db19_app450_afterbigdbmigration.json',
    databaseVersion: 19,
    appVersion: '4.5.0',
    characters: 4,
    hasPrefs: true,
  ),
  BackupFixture(
    'test/fixtures/backups/db19_app450_testv20.json',
    databaseVersion: 19,
    appVersion: '4.5.0',
    characters: 18,
    hasPrefs: true,
  ),
  BackupFixture(
    'test/fixtures/backups/db20_app453_adterupdate.json',
    databaseVersion: 20,
    appVersion: '4.5.3',
    characters: 20,
    hasPrefs: true,
  ),
  BackupFixture(
    'test/fixtures/backups/db20_app460_testing460.json',
    databaseVersion: 20,
    appVersion: '4.6.0',
    characters: 19,
    hasPrefs: true,
  ),
];

/// Defaults `restoreBackup` documents for columns older backups lack.
const restorePatchDefaults = <String, Object?>{
  'ResourceHide': 0,
  'ResourceMetal': 0,
  'ResourceWood': 0,
  'ResourceArrowVine': 0,
  'ResourceAxeNut': 0,
  'ResourceRockRoot': 0,
  'ResourceFlameFruit': 0,
  'ResourceCorpseCap': 0,
  'ResourceSnowThistle': 0,
  'PersonalQuestId': '',
  'PersonalQuestProgress': '[]',
  'ShowResources': 1,
  'IsJawsOfTheLion': 0,
};

/// The rows of [table] a restore of [backup] must produce: the backup's rows
/// with missing columns patched by [restorePatchDefaults].
List<Map<String, Object?>> expectedRestoredRows(List backup, String table) {
  final index = (backup[0] as List).indexOf(table);
  if (index < 0) return [];
  return [
    for (final row in (backup[1][index] as List).cast<Map<String, dynamic>>())
      if (table != 'Characters')
        row
      else
        {...restorePatchDefaults, ...row}
          ..remove('PartyId')
          ..addAll({if (kTownSheetEnabled) 'PartyId': row['PartyId']}),
  ];
}

/// Rows of [table] as a sortable multiset, for order-insensitive equality.
Future<List<String>> tableRows(Database db, String table) async {
  final rows = await db.query(table);
  return rows.map(_canonical).toList()..sort();
}

List<String> canonicalRows(List<Map<String, Object?>> rows) =>
    rows.map(_canonical).toList()..sort();

String _canonical(Map<String, Object?> row) {
  final keys = row.keys.toList()..sort();
  return jsonEncode({for (final k in keys) k: row[k]});
}

/// A fresh database opened through the app, installed as the singleton.
Future<Database> freshAppDatabase() =>
    openThroughApp(tempDbPath(createTempDbDir()));

Future<CharactersModel> loadCharactersModel() async {
  final model = CharactersModel(
    databaseHelper: DatabaseHelper.instance,
    themeProvider: MockThemeProvider(),
    showRetired: true,
  );
  await model.loadCharacters();
  return model;
}

Future<void> restore(String contents) =>
    DatabaseHelper.instance.backupService.restoreBackup(contents);

Future<String> generate() =>
    DatabaseHelper.instance.backupService.generateBackup();
