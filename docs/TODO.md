# Personal Quests

## Status: Phase 1 Implemented

Base Gloomhaven personal quests (24 quests, cards 510-533) are implemented with:
- `PersonalQuest` model and `PersonalQuestsRepository` (second printing values)
- DB migration v18 (PersonalQuestsTable + PQ columns on Characters)
- PQ selection on character creation screen (GH only; GH2E/FH show "Coming soon")
- PQ section on character screen with progress tracking (+/- buttons in edit mode)
- Change quest flow with confirmation dialog
- Retirement prompt: snackbar with confetti pop on PQ completion → confirmation dialog → retire
- `CollapsibleSectionCard` for PQ section; `CharacterSectionCard` for static sections
- Class unlock icon / envelope icon in ExpansionTile header row
- `TextFormField` selector when no quest assigned (edit mode)
- Strikethrough gold display for retired characters (gold forfeited on retirement)
- Full test coverage (model, repository, viewmodel, widget tests — 25 PQ widget tests)

### Architecture & File Locations

| File | Purpose |
|------|---------|
| `lib/models/personal_quest/personal_quest.dart` | `PersonalQuest` model, `PersonalQuestRequirement`, progress encode/decode, DB column constants |
| `lib/data/personal_quests/personal_quests_repository.dart` | Static list of all 24 GH quests with `getById()` and `getByEdition()` |
| `lib/ui/widgets/personal_quest_section.dart` | `PersonalQuestSection`, `_QuestSelectorField`, `_QuestContent`, `_RequirementRow` |
| `lib/ui/widgets/blurred_expansion_container.dart` | Reusable animated backdrop blur + bordered `ExpansionTile` |
| `lib/ui/dialogs/personal_quest_selector_dialog.dart` | Bottom sheet for PQ selection, `PersonalQuestSelectorDialog.show()` |
| `lib/data/database_helpers.dart` | v18 migration, `_seedPersonalQuests()`, `queryPersonalQuests()` |
| `lib/data/database_migrations.dart` | v18 migration entry in `runMigrations()` |
| `test/widgets/personal_quest_section_test.dart` | 25 widget tests for the PQ section |
| `test/models/personal_quest_test.dart` | Model unit tests (constructor, toMap/fromMap, progress encoding) |
| `test/models/personal_quest_repository_test.dart` | Repository tests (quest data integrity, getById, getByEdition) |

### Data Flow

1. `PersonalQuestsRepository` holds static quest definitions (requirements, unlock rewards)
2. `Character.personalQuestId` (String, defaults to `''`) references a quest ID like `"gh_510"`
3. `Character.personalQuestProgress` (List<int>) stores progress per requirement as JSON in DB
4. `Character.personalQuest` getter resolves the full `PersonalQuest` from the repository
5. `CharactersModel.updatePersonalQuest()` changes quest and resets progress to zeros
6. `CharactersModel.updatePersonalQuestProgress()` updates a single requirement's count, returns `bool` (true if quest just transitioned to complete)
7. `CharactersModel.isPersonalQuestComplete()` checks if all progress values meet their targets

### DB Schema (v18)

**PersonalQuestsTable** - quest definitions (seeded from repository):
- `_id` TEXT PRIMARY KEY (e.g., "gh_510")
- `Number` TEXT NOT NULL (e.g., "510")
- `Title` TEXT NOT NULL (e.g., "Seeker of Xorn")
- `Edition` TEXT NOT NULL (e.g., "gloomhaven")

**Characters table** - two new columns:
- `PersonalQuestId` TEXT NOT NULL DEFAULT '' (references PersonalQuestsTable._id)
- `PersonalQuestProgress` TEXT NOT NULL DEFAULT '[]' (JSON-encoded List<int>)

### Design Decisions & Lessons Learned

- **`edition` uses `GameEdition` enum**, not String. Initially implemented as String but refactored. The enum is serialized to/from DB via `.name` and `GameEdition.values.byName()`. Type safety prevents invalid editions at compile time.
- **Second printing values** used for quest targets (e.g., quest 514 target is 12, not 15).
- **Quests unlock either a class OR an envelope**, never both. Enforced in repository test.
- **ExpansionTile state** persisted via `SharedPrefs().personalQuestExpanded`.
- **"Coming soon"** shown for GH2E/FH editions - the selector dialog is disabled, not hidden.
- **Confirmation dialog** appears when changing an existing quest (resets progress).
- **Retirement flow** uses two-step UX: snackbar ("Personal quest complete!" with confetti pop) → tap "Retire" → confirmation dialog with full details → retire. `updatePersonalQuestProgress` returns `bool` to detect completion transitions.
- **`BlurredExpansionContainer`** centralizes animated backdrop blur (`TweenAnimationBuilder<double>` from 0→`expansionBlurSigma`) used by both Resources and PQ sections. Blur fades in on expand, out on collapse.
- **No-quest selector** shows a read-only `TextFormField` (matching create character screen pattern) instead of an `ExpansionTile` when no quest is assigned in edit mode.
- **Gold strikethrough** for retired characters uses `StrikethroughText` widget with `onSurfaceVariant` color.

### Known Gotchas

