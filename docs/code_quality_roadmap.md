# Code Quality (CQ) Roadmap

Findings from the whole-codebase review on 2026-10-07, grouped into shippable chunks. Each item has a stable `CQ-n` ID so it can be referenced in commits and branches (e.g. `fix(CQ-1): ...`, `refactor/cq-8-cost-math`).

**Ordering:** Phase 1 first. It contains user-facing bugs. Phases 2–7 are independent unless an item lists **Depends on**. Line numbers are as of the review and will drift.

**Status legend:** ⬜ Pending · 🟨 In progress · ✅ Done

| Phase | Theme | Items |
|-------|-------|-------|
| 1 | Correctness bugs | CQ-1 – CQ-6 |
| 2 | Single source of truth (drift) | CQ-7 – CQ-14 |
| 3 | Dead code and feature removal | CQ-15 – CQ-18 |
| 4 | Simplify complex code | CQ-19 – CQ-22 |
| 5 | Localization gaps | CQ-23 – CQ-24 |
| 6 | Design-constant sweep | CQ-25 – CQ-26 |
| 7 | Docs sync | CQ-27 – CQ-28 |

---

## Phase 1 — Correctness bugs

These are small and independent, and could ship as one "fixes" branch.

### CQ-1 ✅ Restoring a backup with zero characters keeps the old characters in memory

**File:** `lib/viewmodels/characters_model.dart:271-281` (`loadCharacters`)

`characters = loadedCharacters` is assigned *inside* the per-character loop. With an empty DB the loop never runs, so `_characters` keeps the pre-restore list and `restore_dialog.dart` shows deleted characters. With N characters it also fires `notifyListeners()` N+1 times.

**Fix:** Load perks and masteries in the loop. After the loop, assign `_characters = loadedCharacters` once, then call `_setCurrentCharacter` and notify once. Add a viewmodel test that restores an empty DB.

### CQ-2 ✅ "+1 Move" enhancement selection is lost on relaunch

**Files:** `lib/viewmodels/enhancement_calculator_model.dart:61` (`_enhancementFromPrefs`), `lib/shared_prefs.dart:155`

The selection is persisted as a list index. Move is index 0, which is also the "no selection" default, so the `index > 0` check drops it. Storing a raw index is also what caused the blank-screen crash: any reorder of `EnhancementData.enhancements` breaks it.

**Fix:** Persist a stable key such as `'${category.name}:${name}'` and look it up. Fall back to the legacy `enhancementType` index for existing users, then migrate them over. Update `exportForBackup`/`importFromBackup` and `docs/shared_prefs_keys.md`.

### CQ-3 ✅ v7→v8 perk migration reads the live perk data instead of a frozen snapshot

**File:** `lib/data/database_migrations.dart:361-470` (`_handleBaseVariantPerks`)

The old integer perk ID is derived from the insertion rowid while iterating the **live** `PerksRepository.perksMap`. That map's order has changed since v8: JotL, Frosthaven and the Mercenary Packs now come before Crimson Scales, and positions now come from `indexOf + 1`, not `perk.number`. Users upgrading from schema ≤ 7 likely get their perk selections re-pointed to the wrong perks for every class after Voidwarden. No test covers this path.

**Fix:** Build the mapping from a frozen snapshot of the v8 base-variant order (e.g. from `PerksRepositoryLegacy`, or as explicit legacy-ID → new-ID pairs). Add a migration test that upgrades a v7 database fixture and asserts the resulting perk IDs.

**Done (`fix/cq-phase-1`):** Legacy IDs now come from a per-class layout derived from `PerksRepositoryLegacy` (frozen, 995 rows) instead of insertion rowids. Output IDs still use live base-perk positions, which is correct because those are the IDs the app uses today. The bug dates back to when Vimthreader was added (June 2025), not just recent reorders. `test/data/database_migrations_test.dart` upgrades a v7 database containing every legacy class and fails on the old code.

