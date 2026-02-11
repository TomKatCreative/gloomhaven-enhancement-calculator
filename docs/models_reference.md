# Data Models Reference

> **Directory**: `lib/models/`

This document provides a comprehensive reference for the app's data models, their fields, relationships, and computed properties.

## Model Overview

```
┌─────────────────┐     ┌─────────────────┐
│   PlayerClass   │────▶│    Character    │
│  (class defn)   │     │  (instance)     │
└─────────────────┘     └────────┬────────┘
        │                        │
        │                        ├──────────────────┐
        ▼                        ▼                  ▼
┌─────────────────┐     ┌─────────────────┐ ┌─────────────────┐
│      Perk       │     │ CharacterPerk   │ │CharacterMastery │
│  (definition)   │     │ (join table)    │ │  (join table)   │
└─────────────────┘     └─────────────────┘ └─────────────────┘
                                                    ▲
┌─────────────────┐                                 │
│    Mastery      │─────────────────────────────────┘
│  (definition)   │
└─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│    Campaign     │────▶│     Party       │
│  (town state)   │     │ (party state)   │
└─────────────────┘     └────────┬────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │    Character    │  (optional party link)
                        └─────────────────┘

┌─────────────────┐
│   Enhancement   │  (standalone - calculator only)
│    (option)     │
└─────────────────┘
```

---

## Character

> **File**: `lib/models/character.dart`

Represents a player's character instance with stats, resources, and progression.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `int?` | null | Legacy database primary key (kept for backward compat) |
| `uuid` | `String` | generated | Unique identifier (UUID v4) |
| `name` | `String` | required | Character's display name |
| `playerClass` | `PlayerClass` | required | Reference to the class definition |
| `previousRetirements` | `int` | 0 | Cumulative retirement count (affects max perks) |
| `xp` | `int` | 0 | Experience points (determines level) |
| `gold` | `int` | varies | Current gold (starting amount varies by edition) |
| `notes` | `String` | '' | User-editable notes |
| `checkMarks` | `int` | 0 | Check marks earned (0-18, every 3 = 1 perk) |
| `isRetired` | `bool` | false | Retirement status |
| `variant` | `Variant` | base | Class variant (affects perks/masteries) |
| `partyId` | `String?` | null | FK to Party (nullable — unassigned characters have null) |

**Frosthaven Resources** (all default 0):
| Field | Type | Description |
|-------|------|-------------|
| `resourceHide` | `int` | Hides for crafting |
| `resourceMetal` | `int` | Metal for crafting |
| `resourceLumber` | `int` | Lumber for crafting |
| `resourceArrowvine` | `int` | Arrowvine herb |
| `resourceAxenut` | `int` | Axenut herb |
| `resourceRockroot` | `int` | Rockroot herb |
| `resourceFlamefruit` | `int` | Flamefruit herb |
| `resourceCorpsecap` | `int` | Corpsecap herb |
| `resourceSnowthistle` | `int` | Snowthistle herb |

**Personal Quest Fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `personalQuestId` | `String` | `''` | References a quest ID (e.g., `"gh_510"`) |
| `personalQuestProgress` | `List<int>` | `[]` | Progress per requirement, stored as JSON in DB |

**Loaded from Database** (not constructor params):
| Field | Type | Description |
|-------|------|-------------|
| `perks` | `List<Perk>` | Available perks for this class/variant |
| `characterPerks` | `List<CharacterPerk>` | Perk selections (join table) |
| `masteries` | `List<Mastery>` | Available masteries |
| `characterMasteries` | `List<CharacterMastery>` | Mastery achievements (join table) |

### Computed Properties (Getters)

