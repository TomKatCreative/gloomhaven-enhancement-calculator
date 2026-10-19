# Database Migration & Backup Testing

The harness under `test/migration/` and `test/backup/` checks four things:

- A database from **any schema version a user can still have (v1–v19)** upgrades to the current schema with every character, perk, mastery and setting intact.
- Every real backup file restores correctly.
- Every known gap shows up as a skipped test you can run on demand.
- The schema cannot be bumped without freezing the old one.

## Running

| What | Command |
|---|---|
| Migration and backup suites (desktop SQLite) | `flutter test test/migration test/backup` |
| Known bugs: run the skipped tests, which are expected to fail | `flutter test --run-skipped test/migration test/backup` |
| One known bug | `flutter test --run-skipped --plain-name "<test name>" <file>` |
| On device: run before any release that touches the database | `flutter test integration_test/migration_on_device_test.dart -d <device-id>` |
| Regenerate goldens after a reviewed change | `flutter test --update-goldens test/migration` |

The full `flutter test` suite runs in CI before every internal-track deploy (`.github/workflows/deploy-internal.yml`).

### On-device run

`flutter test` uses a desktop SQLite through `sqflite_common_ffi`. The integration test runs the portable suites (upgrade matrix, schema parity, atomicity, idempotence, synthetic backups) against the **platform SQLite** instead. The app's lowest supported Android version has a much older SQLite than desktop.

Verified on 2026-10-19:
- **iOS 27 simulator:** 158 passed, 9 skipped (known bugs).
- **Android API 24 emulator (SQLite 3.9.2, the oldest the app supports):** 158 passed, 9 skipped.

To set up an API 24 emulator:

```bash
sdkmanager "system-images;android-24;default;arm64-v8a"
avdmanager create avd -n ghc_api24 -k "system-images;android-24;default;arm64-v8a" -d pixel
emulator -avd ghc_api24 -no-snapshot
```

## What the tests prove

| File | Proves |
|---|---|
| `migration/upgrade_matrix_test.dart` | For every start version v1–v19, it opens a frozen DB through the app's real open path (`DatabaseHelper.openForTesting`). Then it checks: `user_version` and MetaData; every Characters field (including Unicode, emoji, quotes, injection-looking notes, legacy numeric UUIDs and uppercase v1–v4 class codes); every perk and mastery selection; DB invariants; and that `CharactersModel.loadCharacters()` shows every row. |
| `migration/legacy_id_mapping_test.dart` | Where each of the 995 legacy (v7) perk rows and 82 mastery rows lands. The real upgrade runs 5 times with bit-encoded selections, so every migrated row decodes back to its source. The result is checked against the reviewed goldens in `test/fixtures/legacy_ids/`, which pair legacy and live perk text. Covers the Infuser 724/725 fix in all four combinations, with two Infusers in one DB. |
| `migration/schema_parity_test.dart` | Every migrated DB has the same tables and columns as a fresh install. Only the allowlisted DEFAULT differences (DRIFT-001…004) may remain, and a stale allowlist entry also fails. |
| `migration/migration_atomicity_test.dart` | A step that throws rolls back everything. Schema, data and `user_version` are byte-identical afterwards, and the next launch fails the same way. |
| `migration/migration_idempotence_test.dart` | Reopening a current DB changes nothing, and the same input always gives the same output. The old definition tables' contents never affect character data. Also characterizes downgrade behavior (RISK-001). |
| `migration/fresh_install_test.dart` | A fresh install's schema matches the golden `test/fixtures/schema/fresh_current.json`. |
| `migration/tripwire_test.dart` | Every version below the current one has a frozen schema, and the fresh-install golden is for the current version. |
| `migration/id_snapshot_test.dart` | Perk and mastery IDs are append-only. Removing or renumbering one always fails. New IDs or text edits need `--update-goldens`. |
| `backup/backup_fixture_restore_test.dart` | Each real backup in `test/fixtures/backups/`, plus `test/helpers/fake_backup_*.txt`, goes through the real `restoreBackup`, into a fresh install and into a populated, upgraded DB. Checks rows, invariants, app load, and a round trip. |
| `backup/backup_synthetic_versions_test.dart` | A backup exported from each frozen v8–v19 schema restores to the same state as the upgrade path. |
| `backup/backup_rejection_test.dart` | Malformed and too-old backups are rejected. The fallback works when the schema rejects a row. Unknown tables are skipped. |
| `backup/backup_prefs_import_test.dart` | Each backup's settings, calculator values, enhancer levels and class unlocks are restored. The legacy `enhancementType` index resolves to the right enhancement, checked against an oracle pinned from `v4.5.0`. |
| `backup/prefs_legacy_migration_test.dart` | `gloomhavenMode` → `gameEdition`; the `clearOldPrefs` default; the character-index clamp after a restore. |

