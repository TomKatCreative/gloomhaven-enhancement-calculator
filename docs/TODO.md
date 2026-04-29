# TODO

Active task tracking. Last reorganized 2026-04-29.

Sections:
- **Active** — work scheduled or in progress.
- **Investigating** — open questions; not committed to building.
- **Deferred** — paused; reactivate when blocking constraints clear.
- **Archive** — completed initiatives, kept for context.

---

## Active

### Convert `_build*` methods to proper widgets

**Added:** 2026-02-04 · **Status:** Pending (audited 2026-04-29 — 53 occurrences remain across `lib/ui/`)

Throughout the codebase, methods like `Widget _buildMyWidget()` should be `StatelessWidget`/`StatefulWidget` classes. The `_build*` pattern doesn't benefit from Flutter's widget lifecycle optimizations, makes isolated testing harder, and mixes building logic with parent state.

**Scan:** `lib/ui/screens/*.dart`, `lib/ui/widgets/**/*.dart`.

**Acceptable exceptions:** methods that need direct access to parent state/controllers that would be awkward to pass as props; very simple one-liner builders.

### Auto-backup to app documents

**Status:** Pending (part of Enhanced Backup System)

- Write backup to app documents directory after each character save
- Keep last 5 auto-backups, rotate oldest
- No user action required

**Files:** `lib/viewmodels/characters_model.dart` (trigger on save), new `lib/data/auto_backup_service.dart` (rotation logic).

### Backup age reminder

**Status:** Pending (part of Enhanced Backup System)

- Track last manual backup date in SharedPrefs
- Show subtle indicator in Settings if >30 days since last backup
- "Last backed up: 45 days ago" with warning color

**Files:** `lib/shared_prefs.dart` (add `lastManualBackupDate`), `lib/ui/widgets/settings/backup_settings_section.dart`, `lib/ui/dialogs/backup_dialog.dart`.

### Town Sheet — remaining work

**Status:** Foundation shipped behind `kTownSheetEnabled` flag. The following are still pending before the flag can ship:

- **Achievement/scenario tracking** — needs scenario data repository (deferred)
- **Frosthaven extensions** — Buildings, morale, seasons (future sprint)
- **GH2E prosperity thresholds** — May differ from GH, needs research
- **Character assignment UI** — assigning characters to parties from the Characters tab
- **Party filter toggle** — UI toggle on Characters tab to filter by active party
- **FH PQ #4 "Greed is Good" prosperity integration** — Currently uses `target: 1` (bool checkbox). When town/campaign data is available, compute the actual target threshold (`80 + 20 × prosperity`) from the character's campaign. No DB migration needed — quest definitions live in code, not the DB. Existing users with `progress[0] >= 1` can be treated as "already confirmed."

### CharactersModel — remaining decomposition (low priority)

**File:** `lib/viewmodels/characters_model.dart` (~470 lines, down from ~598)

Remaining candidates are thin wrappers, tightly coupled to CRUD/theme sync. Likely not worth extracting:
- Element sheet state, scroll controllers, navigation logic
- Perk/mastery toggle (~13 lines each, 2 methods)

### SharedPrefs enhancer level cascade

**File:** `lib/shared_prefs.dart`

Move cascade validation logic (setting lvl4 triggers lvl3/2/1) out of property setters into a dedicated validator. Keeps persistence layer dumb.

### SectionCard / CollapsibleSectionCard deduplication

**File:** `lib/ui/widgets/section_card.dart`

Extract shared title row composition.

### InfoDialog simplification

**File:** `lib/ui/dialogs/info_dialog.dart`

