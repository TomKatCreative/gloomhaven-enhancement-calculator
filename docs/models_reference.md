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
│ PersonalQuest   │──────▶ Character.personalQuestId
│  (definition)   │
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
| `previousRetirements` | `int` | 0 | Cumulative retirement count (adds to max perks, except for JotL — no retirement mechanic) |
| `xp` | `int` | 0 | Experience points (determines level) |
| `gold` | `int` | varies | Current gold (starting amount varies by edition) |
| `notes` | `String` | '' | User-editable notes |
| `checkMarks` | `int` | 0 | Check marks earned (0-18, every 3 = 1 perk) |
| `isRetired` | `bool` | false | Retirement status |
| `showResources` | `bool` | true | Whether the Resources section is shown on the sheet (set by edition at creation; toggleable per-character; hiding never clears counts) |
| `jawsOfTheLionEdition` | `bool` | false | Whether the character was created under the JotL game mode. Drives `isJawsOfTheLion` (game-mode driven, **not** class-driven — a JotL class created under another mode behaves normally), which hides the PQ/prosperity/resources sections |
| `variant` | `Variant` | base | Class variant (affects perks/masteries) |
| `partyId` | `String?` | null | FK to Party (nullable — unassigned characters have null) |

**Frosthaven Resources:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `resources` | `Map<Resource, int>` | every `Resource` → 0 | Count of each crafting resource. The constructor takes `Map<Resource, int> resources = const {}` and merges it over the zero-filled map, so every `Resource` always has an entry. Each `Resource` maps to its own Characters column (`Resource.column`) in `toMap`/`fromMap` |

**Personal Quest Fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `personalQuestId` | `String` | `''` | References a quest ID (e.g., `"pq_gh_510"`) |
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
| `checkMarkProgress` | `int` | Checkmarks toward the next perk: 0 with none, otherwise 1–3 (3 means a perk was just completed) |
| `numOfSelectedPerks` | `int` | Count of selected perks |
| `shouldShowTraits` | `bool` | Whether to display class traits |
| `shouldShowMasteries` | `bool` | Whether the class/variant has masteries (derived from `MasteriesRepository`) |
| `classSubtitle` | `String` | Full display name with variant suffix |
| `personalQuest` | `PersonalQuest?` | Resolved from `PersonalQuestsRepository` by `personalQuestId` |

### Static Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `level(int xp)` | `int` | Convert XP to level using thresholds |
| `xpForNextLevel(int currentLevel)` | `int?` | XP needed for next level |
| `maximumPerks(level, checkMarks, retirements, masteries)` | `int` | Max perks available: `(level - 1) + (checkMarks ~/ 3) + retirements + achievedMasteries`. The `retirements` term is excluded for JotL (no retirement mechanic) |

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
- Maximum 18 check marks (`Character.maxCheckMarks`; 6 perks from check marks)
- `checkMarkProgress` returns 0 with no check marks, otherwise 1, 2 or 3

### Color Handling

`getEffectiveColor()` returns:
- Neutral gray if character is retired
- `playerClass.primaryColor` otherwise

---

## Resource

> **File**: `lib/models/resource.dart`

Enum of the nine Frosthaven crafting resources, used as the key of `Character.resources`. Values are declared in Characters-table column order (`hide`, `metal`, `lumber`, `arrowvine`, `axenut`, `rockroot`, `flamefruit`, `corpsecap`, `snowthistle`) because the create-table SQL is generated from `Resource.values`.

