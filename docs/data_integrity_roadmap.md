# Data Integrity (DI) Roadmap

This roadmap fixes the findings in [`known_data_bugs.md`](known_data_bugs.md). The 10 findings are grouped into **3 tasks**: each task changes one code path and ships as one branch. Reference tasks by ID in commits (e.g. `fix(DI-1): ...`).

**Status legend:** ⬜ Pending · 🟨 In progress · ✅ Done

| Task | Theme | Closes | Schema bump | Size |
|------|-------|--------|-------------|------|
| [DI-1](#di-1) | Safe, atomic restore | BUG-004, BUG-005, BUG-007 | No | M |
| [DI-2](#di-2) | Database open never strands or wipes data | BUG-003, RISK-003, RISK-001 | No | M |
| [DI-3](#di-3) | Reconcile perk/mastery rows (v21) | BUG-001, BUG-002, BUG-006 | **v21** | M |
| — | Accepted, no task | DRIFT-001…004 | — | — |

**Order:** DI-1 → DI-2 → DI-3.
- **DI-1 first:** BUG-004 silently deletes every character, so it ships first.
- **DI-1 and DI-2 together:** neither changes the schema, so they can ship as one patch release.
- **DI-3 last:** it bumps the schema, and its restore half plugs into the restore pipeline DI-1 builds.

**How a task is "done":**
- Remove the task's `skip:` lines. The skipped tests become regression tests and must pass unchanged.
- Update each finding's status in `known_data_bugs.md`.
- Run `flutter test` and the on-device run (iOS + API 24); see [`database_migration_testing.md`](database_migration_testing.md).

---

## DI-1 ⬜ Safe, atomic restore {#di-1}

**Closes:** BUG-004 (restore wipes data before validating), BUG-005 (prefs half-applied), BUG-007 (MetaData overwritten).
**Files:** `lib/data/database_backup_service.dart`, `lib/shared_prefs.dart`, `lib/ui/dialogs/restore_dialog.dart`

All three bugs come from `restoreBackup` doing its work in the wrong order: wipe → parse → insert → import prefs. They share one fix, **validate everything, then apply everything**:

1. **Parse and validate before touching anything.**
   - `jsonDecode`, then the 3-element shape, the MetaData presence and version ≥ 8, and that the table data is lists of maps.
   - Any failure throws a typed `BackupException` while the database is still untouched.
2. **Validate prefs up front (BUG-005).**
   - Split `SharedPrefs.importFromBackup` into `parseBackupPrefs(Map) → BackupPrefs`, which checks every value's type and range and throws on bad input, and `apply(BackupPrefs)`, which only writes.
   - Calling `parse` in step 1 means a bad settings value rejects the whole restore before anything changes.
3. **Wipe and insert in one transaction.**
   - Do the clear, the `sqlite_sequence` reset and all inserts inside `db.transaction`. Any failure rolls back to the user's data.
   - This replaces the `fallBack` backup/re-restore dance and its recursion.
4. **Leave MetaData alone (BUG-007).** Skip the `MetaData` table on clear and on insert. It describes the running schema, not the backup.
5. **Apply the parsed prefs after the transaction commits.**
6. **Make the dialog truthful.** `restore_dialog.dart` can now honestly say "your data was not changed" on failure. Reload characters on failure too, so the UI never shows stale in-memory data.

**Un-skips:** 6 BUG-004 cases, the BUG-005 case and 9 BUG-007 cases (`backup_rejection_test.dart`, `backup_fixture_restore_test.dart`).
**Add:** a rollback test where the insert fails mid-batch (replacing the old fallback test); prefs range checks (`targetCardLvl`, `enhancementsOnTargetAction`, `gameEdition` < 0); and unknown `classUnlocks` keys that must not be written as prefs. All of these were found during the investigation.
**Docs:** the backup section of `database_schema.md`, and the import section of `shared_prefs_keys.md`.

## DI-2 ⬜ Database open never strands or wipes data {#di-2}

**Closes:**
- BUG-003: an orphan row aborts the upgrade, so the app can't open its database.
- RISK-003: the late-v6 dev schema fails the v7 step.
- RISK-001: a downgrade deletes the database.

**Files:** `lib/data/database_helper.dart`, `lib/data/database_migrations.dart`, startup error UI.

All three are about what happens when the app opens the database, and all are fixed without editing any shipped migration step (CLAUDE.md: append-only):

1. **Add a pre-migration sanitizer for BUG-003 and RISK-003.**
   - New `DatabaseMigrations.sanitizeLegacy(txn, oldVersion)`, called at the top of `_runMigrations` before any step, only when `oldVersion ≤ 7`.
   - **Orphans:** delete `CharacterPerks`/`CharacterMasteries` rows whose character no longer exists. They are invisible today and can't be shown by any version.
   - **Infuser:** when a character has legacy 724 but no 725 row, insert 725 unselected so the existing Infuser fix runs.
   - **Late-v6:** when `oldVersion == 6` and `MasteriesTable` exists, drop the late-v6 dev `MasteriesTable`/`CharacterMasteries` so the v7 step can create them. Their `MasteryProgress` counters have no meaning in any later schema.
   - It runs in the same transaction as the upgrade, so a failure still rolls everything back.
2. **Refuse a downgrade instead of deleting (RISK-001).**
   - Replace `onDatabaseDowngradeDelete` with a callback that throws `DatabaseTooNewException`. The file stays on disk.
   - At startup, show "This database was created by a newer version of the app. Update the app to continue." Then a reinstall of the newer build gets the data back.
   - Testers moving from the internal track back to production are the realistic case.
3. **Add a launch-failure screen.** When `DatabaseHelper.database` throws (any upgrade failure), show the error with "Export raw database" and "Contact developer" actions instead of a broken app. With the sanitizer in place this should be unreachable, but a stuck user then has a way out.

**Un-skips:** 3 orphan cases (`migration_atomicity_test.dart`), the Infuser no-725 case (`legacy_id_mapping_test.dart`) and the late-v6 case.
**Change:** the RISK-001 characterization test in `migration_idempotence_test.dart` flips. It should now assert the newer database is left untouched and the open throws `DatabaseTooNewException`.
**Docs:** `database_schema.md` (open/upgrade behavior) and `database_migration_testing.md`. Also note in CLAUDE.md that legacy fixes go in the sanitizer, never in shipped steps.

## DI-3 ⬜ Reconcile perk/mastery rows (schema v21) {#di-3}

**Closes:**
- BUG-001: pre-v7 characters have no mastery rows.
- BUG-002: v7 mastery progress was moved to hidden IDs.
- BUG-006: restore accepts unknown IDs.

**Depends on:** DI-1 (the restore pipeline).
**Files:** `lib/data/database_migrations.dart`, `lib/data/database_helper.dart`, `lib/data/database_backup_service.dart`

All three leave the same wrong state behind: a character's perk/mastery rows don't match what the app shows for its class and variant. The fix is one shared function, run in the two places bad rows can come from.

1. **Add `DatabaseMigrations.reconcileCharacterRows(txn)`.** For every character, make its `CharacterPerks`/`CharacterMasteries` rows exactly match `PerksRepository.getPerkIds` / `MasteriesRepository.getMasteryIds` for its class and variant:
   - insert missing rows unselected;
   - delete rows with unknown IDs or no character;
   - collapse duplicates, keeping "selected" if any duplicate was selected.

   This is the same rule `invariants.dart` checks, so the tests and the fix share one definition.
2. **Run it as the v21 migration step.** This fixes every existing database once (BUG-001, BUG-002), whatever version it came from. Follow the checklist in `database_migration_testing.md#adding-a-migration`:
   - freeze v20;
   - the v21 step is reconcile-only, with no column changes, so the restore patches and `expectedCharacterRow` stay as they are;
   - regenerate the goldens.
3. **Run it inside the DI-1 restore transaction, after the inserts (BUG-006).** This also repairs old backups made from databases that had BUG-001/002 rows.
4. Optionally, run it after `insertCharacter` in debug builds as an assertion. It is not needed in production.

**Un-skips:** the BUG-001/BUG-002 tests in `upgrade_matrix_test.dart` (v6 and v7 groups), the BUG-002 legacy-mapping test, and BUG-006 in `backup_rejection_test.dart`. `masteryBugFor` in `harness/dataset.dart` then always returns null and can be deleted.

### BUG-002: the hidden v7 mastery rows are deleted (decided 2026-10-19) {#decision-bug-002}

4.0.x (v7) stored mastery rows for every character whose class had masteries. The v8 upgrade (4.1+) turned them into `{class}_base_N` IDs on `base`-variant characters, which show no masteries. A character's variant is chosen once, at creation, and can never change. So these rows can never be displayed.

Reconciliation deletes them. Nothing the user can see changes. Release-note line: "Removed hidden mastery data left over from version 4.0." Characters created since 4.1 never get such rows, because `insertCharacter` only adds mastery rows the app will show. This only affects characters that date back to 4.0.x.

---

## Accepted, no task: DRIFT-001…004

Fresh installs declare four column groups without the DEFAULTs that migrated databases have. The app always writes these columns and restore patches them, so this has no effect. Aligning them would need a table rebuild migration, which is risky for no gain. `schema_parity_test.dart` pins the drift so it can't grow silently. If a future migration rebuilds `Characters` anyway, fold the alignment into it.
