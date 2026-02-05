# Personal Quests Implementation Plan

## Overview

Add Personal Quests feature to track character retirement goals. Data sourced from [gloomhavensecretariat](https://github.com/Lurkars/gloomhavensecretariat) repository, bundled statically like perks/masteries.

## Scope

- **Editions**: Gloomhaven (24 quests), GH 2E, Frosthaven (Jaws of the Lion has no personal quests)
- **Per Character**: Each character has ONE assigned quest
- **Progress Tracking**: Counter-based requirements (e.g., "Kill 15 bandits: 7/15")
- **Retirement**: Quest completion enables retirement

---

## Data Models

### PersonalQuest (static game data)
**File**: `lib/models/personal_quest.dart`

```dart
class PersonalQuest {
  String questId;           // "gh_510", "fh_581"
  String edition;           // "gh", "gh2e", "fh"
  String cardId;            // "510" (original card number)
  String title;             // "Seeker of Xorn"
  List<QuestRequirement> requirements;
  QuestReward reward;       // unlockCharacter or openEnvelope
}

class QuestRequirement {
  String description;       // "Crypt scenarios completed"
  int targetCount;          // 3
}

class QuestReward {
  QuestRewardType type;     // character | envelope
  String value;             // "squidface" | "X"
}
```

### CharacterPersonalQuest (character progress)
**File**: `lib/models/character_personal_quest.dart`

```dart
class CharacterPersonalQuest {
  String characterUuid;
  String questId;
  List<int> progress;       // [2, 0] for 2-requirement quest
  bool isCompleted;
}
```

---

## Repository

**File**: `lib/data/personal_quests/personal_quests_repository.dart`

Static data converted from gloomhavensecretariat JSON:

```dart
class PersonalQuestsRepository {
  static final Map<String, List<PersonalQuest>> questsByEdition = {
    'gh': [...],    // 24 quests (510-533)
    'gh2e': [...],  // GH 2E quests
    'fh': [...],    // Frosthaven quests (581+)
  };

  static List<PersonalQuest>? getQuestsForEdition(String edition) =>
      questsByEdition[edition];
}
```

---

## Database Changes

### New Tables

**PersonalQuestsTable** (regenerated from repository):
```sql
CREATE TABLE PersonalQuestsTable (
  _id TEXT PRIMARY KEY,        -- "gh_510"
  Edition TEXT NOT NULL,
  Title TEXT NOT NULL,
  Requirements TEXT NOT NULL,  -- JSON
  RewardType TEXT NOT NULL,
  RewardValue TEXT NOT NULL
)
```

**CharacterPersonalQuests** (persisted):
```sql
CREATE TABLE CharacterPersonalQuests (
  CharacterUuid TEXT NOT NULL,
  QuestID TEXT NOT NULL,
  Progress TEXT NOT NULL,      -- JSON array [2, 0]
  IsCompleted BOOL NOT NULL,
  PRIMARY KEY (CharacterUuid, QuestID)
)
```

### Character Table Update
```sql
ALTER TABLE Characters ADD COLUMN PersonalQuestId TEXT
```

### Migration
- Increment to version 17
- Add migration in `database_migrations.dart`

---

## Character Model Updates

**File**: `lib/models/character.dart`

Add fields:
```dart
String? personalQuestId;
CharacterPersonalQuest? characterPersonalQuest;
```

Add helpers:
```dart
bool supportsPersonalQuests() => category != ClassCategory.jawsOfTheLion;
bool isQuestComplete() => characterPersonalQuest?.isCompleted ?? false;
```

---

## State Management

**File**: `lib/viewmodels/characters_model.dart`

Add methods:
- `assignPersonalQuest(character, questId)` - Assign quest, create progress record
- `updateQuestProgress(character, requirementIndex, newValue)` - Update counter
- `_loadPersonalQuest(character)` - Load quest progress on character load

---

## UI Components

### PersonalQuestSection
**File**: `lib/ui/widgets/personal_quest_section.dart`

Location: Character screen, after Stats row, before Resources

```
+------------------------------------------+
| Personal Quest                      [v]  |
|------------------------------------------|
| #510 - Seeker of Xorn                    |
|                                          |
| [ ] Crypt scenarios          [2] / 3     |
| [ ] Follow Noxious Cellar    [0] / 1     |
|                                          |
| Reward: [eye icon to reveal]             |
+------------------------------------------+
```

- `ExpansionTile` like Resources section
- Shows quest card ID + title
- Requirement rows with counter widgets
- Edit mode: +/- buttons on counters
- Spoiler toggle for reward

### SelectPersonalQuestDialog
**File**: `lib/ui/dialogs/select_personal_quest_dialog.dart`

- Lists quests for character's edition
- Shows card ID + title (reward hidden)
- "Random" selection option

---

## Localization

Add to ARB files:
```json
"personalQuest": "Personal Quest",
"assignPersonalQuest": "Assign Personal Quest",
"questComplete": "Quest Complete!",
"readyToRetire": "Ready to Retire",
"noQuestAssigned": "No quest assigned"
```

---

## Implementation Phases

### Phase 1: Data Layer
1. Create `PersonalQuest` and `CharacterPersonalQuest` models
2. Create `PersonalQuestsRepository` with converted static data
3. Add database tables and migration (v17)
4. Update `Character` model
5. Add `DatabaseHelper` query methods

### Phase 2: State Management
1. Add quest methods to `CharactersModel`
2. Integrate quest loading into character load flow

### Phase 3: UI
1. Create `PersonalQuestSection` widget
2. Add to `CharacterScreen`
3. Create `SelectPersonalQuestDialog`

### Phase 4: Polish
1. Add spoiler handling for rewards
2. Add localization strings
3. Update backup/restore to include quest tables

---

## Key Files to Modify

| File | Changes |
|------|---------|
| `lib/models/character.dart` | Add `personalQuestId` field |
| `lib/data/database_helpers.dart` | Add tables, queries |
| `lib/data/database_migrations.dart` | Add v17 migration |
| `lib/viewmodels/characters_model.dart` | Add quest methods |
| `lib/ui/screens/character_screen.dart` | Add PersonalQuestSection |
| `lib/l10n/app_en.arb` | Add localization strings |
| `lib/l10n/app_pt.arb` | Add Portuguese translations |

---

## Verification

1. **Create character** - Verify quest can be assigned
2. **Update progress** - Increment/decrement counters, verify persistence
3. **Complete quest** - Mark all requirements complete, verify `isCompleted` flag
4. **Reload app** - Verify quest data persists correctly
5. **Backup/restore** - Verify quest progress included in backup
6. **Edition switching** - Verify correct quests shown per edition

---

## Enhancement Type Card - Make it stand out ✅ DONE

**Implemented:** Pinned header with animated primary-colored glow.

- Card is now pinned at the top (stays visible when scrolling)
- Pulsing glow animation when no enhancement is selected (draws attention)
- Subtle static glow when enhancement is selected
- Larger icon (40px vs 30px) and text (titleLarge vs bodyMedium) for prominence

---

## Font Consolidation - Investigate

Consider changing fonts to use **Tinos** for body text and **Germania One** for subtitles (keeping Pirata One for select large titles). This would mean we could potentially remove some of the font assets and use Google Fonts or built-in alternatives.

**To investigate:**
- Are Tinos and Germania One available via `google_fonts` package or system fonts?
- Which current font assets could be removed (HighTower, Nyala, OpenSans, Roboto)?
- How would this affect app bundle size?
- Visual comparison of current fonts vs proposed alternatives

---

## Code Audit Refactors - Remaining Issues

**Added:** 2026-02-04
**Status:** Pending

Issues #1-5, #15-19 completed and pushed to dev. The following larger refactors remain.

### Issue #8: Long Method - database_helpers.dart _onCreate

**File:** `lib/data/database_helpers.dart` (lines ~76-166)
**Problem:** `_onCreate` method is ~90 lines with nested `Future.forEach` and 3-level deep nesting

**Suggested Refactor:**
1. Extract table creation to `_createTables(Database db)`
2. Extract perk seeding to `_seedPerks(Database db)`
3. Extract mastery seeding to `_seedMasteries(Database db)`
4. Keep `_onCreate` as a coordinator calling these methods

---

### Issue #9: Long Method - database_helpers.dart _onUpgrade

**File:** `lib/data/database_helpers.dart` (lines ~168-247)
**Problem:** ~80 lines with 40+ sequential `if (oldVersion < X)` blocks

**Suggested Refactor:**
1. Create a `_migrations` map: `Map<int, Future<void> Function(Database)>`
2. Iterate through migrations where version > oldVersion
3. Each migration becomes a focused, testable function

---

### Issue #10: Long Method - getCalculationBreakdown

**File:** `lib/viewmodels/enhancement_calculator_model.dart`
**Problem:** `getCalculationBreakdown()` is ~200 lines building calculation steps

**Suggested Refactor:**
1. `_buildBaseCostStep()` - Enhancement type base cost
2. `_buildCardLevelStep()` - Card level penalty
3. `_buildPreviousEnhancementsStep()` - Previous enhancements penalty
4. `_buildModifierSteps()` - Multi-target, loss, persistent modifiers
5. `_buildDiscountSteps()` - Temp enhancement, Hail's, Party Boon, Enhancer
6. Main method becomes a coordinator assembling steps

---

### Issue #11: Deep Database Nesting (4 levels)

**File:** `lib/data/database_helpers.dart` (lines ~110-129)
**Problem:** 4 levels of nested loops in perk/mastery seeding

**Fix:** Address together with Issue #8 by extracting to helper methods

---

### Issue #12: Deep UI Nesting (7+ levels)

**File:** `lib/ui/screens/enhancement_calculator_screen.dart` (lines ~445-514)
**Problem:** `_buildToggleRow` has 7+ levels: `Padding > Row > [IconButton, Expanded > GestureDetector > Padding > Column, GestureDetector > Switch]`

**Fix:** Extract `_ToggleRow` as a separate widget class, or simplify layout

---

### Issue #13: God Widget - _CardDetailsGroupCard

**File:** `lib/ui/screens/enhancement_calculator_screen.dart` (lines ~183-516)
**Problem:** 330 lines handling card level, previous enhancements, and all modifier toggles

**Suggested Refactor:**
1. `_CardLevelSection` - Slider and cost display
2. `_PreviousEnhancementsSection` - Segmented button and cost
3. `_ModifierTogglesSection` - All toggle rows
4. Or extract helper methods within the existing widget

---

### Issue #14: God Widget - _DiscountsGroupCard

**File:** `lib/ui/screens/enhancement_calculator_screen.dart` (lines ~576-834)
**Problem:** 250 lines with toggle group config + enhancer dialog (~100 lines)

**Suggested Refactor:**
1. Extract `EnhancerDialog` to `lib/ui/dialogs/enhancer_dialog.dart`
2. Keep `_DiscountsGroupCard` focused on toggle group configuration

---

### Issue #15: Convert `_build*` Methods to Proper Widgets

**Problem:** Throughout the codebase, there are methods like `Widget _buildMyWidget()` that return widgets. This pattern:
- Doesn't benefit from Flutter's widget lifecycle optimizations
- Makes the code harder to test in isolation
- Mixes widget building logic with parent widget state

**Goal:** Scan the app for `Widget _build` method patterns and convert them to proper StatelessWidget or StatefulWidget classes.

**Files to scan:**
- `lib/ui/screens/*.dart`
- `lib/ui/widgets/**/*.dart`

**Exceptions (acceptable patterns):**
- Methods that need direct access to parent state/controllers that would be awkward to pass as props
- Very simple one-liner builders

---

### Refactoring Guidelines

Follow `/refactor` skill principles:
- **Small steps** - Make one change, verify, commit
- **Behavior preserved** - No functional changes
- **One thing at a time** - Don't mix refactoring with features

### Testing Checklist:
- [ ] Enhancement calculator displays correctly
- [ ] All toggles work (multiple targets, loss, persistent)
- [ ] Cost calculations are correct for all editions
- [ ] Info dialogs open properly
- [ ] Database operations succeed (character CRUD, perks, masteries)
- [ ] Backup/restore works

### Completion Checklist:
- [x] #8: Extract `_onCreate` helper methods
- [x] #9: Refactor `_onUpgrade` migrations
- [x] #10: Split `getCalculationBreakdown` into sections
- [x] #11: Flatten database nesting (with #8)
- [x] #12: Reduce UI nesting in toggle rows
- [x] #13: Extract `_CardDetailsGroupCard` sections
- [x] #14: Extract `EnhancerDialog` from `_DiscountsGroupCard`
- [ ] #15: Convert `_build*` methods to proper widgets