**Known limitation (won't fix):** The v8 *mastery* migration (`_handleVariantMasteries`) has the same rowid drift: 80 of 82 legacy mastery IDs now line up with the wrong class. It can't be fixed the same way because GH classes and Incarnate no longer have `base` masteries (theirs moved to `frosthavenCrossover`/`gloomhaven2E`), so there is no correct `base` target ID. **Decision (2026-10-07): leave as is.** Very few users can still hit the schema ≤ 7 path, and the current behaviour is acceptable.

**Note:** `regeneratePerksAndMasteriesTables` (v8–v17) has the same live-data dependency. It is harmless only because v19 drops those tables. Freeze it too, or document why it's safe.

### CQ-4 ✅ JotL `maxStartingLevel` returns 9; JotL is locked to level 1

**Files:** `lib/models/game_edition.dart:35-45`, `lib/ui/screens/create_character_screen.dart:114-117`, `test/models/game_edition_test.dart:143-144`

The model returns 9 (and its doc says "any level 1–9"). The screen separately hardcodes `_selectedLevel = 1`, and the test asserts the wrong value.

**Fix:** Return `1` for JotL and update the doc and test. Have the screen read `edition.maxStartingLevel(...)` instead of hardcoding 1. Optionally make `startingGold` return 30 explicitly for JotL.

### CQ-5 ✅ Fake DB inserts masteries for every character

**File:** `test/helpers/fake_database_helper.dart:77-87`

The fake always calls `_generateCharacterMasteries`. The real `database_helper.dart:290` only does so when `character.shouldShowMasteries` is true, so tests can pass on mastery-visibility bugs.

**Fix:** Guard the call with `if (character.shouldShowMasteries)` and re-run the viewmodel tests.

### CQ-6 ✅ Small latent correctness issues

- **`lib/models/character.dart:157`:** `id = map[columnCharacterId] ?? ''` puts a String into `int?`, which throws a TypeError instead of falling back. Use `as int?`.
- **`lib/ui/widgets/character/stats_section.dart:422-423`:** `ResourcesContent` reads `isEditMode` with `context.read` in `build`. It only updates because the parent watches the whole model, so narrowing the parent to a `Selector` (as the perf work is doing) would break edit mode. Use `context.select<CharactersModel, bool>((m) => m.isEditMode)`.
- **`lib/data/perks/perks_repository.dart:58-59`:** `getPerksForCharacter` mutates the shared static `Perk` objects (`variant`, `classCode`) before copying them. The copy already sets both fields, so delete the mutation.

---

## Phase 2 — Single source of truth (drift-prone duplication)

Each item is its own branch. Each removes a rule or list that is currently maintained by hand in several places.

### CQ-7 ⬜ Page-index constants for the Town flag

**Files:** `lib/ui/screens/home.dart:53-54,63,142,146`, `lib/ui/widgets/ghc_animated_app_bar.dart:284-285,365`, `lib/viewmodels/app_model.dart:36`, `lib/shared_prefs.dart:100`

`kTownSheetEnabled ? 1 : 0` / `? 2 : 1` is repeated about 6 times, and the Town page is sometimes a bare `0`. Missing one copy when the Town tab ships breaks navigation.

**Fix:** Define `kTownPageIndex`, `kCharactersPageIndex` and `kCalculatorPageIndex` in `lib/data/constants.dart` and use them everywhere. **Do this before shipping the Town tab.**

### CQ-8 ⬜ Enhancement cost rules: one source of truth

**Files:** `lib/models/enhancement_cost_calculator.dart`, `lib/viewmodels/enhancement_calculator_model.dart:427-466`, `lib/data/enhancement_data.dart:323`

- The cost math is written twice. `enhancementCost`, `cardLevelPenalty`, `previousEnhancementsPenalty` and `totalCost` (about :119-197) duplicate the `_add*Step` breakdown builders (about :263-489), with 25/75/5/10/25/20/0.8/÷2/×3 in both. Only one test checks that they agree.
- `eligibleForMultipleTargets` matches on name substrings (`'hex'`, `'target'`, `'element'`), and `enhancementSelected` encodes the same rule with a category switch.
- `isAvailableInEdition` switches on the strings `'Disarm'` and `'Ward'`. A caller comment mentions "Regenerate in GH2E", which nothing implements.
- The library doc says step 7 is "max(0, total)", but `totalCost` never clamps.

**Fix:** Make the step builders the only source (`totalCost => breakdown.last.value`, with the per-part getters as thin wrappers). Hoist the numbers to named `static const` values. Base multi-target eligibility on `EnhancementCategory` and reuse it in `enhancementSelected`. Add an `excludedEditions` field to `Enhancement`. Fix the stale doc and Regenerate comment, and cross-check against `docs/enhancement_rules.md`.

**Enables:** CQ-24 (localized breakdown text).

### CQ-9 ⬜ Shared enhancement icon widget

**Files:** `lib/ui/screens/enhancement_type_selector_screen.dart:247-262`, `lib/ui/widgets/expandable_cost_chip.dart:455-477`, `lib/ui/widgets/calculator/enhancement_type_body.dart:63-99`, `lib/models/enhancement_cost_calculator.dart:269-272`

The "is +1" check and icon builder (including `enhancement.name == 'Element'`) are copied 3–4 times and have already drifted: only one copy guards a null `assetKey`, and the sizes differ.

**Fix:** Add an `Enhancement.isPlusOne` getter and one `EnhancementIcon(enhancement:, size:)` widget in `lib/ui/widgets/calculator/`.

### CQ-10 ⬜ `Resource` enum for Characters resource columns

**Files:** `lib/models/character.dart:41-219`, `lib/data/database_helper.dart:91-117`, `lib/data/database_backup_service.dart:94-113`, `lib/ui/widgets/character/resource_field.dart`, `resource_card.dart:67`

The 9 resources are listed by hand in the column constants, fields, constructor, `fromMap`/`toMap`, create-table, backup patcher and UI.

**Fix:** Add one `Resource` enum (column name, asset key, l10n getter) and have the columns, backup defaults and UI loop over it. At minimum, generate the backup defaults from the same list. This needs a careful look at backup/restore compatibility, so run the `persistence` reviewer on it.

**Enables:** localizing resource names (part of CQ-24).

### CQ-11 ⬜ SharedPreferences key constants

**Files:** `lib/shared_prefs.dart`, `lib/viewmodels/enhancement_calculator_model.dart:367-374`

Each key string appears 3–4 times (getter/setter, `exportForBackup`, `importFromBackup`, calculator reset). `resetCost` removes `'enhancementCost'`, which nothing writes. The enhancer-level cascade rule (L2 implies L1, and so on) lives in `shared_prefs.dart:37-68` rather than the model.

**Fix:** Add private `static const _kFoo` key constants and reset helpers on `SharedPrefs`, drop the dead key, and consider moving the cascade rule into the calculator model. Pair with CQ-2 if convenient, since both touch the same keys.

### CQ-12 ⬜ Derive mastery and legacy data instead of duplicating it

- **`lib/models/character.dart:306-315`:** `shouldShowMasteries` hand-lists class codes, categories and variants that `MasteriesRepository.masteriesMap` already knows. Replace it with `masteriesMap[classCode]?.any((m) => m.variant == variant) ?? false`. The reviewer confirmed it gives the same answers on current data. Also delete the stale TODO at :292-294.
- **`lib/data/migrations/perks_repository_legacy.dart:7`:** the "frozen" legacy data depends on `PerkAndMasteryConstants`, which the live `masteries_repository.dart` still uses, so editing it for current masteries silently changes migration data. A near-duplicate, `PerkTextConstants`, also exists. Switch masteries to `PerkTextConstants`, then move `PerkAndMasteryConstants` into `lib/data/migrations/` as migration-only.
- Move migration-only serializers (`Perk.toMap`, `Mastery.toMap`, `PersonalQuest.toMap` and the legacy table-column constants) out of the live models into `lib/data/migrations/`.

**Pairs with:** CQ-3 (both freeze migration inputs).

### CQ-13 ⬜ Small shared constants and getters

- **`GameEdition.shortLabel`:** 'GH', 'GH2e' and 'FH' are hardcoded in `ghc_animated_app_bar.dart:245-258` and `edition_toggle.dart:64-84`.
- **`kDefaultSeedColor`:** `0xff4e7ec1` appears in `characters_model.dart:374`, `shared_prefs.dart:86` and `player_class_constants.dart:13`.
- **`maxCheckmarks`:** the `18` in `characters_model.dart:420`.
- **Retired colour:** `characters_model.dart:378` reads `SharedPrefs().darkTheme` instead of `themeProvider.useDarkMode`.
- **Checkmark math:** `character.dart:254` `((checkMarks - 1) / 3).round()` equals `checkMarks ~/ 3` for values ≥ 0. Simplify it and `checkMarkProgress` the same way.

### CQ-14 ⬜ Duplicated UI layout values

- **Class-icon backdrop:** `character_screen.dart:180-187` and `character_header_delegates.dart:113-117` both use `right: -32, top: -45, +75, width: 260` and must stay in sync. Extract a `ClassIconBackdrop` widget or named constants.
- **Scroll-tint animation:** the `TweenAnimationBuilder` + `Color.lerp(surface, getTintedBackground)` + 300ms pattern is copied in `ghc_app_bar.dart:114-122`, `ghc_animated_app_bar.dart:321-325` and `character_header_delegates.dart:88-100,408-428`. Extract a `ScrollTintBuilder` next to `AppBarUtils` and add a `tintAnimationDuration` constant.

---

## Phase 3 — Dead code and feature removal

CQ-15 is its own branch. CQ-16 – CQ-18 are best done as one branch after it, since CQ-15 deletes some of the same code. Verify each removal with grep before deleting.

### CQ-15 ✅ Remove the element tracker feature entirely

**Decision (2026-10-07):** The element tracker will not be used, so the whole feature goes: the tracker sheet, the animated element icons, element state tracking and persistence, and the sheet's interactions with navigation and the character screen.

**Delete:**
- `lib/ui/widgets/element_tracker_sheet.dart`
- `lib/ui/widgets/animated_element_icon.dart` (945 lines)
- `lib/ui/widgets/animated_element_config.dart`
- `lib/models/element_state.dart` and `test/models/element_state_test.dart`
- `docs/element_tracker.md`

**Unwire:**
- **`lib/viewmodels/characters_model.dart:100-150`:** `_isElementSheetExpanded`, `_isElementSheetFullExpanded`, `collapseElementSheetNotifier` and their getters/setters.
- **`lib/ui/screens/home.dart:68,86`:** the back-button and page-change handling for the sheet.
- **`lib/ui/screens/character_screen.dart:159`:** `isSheetExpanded` and whatever layout depends on it (bottom clearance, scrim, etc.).
- **`lib/ui/widgets/ghc_navigation_bar.dart:29`:** the collapse-on-tab-change call.
- **`lib/data/constants.dart:119`:** `elementTrackerClearance`, and any other constants only the tracker uses.
- **`lib/shared_prefs.dart:279-300`:** the six `element*State` getters/setters. The keys are not part of `exportForBackup`, so there is no backup-format impact. Optionally clear the stale keys once on startup.
- Any l10n strings and `asset_config.dart` entries used only by the tracker, after grepping for other users.

**Keep:** `lib/ui/widgets/element_stack_icon.dart`. It is used by the enhancement calculator, not the tracker.

**Docs to update:** `docs/shared_prefs_keys.md` (Element Tracker State section and the transient-state table), `docs/viewmodels_reference.md`, `docs/TODO.md`, `docs/technical_debt.md` and the CLAUDE.md docs list (`element_tracker.md`).

**Supersedes:** the earlier `animated_element_icon.dart` simplification item, the element-icon fallback removal, the ring-padding duplicate, and the element-tracker entries in CQ-25.

**Done:** The sheet had not been mounted since `6575f58` ("Code audit cleanup"), so the expansion flags were always `false` and the removal changes nothing visible. Also removed `sheetExpandedSize`, which only the tracker and the character-screen padding ternary used. The six `element*State` prefs keys are left orphaned on existing installs. They are harmless and were never part of backups, so there is no cleanup migration.

### CQ-16 ⬜ Dead Dart members

- **`AppModel`:** `themeMode` and `useDefaultFonts` (plus setters) are only used by tests, since `ThemeProvider` owns this state. `updateTheme()` is a bare `notifyListeners()` called from `ghc_animated_app_bar.dart:122` and `retirement_prompt.dart:95`. Remove all four, both call sites, the tests and the doc entries.
- **Theme:** `AppThemeBuilder.darkSurface`, `ColorUtils.readableTextColor` and `ColorSchemeContrast.contrastedPrimary` (its doc promises contrast adjustment but it returns `primary`). In `AppThemeExtension`, `characterSecondary`, `characterAccent` and `isRetiredCharacter` are never read, and `_adjustColor` exists only to feed them.
- **Models and prefs:** `SharedPrefs.personalQuestExpanded`, `PlayerClass.hasVariantName`, `Variant.v4`, and `PersonalQuest.fromMap` (plus its tests).
- **`CharactersModel` party filter** (`characters_model.dart:253-262`): `_showAllCharacters` is always `true`. Either wire it up as part of the Town work or remove it. The getter also builds a new list on every call, including inside `indexOf`.
- **`blurBarHeight`** (`constants.dart:116`): use it in `expandable_cost_chip.dart:161` instead of the hardcoded `100`. This overlaps CQ-25.
- **`_lerpDouble`** in `expandable_cost_chip.dart:479` duplicates `dart:ui`'s `lerpDouble`.

### CQ-17 ⬜ Unused l10n keys

Remove from both `app_en.arb` and `app_pt.arb`, then run `flutter gen-l10n`: `appTitleIOS`, `appTitleAndroid`, `enhancementType`, `enhancementCalculator`, `generalGuidelines`, `lossNonPersistent`, `saved`, `filenameRequired`, `comingSoon`, `noPersonalQuest`, `checkmarks`.

**Keep for Town (decide later):** `renameCampaign`, `notAssignedToParty`.

### CQ-18 ⬜ Unused dependencies and assets

- **Dependencies:** `material_design_icons_flutter` (runtime bloat), `mockito`, `build_runner` and `cupertino_icons`.
- **Assets:**
  - The whole `images/titles/` directory, plus its `pubspec.yaml` entry.
  - `images/branding/switch_gh.png`
  - `images/class_icons/rootwhisperer_old.svg`
  - `images/attack_modifiers/minus_3.svg`
  - `images/status_effects/empower_major.svg`, `enfeeble_major.svg` and `immune.svg`
  - `images/ui/xp_2.svg`
- Check that `.DS_Store` is gitignored inside the asset directories.

---

## Phase 4 — Simplify complex code

These are independent and can be picked up opportunistically.

### CQ-19 ⬜ Theme builder

**File:** `lib/theme/app_theme_builder.dart`

- `_buildDefaultTextTheme` and `_buildCustomTextTheme` (:259-366) are about 50 identical lines. Merge them into one `_buildTextTheme(bodyFont, displayFont, displayLetterSpacing)`.
- The theme cache is keyed by `config.hashCode`, so a hash collision returns the wrong theme. Key it by `ThemeConfig`, which already defines `==`.

### CQ-20 ⬜ Provider wiring in `main.dart`

**File:** `lib/main.dart:113-127`

- The `ChangeNotifierProxyProvider<ThemeProvider, CharactersModel>` `update` returns the previous model, so the proxy does nothing. Use a plain `ChangeNotifierProvider` with `context.read<ThemeProvider>()` in `create`, and update the `CharactersModel` doc.
- The `Builder` both `context.watch`es `ThemeProvider` and wraps an `AnimatedBuilder` on the same listenable, so it subscribes twice. Pick one.
- `themeAnimationCurve` is a no-op with `Duration.zero`.

### CQ-21 ⬜ Calculator model rebuild churn

**Files:** `lib/ui/screens/enhancement_calculator_screen.dart:27`, `lib/viewmodels/enhancement_calculator_model.dart`

- `build` calls `calculateCost(notify: false)`, which throws away the cached calculator on every rebuild even though the setters already invalidate it. Drop the call.
- `enhancementSelected` and `gameVersionToggled` notify 3–5 times per tap. Assign the private fields and notify once.
- The `calculateCost` doc mentions "EnhancerDialog writing directly to SharedPrefs", which no longer happens.

Do this together with or after CQ-8.

### CQ-22 ⬜ `asset_config.dart` lookup duplication

**File:** `lib/utils/asset_config.dart:922-999`

`getAssetConfig` and `tryGetAssetConfig` duplicate the key-cleaning logic and recompile two regexes on every call. That runs per word in the tokenizer and per `ThemedSvg` build, which is on the perk-row rebuild path. Extract one `_cleanKey` with `static final` RegExps and make `getAssetConfig` the `tryGet…` lookup plus a throw. The assertion message also references a non-existent `standardAssets`.

---

## Phase 5 — Localization gaps

### CQ-23 ⬜ Hardcoded English UI strings

- **`ghc_animated_app_bar.dart:153-155,165,186`:** the delete-character dialog body, confirm and cancel labels, and the "X deleted" snackbars. Use `l10n.delete`/`l10n.cancel` and add keys with placeholders.
- **`lib/ui/dialogs/custom_class_warning_dialog.dart`:** the whole dialog.
- **`previous_enhancements_body.dart:20`:** `Text('None')`.
- **`edition_toggle.dart:73`:** the `'Gloomhaven 2nd Edition'` tooltip.

### CQ-24 ⬜ Calculator and resource text

- **Calculator breakdown descriptions** ("Base cost", "Card level", "Multiple targets", "Party Boon", …) in `enhancement_cost_calculator.dart`, shown in `expandable_cost_chip.dart:423`. Have the calculator return step identifiers and let the UI map them through `AppLocalizations`. `multipleTargets` already exists in the ARB. **Depends on:** CQ-8.
- **`EnhancementCategory.sectionTitle`** (`enhancement_data.dart:17-31`).
- **Resource names** ('Lumber', 'Metal', …) in `resource_card.dart:67`. **Depends on:** CQ-10.

---

## Phase 6 — Design-constant sweep

### CQ-25 ⬜ Replace hardcoded sizes and durations with `constants.dart`

About 50 non-0/1 numeric literals remain in `lib/ui`, plus repeated `Duration(milliseconds: 300)` (`expandable_cost_chip.dart:66,293`, `characters_model.dart:395`). Hot spots:

- **`expandable_cost_chip.dart`:** `161` (`blurBarHeight`), `326`, `331` (`iconSizeMedium`), `340`, `343`, `376` and `379`.
- **`stats_section.dart`:** `163`, `339` and `392-394`.
- **`enhancement_type_selector_screen.dart`:** `225`, `280` and `291`.
- **Other files:**
  - `cost_display.dart:75`
  - `card_details_card.dart:203`
  - `custom_class_warning_dialog.dart:93`
  - `update_450_dialog.dart:41-47`
  - `character_header_delegates.dart:310` (`fontSize: 31`)
  - `diagnostic_error_view.dart` (11 sites)

Also reopen the "Hardcoded Magic Numbers" item in `docs/technical_debt.md:71`, which is marked RESOLVED but isn't.

### CQ-26 ⬜ Party popup menu convention

**File:** `lib/ui/widgets/town/party_section.dart:182-222`

The menu uses `Row(Text, SizedBox, Icon)` instead of `ListTile(title:, trailing:, contentPadding: EdgeInsets.zero)`. It is behind the Town flag, so fix it before Town ships.

---

## Phase 7 — Docs sync

### CQ-27 ⬜ Reference docs out of date

- **`docs/models_reference.md`:**
  - The `EnhancementCategory` section (:252-264) has the wrong file path (the enum lives in `enhancement_data.dart`) and the wrong values.
  - The CharacterPerk and CharacterMastery fields (:390-392, :436-438) should be `associatedCharacterUuid`, `associatedPerkId`/`associatedMasteryId` and `characterPerkIsSelected`/`characterMasteryAchieved`.
  - The path at :428 should be `lib/models/mastery/character_mastery.dart`.
- **`docs/viewmodels_reference.md`:**
  - :392-399 lists `setEditMode`-style methods, but these are property setters.
  - TownModel's Party Methods are missing `updatePartyLocation`, `updatePartyNotes` and `toggleAchievement`.
  - The calculator's Core Methods are missing `enhancementCost`, `cardLevelPenalty` and `previousEnhancementsPenalty`.
- **`docs/screens.md`:**
  - :606-618 references the private `_EnhancementTypeCard`, `_CardDetailsGroupCard` and `_DiscountsGroupCard`, which are now public widgets in `lib/ui/widgets/calculator/`.
  - :612 says "0-9" but the widget has 0-3.
  - :363 says `CreatePartyScreen`, which is now `CreatePartySheet`.
  - `ChangelogScreen` is missing.
- **`docs/calculator_widgets.md:144`:** stale `_CardDetailsGroupCard` reference.
- **`docs/dialogs.md`:** missing `AddSubtractDialog` and `Update450Dialog`.

### CQ-28 ⬜ Stale comments and CLAUDE.md

- `lib/models/character.dart:120-125` and `lib/data/database_helper.dart:253-256` still say a JotL *class* makes a character JotL. Reword both to say only the persisted game-mode flag counts.
- In CLAUDE.md, the v19 note says "24 GH + 23 FH quests", but the repository has 105 quests across 5 editions.
