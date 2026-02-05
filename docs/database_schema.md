# Database Schema Reference

> **Files**: `lib/data/database_helpers.dart`, `lib/data/database_migrations.dart`

This document provides a comprehensive reference for the SQLite database schema, migrations, and key operations.

## Overview

- **Database Name**: `GloomhavenCompanion.db`
- **Current Schema Version**: 17
- **ORM**: sqflite (direct SQL)
- **Pattern**: Singleton DatabaseHelper

## Tables

### MetaData

Tracks database version and app info for migration management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `DatabaseVersion` | INTEGER | NOT NULL | Current schema version |
| `AppVersion` | TEXT | NOT NULL | App version string (e.g., "4.3.0") |
| `AppBuildNumber` | INTEGER | NOT NULL | Build number |
| `LastUpdated` | DATETIME | | Timestamp of last migration |

**Added in**: v8

---

### Characters

Core character data storage.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `CharacterId` | INTEGER | PRIMARY KEY AUTOINCREMENT | Legacy ID (backward compat) |
| `CharacterUUID` | TEXT | NOT NULL | UUID primary identifier |
| `CharacterName` | TEXT | NOT NULL | Display name |
| `CharacterClassCode` | TEXT | NOT NULL | Class code (e.g., "br") |
| `PreviousRetirements` | INTEGER | NOT NULL | Retirement count |
| `CharacterXp` | INTEGER | NOT NULL | Experience points |
| `CharacterGold` | INTEGER | NOT NULL | Gold amount |
| `CharacterNotes` | TEXT | NOT NULL | User notes |
| `CharacterCheckMarks` | INTEGER | NOT NULL | Check marks (0-18) |
| `IsRetired` | BOOL | NOT NULL | Retirement status |
| `Variant` | TEXT | NOT NULL | Class variant name |

**Frosthaven Resources** (added v7):

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `ResourceHide` | INTEGER | 0 | Hides |
| `ResourceMetal` | INTEGER | 0 | Metal |
| `ResourceLumber` | INTEGER | 0 | Lumber |
| `ResourceArrowvine` | INTEGER | 0 | Arrowvine herb |
| `ResourceAxenut` | INTEGER | 0 | Axenut herb |
| `ResourceRockroot` | INTEGER | 0 | Rockroot herb |
| `ResourceFlamefruit` | INTEGER | 0 | Flamefruit herb |
| `ResourceCorpsecap` | INTEGER | 0 | Corpsecap herb |
| `ResourceSnowthistle` | INTEGER | 0 | Snowthistle herb |

---

### Perks

Perk definitions seeded from `PerksRepository`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `PerkId` | TEXT | PRIMARY KEY | Format: `{classCode}_{variant}_{index}{letter}` |
| `PerkClass` | TEXT | NOT NULL | Class code |
| `PerkDetails` | TEXT | NOT NULL | Perk description with icons |
| `PerkIsGrouped` | BOOL | NOT NULL DEFAULT 0 | Grouping flag |
| `PerkVariant` | TEXT | NOT NULL | Variant name |

**Perk ID Format**:
```
{classCode}_{variant}_{paddedIndex}{letter}
```
- `paddedIndex`: 1-based, zero-padded (01, 02, ..., 15)
- `letter`: a, b, c... for multiple copies (quantity > 1)

Examples:
- `br_base_01a` - Brute, base variant, perk 1, first copy
- `br_base_01b` - Brute, base variant, perk 1, second copy
- `dh_frosthavenCrossover_05a` - Doomstalker crossover variant

---

### CharacterPerks

Join table linking characters to their perk selections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `AssociatedCharacterUuid` | TEXT | NOT NULL | FK to Characters.CharacterUUID |
| `AssociatedPerkId` | TEXT | NOT NULL | FK to Perks.PerkId |
| `CharacterPerkIsSelected` | BOOL | NOT NULL | Selection state |

**Auto-created**: When a character is inserted, rows are created for all matching perks with `isSelected = 0`.

---

### Masteries

Mastery definitions seeded from `MasteriesRepository` (Frosthaven+ only).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `MasteryId` | TEXT | PRIMARY KEY | Format: `{classCode}_{variant}_{index}` |
| `MasteryClass` | TEXT | NOT NULL | Class code |
| `MasteryDetails` | TEXT | NOT NULL | Mastery description |
| `MasteryVariant` | TEXT | NOT NULL | Variant name |

---

### CharacterMasteries

Join table linking characters to their mastery achievements.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `AssociatedCharacterUuid` | TEXT | NOT NULL | FK to Characters.CharacterUUID |
| `AssociatedMasteryId` | TEXT | NOT NULL | FK to Masteries.MasteryId |
| `CharacterMasteryAchieved` | BOOL | NOT NULL | Achievement state |

**Conditional creation**: Only created when `character.shouldShowMasteries == true`.

---

## Key Operations

### Character Operations

| Method | Description |
|--------|-------------|
| `insertCharacter(Character)` | Create character + auto-populate perks/masteries |
| `updateCharacter(Character)` | Update character core data |
| `deleteCharacter(Character)` | Cascading delete (char + perks + masteries) |
| `queryAllCharacters()` | Fetch all characters |

### Perk Operations

| Method | Description |
|--------|-------------|
| `queryPerks(Character)` | Fetch perks matching class + variant |
| `queryCharacterPerks(String uuid)` | Fetch perk selections for character |
| `updateCharacterPerk(CharacterPerk, bool)` | Update selection state |

