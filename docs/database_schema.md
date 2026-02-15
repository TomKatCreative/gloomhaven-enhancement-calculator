# Database Schema Reference

> **Files**: `lib/data/database_helpers.dart`, `lib/data/database_migrations.dart`

This document provides a comprehensive reference for the SQLite database schema, migrations, and key operations.

## Overview

- **Database Name**: `GloomhavenCompanion.db`
- **Current Schema Version**: 18 (production) / 19 (dev — Frosthaven PQs + Perks/Masteries table removal)
- **ORM**: sqflite (direct SQL)
- **Pattern**: Singleton DatabaseHelper

> **Conditional schema**: Production schema is v18 (Personal Quests table with 24 GH quests and PQ columns on Characters). Dev branch bumps to v19 (regenerates PQ table with 24 GH + 23 FH quests, drops Perks and Masteries definition tables). When `kTownSheetEnabled` is `true`, Campaigns and Parties tables plus `PartyId` column on Characters are created on fresh installs.

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
| `CharacterCheckMarks` | INTEGER | NOT NULL | Check marks (0-18, every 3 = 1 perk) |
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

**Personal Quest Fields** (added v18):

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `PersonalQuestId` | TEXT | `''` | FK to PersonalQuestsTable._id (e.g., "pq_gh_510") |
| `PersonalQuestProgress` | TEXT | `'[]'` | JSON array of ints (progress per requirement) |

**Party Fields** (added v18):

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `PartyId` | TEXT | NULL | FK to Parties._id (nullable — unassigned characters have NULL) |

---

### ~~Perks~~ (Removed in v19)

> **Dropped in v19.** Perk definitions are now loaded directly from `PerksRepository.getPerksForCharacter()` at runtime. The table existed in v5-v18 for storing seeded perk definitions. Migration code (v5-v17) still references this table for users upgrading from old versions.

**Perk ID Format** (still used by `CharacterPerks` and `PerksRepository`):
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
| `AssociatedPerkId` | TEXT | NOT NULL | Perk ID (format: `{classCode}_{variant}_{index}{letter}`) |
| `CharacterPerkIsSelected` | BOOL | NOT NULL | Selection state |

**Auto-created**: When a character is inserted, rows are created for all matching perks (IDs from `PerksRepository.getPerkIds()`) with `isSelected = 0`.

---

### ~~Masteries~~ (Removed in v19)

> **Dropped in v19.** Mastery definitions are now loaded directly from `MasteriesRepository.getMasteriesForCharacter()` at runtime. The table existed in v7-v18 for storing seeded mastery definitions.

---

### CharacterMasteries

Join table linking characters to their mastery achievements.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `AssociatedCharacterUuid` | TEXT | NOT NULL | FK to Characters.CharacterUUID |
| `AssociatedMasteryId` | TEXT | NOT NULL | Mastery ID (format: `{classCode}_{variant}_{index}`) |
| `CharacterMasteryAchieved` | BOOL | NOT NULL | Achievement state |

**Conditional creation**: Only created when `character.shouldShowMasteries == true`.

---

### ~~PersonalQuestsTable~~ (Removed in v19)

> **Dropped in v19.** Personal quest definitions are now loaded directly from `PersonalQuestsRepository` at runtime. The table existed in v18 for storing seeded quest definitions (id, number, title, edition). Requirements, unlock class, and unlock envelope were always stored in the repository, not the DB.

**Added in**: v18 | **Removed in**: v19

---

> **Gated by** `kTownSheetEnabled` — these tables only exist when the feature flag is enabled.

### Campaigns

Tracks game campaigns with edition-specific prosperity.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `_id` | TEXT | PRIMARY KEY | UUID |
| `Name` | TEXT | NOT NULL | Campaign name |
| `Edition` | TEXT | NOT NULL | GameEdition.name (e.g., "gloomhaven") |
| `ProsperityCheckmarks` | INTEGER | NOT NULL DEFAULT 0 | Raw checkmark count |
| `DonatedGold` | INTEGER | NOT NULL DEFAULT 0 | Sanctuary donations |
| `CreatedAt` | DATETIME | | Creation timestamp |

**Added in**: v19 (conditional)

---

### Parties

Tracks parties within a campaign.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `_id` | TEXT | PRIMARY KEY | UUID |
| `CampaignId` | TEXT | NOT NULL | FK to Campaigns._id |
| `Name` | TEXT | NOT NULL | Party name |
| `Reputation` | INTEGER | NOT NULL DEFAULT 0 | Party reputation (-20 to +20) |
| `CreatedAt` | DATETIME | | Creation timestamp |
| `Location` | TEXT | DEFAULT '' | Current scenario location |
| `Notes` | TEXT | DEFAULT '' | Party notes |
| `Achievements` | TEXT | DEFAULT '[]' | JSON array of achievement strings |

