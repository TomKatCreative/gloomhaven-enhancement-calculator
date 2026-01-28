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

## Usage

These files are imported only by `database_migrations.dart` and should not be
used elsewhere in the application. The current/active perk and mastery data
lives in the parent directories (`perks/` and `masteries/`).

## Warning

**Do not modify these files** unless you are specifically fixing a migration issue.
Changing the data or order of entries could break migrations for users upgrading
from older versions of the app.
