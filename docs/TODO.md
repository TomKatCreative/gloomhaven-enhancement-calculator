# Personal Quests

## Status: Released (v4.5.1), dev has additional editions

Personal quests for Gloomhaven (24 quests) and Frosthaven (23 quests) are shipped in production. Crimson Scales (28 quests), Trail of Ashes (8 quests), and Gloomhaven 2E (22 quests) are on `dev`.

### Gloomhaven PQs (v4.5.0)
- `PersonalQuest` model and `PersonalQuestsRepository` (second printing values)
- DB migration v18 (PersonalQuestsTable + PQ columns on Characters)
- PQ selection on character creation screen
- PQ section on character screen with stepper-based progress tracking in edit mode
- Sequential "Then" requirements: disabled until predecessor requirement is complete
- Change/remove quest flow with confirmation dialog (shown after new quest selection)
- Remove quest option in PQ selector screen
- Retirement prompt: snackbar with confetti pop on PQ completion → confirmation dialog → retire
- `CollapsibleSectionCard` for PQ section; `SectionCard` for static sections
- Class unlock icon / envelope icon in header row
- Strikethrough gold display for retired characters (gold forfeited on retirement)
- Text overflow handling for long requirement descriptions
- Full test coverage (model, repository, viewmodel, widget tests)

### Frosthaven PQs (v4.5.1)