Replace per-category `_configure*` methods with data-driven configuration. (Cross-ref: 2026-04-29 audit Tier 2 #11.)

### Remaining direct SharedPrefs access in UI

~34 calls in 7 files, deferred from the broader cleanup:

| File | Calls | Reason |
|------|-------|--------|
| `element_tracker_sheet.dart` | 12 | Purely local widget state, self-contained |
| `class_selector_screen.dart` | 5 | Needs per-class unlock map in a new model |
| `gameplay_settings_section.dart` | 8 | Envelope X/V toggles need new model or AppModel expansion |
| `home.dart` | 1 | One-shot dialog flag, minimal value |
| `update_450_dialog.dart` | 2 | One-shot flags, minimal value |
| `custom_class_warning_dialog.dart` | 2 | Dialog-local preference |
| `restore_dialog.dart` | 4 | Legitimate post-restore sync reads |

### Audit follow-ups (2026-04-29)

These came out of the codebase audit on 2026-04-29 — see `docs/technical_debt.md` and `~/.claude/plans/i-want-you-to-mutable-pie.md` for details:

- **Add tests for v4.5.3 changes** — `restore_dialog.dart` (no test file), `stats_section.dart` hand size edit-mode/variant cases.
- **Add `DatabaseBackupService` unit tests** — round-trip, version validation, SharedPrefs sync, error paths.
- **Add `test/utils/` coverage** — `game_text_tokenizer`, `themed_svg`, `color_utils`.
- **Add dialog widget tests** — restore, info, enhancer (only backup is currently covered).
- ~~**Theme cache invalidation**~~ — Verified 2026-04-29: the cache is content-addressed by `ThemeConfig.hashCode` (immutable, defines `==` over all theme inputs), so it cannot go stale. Removed the unused `clearCache()` method and added a regression test (`test/theme/app_theme_builder_test.dart`) that locks the contract in place.
- **Element color theming** — replace raw `Colors.deepOrange` etc. in `animated_element_icon.dart` with theme-aware element palette.
- **Marker rendering DRY** — extract `CostMarkerBuilder` shared by `info_dialog.dart` and `enhancement_calculator_screen.dart` for `†‡§*` markers.
- **Refactor oversized files** — `info_dialog.dart` (403 lines, 9 `_configure*` methods), `enhancement_calculator_screen.dart` (639 lines, 9 file-scoped `_…Card` classes), `animated_element_icon.dart` (1,218 lines, per-element configs).

---

## Investigating

### Font consolidation

Consider switching to **Tinos** (body) + **Germania One** (subtitles), keeping Pirata One for select large titles. Could potentially drop bundled font assets (HighTower, Nyala, OpenSans, Roboto) in favor of `google_fonts` or system fonts.

**Open questions:**
- Are Tinos / Germania One available via `google_fonts` or as system fonts?
- Which current font assets could be removed?
- App bundle size impact?
- Visual comparison vs. current fonts.

### Migrate dialogs to bottom sheets

**Added:** 2026-02-23

Several dialogs use `AlertDialog` / `showDialog` where a bottom sheet would feel more native on mobile (easier to reach, swipe-to-dismiss, avoids the small centered dialog pattern on phones).

| Current dialog | File | Notes |
|---|---|---|
| `ConfirmationDialog` | `lib/ui/dialogs/confirmation_dialog.dart` | Generic confirm/cancel — could become a confirmation bottom sheet |
| `EnhancerDialog` | `lib/ui/dialogs/enhancer_dialog.dart` | Enhancer level picker |
| `InfoDialog` | `lib/ui/dialogs/info_dialog.dart` | Long scrollable content — good fit for sheet |
| `BackupDialog` | `lib/ui/dialogs/backup_dialog.dart` | Backup/restore actions |
| `CustomClassWarningDialog` | `lib/ui/dialogs/custom_class_warning_dialog.dart` | Simple warning |

**Approach:** migrate one at a time, starting with `InfoDialog` (most content-heavy). Follow the existing `RequirementDetailsSheet` / `ResourceStepperSheet` pattern (static `.show()`, `SafeArea`, `isScrollControlled: true`). Save `ConfirmationDialog` for last — used widely, needs careful testing.

### Enum serialization inconsistency

`GameEdition` persists by **index** (`GameEdition.values[editionIndex]`) while `Variant` persists by **string name**. Index-based serialization is fragile — reordering an enum breaks existing data.

**Question:** worth a migration to unify on string-name? Index approach is faster but lossy.

### Incomplete database interface

`database_helper_interface.dart` is missing Town CRUD methods (`queryAllCampaigns`, `insertParty`, etc.), so Town features can't be properly mocked in tests. Add to the interface before Town Sheet ships.

### Column naming mismatches

`columnResourceLumber` maps to DB column `'ResourceWood'`. Either rename the constant or document why they diverge.

### Standardize import style

Some files use relative imports, most use `package:` — pick one and stick with it.

---

## Deferred

### Character PageView swiping performance

**Added:** 2026-02-09 · **Status:** Active jank fixed; deeper profiling deferred unless issue recurs.

Initial scroll jank and tint-persistence bugs are resolved (commits `42925b8`, `8cc8c66`). Remaining ideas, only if the issue resurfaces:
1. Add `allowImplicitScrolling: true` to `PageView.builder` to preload adjacent pages
2. Wrap `CharacterScreen` in `RepaintBoundary`
3. Profile with Flutter DevTools Performance overlay
4. Cache the rasterized class icon background image

---

## Archive

### Personal Quests (v4.5.0 → v4.5.2)

**Status:** Released. Personal quests for all current game editions are shipped: Gloomhaven (24), Gloomhaven 2e (22), Frosthaven (23), Crimson Scales (28), Trail of Ashes (8) — 105 quests total.

#### Gloomhaven PQs (v4.5.0)
- `PersonalQuest` model and `PersonalQuestsRepository` (second printing values)
- DB migration v18 (PersonalQuestsTable + PQ columns on Characters)
- PQ selection on character creation; section on character screen with stepper progress
- Sequential "Then" requirements; change/remove flow with confirmation
- Retirement prompt with confetti pop on completion
- `CollapsibleSectionCard`, `SectionCard` widgets
- Class unlock / envelope icon in header row
- Strikethrough gold display for retired characters
- Full test coverage

#### Frosthaven PQs (v4.5.1)
- 23 FH quests added; DB migration v19 dropped definition tables
- Dual numbering via `altNumber` field; `displayNumber` getter
- All FH quests unlock envelopes (no class unlocks)
- Envelope display: PirataOne for single-letter, ENVELOPE SVG + alt number for numbered
- Scenario SVG assets (boat, climbing_gear, sled)
- Checkbox UI for binary requirements
- Edition filter chips on PQ selector

#### Gloomhaven 2e PQs
- 22 GH2E quests; `PersonalQuestEdition.gloomhaven2e` enum value
- Dual numbering pattern matching FH
- All unlock classes (no envelopes); 2 per class for 11 unlockable classes
- Section book pattern ("Then read Section X")

### Spoiler protection

Locked classes in `ClassSelectorScreen` show the real name with an animated blur effect (replacing "???"). Eye icon toggles reveal.

### Town Sheet foundation

Campaign/party CRUD, prosperity/reputation tracking, party filtering, full test coverage. Behind `kTownSheetEnabled` flag pending the remaining work in **Active**.

### Enhanced backup system — phases 1–3

- SharedPreferences included in backup JSON (third array element)
- One-tap share via `share_plus`
- Minimum backup version enforcement (rejects pre-v8 backups)

### Eliminate definition tables (v19)

Perks, Masteries, PersonalQuests definition tables removed in v19. Definitions now load from repositories at runtime. Only join tables (`CharacterPerks`, `CharacterMasteries`) remain for user state.

### Stable perk/mastery IDs

Perk and mastery IDs now derive from explicit `number` fields instead of list position. Numbers match original positional order (zero migration cost). Debug assertions + `test/models/repository_id_stability_test.dart` validate uniqueness.

### EnhancementCalculatorModel cost extraction

Pure calculation logic moved to `EnhancementCostCalculator`. Model is a thin state-management layer (~290 lines, down from 713). 84 new pure unit tests.

### DatabaseHelper decomposition

Backup/restore extracted to `DatabaseBackupService` (`lib/data/database_backup_service.dart`).

### Database query boilerplate

Generic `_queryAndMap<T>()` helper added; all 6 query methods delegate to it.