How expected results are stated independently of the migration code:
- `expectedCharacterRow`, `expectedPerks` and `expectedMasteries` in `harness/dataset.dart` spell out the documented defaults per start version.
- The legacy-ID goldens and the real backup files are the oracles for mapping and restore.

## Harness layout

```
test/migration/harness/   harness.dart (open/close/temp paths), ffi.dart (desktop only),
                          frozen_schemas.dart, dataset.dart, invariants.dart,
                          db_snapshot.dart, known_bugs.dart
test/migration/suites/    portable suites shared with integration_test/
test/backup/backup_harness.dart   backup fixture manifest + restore helpers
test/fixtures/            schema/, ids/, legacy_ids/, backups/
```

The only production seam is `DatabaseHelper.openForTesting` / `closeForTesting` / `currentVersion` (`@visibleForTesting`). Production still opens through the same private `_open`.

## Schema provenance

Each frozen schema in `harness/frozen_schemas.dart` is the fresh-install DDL of a release, with every constant expanded to literal SQL.

| Versions | Releases | Source |
|---|---|---|
| v1–v4 | 3.0.0 – 3.2.1 | `1524e9a`, `19270f4`, `e611670`, `863d276` (identical DDL) |
| v5–v6 | 3.2.5 – 3.6.3+86 | `19581f1`, `b133d58` (identical DDL) |
| v6 (late dev) | 3.6.3+90, not a known release | `e186195` — RISK-003 characterization only |
| v7 | 4.0.0 – 4.1.0 | `d297c90` |
| v8–v17 | 4.2.0 – 4.4.0 | `c57b409`, `v4.2.2`, `v4.3.0`–`v4.4.0` (identical DDL) |
| v18 | 4.5.0 | `v4.5.0` |
| v19 | 4.5.1 – 4.5.3 | `v4.5.3` |
| v20 (current) | 4.6.x | `test/fixtures/schema/fresh_current.json` |

Within a version, the schema sometimes changed across commits without a version bump (v6, v7, v8). Freeze from the **release**, not from the commit that bumped the version. For example, `b89f9d1`'s v8 MetaData lacks `LastUpdated`, while the shipped 4.2.0 has it.

## Adding a migration

1. **Freeze the outgoing schema.** Copy the `sql` statements from `test/fixtures/schema/fresh_current.json` (as committed, before your change) into a new `FrozenSchema` in `harness/frozen_schemas.dart`. Add a provenance comment naming the release.
2. **Teach the seed writer the new shape.** In `harness/dataset.dart`'s `_writeCharacter`, add a `version >= N` branch, and add dataset characters for any new class or field.
3. **Write the step.** Bump `_databaseVersion` and append a step to `_runMigrations`. Steps are append-only: never edit a step that has shipped, and every push to `dev` counts as shipped (it deploys to the internal track).
4. **Update `_createTables` to match.** Give new NOT NULL columns the same DEFAULT on both paths, or add a DRIFT entry to `schema_parity_test.dart` and `docs/known_data_bugs.md`.
5. **Patch older backups.** Add a `??=` default in `DatabaseBackupService.restoreBackup` for every new column, and mirror it in `restorePatchDefaults` in `test/backup/backup_harness.dart`.
6. **Update the expectations.** Add the new column's default to `expectedCharacterRow`.
7. **Regenerate and review.** Run `flutter test --update-goldens test/migration`, then review the golden diff.
8. **Never renumber perk or mastery IDs.** `id_snapshot_test` enforces this.
9. **Run everything.** Run `flutter test`, then the on-device run on iOS and API 24.
10. **Update the docs:** `docs/database_schema.md` (Migration History) and the CLAUDE.md "Database versioning" line.

If you skip step 1, `tripwire_test` fails with these instructions.

## Limitations

- **v1–v7 perk layout.** v1–v7 fixtures use the 4.0.0 perk layout (`PerksRepositoryLegacy`). Builds before 4.0.0 used different layouts for some classes (Diviner in 3.0.0, Crimson Scales in 3.2.1, Frosthaven classes in 3.6.x–3.7.0 dev builds). By decision, these are out of scope.
- **v8–v19 perk IDs.** v8–v19 fixtures store today's perk IDs. Historical ID stability is covered by the real backups (v8, v10, v16, v19, v20) and, from now on, by `id_snapshot_test`.
- **Bundled SQLite.** Desktop runs use a bundled modern SQLite; the on-device run covers platform SQLite.

See `docs/known_data_bugs.md` for what the harness found.
