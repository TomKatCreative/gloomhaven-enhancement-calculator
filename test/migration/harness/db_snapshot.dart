import 'package:sqflite/sqflite.dart';

/// One column as SQLite reports it, normalized for comparison.
class ColumnInfo {
  ColumnInfo(Map<String, Object?> row)
    : name = row['name'] as String,
      type = (row['type'] as String).toUpperCase(),
      notNull = row['notnull'] == 1,
      defaultValue = row['dflt_value'] as String?,
      primaryKey = row['pk'] as int;

  final String name;
  final String type;
  final bool notNull;
  final String? defaultValue;
  final int primaryKey;

  Map<String, Object?> toJson() => {
    'type': type,
    'notNull': notNull,
    'default': defaultValue,
    'pk': primaryKey,
  };
}

/// User tables (excluding SQLite internals) → column name → column info.
Future<Map<String, Map<String, ColumnInfo>>> schemaSnapshot(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  return {
    for (final t in tables)
      t['name'] as String: {
        for (final c in await db.rawQuery("PRAGMA table_info('${t['name']}')"))
          c['name'] as String: ColumnInfo(c),
      },
  };
}

/// JSON-friendly form of [schemaSnapshot], with columns sorted by name.
Future<Map<String, Object?>> schemaSnapshotJson(Database db) async {
  final snapshot = await schemaSnapshot(db);
  return {
    for (final table in snapshot.keys.toList()..sort())
      table: {
        for (final column in snapshot[table]!.keys.toList()..sort())
          column: snapshot[table]![column]!.toJson(),
      },
  };
}

/// Raw `sqlite_master` rows (type, name, sql), for byte-exact comparisons.
Future<List<Map<String, Object?>>> masterDump(Database db) =>
    db.rawQuery('SELECT type, name, sql FROM sqlite_master ORDER BY name');

/// Every row of every user table, ordered deterministically. MetaData's
/// LastUpdated timestamp is replaced by a placeholder.
Future<Map<String, List<Map<String, Object?>>>> dataDump(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  final dump = <String, List<Map<String, Object?>>>{};
  for (final t in tables) {
    final name = t['name'] as String;
    final rows = await db.rawQuery('SELECT * FROM "$name"');
    final normalized = [
      for (final row in rows)
        {
          for (final MapEntry(:key, :value) in row.entries)
            key: name == 'MetaData' && key == 'LastUpdated'
                ? '<timestamp>'
                : value,
        },
    ];
    normalized.sort((a, b) => '$a'.compareTo('$b'));
    dump[name] = normalized;
  }
  return dump;
}
