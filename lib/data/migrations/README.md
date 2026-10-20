# Database Migration Legacy Files

This directory contains legacy repository files that are only used during database
migrations. These files preserve the old data structures and IDs that were used
in earlier versions of the app, enabling smooth migration of existing user data.

## Files

### `perks_repository_legacy.dart`
Contains the legacy perk definitions with the old integer-based ID system.
Used in database migration code to map old perk IDs to new text-based IDs.

### `masteries_repository_legacy.dart`
Contains the legacy mastery definitions with the old integer-based ID system.
Used during database upgrades to migrate mastery data.

### `perk_and_mastery_constants.dart`
Frozen text fragments used by `perks_repository_legacy.dart`. Live perk and
mastery text uses `PerkTextConstants` instead.

### `legacy_perk.dart` / `legacy_mastery.dart`
The integer-ID row models for the pre-v8 definition tables.

### `legacy_definition_rows.dart`
Table/column names and `toLegacyRow` serializers for the text-ID Perks,
Masteries and PersonalQuests definition tables that migrations v8–v18 build
(all dropped in v19).

## Usage

These files are imported only by `database_migrations.dart` (and by each other)
and should not be used elsewhere in the application. The current/active perk and mastery data
lives in the parent directories (`perks/` and `masteries/`).

## Warning

**Do not modify these files** unless you are specifically fixing a migration issue.
Changing the data or order of entries could break migrations for users upgrading
from older versions of the app.

## Tests

These files are the oracle for the v7→v8 ID remap. `test/migration/legacy_id_mapping_test.dart` proves where every legacy perk/mastery ID lands against reviewed goldens in `test/fixtures/legacy_ids/`; editing these files makes it fail. See `docs/database_migration_testing.md`.
