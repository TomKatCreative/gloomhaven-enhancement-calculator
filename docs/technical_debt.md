# Technical Debt Analysis

Last updated: 2026-02-15

A consolidated analysis of technical debt across the codebase, organized by impact tier.

---

## Tier 1: God Files

The highest-impact debt. These files have too many responsibilities, making them hard to test, navigate, and modify safely.

### ~~`character_screen.dart` (1,699 lines)~~ — RESOLVED

> **Refactored** (2026-02-15): Extracted 11 embedded private widget classes into 7 separate files in `lib/ui/widgets/character/`. The main `character_screen.dart` is now ~288 lines containing only scroll-spy logic and sliver assembly. Magic numbers replaced with named constants in `constants.dart`. All 795 tests pass unchanged.
>
> **New files**: `character_header_delegates.dart`, `stats_and_resources_card.dart`, `stats_section.dart`, `checkmarks_and_retirements_row.dart`, `quest_and_notes_card.dart`, `perks_and_masteries_card.dart`, `party_assignment_row.dart`

### ~~`enhancement_calculator_model.dart` (713 lines)~~ — RESOLVED

> **Refactored** (2026-02-16): Extracted all pure cost calculation logic into `EnhancementCostCalculator` (`lib/models/enhancement_cost_calculator.dart`), an immutable class with zero dependencies on SharedPrefs, ChangeNotifier, or Flutter. The model (`lib/viewmodels/enhancement_calculator_model.dart`) is now a thin state management layer (~290 lines, down from 713) that caches and delegates to the calculator. `resetCost()` cleaned up from 8+ redundant `notifyListeners()` calls to a single invalidation. 84 new pure unit tests added. All 879 tests pass.

### ~~`database_helper.dart` (654 lines)~~ — PARTIALLY RESOLVED

> **Refactored** (2026-02-16): Extracted backup/restore logic (~107 lines) into `DatabaseBackupService` (`lib/data/database_backup_service.dart`). Fixed magic index check (`if (i < 1)` → explicit `tableCharacters` comparison). `DatabaseHelper` is now ~548 lines focused on DB lifecycle, schema, and CRUD. Accessed via `DatabaseHelper.instance.backupService`. All 879 tests pass unchanged.
>
> **Remaining debt**: CRUD for 5+ entities still in one file; table creation and migration orchestration mixed with queries; manual perk/mastery insert loops (no batch).

### `game_text_parser.dart` (648 lines)

- 8+ token classes with complex multi-phase parsing
- `StackedElementToken` directly uses `SvgPicture.asset()` — violates the ThemedSvg-only convention
- `ParsedWord` has 4+ parsing phases that interact in non-obvious ways

### `create_character_screen.dart` (620 lines)

- 8 `TextEditingController`s and 10+ state variables
- Form validation mixed with UI layout
- Random name generation via `faker` package

### `characters_model.dart` (~470 lines, down from 598) — PARTIALLY RESOLVED

> **Refactored** (2026-02-16): Extracted personal quest logic into `PersonalQuestService` (`lib/data/personal_quest_service.dart`). Moved debug character creation (`createCharactersTest`) to `DebugSettingsSection` where it's actually used. 15 new service tests added. All 894 tests pass.

Remaining responsibilities (tightly coupled, low extraction value):
- Character CRUD
- Filtering & pagination with complex index management (`_calculateTargetIndex()` — 50+ lines)
- Perk/mastery loading & toggling
- Theme synchronization (`updateThemeForCharacter()` directly calls `themeProvider.updateSeedColor()`)
- Scroll position tracking via two controllers AND a `ValueNotifier<double>`

### ~~`personal_quest_section.dart` (580 lines)~~ — RESOLVED

> **Refactored** (2026-02-16): Extracted 3 embedded classes into separate files in `lib/ui/widgets/character/`. Removed unused `embedded` parameter and standalone card wrapper (dead code — only `QuestAndNotesCard` provides the card). The main `personal_quest_section.dart` is now ~84 lines containing only orchestration and the select-quest button. All test groups pass (1 expansion-state test removed as it tested the deleted standalone wrapper).
>
> **New files**: `retirement_prompt.dart` (retirement celebration flow), `requirement_row.dart` (progress controls widget), `quest_content.dart` (quest title + requirements list)

---

## Tier 2: Architectural Smells

Patterns that aren't single-file problems but affect the codebase broadly.

### `shared_prefs.dart` — God Object (472 lines)

77 getter/setter pairs covering every persistent preference in the app. No logical grouping or domain separation.

**Cascading side effects in setters:** Setting `enhancerLvl1 = false` cascades and clears lvl2-4. This business logic belongs in a ViewModel, not a persistence wrapper.