| Member | Type | Description |
|--------|------|-------------|
| `column` | `String` | Characters table column holding the count (e.g. `ResourceWood` for `lumber`) |
| `assetKey` | `String` | `asset_config.dart` icon key (e.g. `LUMBER`) |
| `label(AppLocalizations l10n)` | `String` | Localized resource name |
| `displayOrder` | `List<Resource>` | Static: the order the Resources section shows them in (materials, then herbs alphabetically) |

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
| `handSize` | `int` | **required** | Base hand size (number of ability cards) |
| `variantHandSizes` | `Map<Variant, int>?` | null | Variant-specific hand size overrides |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getDisplayName(Variant)` | `String` | Variant override name or base name |
| `getFullDisplayName(Variant)` | `String` | "Race - ClassName" or just title for merc packs |
| `getHandSize(Variant)` | `int` | Variant hand size, falling back to base `handSize` |
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
| `v2`, `v3` | Additional version variants |

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
| `assetKey` | `String` | required | SVG asset identifier. Every enhancement has one; draw it with `EnhancementIcon` |
| `excludedEditions` | `Set<GameEdition>` | `{}` | Editions the enhancement does not exist in (Disarm: all but GH; Ward: GH) |

### Getters

| Getter | Type | Description |
|--------|------|-------------|
| `cost` | `int` | Edition-specific cost with fallback |
| `isPlusOne` | `bool` | True for `charPlusOne`, `summonPlusOne` and `target`: shown with a +1 badge and labelled "+1 Name" in the cost breakdown |
| `isAvailableIn(GameEdition)` | `bool` | False if the edition is in `excludedEditions`. `EnhancementData.isAvailableInEdition` delegates here |
| `key` | `String` | Stable persistence ID, `'<category>:<name>'` (e.g. `charPlusOne:Move`). Survives reordering of `EnhancementData.enhancements`; look it up with `EnhancementData.byKey(key)` (null if unknown) |

### EnhancementCategory Enum

Defined in `lib/data/enhancement_data.dart`:

| Value | Description | Example Enhancements |
|-------|-------------|---------------------|
| `charPlusOne` | +1 character stats | +1 Move, +1 Attack, +1 Range |
| `target` | +1 Target | Target |
| `summonPlusOne` | +1 summon stats | +1 Summon Move, +1 Summon HP |
| `posEffect` | Positive conditions | Strengthen, Bless, Regenerate, Ward |
| `negEffect` | Negative conditions | Poison, Wound, Muddle, Curse |
| `jump` | Jump | Jump |
| `specElem` | Specific element | Element |
| `anyElem` | Any (wild) element | Wild Element |
| `hex` | Attack hex (cost by existing hex count) | 2–13 hexes |

`sectionTitle(AppLocalizations l10n)` returns the localized section header the category is listed under (Character, Summon, Effect, Existing Hexes); `sectionAssetKey` returns the section icon key (`plus_one` for the +1 categories, `hex` for hex, otherwise null).

---

## EnhancementCostCalculator

> **File**: `lib/models/enhancement_cost_calculator.dart`

Pure, immutable computation class for enhancement cost calculations. Has zero dependencies on SharedPrefs, ChangeNotifier, or Flutter. Used by `EnhancementCalculatorModel` via cached delegation.

### Constructor

All fields are `final`. Construct a new instance when inputs change.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `edition` | `GameEdition` | required | Game edition determining rules |
| `enhancement` | `Enhancement?` | null | Selected enhancement |
| `cardLevel` | `int` | 0 | Card level above 1 |
| `previousEnhancements` | `int` | 0 | Previous enhancements count |
| `multipleTargets` | `bool` | false | Multi-target multiplier |
| `lostNonPersistent` | `bool` | false | Lost action modifier (GH2E/FH) |
| `persistent` | `bool` | false | Persistent modifier (FH only) |
| `temporaryEnhancementMode` | `bool` | false | Temporary enhancement mode |
| `hailsDiscount` | `bool` | false | Hail's discount (-5g) |
| `partyBoon` | `bool` | false | Party boon (GH/GH2E) |
| `enhancerLvl2` | `bool` | false | Enhancer L2 (-10g base) |
| `enhancerLvl3` | `bool` | false | Enhancer L3 (-10g/level) |
| `enhancerLvl4` | `bool` | false | Enhancer L4 (-25g/enh) |

### Getters

| Getter | Type | Description |
|--------|------|-------------|
| `totalCost` | `int` | Final calculated total cost |
| `showCost` | `bool` | Whether any input is set |
| `breakdown` | `List<CalculationStep>` | Step-by-step cost breakdown. Steps carry a `CalculationStepKind`, not display text (see [CalculationStep](#calculationstep)). Step values are running totals; the enhancement cost's clamp at 0 is not recorded, so read the total from `totalCost` |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `enhancementCost(Enhancement?)` | `int` | Base cost with multipliers and discounts |
| `cardLevelPenalty(int)` | `int` | Card level penalty with discounts |
| `previousEnhancementsPenalty(int)` | `int` | Previous enhancements penalty |
| `eligibleForMultipleTargets(Enhancement, {edition})` | `bool` | Static: multi-target eligibility, by `EnhancementCategory` (never hex; in GH2E/FH not target or elements) |

The totals and the breakdown share one set of private step builders, so the two cannot drift. The public methods are thin wrappers over them.

### Rule Constants

`static const` fields hold every number in the cost rules: `multiTargetMultiplier` (2), `lostDivisor` (2), `persistentMultiplier` (3), `enhancerL2Discount` (10), `hailsDiscountAmount` (5), `costPerCardLevel` (25), `partyBoonDiscountPerLevel` (5), `enhancerL3DiscountPerLevel` (10), `costPerPreviousEnhancement` (75), `enhancerL4DiscountPerEnhancement` (25), `temporaryEnhancementDiscount` (20) and `temporaryEnhancementMultiplier` (0.8). `CardDetailsCard` uses the per-level and per-enhancement values for its before-discount figures.

---

## CalculationStep

> **File**: `lib/models/calculation_step.dart`

One step of `EnhancementCostCalculator.breakdown`. Holds no display text: the UI turns it into localized strings via the `title(l10n)` and `modifierText(l10n)` extensions in `lib/ui/widgets/calculator/calculation_step_text.dart`.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `kind` | `CalculationStepKind` | required | What the step represents (`baseCost`, `multipleTargets`, `lostAction`, `lostNonPersistentAction`, `persistentAction`, `enhancerLevel2`, `hailsDiscount`, `cardLevel`, `previousEnhancements`, `temporaryEnhancement`) |
| `value` | `int` | required | Running total or the step's value |
| `formula` | `String?` | null | How the value was calculated (e.g. `x2`, `+75g`) |
| `enhancementName` | `String?` | null | Enhancement display name, for `baseCost` |
| `count` | `int?` | null | Printed card level for `cardLevel`, or enhancement count for `previousEnhancements` |
| `modifiers` | `List<CalculationModifier>` | `[]` | Discounts applied within the step, in display order. Each has a `kind` (`CalculationModifierKind`: `partyBoon`, `enhancerLevel3`, `enhancerLevel4`, `temporaryEnhancement`) and an `amount` in gold |

---

## Perk

> **File**: `lib/models/perk/perk.dart`

Defines a class perk that modifies the attack modifier deck.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `number` | `int` | required | Stable identity number (1-based). First positional param. Used to generate `perkId`. |
| `perkId` | `String` | generated | Composite ID: `{classCode}_{variant}_{paddedNumber}{letter}` |
| `classCode` | `String` | required | Reference to PlayerClass |
| `quantity` | `int` | 1 | Number of this perk available |
| `perkDetails` | `String` | required | Game text with icon placeholders |
| `grouped` | `bool` | false | Whether perk is grouped with others |
| `variant` | `Variant` | base | Class variant |

### Perk ID Format

```
{classCode}_{variant}_{paddedNumber}{letter}
```

The `paddedNumber` is derived from the perk's explicit `number` field (zero-padded to 2 digits), not from its position in the list. This makes IDs stable even if definitions are reordered.

**Note:** Perk numbers are **1-based** (first perk in a group is `number: 1`). This differs from masteries which are 0-based — see [Mastery](#mastery) below.

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
| `associatedCharacterUuid` | `String` | FK to Character |
| `associatedPerkId` | `String` | FK to Perk |
| `characterPerkIsSelected` | `bool` | Whether perk is checked |

---

## Mastery

> **File**: `lib/models/mastery/mastery.dart`

Defines a class mastery (Frosthaven feature).

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `number` | `int` | Stable identity number (0-based). First positional param. Used to generate `id`. |
| `id` | `String` | Composite ID: `{classCode}_{variant}_{number}` |
| `classCode` | `String` | Reference to PlayerClass |
| `masteryDetails` | `String` | Game text with icon placeholders |
| `variant` | `Variant` | Class variant |

**Note:** Mastery numbers are **0-based** (first mastery in a group is `number: 0`). This differs from perks which are 1-based — a legacy inconsistency preserved for backward compatibility with existing database records.

### Mastery Availability

Masteries are only available for:
- Frosthaven classes
- The Frosthaven Crossover and Gloomhaven 2e variants of Gloomhaven, Jaws of the Lion and Forgotten Circles classes (base variants have none)
- Mercenary packs
- Some custom (community) classes: Vimthreader, Incarnate, Core, Dome, Skitterclaw, Alchemancer

The `Character.shouldShowMasteries` getter determines display. It is derived from `MasteriesRepository.getMasteryIds(classCode, variant)`, so there is no separate list of classes to update.

---

## CharacterMastery (Join Table)

> **File**: `lib/models/mastery/character_mastery.dart`

Links a character to a mastery with achievement state.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `associatedCharacterUuid` | `String` | FK to Character |
| `associatedMasteryId` | `String` | FK to Mastery |
| `characterMasteryAchieved` | `bool` | Whether mastery is completed |

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
| `shortLabel` | `String` | Toggle abbreviation: GH, GH2e, FH, JotL (not localized) |

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
| `maxStartingLevel(int prosperityLevel)` | `int` | Max starting level for a given prosperity. GH: prosperity level directly. GH2E/FH: `(prosperity / 2).ceil()`. JotL: always 1 (JotL characters are locked to level 1; the create screen reads this when JotL is selected) |
| `startingGold({int level, int prosperityLevel})` | `int` | Starting gold for a new character. GH: `15 × (level + 1)`. GH2E: `10 × prosperity + 15`. FH: `10 × prosperity + 20`. JotL: always 30 (the GH rule at the locked level 1) |

### Starting Character Rules

| Edition | Max Starting Level | Starting Gold Formula |
|---------|-------------------|----------------------|
| Gloomhaven | Prosperity Level | 15 × (L + 1) |
| Gloomhaven 2e | Prosperity / 2 (rounded up) | 10 × P + 15 |
| Frosthaven | Prosperity / 2 (rounded up) | 10 × P + 20 |
| Jaws of the Lion | 1 (locked) | 15 × (L + 1) = 30 |

Where L = starting level, P = prosperity level. JotL characters always start at level 1 — the create screen hides the level slider and shows a fixed starting-gold amount (30).

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

## PersonalQuest

> **File**: `lib/models/personal_quest/personal_quest.dart`

Represents a personal quest card with retirement requirements.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | Quest ID (e.g., `"pq_gh_510"`, `"pq_fh_581"`) |
| `number` | `int` | required | Primary card number (e.g., 510 for GH, 1 for FH) |
| `title` | `String` | required | Quest title (e.g., "Seeker of Xorn") |
| `edition` | `GameEdition` | required | Game edition |
| `requirements` | `List<PersonalQuestRequirement>` | `[]` | Retirement requirements (from repository, not DB) |
| `unlockClassCode` | `String?` | null | Class unlocked upon completion (GH only) |
| `unlockEnvelope` | `String?` | null | Envelope unlocked upon completion |
| `altNumber` | `int?` | null | Secondary card number for dual-numbered editions (e.g., FH asset number). Repository-only, not stored in DB. |

### Computed Properties

| Getter | Type | Description |
|--------|------|-------------|
| `displayNumber` | `String` | `"510"` for GH, `"01"` for FH/GH2E (zero-padded when `altNumber` set) |
| `displayName` | `String` | `"510: Seeker of Xorn"` or `"01: The Study of Plants"` |

### Serialization

- No serializer on the model. The v18 migration seeds the legacy `PersonalQuestsTable` (dropped in v19) through the `toLegacyRow()` extension in `lib/data/migrations/legacy_definition_rows.dart`
- Definitions (requirements, unlock class, unlock envelope) come from `PersonalQuestsRepository`, not the DB

---

## PersonalQuestRequirement

> **File**: `lib/models/personal_quest/personal_quest.dart`

A single requirement within a personal quest.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | `String` | Requirement text |
| `target` | `int` | Numeric target count (1 for binary requirements) |
| `details` | `String?` | Supplemental rules text shown in a bottom sheet (e.g., how to gain Votes) |
| `checklistItems` | `List<String>?` | Optional sub-items rendered as individual checkboxes. Progress stored as bitmask. |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `checkedCount(int rawProgress)` | `int` | For checklist requirements, counts set bits in bitmask. For standard requirements, returns `rawProgress` unchanged. |

---

## Progress Encoding Utilities

> **File**: `lib/models/personal_quest/personal_quest.dart`

| Function | Returns | Description |
|----------|---------|-------------|
| `encodeProgress(List<int>)` | `String` | JSON-encode progress for DB storage |
| `decodeProgress(String)` | `List<int>` | Decode JSON progress; empty string → `[]` |

---

## Party

> **File**: `lib/models/party.dart`

Represents a party within a campaign, tracking reputation, location, notes, and achievements.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | UUID identifier |
| `campaignId` | `String` | required | FK to Campaign |
| `name` | `String` | required | Party name |
| `reputation` | `int` | 0 | Party reputation (-20 to +20) |
| `location` | `String` | `''` | Current scenario location |
| `notes` | `String` | `''` | Party notes |
| `achievements` | `List<String>` | `[]` | Party achievements (JSON-encoded in DB) |
| `createdAt` | `DateTime?` | null | Creation timestamp |

### Computed Properties

| Getter | Type | Description |
|--------|------|-------------|
| `shopPriceModifier` | `int` | Shop price modifier derived from reputation (-5 to +5) |

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `minReputation` | -20 | Minimum reputation bound |
| `maxReputation` | 20 | Maximum reputation bound |

### Serialization

- `toMap()` / `fromMap()` for SQLite persistence
- `achievements` stored as JSON string in DB

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