- 23 Frosthaven quests added to `PersonalQuestsRepository` (47 total: 24 GH + 23 FH)
- DB migration v19: drops Perks, Masteries, and PersonalQuests definition tables (loaded from repositories)
- Dual numbering: `altNumber` field on `PersonalQuest` for FH cards (e.g., card #1 / asset 581)
- `displayNumber` getter: `"01 (581)"` for FH, `"510"` for GH
- FH quests all unlock envelopes (no class unlocks); envelope values shown in UI
- Envelope display: PirataOne for single-letter (X, A), ENVELOPE SVG + styled text for numbered envelopes (alt number in `#1D5678`)
- Scenario SVG assets (boat, climbing_gear, sled) for FH quest descriptions
- Checkbox UI for binary (target=1) requirements: edit mode (interactive), view mode (disabled)
- Removed circle status icons from requirement rows (dimming + primary color conveys state)
- Edit-mode stepper counter uses `contrastedPrimary` when complete
- Search in PQ selector matches `displayNumber` (padded + alt numbers)
- Edition filter chips on PQ selector screen

### Gloomhaven 2E PQs

- 22 GH2E quests added to `PersonalQuestsRepository` (105 total: 24 GH + 22 GH2E + 23 FH + 28 CS + 8 TOA)
- `PersonalQuestEdition.gloomhaven2e` added to enum
- Dual numbering: card 01-22 / asset 537-558 (same pattern as FH)
- All 22 quests unlock classes (no envelope unlocks), 2 per class (11 GH unlockable classes)
- GH2E quests include "Then read Section X" requirements (section book pattern)

## Remaining Work

- **Spoiler protection** - Consider hiding unlock class name/icon behind a spoiler toggle for players who don't want to know what class they'll unlock.

---

## Town Sheet — Foundation

> **Feature flag**: `kTownSheetEnabled` in `lib/data/constants.dart` — currently `false`

## Status: Implemented

Campaign/party management for tracking persistent game state across play groups.

### What's Implemented

- **Campaign model** (`lib/models/campaign.dart`): Edition-specific prosperity tracking with level computation from checkmark thresholds
- **Party model** (`lib/models/party.dart`): Party reputation tracking with bounds (-20 to +20)
- **Character-Party linking**: Nullable `partyId` FK on Characters (existing characters unassigned)
- **TownModel** (`lib/viewmodels/town_model.dart`): ChangeNotifier for campaign/party CRUD, prosperity/reputation management, active selection persistence via SharedPrefs
- **Party filtering** on CharactersModel: `showAllCharacters` toggle filters character list by active party
- **DB migration v19** (conditional): Campaigns/Parties tables + PartyId column on Characters (separate from Personal Quests v18 migration; only runs when `kTownSheetEnabled` is `true`)
- **Town screen** (`lib/ui/screens/town_screen.dart`): Empty state → campaign card (prosperity + sanctuary) → party section
- **Party switching**: Swap icon in PartySection header opens bottom sheet (2+ parties); add icon opens CreatePartyScreen (1 party)
- **Create Campaign/Party screens**: Pushed-route forms following CreateCharacterScreen pattern
- **Section widgets**: `TownEmptyState`, `ProsperitySection`, `PartySection`, `CampaignSelector`
- **App bar integration**: Campaign name title, create/delete actions in edit mode
- **FAB edit mode**: Same toggle pattern as Characters page
- **Localization**: EN + PT strings for all town UI
- **Backup/restore**: Campaigns and Parties tables included in backup, SharedPrefs town state included
- **Full test coverage**: Campaign model tests (36), Party model tests, TownModel tests (28), 714 total tests passing

### Architecture

| Level | What it tracks | Scope |
|-------|---------------|-------|
| **Campaign** | Prosperity, donated gold | Persistent across all parties |
| **Party** | Party name, reputation | Per party group |
| **Character** | XP, gold, perks, etc. | Per character (optionally linked to party) |

### Remaining Work

- **Achievement/scenario tracking** — Complex, needs scenario data repository (deferred)
- **Frosthaven extensions** — Buildings, morale, seasons (future sprint)
- **GH2E prosperity thresholds** — May differ from GH, needs research
- **Character assignment UI** — UI for assigning characters to parties from the Characters tab
- **Party filter toggle** — UI toggle on Characters tab to filter by active party
- **FH PQ #4 "Greed is Good" prosperity integration** — Currently uses `target: 1` (bool checkbox). When town/campaign data is available, compute the actual target threshold (`80 + 20 × prosperity`) from the character's campaign. No DB migration needed — quest definitions live in code, not the DB. Existing users with `progress[0] >= 1` can be treated as "already confirmed."

---

## Font Consolidation - Investigate

Consider changing fonts to use **Tinos** for body text and **Germania One** for subtitles (keeping Pirata One for select large titles). This would mean we could potentially remove some of the font assets and use Google Fonts or built-in alternatives.

**To investigate:**
- Are Tinos and Germania One available via `google_fonts` package or system fonts?
- Which current font assets could be removed (HighTower, Nyala, OpenSans, Roboto)?
- How would this affect app bundle size?
- Visual comparison of current fonts vs proposed alternatives

---

## Code Audit Refactors - Remaining Issue

**Added:** 2026-02-04
**Status:** Pending

### Convert `_build*` Methods to Proper Widgets

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

## Enhanced Backup System

**Added:** 2026-02-04
**Status:** Partially Done

### Improvements

#### ~~1. Include SharedPreferences in Backup (High Priority)~~ — **Done**

SharedPreferences are now included as an optional third element in the backup JSON array. See `docs/shared_prefs_keys.md` "Backup Integration" section for details.

#### ~~2. One-Tap Backup Sharing~~ — **Done**

Share sheet implemented via `share_plus` in `backup_dialog.dart`. Both "Save" and "Share" buttons available.

#### ~~3. Minimum Backup Version Enforcement~~ — **Done**

Restore rejects backups older than DB v8 (app 4.2.0) with a user-facing error message. Prevents crashes from ancient schema formats.

#### 4. Auto-Backup to App Documents

- Write backup to app documents directory after each character save
- Keep last 5 auto-backups, rotate oldest
- No user action required

**Files to modify:**
- `lib/viewmodels/characters_model.dart` - Trigger auto-backup on character save
- New file: `lib/data/auto_backup_service.dart` - Handle rotation logic

#### 5. Backup Age Reminder

- Track last manual backup date in SharedPrefs
- Show subtle indicator in Settings if >30 days since last backup
- "Last backed up: 45 days ago" with warning color

**Files to modify:**
- `lib/shared_prefs.dart` - Add `lastManualBackupDate` key
- `lib/ui/widgets/settings/backup_settings_section.dart` - Show last backup indicator
- `lib/ui/dialogs/backup_dialog.dart` - Update timestamp on successful backup

### Remaining Implementation Order

1. Backup age reminder (quick win)
2. Auto-backup (nice-to-have)

---

## Character PageView Swiping Performance

**Added:** 2026-02-09
**Status:** Partially addressed

### Completed Fixes
- ~~Scroll jank from active section tracking~~ — Replaced `context.watch` rebuild with `ValueNotifier` for active section state (`42925b8`)
- ~~Header tint persisting after swiping~~ — Fixed character header tint not resetting when swiping to a new character (`8cc8c66`)

### Remaining Investigation (if still needed)
1. Add `allowImplicitScrolling: true` to `PageView.builder` to preload adjacent pages
2. Consider wrapping entire `CharacterScreen` in `RepaintBoundary` if needed
3. Profile with Flutter DevTools Performance overlay to identify actual jank
4. Consider caching the rasterized class icon background image

---

## Code Audit — Future Refactors

**Added:** 2026-02-09
**Status:** Pending

Larger refactoring opportunities identified during codebase audit. These are non-urgent structural improvements that would reduce complexity and improve maintainability.

### CharactersModel Decomposition — Partially Done
**File:** `lib/viewmodels/characters_model.dart` (~470 lines, down from ~598)

**Completed:**
- Extracted `PersonalQuestService` (`lib/data/personal_quest_service.dart`) — quest assignment, progress, and completion logic delegated from CharactersModel
- Moved debug character creation (`createCharactersTest`) from CharactersModel to `DebugSettingsSection` (where it's actually used)

**Remaining candidates (low priority — thin wrappers, tightly coupled):**
- Element sheet state, scroll controllers, navigation logic — tightly coupled to CRUD/theme sync
- Perk/mastery toggle — too thin (2 methods, ~13 lines each)

### ~~EnhancementCalculatorModel Cost Calculation Extraction~~ — Done
**File:** `lib/viewmodels/enhancement_calculator_model.dart`

Extracted into `EnhancementCostCalculator` (`lib/models/enhancement_cost_calculator.dart`). Model delegates cost computation to cached calculator instance.

### ~~Eliminate Direct SharedPrefs Access from UI Files~~ — Partially Done

**Completed:** ~30 `SharedPrefs()` calls eliminated across 10 UI files. All calculator state (gameEdition, partyBoon, enhancerLvl2/3/4), section expansion state (generalExpanded, questAndNotesExpanded, perksAndMasteriesExpanded, townDetailsExpanded, partyDetailsExpanded), and the redundant navigation bar persist call now go through ViewModels.

**Files fully cleaned (SharedPrefs import removed):** `ghc_navigation_bar.dart`, `enhancement_calculator_screen.dart`, `ghc_animated_app_bar.dart`, `enhancer_dialog.dart`, `info_dialog.dart`, `stats_and_resources_card.dart`, `quest_and_notes_card.dart`, `perks_and_masteries_card.dart`, `town_screen.dart`

**Deferred (~34 calls in 7 files):**

| File | Calls | Reason |
|------|-------|--------|
| `element_tracker_sheet.dart` | 12 | Purely local widget state, self-contained |
| `class_selector_screen.dart` | 5 | Needs per-class unlock map in a new model |
| `gameplay_settings_section.dart` | 8 | Envelope X/V toggles need new model or AppModel expansion |
| `home.dart` | 1 | One-shot dialog flag, minimal value |
| `update_450_dialog.dart` | 2 | One-shot flags, minimal value |
| `custom_class_warning_dialog.dart` | 2 | Dialog-local preference |
| `restore_dialog.dart` | 4 | Legitimate post-restore sync reads |

### SharedPrefs Enhancer Level Cascade
**File:** `lib/shared_prefs.dart`

Move the cascade validation logic (setting lvl4 triggers lvl3/2/1) out of property setters into a dedicated validator.

### ~~DatabaseHelper Decomposition~~ — Done
**File:** `lib/data/database_helper.dart`

Extracted into `DatabaseBackupService` (`lib/data/database_backup_service.dart`), separate from query logic.

### SectionCard / CollapsibleSectionCard Deduplication
**File:** `lib/ui/widgets/section_card.dart`

Extract shared title row composition.

### ~~Database Query Boilerplate~~ — Done
**File:** `lib/data/database_helper.dart`

Added private `_queryAndMap<T>()` generic helper. All 6 query methods now delegate to it.

### InfoDialog Simplification
**File:** `lib/ui/dialogs/info_dialog.dart`

Replace per-category `_configure*` methods with data-driven configuration.

### Import Style Standardization
Some files use relative imports, most use `package:` — standardize on `package:` imports throughout the codebase.

### ~~Eliminate Definition Tables~~ — Done (v19)

All three definition tables (Perks, Masteries, PersonalQuests) were removed in v19. Definitions now load directly from `PerksRepository`, `MasteriesRepository`, and `PersonalQuestsRepository` at runtime. Only the join tables (`CharacterPerks`, `CharacterMasteries`) remain for storing user state.

### ~~Stable Perk/Mastery IDs~~ — Done

Perk and mastery IDs were previously derived from list position, creating silent data corruption risk if definitions were reordered. Now each `Perk` and `Mastery` carries an explicit `number` field used for ID generation. Numbers match the original positional order so existing DB records are unaffected (zero migration cost). Perks are 1-based, masteries are 0-based (legacy inconsistency preserved for DB compatibility). Debug assertions validate uniqueness at runtime; `test/models/repository_id_stability_test.dart` validates all IDs across all classes in CI.
