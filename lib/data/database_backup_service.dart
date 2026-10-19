import 'dart:convert' as convert;

import 'package:gloomhaven_enhancement_calc/data/backup_exception.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:sqflite/sqflite.dart';

/// Handles database backup generation and restore.
///
/// Serializes all database tables and SharedPreferences to a JSON string,
/// and restores from that format with validation and column patching.
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

  /// Restores database and SharedPreferences from a JSON backup string.
  ///
  /// Validates the whole backup first and throws a [BackupException] if it is
  /// rejected. The database is then replaced in a single transaction, so a
  /// failed insert rolls back to the user's data. Prefs are written only after
  /// the transaction commits. The MetaData table is left alone: it describes
  /// the running schema, not the backup.
  Future<void> restoreBackup(String backup) async {
    final parsed = _parseBackup(backup);

    final dbs = await _getDatabase();
    await dbs.transaction((txn) async {
      await _clearAllTables(txn);
      final batch = txn.batch();
      for (final MapEntry(key: table, value: rows) in parsed.tables.entries) {
        for (final row in rows) {
          batch.insert(table, row);
        }
      }
      await batch.commit(noResult: true);
    });

    if (parsed.prefs != null) SharedPrefs().applyBackupPrefs(parsed.prefs!);
  }

  /// Decodes and validates [backup] without touching any stored data.
  ///
  /// Returns the rows to insert per table, with missing columns patched for
  /// older backups, and the validated prefs.
  _ParsedBackup _parseBackup(String backup) {
    final Object? json;
    try {
      json = convert.jsonDecode(backup);
    } on FormatException catch (e) {
      throw BackupException('This file is not a valid backup: ${e.message}');
    }

    if (json is! List ||
        json.length < 2 ||
        json[0] is! List ||
        json[1] is! List ||
        (json[0] as List).length != (json[1] as List).length) {
      throw const BackupException(
        'This file is not a valid backup: unexpected format',
      );
    }
    final tableNames = json[0] as List;
    final tableData = json[1] as List;
    for (var i = 0; i < tableNames.length; i++) {
      final rows = tableData[i];
      if (tableNames[i] is! String ||
          rows is! List ||
          rows.any((row) => row is! Map<String, dynamic>)) {
        throw BackupException(
          'This file is not a valid backup: bad data for table '
          '${tableNames[i]}',
        );
      }
    }

    if (!tableNames.contains(DatabaseHelper.tableMetaData)) {
      throw const BackupException('No Meta Data Table');
    }
    final metaData =
        tableData[tableNames.indexOf(DatabaseHelper.tableMetaData)] as List;
    final version = metaData.isEmpty
        ? null
        : metaData[0][DatabaseHelper.columnDatabaseVersion];
    if (version is! int || version < _minimumBackupVersion) {
      final appVersion = metaData.isNotEmpty
          ? metaData[0][DatabaseHelper.columnAppVersion] ?? 'unknown'
          : 'unknown';
      throw BackupException(
        'This backup was created with app version $appVersion, '
        'which is no longer supported. '
        'Only backups from version 4.2.0 or later can be restored.',
      );
    }

    // Validate prefs before anything is written, so bad settings reject the
    // whole restore. Backups older than 4.5.0 have no prefs element.
    BackupPrefs? prefs;
    if (json.length > 2 && json[2] != null) {
      if (json[2] is! Map) {
        throw const BackupException(
          'This file is not a valid backup: settings are not a map',
        );
      }
      prefs = BackupPrefs.parse(Map<String, dynamic>.from(json[2] as Map));
    }

    final tables = <String, List<Map<String, dynamic>>>{};
    for (var i = 0; i < tableNames.length; i++) {
      final table = tableNames[i] as String;
      // Skip tables that don't exist in the current schema, and MetaData,
      // which describes the running schema rather than the backup.
      if (!_tables.contains(table) || table == DatabaseHelper.tableMetaData) {
        continue;
      }
      tables[table] = [
        for (final row in (tableData[i] as List).cast<Map<String, dynamic>>())
          _patchRow(table, {...row}),
      ];
    }
    tables[tableCharacters]?.forEach(_checkCharacterRow);

    return _ParsedBackup(tables, prefs);
  }

  /// Rejects a character this app can't load, such as one whose class or
  /// variant was added in a newer app version. Restoring it would replace the
  /// user's data with characters that fail to load on every launch.
  void _checkCharacterRow(Map<String, dynamic> row) {
    final classCode = row[columnCharacterClassCode];
    final variant = row[columnVariant];
    final knownClass =
        classCode is String &&
        PlayerClasses.playerClasses.any(
          (c) => c.classCode == classCode.toLowerCase(),
        );
    final knownVariant =
        variant == null || Variant.values.any((v) => v.name == variant);
    if (!knownClass || !knownVariant) {
      throw BackupException(
        'This backup has a character this app version does not support '
        '(class: $classCode, variant: $variant). Please update the app.',
      );
    }
  }

  /// Patches columns for backups from v8+ (app 4.2.0+) that predate later
  /// schema changes.
  Map<String, dynamic> _patchRow(String table, Map<String, dynamic> row) {
    // Resource columns (v7) are defaulted for safety, though v8+ backups
    // already have them. PersonalQuest columns were added in v18.
    if (table == tableCharacters) {
      row[columnResourceHide] ??= 0;
      row[columnResourceMetal] ??= 0;
      row[columnResourceLumber] ??= 0;
      row[columnResourceArrowvine] ??= 0;
      row[columnResourceAxenut] ??= 0;
      row[columnResourceRockroot] ??= 0;
      row[columnResourceFlamefruit] ??= 0;
      row[columnResourceCorpsecap] ??= 0;
      row[columnResourceSnowthistle] ??= 0;
      row[columnCharacterPersonalQuestId] ??= '';
      row[columnCharacterPersonalQuestProgress] ??= '[]';
      // ShowResources and IsJawsOfTheLion were both added in v20. Default
      // to shown / not-JotL so older backups restore cleanly into a fresh
      // install (whose columns have no DEFAULT, unlike the ALTER path).
      row[columnShowResources] ??= 1;
      row[columnIsJawsOfTheLion] ??= 0;
      if (kTownSheetEnabled) {
        // PartyId is nullable, no default needed — just ensure key exists
        row.putIfAbsent(columnCharacterPartyId, () => null);
      } else {
        row.remove(columnCharacterPartyId);
      }
    }

    // Default missing party detail columns (added in v19)
    if (table == tableParties) {
      row[columnPartyLocation] ??= '';
      row[columnPartyNotes] ??= '';
      row[columnPartyAchievements] ??= '[]';
    }
    return row;
  }

  /// Empties every restorable table (all but MetaData) and resets its
  /// AUTOINCREMENT counter.
  Future<void> _clearAllTables(Transaction txn) async {
    // sqlite_sequence only exists once an AUTOINCREMENT insert has happened.
    final hasSequence = (await txn.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'sqlite_sequence'],
    )).isNotEmpty;
    for (final String table in _tables) {
      if (table == DatabaseHelper.tableMetaData) continue;
      await txn.delete(table);
      if (hasSequence) {
        await txn.delete(
          'sqlite_sequence',
          where: 'name = ?',
          whereArgs: [table],
        );
      }
    }
  }
}

class _ParsedBackup {
  const _ParsedBackup(this.tables, this.prefs);

  /// Table name → rows to insert, in backup order.
  final Map<String, List<Map<String, dynamic>>> tables;
  final BackupPrefs? prefs;
}