**Foreign Key**: `CampaignId REFERENCES Campaigns(_id) ON DELETE CASCADE`

**Added in**: v19 (conditional)

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
| `queryCharacterPerks(String uuid)` | Fetch perk selections for character |
| `updateCharacterPerk(CharacterPerk, bool)` | Update selection state |

> Perk definitions are loaded via `PerksRepository.getPerksForCharacter()` (not from DB).

### Mastery Operations

| Method | Description |
|--------|-------------|
| `queryCharacterMasteries(String uuid)` | Fetch mastery achievements |
| `updateCharacterMastery(CharacterMastery, bool)` | Update achievement state |

> Mastery definitions are loaded via `MasteriesRepository.getMasteriesForCharacter()` (not from DB).

### Personal Quest Operations

> Quest definitions are loaded via `PersonalQuestsRepository` (not from DB).
> Characters store their assigned quest ID and progress directly in the Characters table.

### Campaign Operations

| Method | Description |
|--------|-------------|
| `queryAllCampaigns()` | Fetch all campaigns |
| `insertCampaign(Campaign)` | Create a new campaign |
| `updateCampaign(Campaign)` | Update campaign data (name, prosperity, etc.) |
| `deleteCampaign(String campaignId)` | Cascading delete (campaign + parties + unlink characters) |

### Party Operations

| Method | Description |
|--------|-------------|
| `queryParties(String campaignId)` | Fetch parties for a campaign |
| `insertParty(Party)` | Create a new party |
| `updateParty(Party)` | Update party data |
| `deleteParty(String partyId)` | Delete party and unlink characters |

### Character-Party Linking

| Method | Description |
|--------|-------------|
| `assignCharacterToParty(String uuid, String? partyId)` | Link/unlink a character to a party |
| `queryCharactersByParty(String partyId)` | Fetch characters in a party |

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
| v18 | Personal Quests table (24 GH quests), PQ columns on Characters |
| v19 | Drop all definition tables (Perks, Masteries, PersonalQuests) — loaded from repositories |

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

## Perk & Mastery Definitions (Repository-Based)

As of v19, perk and mastery definitions are loaded directly from code repositories at runtime — no database tables needed.

### Loading Definitions

```dart
// In CharactersModel._loadPerks():
character.perks = PerksRepository.getPerksForCharacter(classCode, variant);

// In CharactersModel._loadMasteries():
character.masteries = MasteriesRepository.getMasteriesForCharacter(classCode, variant);
```

### Creating CharacterPerk/Mastery Records

When a character is inserted, `DatabaseHelper.insertCharacter()` creates join records using IDs from the repositories:

```dart
final perkIds = PerksRepository.getPerkIds(classCode, variant);
for (final perkId in perkIds) {
  INSERT INTO CharacterPerks VALUES (characterUuid, perkId, 0);
}
```

### Historical Context

The Perks and Masteries **definition tables** existed in v5-v18. They were seeded from the same repositories and regenerated whenever a new class was added (migrations v9-v17). Removing them eliminates redundant data and the need for regeneration migrations when adding classes or fixing perk text.

The **CharacterPerks** and **CharacterMasteries** join tables (which store user progress) remain unchanged.

---

## Helper Functions

### indexToLetter

Converts a 0-based index to a lowercase letter (defined in `perks_repository.dart`):

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
  ],
  "Campaigns": [
    {
      "_id": "uuid-string",
      "Name": "My Campaign",
      "Edition": "gloomhaven",
      "ProsperityCheckmarks": 12,
      "DonatedGold": 50,
      "CreatedAt": "2025-01-15T10:30:00.000"
    }
  ],
  "Parties": [
    {
      "_id": "uuid-string",
      "CampaignId": "uuid-string",
      "Name": "Party One",
      "Reputation": 3,
      "CreatedAt": "2025-01-15T10:30:00.000",
      "Location": "Gloomhaven",
      "Notes": "",
      "Achievements": "[\"First Steps\"]"
    }
  ]
}
```

**Note**: All definition tables (Perks, Masteries, PersonalQuests) were removed in v19 and were never included in backup. Campaigns and Parties tables ARE included in backup since they contain user-created data.

**Minimum supported backup version**: DB schema v8 (app v4.2.0). Backups from older versions are rejected during restore with a descriptive error message.

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