| Getter | Type | Description |
|--------|------|-------------|
| `level` | `int` | Current level (1-9) based on XP thresholds |
| `xpForNextLevel` | `int?` | XP needed to level up (null at max level) |
| `pocketItemsAllowed` | `int` | Level / 2, rounded up |
| `checkMarkProgress` | `int` | Current progress toward next perk (0-2) |
| `numOfSelectedPerks` | `int` | Count of selected perks |
| `shouldShowTraits` | `bool` | Whether to display class traits |
| `shouldShowMasteries` | `bool` | Whether masteries apply to this character |
| `classSubtitle` | `String` | Full display name with variant suffix |
| `personalQuest` | `PersonalQuest?` | Resolved from `PersonalQuestsRepository` by `personalQuestId` |

### Static Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `level(int xp)` | `int` | Convert XP to level using thresholds |
| `xpForNextLevel(int currentLevel)` | `int?` | XP needed for next level |
| `maximumPerks(level, checkMarks, retirements, masteries)` | `int` | Max perks available |

### Level Thresholds

| Level | XP Required |
|-------|-------------|
| 1 | 0 |
| 2 | 45 |
| 3 | 95 |
| 4 | 150 |
| 5 | 210 |
| 6 | 275 |
| 7 | 345 |
| 8 | 420 |
| 9 | 500 |

### Check Mark Progression

- Every 3 check marks = 1 additional perk
- Maximum 18 check marks (6 perks from check marks)
- `checkMarkProgress` returns 0, 1, or 2 (progress toward next perk)

### Color Handling

`getEffectiveColor()` returns:
- Neutral gray if character is retired
- `playerClass.primaryColor` otherwise

---

## PlayerClass

> **File**: `lib/models/player_class.dart`

Defines a character class with its attributes, colors, and variant support.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `race` | `String` | required | Race name (e.g., "Valrath", "Inox") |
| `name` | `String` | required | Base class name (e.g., "Brute") |
| `classCode` | `String` | required | Short code for lookups (e.g., "br") |
| `category` | `ClassCategory` | required | Edition/expansion source |
| `primaryColor` | `int` | required | Hex color for theme (RGB int) |
| `title` | `String?` | null | Mercenary pack title (required for `mercenaryPacks`) |
| `variantNames` | `Map<Variant, String>?` | null | Override names per variant |
| `secondaryColor` | `int?` | null | Optional secondary color |
| `locked` | `bool` | true | Whether class is locked/spoiler |
| `traits` | `List<String>` | [] | Class traits (e.g., "Tank", "Support") |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getDisplayName(Variant)` | `String` | Variant override name or base name |
| `getFullDisplayName(Variant)` | `String` | "Race - ClassName" or just title for merc packs |
| `hasVariantName(Variant)` | `bool` | Whether variant has an override name |
| `getCombinedDisplayNames()` | `String` | All unique variant names joined |

### ClassCategory Enum

| Value | Description |
|-------|-------------|
| `gloomhaven` | Original Gloomhaven base game |
| `jawsOfTheLion` | Starter set (simpler classes) |
| `frosthaven` | Sequel with masteries and resources |
| `crimsonScales` | Fan expansion |
| `custom` | User-created classes |
| `mercenaryPacks` | Standalone character packs |

**Mercenary Pack Special Case:**
- Requires non-null `title` (assertion enforced)
- Uses `title` instead of "Race - Name" format
- Does not show race in display

### Variant Enum

| Value | Description |
|-------|-------------|
| `base` | Original version |
| `frosthavenCrossover` | Frosthaven crossover rules |
| `gloomhaven2E` | Gloomhaven 2nd Edition |
| `v2`, `v3`, `v4` | Additional version variants |

### Example: Variant Names

```dart
// Brute has different names in different editions
PlayerClass(
  name: 'Brute',
  race: 'Inox',
  classCode: ClassCodes.brute,
  variantNames: {
    Variant.gloomhaven2E: 'Bruiser',
  },
  // ...
)

