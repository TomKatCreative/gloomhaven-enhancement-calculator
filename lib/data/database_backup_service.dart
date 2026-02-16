import 'dart:convert' as convert;

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:sqflite/sqflite.dart';

/// Handles database backup generation and restore.
///
/// Serializes all database tables and SharedPreferences to a JSON string,
/// and restores from that format with version validation and column patching.
///
/// The backup format is a 3-element JSON array:
/// ```json
/// [
///   ["Characters", "CharacterPerks", ...],  // table names
///   [[{...}, {...}], [{...}], ...],          // table data (parallel arrays)
///   {"settings": {...}, "calculator": {...}} // SharedPreferences export
/// ]
/// ```
class DatabaseBackupService {
  final Future<Database> Function() _getDatabase;
  final List<String> _tables;

  /// Minimum DB schema version accepted for backup restore (DB v8 = app v4.2.0).
  static const _minimumBackupVersion = 8;

  DatabaseBackupService({
    required Future<Database> Function() getDatabase,
    required List<String> tables,
  }) : _getDatabase = getDatabase,
       _tables = tables;

  /// Generates a JSON backup string containing all table data and
  /// SharedPreferences.
  Future<String> generateBackup() async {
    Database dbs = await _getDatabase();
    List data = [];
    List<Map<String, dynamic>> listMaps = [];

    for (final String table in _tables) {
      listMaps = await dbs.query(table);
      data.add(listMaps);
    }

    List backups = [_tables, data, SharedPrefs().exportForBackup()];

    return convert.jsonEncode(backups);
  }

  /// Restores database from a JSON backup string.
  ///
  /// Creates a safety backup first and restores it if an error occurs.
  /// Validates the backup version and patches missing columns for older backups.
  Future<void> restoreBackup(String backup) async {
    // Backup the current data incase of an error and restore it
    String fallBack = await generateBackup();

    var dbs = await _getDatabase();

    await _clearAllTables();

    Batch batch = dbs.batch();

    List json = convert.jsonDecode(backup);

    if (!json[0].contains('MetaData')) {
      throw ('No Meta Data Table');
    }

    final metaDataIndex = json[0].indexOf('MetaData');
    final metaData = json[1][metaDataIndex] as List;
    if (metaData.isEmpty ||
        (metaData[0][DatabaseHelper.columnDatabaseVersion] ?? 0) <
            _minimumBackupVersion) {
      final version = metaData.isNotEmpty
          ? metaData[0][DatabaseHelper.columnAppVersion] ?? 'unknown'
          : 'unknown';
      throw ('This backup was created with app version $version, '
          'which is no longer supported. '
          'Only backups from version 4.2.0 or later can be restored.');
    }

    for (var i = 0; i < json[0].length; i++) {
      // Skip tables that don't exist in the current schema
      if (!_tables.contains(json[0][i])) continue;

      for (var k = 0; k < json[1][i].length; k++) {
        // Patch columns for backups from v8+ (app 4.2.0+) that predate later schema changes.
        // Resource columns (v7) are defaulted for safety, though v8+ backups already have them.
        // PersonalQuest columns were added in v18.
        if (json[0][i] == tableCharacters) {
          json[1][i][k][columnResourceHide] ??= 0;
          json[1][i][k][columnResourceMetal] ??= 0;
          json[1][i][k][columnResourceLumber] ??= 0;
          json[1][i][k][columnResourceArrowvine] ??= 0;
          json[1][i][k][columnResourceAxenut] ??= 0;
          json[1][i][k][columnResourceRockroot] ??= 0;
          json[1][i][k][columnResourceFlamefruit] ??= 0;
          json[1][i][k][columnResourceCorpsecap] ??= 0;
          json[1][i][k][columnResourceSnowthistle] ??= 0;
          json[1][i][k][columnCharacterPersonalQuestId] ??= '';
          json[1][i][k][columnCharacterPersonalQuestProgress] ??= '[]';
          if (kTownSheetEnabled) {
            // PartyId is nullable, no default needed — just ensure key exists
            json[1][i][k].putIfAbsent(columnCharacterPartyId, () => null);
          } else {
            json[1][i][k].remove(columnCharacterPartyId);
          }
        }

        // Default missing party detail columns (added in v19)
        if (json[0][i] == tableParties) {
          json[1][i][k][columnPartyLocation] ??= '';
          json[1][i][k][columnPartyNotes] ??= '';
          json[1][i][k][columnPartyAchievements] ??= '[]';
        }

        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true).onError((
      error,
      stackTrace,
    ) async {
      await restoreBackup(fallBack);
      throw error ?? 'Error restoring backup';
    });

    // Restore SharedPreferences if present (new format backups)
    if (json.length > 2 && json[2] is Map) {
      SharedPrefs().importFromBackup(Map<String, dynamic>.from(json[2]));
    }
  }

  Future _clearAllTables() async {
    try {
      Database dbs = await _getDatabase();
      for (String table in _tables) {
        await dbs.delete(table);
        await dbs.rawQuery('DELETE FROM sqlite_sequence where name="$table"');
      }
    } catch (e) {
      rethrow;
    }
  }
}