- **`Character.fromMap` id bug**: `id = map[columnCharacterId] ?? ''` assigns String to int? when id is null. This is a pre-existing bug (not from PQ work). Tests that do toMap/fromMap round-trips must set `character.id = 1` first.
- **PQ section visibility**: Shows when quest is assigned OR in edit mode. If neither, it's hidden entirely.
- **ThemedSvg/ClassIconSvg in tests**: SVG widgets fail silently in tests (no real asset files). PQ section tests that render class icons can't verify them visually - use model-level assertions instead.
- **Widget test viewport**: Some PQ tests need `tester.view.physicalSize = const Size(800, 600)` to avoid overflow in +/- button layouts. Remember to reset in `addTearDown`.
- **Progress encoding**: `encodeProgress([1,0,3])` → `"[1,0,3]"`. `decodeProgress('')` → `[]`. The JSON format is simple but watch for empty-string edge cases.

## Remaining Work

- **GH2E quest data** - Add Gloomhaven 2nd Edition quests to repository. Will need to add quests with `edition: GameEdition.gloomhaven2e`, update the "Coming soon" guard in `personal_quest_section.dart` and `create_character_screen.dart`, and regenerate the PersonalQuestsTable (use `DatabaseMigrations.regeneratePersonalQuestsTable()`).
- **Frosthaven quest data** - Same pattern as GH2E but with `edition: GameEdition.frosthaven`.
- **Adaptive widgets** - Replace basic +/- counters with segmented buttons, sliders, etc. for specific requirement types (e.g., binary yes/no for scenario completion, counter for kill counts).
- ~~**Quest completion** - Visual indicator when all requirements are met (e.g., green checkmark, confetti).~~ **Done** — confetti pop + snackbar on completion, strikethrough on completed requirements.
- ~~**Retirement integration** - Link quest completion to retirement flow. When all requirements are met, prompt or enable retirement.~~ **Done** — snackbar → confirmation dialog → `retireCurrentCharacter()`.
- **Spoiler protection** - Consider hiding unlock class name/icon behind a spoiler toggle for players who don't want to know what class they'll unlock.

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

#### 2. One-Tap Backup Sharing

Currently: Backup → Save to Downloads → User must find file to share
Improved: Backup → Immediate share sheet option (keep save option too)

**File:** `lib/ui/dialogs/backup_dialog.dart`

#### 3. Auto-Backup to App Documents

- Write backup to app documents directory after each character save
- Keep last 5 auto-backups, rotate oldest
- No user action required

**Files to modify:**
- `lib/viewmodels/characters_model.dart` - Trigger auto-backup on character save
- New file: `lib/data/auto_backup_service.dart` - Handle rotation logic

#### 4. Backup Age Reminder

- Track last manual backup date in SharedPrefs
- Show subtle indicator in Settings if >30 days since last backup
- "Last backed up: 45 days ago" with warning color

**Files to modify:**
- `lib/shared_prefs.dart` - Add `lastManualBackupDate` key
- `lib/ui/widgets/settings/backup_settings_section.dart` - Show last backup indicator
- `lib/ui/dialogs/backup_dialog.dart` - Update timestamp on successful backup

### Implementation Order

1. SharedPrefs in backup (most value, lowest effort)
2. Backup age reminder (quick win)
3. One-tap sharing (UX improvement)
4. Auto-backup (nice-to-have)

---

## Character PageView Swiping Performance

**Added:** 2026-02-09
**Status:** Pending investigation
**File:** `lib/ui/screens/characters_screen.dart:80-86`

If swiping between character pages is still not smooth, investigate:
1. Add `allowImplicitScrolling: true` to `PageView.builder` to preload adjacent pages
2. Change `context.watch<CharactersModel>()` to more targeted selectors or move to child widgets to reduce unnecessary rebuilds
3. Consider wrapping entire `CharacterScreen` in `RepaintBoundary` if needed
4. Profile with Flutter DevTools Performance overlay to identify actual jank
5. Consider caching the rasterized class icon background image

---

## Code Audit — Future Refactors

**Added:** 2026-02-09
**Status:** Pending

Larger refactoring opportunities identified during codebase audit. These are non-urgent structural improvements that would reduce complexity and improve maintainability.

### CharactersModel Decomposition
**File:** `lib/viewmodels/characters_model.dart` (~572 lines)

Extract element sheet state, scroll controllers, and navigation logic into smaller focused classes. Currently a god class managing too many concerns.

### EnhancementCalculatorModel Cost Calculation Extraction
**File:** `lib/viewmodels/enhancement_calculator_model.dart`

Extract `calculateCost()` and `getCalculationBreakdown()` into a pure `CostCalculator` class, separate from state management.

### SharedPrefs Enhancer Level Cascade
**File:** `lib/shared_prefs.dart`

Move the cascade validation logic (setting lvl4 triggers lvl3/2/1) out of property setters into a dedicated validator.

### DatabaseHelper Decomposition
**File:** `lib/data/database_helpers.dart`

Extract backup/restore into `DatabaseBackupService`, separate from query logic.

### PerkRow / MasteryRow Deduplication
**Files:** `lib/ui/widgets/perk_row.dart`, `lib/ui/widgets/mastery_row.dart`

Extract shared `CheckableRow` base component.

### CharacterSectionCard / CollapsibleSectionCard Deduplication
**File:** `lib/ui/widgets/character_section_card.dart`

Extract shared title row composition.

### Database Query Boilerplate
**File:** `lib/data/database_helpers.dart`

Create generic `queryAndMap<T>()` method to replace 4 identical query patterns.

### InfoDialog Simplification
**File:** `lib/ui/dialogs/info_dialog.dart`

Replace per-category `_configure*` methods with data-driven configuration.

### Import Style Standardization
Some files use relative imports, most use `package:` — standardize on `package:` imports throughout the codebase.
