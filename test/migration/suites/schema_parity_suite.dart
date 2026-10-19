import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';

import '../harness/dataset.dart';
import '../harness/db_snapshot.dart';
import '../harness/harness.dart';

/// A known, accepted difference between a migrated and a fresh-install
/// schema: migrations add NOT NULL columns with ALTER TABLE, which requires a
/// DEFAULT, while `_createTables` declares them without one.
class _Drift {
  const _Drift(this.id, this.migratedDefault, {required this.fromVersionsUpTo});

  /// Entry in docs/known_data_bugs.md.
  final String id;
  final String migratedDefault;

  /// The drift exists for upgrades from versions up to and including this.
  final int fromVersionsUpTo;
}

const _resourceDrift = _Drift('DRIFT-001', '0', fromVersionsUpTo: 6);

const Map<String, _Drift> _allowedDrift = {
  'Characters.ResourceHide': _resourceDrift,
  'Characters.ResourceMetal': _resourceDrift,
  'Characters.ResourceWood': _resourceDrift,
  'Characters.ResourceArrowVine': _resourceDrift,
  'Characters.ResourceAxeNut': _resourceDrift,
  'Characters.ResourceRockRoot': _resourceDrift,
  'Characters.ResourceFlameFruit': _resourceDrift,
  'Characters.ResourceCorpseCap': _resourceDrift,
  'Characters.ResourceSnowThistle': _resourceDrift,
  'Characters.Variant': _Drift('DRIFT-002', "'base'", fromVersionsUpTo: 7),
  'Characters.ShowResources': _Drift('DRIFT-003', '1', fromVersionsUpTo: 19),
  'Characters.IsJawsOfTheLion': _Drift('DRIFT-004', '0', fromVersionsUpTo: 19),
};

/// Every upgraded database must end up with the same tables and columns as a
/// fresh install. Only the allowlisted DEFAULT differences may remain, and an
/// allowlist entry that no longer matches reality fails too.
/// Also run on device by integration_test/migration_on_device_test.dart.
void defineSchemaParityTests() {
  group('schema parity', () {
    setUpAll(initMigrationHarness);

    late Map<String, Map<String, ColumnInfo>> fresh;

    setUpAll(() async {
      final db = await openThroughApp(tempDbPath(createTempDbDir()));
      fresh = await schemaSnapshot(db);
      await closeApp();
    });

    for (int version = 1; version < DatabaseHelper.currentVersion; version++) {
      test('upgrade from v$version matches a fresh install', () async {
        final path = tempDbPath(createTempDbDir());
        final raw = await rawOpen(path);
        await seedFrozenDatabase(raw, version);
        await raw.close();
        final migrated = await schemaSnapshot(await openThroughApp(path));
        await closeApp();

        expect(migrated.keys.toSet(), fresh.keys.toSet(), reason: 'tables');
        final unexpected = <String>[];
        final observed = <String>{};
        for (final table in fresh.keys) {
          expect(
            migrated[table]!.keys.toSet(),
            fresh[table]!.keys.toSet(),
            reason: '$table columns',
          );
          for (final column in fresh[table]!.keys) {
            final f = fresh[table]![column]!;
            final m = migrated[table]![column]!;
            final key = '$table.$column';
            if (m.type != f.type ||
                m.notNull != f.notNull ||
                m.primaryKey != f.primaryKey) {
              unexpected.add('$key: ${m.toJson()} vs fresh ${f.toJson()}');
              continue;
            }
            if (m.defaultValue == f.defaultValue) continue;
            final drift = _allowedDrift[key];
            if (drift != null &&
                version <= drift.fromVersionsUpTo &&
                f.defaultValue == null &&
                m.defaultValue == drift.migratedDefault) {
              observed.add(key);
            } else {
              unexpected.add(
                '$key: default ${m.defaultValue} vs fresh ${f.defaultValue}',
              );
            }
          }
        }
        expect(unexpected, isEmpty, reason: 'unlisted schema drift');
        final stale = _allowedDrift.entries
            .where((e) => version <= e.value.fromVersionsUpTo)
            .map((e) => e.key)
            .where((key) => !observed.contains(key));
        expect(stale, isEmpty, reason: 'allowlisted drift no longer occurs');
      });
    }
  });
}
