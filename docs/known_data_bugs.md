# Known Data Bugs

These are data-integrity problems found by the migration and backup harness (`docs/database_migration_testing.md`). Each one has at least one skipped test that fails when forced to run. The ID matches the `skip:` reason, from `test/migration/harness/known_bugs.dart`.

```bash
flutter test --run-skipped test/migration test/backup   # all 12 skips fail
```

When fixing a bug, remove its `skip:` and leave the test in place as a regression check. The fix plan, grouped into three tasks, is in [`data_integrity_roadmap.md`](data_integrity_roadmap.md).

| ID | Severity | Status |
|---|---|---|
| [BUG-004](#bug-004) | **Critical**: silent loss of all characters | Fixed (DI-1) |
| [BUG-003](#bug-003) | **High**: app can't open its database | Open |
| [BUG-001](#bug-001) | Medium: mastery checkboxes hidden | Open |
| [BUG-002](#bug-002) | Low: hidden mastery rows that can never be shown | Open (fix decided: delete) |
| [BUG-005](#bug-005) | Medium: settings half-applied | Fixed (DI-1) |
| [BUG-006](#bug-006) | Low: orphan rows from crafted/old backups | Open |
| [BUG-007](#bug-007) | Low: wrong MetaData after restore | Fixed (DI-1) |
| [RISK-001](#risk-001) | Medium: data wiped on downgrade | By design (sqflite), undecided |
| [RISK-003](#risk-003) | Unknown: only if a late-v6 dev build shipped | Open |
| [DRIFT-001…004](#drift) | Low: schema DEFAULT differences | Accepted |

---

## BUG-004

**Restore wipes all tables before validating the backup.**

- **Who:** Anyone who picks a file that isn't a valid backup: a v4.1-or-older backup, a truncated file, or a non-JSON file.
- **Observed:** The restore throws, as it should. But every character, perk and mastery is already gone (`Characters: []`, `CharacterPerks: []`).
- **Message mismatch:** The error dialog (`restoreErrorMessage`) tells the user "Your existing data was saved".
- **Tests:** `backup/backup_rejection_test.dart`, 6 cases, "… leaves the existing characters untouched".
- **Root cause:** `lib/data/database_backup_service.dart:63` runs `_clearAllTables()` before `jsonDecode` (`:67`) and before the MetaData/version checks. The `fallBack` backup is only restored when `batch.commit` fails (`:130`), not when parsing or validation throws.
- **Fixed (DI-1):** `restoreBackup` parses and validates everything first, throwing `BackupException` with the database untouched, then wipes and inserts inside one transaction.

## BUG-003

**An orphaned perk/mastery row aborts the v7→v8 upgrade.**

- **Who:** v1–v7 databases with a CharacterPerks or CharacterMasteries row whose character no longer exists. These are possible because v1–v4 `deleteCharacter` didn't await its deletes (`git show 863d276:lib/data/database_helpers.dart`). The same failure happens for an Infuser with legacy perk 724 but no 725 row.
- **Observed:** `Bad state: No element` (orphans) or `RangeError (length)` (Infuser) during open. The transaction rolls back correctly, so the data is intact, but the DB stays at the old version and the app fails the same way on every launch.
- **Tests:**
  - `migration/migration_atomicity_test.dart` "a v7 perk row / v7 mastery row / v1 perk row does not block the upgrade"
  - `migration/legacy_id_mapping_test.dart` "a character with a 724 row but no 725 row still upgrades"
  - Companion tests that pass today prove the data is left untouched.
- **Root cause:**
  - `lib/data/database_migrations.dart:444` uses `characters.firstWhere` with no `orElse`.
  - `:634` uses `Character.fromMap(characters.first)` on an empty query.
  - `:465` uses `perk725List[0]`.
- **Fix direction:** Skip (or delete) rows with no matching character, and guard the 725 lookup.

## BUG-001

**Characters created before v7 never get CharacterMasteries rows.**

- **Who:** Characters that existed before 4.0.0 and belong to a class the app now shows masteries for. Frosthaven starters were selectable from v6.
- **Observed:** `Expected: {'drifter_base_0': false, 'drifter_base_1': false}`, `Actual: {}`. The UI hides both mastery checkboxes (`perk_row.dart` lookup).
- **Tests:** `migration/upgrade_matrix_test.dart`, upgrade from v6: "maps masteries of pre-v7 characters", "satisfies every database invariant", "loads in the app with every mastery visible".
- **Root cause:** The v7 step `includeClassMasteries` (`lib/data/database_migrations.dart:197`) creates an empty `CharacterMasteries` table. No step ever backfills rows for existing characters.
- **Fix direction:** Add a reconciliation step, either post-migration or on load, that inserts missing perk and mastery rows (unselected).

## BUG-002

**v7 mastery progress is remapped to IDs the app never shows.**

- **Who:** 4.0.x/4.1.x characters of classes with no live `base` mastery list. That is 18 Gloomhaven classes, 5 Jaws of the Lion classes, and Incarnate. 4.0.0 stored their (Frosthaven-crossover) mastery progress.
- **Observed:** Rows such as `br_base_0` / `br_base_1` (and `sw_`, `mt_`, `sb_`, `incarnate_`, `dl_`). They match no live mastery, so the progress is invisible.
- **Tests:**
  - `migration/upgrade_matrix_test.dart`, upgrade from v7: "maps masteries of v7 characters", "satisfies every database invariant"
  - `migration/legacy_id_mapping_test.dart` "legacy masteries of classes without live base masteries leave no hidden rows"
- **Root cause:** `_handleVariantMasteries` (`lib/data/database_migrations.dart:596`) always writes `{class}_base_{index}`.
  - Its legacy-ID matching uses insertion rowids over the live map. It is correct only because every mastery list has exactly 2 entries; the legacy-ID golden test would catch a change.
  - The update at `:643` has no character filter.
- **Fix (decided):** Delete these rows in the DI-3 reconciliation. A character's variant is fixed at creation, so they can never be shown. See [`data_integrity_roadmap.md`](data_integrity_roadmap.md#decision-bug-002).

## BUG-005

**The prefs import is not atomic and hard-casts values.**

- **Who:** Anyone restoring a backup with a malformed or hand-edited settings section.
- **Observed:** The restore throws, but `primaryClassColor` has already been overwritten (`Expected: <4279383126>`, `Actual: <4289449455>`). The database restore has already committed by then.
- **Test:** `backup/backup_rejection_test.dart` "a backup whose prefs contain a wrong-typed value leaves every pref as it was".
- **Root cause:**
  - `SharedPrefs.importFromBackup` (`lib/shared_prefs.dart:346`) applies values one by one with `as bool` / `as int`.
  - It is called after `batch.commit` (`lib/data/database_backup_service.dart:140`).
- **Fixed (DI-1):** `BackupPrefs.parse` type-checks every value during backup validation, before the DB is touched. `SharedPrefs.applyBackupPrefs` runs only after the restore transaction commits.

## BUG-006

**Restore never validates perk/mastery IDs.**

- **Observed:** A backup row with `PerkID: 'br_base_99z'` restores as an orphan (`noOrphanPerks` invariant).
- **Test:** `backup/backup_rejection_test.dart` "perk/mastery IDs the app does not know are not restored as orphans".
- **Root cause:** `lib/data/database_backup_service.dart:126` inserts rows verbatim.
- **Fix direction:** The same reconciliation as BUG-001: drop unknown IDs and add missing ones.

## BUG-007

**Restore replaces MetaData with the backup's version.**

- **Observed:** After restoring a v8 backup into a v20 database, MetaData says `DatabaseVersion: 8`. Later backups then carry the wrong version. That's why `db16_app432_version_440.json` claims v16 / 4.3.2 although it was exported by a 4.5+ app.
- **Tests:** `backup/backup_fixture_restore_test.dart` "keeps the MetaData of the running schema" (9 fixtures).
- **Root cause:** MetaData is in `DatabaseHelper.tables`, so it is wiped and restored like user data.
- **Fixed (DI-1):** MetaData is skipped on clear and on insert. Backups exported before this fix can still carry a wrong MetaData version.

## RISK-001

**Downgrade deletes the database.**

- **What happens:** `onDowngrade: onDatabaseDowngradeDelete` (`lib/data/database_helper.dart:73`) deletes the file and creates an empty one whenever a build with a lower schema version opens it.
- **Who it can hit:** For example, a tester moving from the internal track back to production.
- **Test:** Pinned by `migration/migration_idempotence_test.dart` "a database from a newer app version is deleted on open (RISK-001)". This test passes; it characterizes the current behavior.
- **Fix direction:** Refuse to open and show a message, or keep the file aside.

## RISK-003

**The late-v6 development schema fails to upgrade.**

- **What happens:** Builds around 3.6.3+90 (`e186195`, May 2022) created `MasteriesTable` and `CharacterMasteries (MasteryProgress)` at fresh install without bumping past v6. The v7 step then fails with `table MasteriesTable already exists`. The rollback works, but the app can't open its database.
- **Who it can hit:** Only installs of those dev builds, if any shipped.
- **Tests:** `migration/migration_atomicity_test.dart` "late v6 development schema … upgrades" (skipped), plus a passing companion test that shows the data is intact.

## DRIFT

**Fresh-install and migrated schemas have different DEFAULTs.**

Migrations add NOT NULL columns with `ALTER TABLE … DEFAULT x`, while `_createTables` declares them without a DEFAULT. This is harmless today, because the app always writes these columns and restore patches them. It is pinned by `migration/schema_parity_test.dart`.

| ID | Columns | Migrated DEFAULT | Upgrades from |
|---|---|---|---|
| DRIFT-001 | 9 `Resource*` columns | `0` | v1–v6 |
| DRIFT-002 | `Variant` | `'base'` | v1–v7 |
| DRIFT-003 | `ShowResources` | `1` | v1–v19 |
| DRIFT-004 | `IsJawsOfTheLion` | `0` | v1–v19 |