// getDisplayName returns:
// - Variant.base → "Brute"
// - Variant.gloomhaven2E → "Bruiser"
```

---

## Enhancement

> **File**: `lib/models/enhancement.dart`

Represents an enhancement option for the calculator.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `category` | `EnhancementCategory` | required | Type of enhancement |
| `name` | `String` | required | Display name |
| `ghCost` | `int` | 0 | Gloomhaven cost |
| `fhCost` | `int?` | null | Frosthaven/GH2E cost (fallback to ghCost) |
| `assetKey` | `String?` | null | SVG asset identifier |

### Getters

| Getter | Type | Description |
|--------|------|-------------|
| `cost` | `int` | Edition-specific cost with fallback |

### EnhancementCategory Enum

Defined in `lib/models/enhancement_category.dart`:

| Value | Description | Example Enhancements |
|-------|-------------|---------------------|
| `charPlusOne` | +1 character stats | +1 Move, +1 Attack, +1 Range |
| `summonPlusOne` | +1 summon stats | +1 Summon Move, +1 Summon Attack |
| `negativeConditions` | Negative status effects | Poison, Wound, Muddle |
| `positiveConditions` | Positive status effects | Strengthen, Bless |
| `element` | Element infusions | Fire, Ice, Earth, etc. |
| `hex` | Hex targeting | Add Hex |
| `other` | Miscellaneous | Jump, Specific Element |

---

## Perk

> **File**: `lib/models/perk/perk.dart`

Defines a class perk that modifies the attack modifier deck.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `perkId` | `String` | required | Composite ID: `{classCode}_{variant}_{index}` |
| `classCode` | `String` | required | Reference to PlayerClass |
| `quantity` | `int` | 1 | Number of this perk available |
| `perkDetails` | `String` | required | Game text with icon placeholders |
| `grouped` | `bool` | false | Whether perk is grouped with others |
| `variant` | `Variant` | base | Class variant |

### Perk ID Format

```
{classCode}_{variant}_{index}{letter}
```

Examples:
- `br_base_01a` - Brute, base variant, perk 1, first copy
- `br_base_01b` - Brute, base variant, perk 1, second copy (quantity=2)
- `br_gloomhaven2E_05a` - Bruiser variant, perk 5

### Perk Text Parsing

The `perkDetails` field contains game text with icon placeholders that are parsed by `GameTextParser`:

```
"Remove two {-1} cards"
"Add one {+2} card"
"Add one {ROLLING} {PUSH} 2 card"
```

See `docs/game_text_parser.md` for placeholder syntax.

### Grouped Perks

When `grouped = true`, the perk is visually grouped with adjacent perks in the UI. This is used for perks that are thematically related (e.g., "Remove four +0 cards" + "Add one +1 card").

---

## Perks (Container)

> **File**: `lib/models/perk/perk.dart`

Container class for variant-specific perk lists.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `perks` | `List<Perk>` | List of perk definitions |
| `variant` | `Variant` | Which variant these perks belong to |

---

## CharacterPerk (Join Table)

> **File**: `lib/models/perk/character_perk.dart`

Links a character to a perk with selection state.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `characterUuid` | `String` | FK to Character |
| `perkId` | `String` | FK to Perk |
| `isSelected` | `bool` | Whether perk is checked |

---

## Mastery

> **File**: `lib/models/mastery.dart`

Defines a class mastery (Frosthaven feature).

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `masteryId` | `String` | Composite ID: `{classCode}_{variant}_{index}` |
| `classCode` | `String` | Reference to PlayerClass |
| `masteryDetails` | `String` | Game text with icon placeholders |
| `variant` | `Variant` | Class variant |

### Mastery Availability

Masteries are only available for:
- Frosthaven classes
- Custom classes (community)
- Mercenary packs
- Crimson Scales classes

The `Character.shouldShowMasteries` getter determines display.

---

## CharacterMastery (Join Table)

> **File**: `lib/models/character_mastery.dart`

Links a character to a mastery with achievement state.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `characterUuid` | `String` | FK to Character |
| `masteryId` | `String` | FK to Mastery |
| `isAchieved` | `bool` | Whether mastery is completed |

---

## GameEdition

> **File**: `lib/models/game_edition.dart`

Enum representing game editions with edition-specific rules.

### Values

| Value | Description |
|-------|-------------|
| `gloomhaven` | Original Gloomhaven |
| `gloomhaven2e` | Gloomhaven 2nd Edition |
| `frosthaven` | Frosthaven |

### Getters

| Getter | Type | Description |
|--------|------|-------------|
| `displayName` | `String` | Human-readable edition name (e.g., "Gloomhaven 2e") |

### Edition-Specific Properties

| Property | GH | GH2E | FH |
|----------|----|----|-----|
| `hasLostModifier` | false | true | true |
| `hasPersistentModifier` | false | false | true |
| `hasEnhancerLevels` | false | false | true |
| `supportsPartyBoon` | true | true | false |
| `multiTargetAppliesToAll` | true | false | false |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `maxStartingLevel(int prosperityLevel)` | `int` | Max starting level for a given prosperity. GH: prosperity level directly. GH2E/FH: `(prosperity / 2).ceil()` |
| `startingGold({int level, int prosperityLevel})` | `int` | Starting gold for a new character. GH: `15 × (level + 1)`. GH2E: `10 × prosperity + 15`. FH: `10 × prosperity + 20` |

### Starting Character Rules

| Edition | Max Starting Level | Starting Gold Formula |
|---------|-------------------|----------------------|
| Gloomhaven | Prosperity Level | 15 × (L + 1) |
| Gloomhaven 2E | Prosperity / 2 (rounded up) | 10 × P + 15 |
| Frosthaven | Prosperity / 2 (rounded up) | 10 × P + 20 |

Where L = starting level, P = prosperity level.

---

## Campaign

> **File**: `lib/models/campaign.dart`

Represents a persistent game campaign with edition-specific prosperity tracking.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | UUID identifier |
| `name` | `String` | required | Campaign name |
| `edition` | `GameEdition` | required | Game edition (affects prosperity thresholds) |
| `prosperityCheckmarks` | `int` | 0 | Raw checkmark count |
| `donatedGold` | `int` | 0 | Sanctuary donations |
| `createdAt` | `DateTime?` | null | Creation timestamp |

### Computed Properties

| Getter | Type | Description |
|--------|------|-------------|
| `prosperityLevel` | `int` | Current level (1-9) based on checkmark thresholds |
| `maxProsperityLevel` | `int` | Maximum level (currently 9 for all editions) |
| `checkmarksForNextLevel` | `int?` | Checkmarks needed for next level (null at max) |
| `checkmarksForCurrentLevel` | `int` | Checkmarks threshold for current level |

### Prosperity Thresholds

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|-------|---|---|---|---|---|---|---|---|---|
| Checkmarks | 0 | 5 | 10 | 16 | 23 | 31 | 40 | 51 | 65 |

### Serialization

- `toMap()` / `fromMap()` for SQLite persistence
- `edition` stored as `GameEdition.name` string in DB

---

## Party

> **File**: `lib/models/party.dart`

Represents a party within a campaign, tracking reputation.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | UUID identifier |
| `campaignId` | `String` | required | FK to Campaign |
| `name` | `String` | required | Party name |
| `reputation` | `int` | 0 | Party reputation (-20 to +20) |
| `createdAt` | `DateTime?` | null | Creation timestamp |

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `minReputation` | -20 | Minimum reputation bound |
| `maxReputation` | 20 | Maximum reputation bound |

### Serialization

- `toMap()` / `fromMap()` for SQLite persistence

---

## Database Relationships

### Character Creation Flow

1. User selects `PlayerClass` and `Variant`
2. `Character` created with UUID
3. `CharacterPerk` rows auto-created for all class/variant perks
4. `CharacterMastery` rows auto-created (if masteries apply)

### Data Loading Flow

1. `DatabaseHelper.queryAllCharacters()` loads base character data
2. `CharactersModel._loadPerks()` loads perks + selections
3. `CharactersModel._loadMasteries()` loads masteries + achievements
4. Assembled `Character` objects are stored in model

See `docs/database_schema.md` for table schemas and migrations.