**Backup export/import is 95 lines** because state is scattered — requires manual categorization into `settings`, `town`, `calculator`, `enhancerLevels`, `classUnlocks`.

### Direct SharedPrefs Access in UI

60+ direct `SharedPrefs().xxx` calls scattered across UI files and ViewModels instead of being encapsulated in ViewModels. Screens should not directly read/write SharedPrefs.

### Hardcoded Magic Numbers (~40 violations)

Despite the constants policy in `constants.dart`, several files still use hardcoded values:

| File | Examples | Count |
|------|----------|-------|
| ~~`character_screen.dart`~~ | ~~`0.85`, `82.0`, `180.0`~~ | ~~resolved~~ |
| `element_tracker_sheet.dart` | `0.065`, `0.14`, `100.0` | ~10 |
| `expandable_cost_chip.dart` | `56.0`, `468.0`, `100.0` | ~8 |

### `asset_config.dart` (995 lines)

400+ asset definitions with no way to detect unused assets and no path validation.

---

## Tier 3: Dead Code & Legacy

Code that is no longer needed but remains in the repo.

### Legacy Repository Files

| File | Lines | Status |
|------|-------|--------|
| `perks_repository_legacy.dart` | 3,400 | Only referenced by DB migrations v5-v17 |
| `masteries_repository_legacy.dart` | 394 | Only referenced by DB migrations v5-v17 |
| `legacy_perk.dart` | ~37 | Only referenced by dead legacy repositories |
| `legacy_mastery.dart` | small | Only referenced by dead legacy repositories |

These legacy files are **required for database migration** from older schema versions (v5–v17). They cannot be removed without breaking upgrades for users on older app versions. The migration code references them to populate/transform definition tables before v19 drops those tables.

### Unused `fromMap()` Constructors

`Perk.fromMap()` and `Mastery.fromMap()` both hardcode `number = 0`. These constructors are never called since definitions moved out of the database and are loaded from repositories instead.

---

## Tier 4: Inconsistencies

Small issues that create confusion and maintenance burden.

### Enum Serialization

Two different strategies for the same pattern:
- `GameEdition` persists by **index**: `GameEdition.values[editionIndex]`
- `Variant` persists by **string name**: `Variant.values.firstWhere((v) => v.name == map[columnVariant])`

Index-based serialization is fragile — reordering the enum breaks existing data.

### Incomplete Database Interface

`database_helper_interface.dart` defines 11 character/perk/mastery methods, but the implementation has Campaign/Party CRUD methods that are **not** in the interface:
- `queryAllCampaigns()`, `insertCampaign()`, `updateCampaign()`, `deleteCampaign()`
- `queryParties()`, `insertParty()`, `updateParty()`, `deleteParty()`
- `assignCharacterToParty()`, `queryCharactersByParty()`

Town features cannot be properly mocked in tests because these methods are not on the interface.

### Column Naming Mismatches

`columnResourceLumber` maps to DB column `'ResourceWood'` — the Dart constant name doesn't match the stored column name.

### ~~Test Code in Production~~ — RESOLVED

> `createCharactersTest()` moved from `CharactersModel` to `DebugSettingsSection` (debug-only widget behind `kDebugMode`).

---

## Additional Notes

### Large Static Data Files

Perk, mastery, and quest definitions are all hardcoded as Dart code:

| File | Lines |
|------|-------|
| `perks_gloomhaven.dart` | 1,630 |
| `masteries_repository.dart` | 923 |
| `perks_frosthaven.dart` | 781 |
| `personal_quests_repository.dart` | 769 |
| `perks_crimson_scales.dart` | 662 |
| `perks_custom.dart` | 600 |

These use 130+ local `const` string aliases to reduce duplication. Changing game data requires a source code edit, recompile, and app release. Moving to external data files (JSON/YAML) would decouple data from code.

### Other Notable Files

- **`AppThemeBuilder`** (350 lines) — Manual theme caching via `_lightThemeCache`/`_darkThemeCache` maps that may be unnecessary given Flutter's built-in theme computation.
- **`InfoDialog`** (401 lines) — 8+ private configuration methods with a switch statement that could be data-driven.
- **`ElementTrackerSheet`** (453 lines) — 3 expansion states with hardcoded size values.
- **`ExpandableCostChip`** (482 lines) — Handles collapsed chip, expanded card, 3-layer blur, and scroll animation in one widget.
- **`ClassSelectorScreen`** (561 lines) — Complex filtering/search with SearchDelegate pattern.
- **`EnhancementCalculatorScreen`** (650 lines) — Overly nested widget structure; `setState({})` called in build callback.