### Mastery Operations

| Method | Description |
|--------|-------------|
| `queryMasteries(Character)` | Fetch masteries matching class + variant |
| `queryCharacterMasteries(String uuid)` | Fetch mastery achievements |
| `updateCharacterMastery(CharacterMastery, bool)` | Update achievement state |

### Backup Operations

| Method | Description |
|--------|-------------|
| `generateBackup()` | Export all tables as JSON string |
| `restoreBackup(String)` | Restore from JSON with safety fallback |

---

## Migration History

### Overview

| Version | Key Changes |
|---------|-------------|
| v5 | UUID migration, perk table regeneration |
| v6 | Perk cleanup, add Ruinmaw class |
| v7 | Frosthaven perks, masteries table, resources |
| v8 | MetaData table, Variant column, TEXT IDs |
| v9 | Add Vimthreader class |
| v10 | Add CORE class |
| v11 | Add DOME class |
| v12 | Add Skitterclaw class |
| v13 | Add GH2E classes (Bruiser, Tinkerer, etc.) |
| v14 | Add Mercenary Pack 2025 classes |
| v15 | Fix consume_X icon references |
| v16 | Add Alchemancer class |
| v17 | Rename item_minus_one icon |

### Critical Migrations

#### v5: UUID Migration

Converts integer character IDs to UUIDs for multi-device sync support.

```sql
-- Before: CharacterId INTEGER PRIMARY KEY
-- After: CharacterUUID TEXT NOT NULL (with legacy CharacterId kept)
```

**Process**:
1. Create new Characters table with UUID column
2. Generate UUIDs for existing characters
3. Update CharacterPerks to use UUID references
4. Keep legacy `CharacterId` for backward compatibility

#### v7: Frosthaven Support

Adds masteries system and resource tracking.

**New Tables**:
- `Masteries` - Mastery definitions
- `CharacterMasteries` - Join table

**New Columns** (Characters):
- 9 resource columns with DEFAULT 0

#### v8: Variant System

Major schema overhaul for multi-edition class support.

**Changes**:
1. Create `MetaData` table for version tracking
2. Add `Variant` column to Characters (default: "base")
3. Convert perk/mastery IDs from INT to TEXT
4. Regenerate perks/masteries with new ID format

**New Perk ID Format**:
```
{classCode}_{variant}_{paddedIndex}{letter}
```

#### Infuser Perk Fix (v8)

Historical correction for Infuser class perks 724-726 where a grouped perk was incorrectly set up:

```dart
// If perk 724 selected, automatically select 725
if (perk724Selected) {
  UPDATE CharacterPerks SET isSelected = 1
  WHERE perkId = 725 AND characterUuid = ?
}
```

---

## Database Seeding

### Perk Seeding

When the database is created, perks are seeded from `PerksRepository.perksMap`:

```dart
for (classCode in perksMap.keys) {
  for (perk in perksMap[classCode]) {
    for (i in 0..<perk.quantity) {
      INSERT INTO Perks VALUES (
        '${classCode}_${variant}_${paddedIndex}${letter}',
        classCode,
        perk.perkDetails,
        perk.grouped ? 1 : 0,
        variant
      )
    }
  }
}
```

### Mastery Seeding

Similar pattern from `MasteriesRepository.masteriesMap`:

```dart
for (classCode in masteriesMap.keys) {
  for (mastery in masteriesMap[classCode]) {
    INSERT INTO Masteries VALUES (
      '${classCode}_${variant}_${index}',
      classCode,
      mastery.masteryDetails,
      variant
    )
  }
}
```

---

## Helper Functions

### indexToLetter

Converts a 0-based index to a lowercase letter:

```dart
String indexToLetter(int index) => String.fromCharCode('a'.codeUnitAt(0) + index);
// 0 → 'a', 1 → 'b', ..., 25 → 'z'
```

Used for generating unique perk IDs when quantity > 1.

---

## Backup Format

The backup JSON structure:

```json
{
  "Characters": [
    {
      "CharacterUUID": "uuid-string",
      "CharacterName": "Bob",
      "CharacterClassCode": "br",
      // ... all character columns
    }
  ],
  "CharacterPerks": [
    {
      "AssociatedCharacterUuid": "uuid-string",
      "AssociatedPerkId": "br_base_01a",
      "CharacterPerkIsSelected": 1
    }
  ],
  "CharacterMasteries": [
    {
      "AssociatedCharacterUuid": "uuid-string",
      "AssociatedMasteryId": "bn_base_0",
      "CharacterMasteryAchieved": 0
    }
  ]
}
```

**Note**: Perks and Masteries tables are NOT included in backup since they're seeded from repositories on database creation.

---

## Migration Best Practices

When adding new migrations:

1. **Append only** - Never modify existing migrations
2. **Increment version** - Update schema version in `database_helpers.dart`
3. **Add to map** - Add migration function to `_migrations` map
4. **Handle nulls** - Account for existing data that may not have new columns
5. **Test upgrade paths** - Verify migrations work from multiple prior versions
6. **Update MetaData** - Call `updateMetaDataTable()` at end of migration

```dart
// In database_migrations.dart
static final Map<int, Future<void> Function(Transaction)> _migrations = {
  // ... existing migrations
  18: _migrateV17ToV18,
};

static Future<void> _migrateV17ToV18(Transaction txn) async {
  // Your migration logic
  await updateMetaDataTable(txn);
}
```
