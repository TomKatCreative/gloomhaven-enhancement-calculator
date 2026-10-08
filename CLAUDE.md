# CLAUDE.md - Project Context for AI Assistants

## Project Overview

**Gloomhaven Enhancement Calculator** - A Flutter mobile app (iOS/Android/Web) for the Gloomhaven board game series. Provides character sheet management, enhancement cost calculator, perk/mastery tracking, and resource tracking.

Standard Flutter workflow — see `pubspec.yaml` for dependencies, `flutter test` to run tests, `dart format .` after changes.

## Git Branching Strategy

**IMPORTANT:** Commit development work directly to `dev`, never `master`. Don't create feature branches.

- **`master`** - Production-ready code only. Only merge in when preparing a production release.
- **`dev`** - Main development branch. Pushes auto-deploy to Google Play's internal testing track via `.github/workflows/deploy-internal.yml`.

### Common Git Commands

**IMPORTANT:** Git options (like `--stat`, `--oneline`) must come BEFORE file arguments, not after.

```bash
# ✅ Correct
git diff --stat lib/ui/screens/file.dart
git log --oneline main..HEAD

# ❌ Wrong - "fatal: option must come before non-option arguments"
git diff lib/ui/screens/file.dart --stat
```

## Architecture

### State Management: Provider + ChangeNotifier

Models are registered in `main.dart` (`CharactersModel` via ProxyProvider).

### Data Persistence

- **SQLite** (`sqflite`) — Characters, perks, masteries, campaigns, parties (schema v20; see Feature Flags).
- **SharedPreferences** — App settings, theme, calculator state. Singleton wrapper at `lib/shared_prefs.dart`.

### Feature Flags

One compile-time constant in `lib/data/constants.dart` gates unreleased features:

```dart
const bool kTownSheetEnabled = false;
```

| Flag | What it gates |
|------|---------------|
| `kTownSheetEnabled` | Town tab in bottom nav, TownScreen page, Campaigns/Parties DB tables, TownModel initialization, page indices (`kTownPageIndex`, `kCharactersPageIndex`, `kCalculatorPageIndex` in `constants.dart`) |

**Database versioning**: Production schema is v20 (v19: Personal Quests with 24 GH + 23 FH quests, Perks/Masteries/PersonalQuests definition tables dropped — loaded from repositories; v20: `ShowResources` and `IsJawsOfTheLion` columns on Characters). When `kTownSheetEnabled` is `true`, Campaigns/Parties tables and `PartyId` column on Characters are created on fresh installs (will need a numbered migration when the flag ships).

## Key Domain Concepts

### Class Variants

Some classes have different names/perks across game editions (`Variant` enum). Example: "Brute" in base game → "Bruiser" in Gloomhaven 2e.

### Game Editions (GameEdition)

`ClassCategory` groups classes by release; `GameEdition` (used by the enhancement calculator and character creation) applies edition-specific rules:

**Starting Character Rules by Edition:**

| Edition | Max Starting Level | Starting Gold Formula |
|---------|-------------------|----------------------|
| Gloomhaven | Prosperity Level | 15 × (L + 1) |
| Gloomhaven 2e | Prosperity / 2 (rounded up) | 10 × P + 15 |
| Frosthaven | Prosperity / 2 (rounded up) | 10 × P + 20 |
| Jaws of the Lion | 1 (locked) | 15 × (L + 1) = 30 |

Where L = starting level, P = prosperity level.

**Jaws of the Lion (JotL):** A simplified standalone **game mode**. It has **no personal quests, no prosperity/town, no Frosthaven-style resources, and no retirement mechanic** — those inputs are hidden in character creation when the JotL game mode is selected, and the corresponding sections are hidden on the sheet via `Character.isJawsOfTheLion`. JotL characters always **start at level 1**: the level slider is hidden in character creation (replaced by a fixed "Starting gold: 30" row). JotL still has battle-goal checkmarks and level-up perks; only retirement-granted perks are removed — `Character.maximumPerks` excludes `previousRetirements` for JotL.

**Game mode is authoritative, not class.** `isJawsOfTheLion` reflects only the persisted `jawsOfTheLionEdition` flag (the game mode chosen at creation) — it does **not** look at the class. Any class can be created under any game mode: a JotL class (e.g. Demolitionist) created under GH/GH2e/FH is a normal character of that mode and shows all the usual fields (resources default on for FH). Conversely, picking the JotL mode with any class hides the PQ/prosperity/resources fields. (Mastery visibility is a separate, class-based concern via `shouldShowMasteries`.)

JotL is **not** part of the enhancement calculator (it has no enhancement system), so it is intentionally absent from the calculator's edition picker — only the character-creation `EditionToggle` offers it.

**Enhancement Calculator Differences:**
- **Gloomhaven**: Multi-target multiplier applies to all enhancement types including Target and elements.
- **GH2E**: Has lost modifier (halves cost), no persistent modifier, multi-target excludes Target/hex/elements.
- **Frosthaven**: Has lost modifier, persistent modifier (triples cost), enhancer building levels.

## Conventions

### File Naming

- Models, screens, widgets: `snake_case.dart` (e.g., `player_class.dart`, `enhancement_calculator_screen.dart`, `perk_row.dart`).

### Popup Menus

All `PopupMenuButton` items use `ListTile` with **text on the left** (`title`) and **icon on the right** (`trailing`).

```dart
// ✅ Correct - text left, icon right
PopupMenuItem(
  value: MyAction.doSomething,
  child: ListTile(
    title: Text(l10n.doSomething),
    trailing: const Icon(Icons.arrow_forward),
    contentPadding: EdgeInsets.zero,
  ),
),
```

### Design Constants (IMPORTANT)

**NEVER hardcode pixel values, font sizes, border radii, or animation durations.** Use the named constants in `lib/data/constants.dart` (see inline doc comments for the full set: `tinyPadding`, `smallPadding`, `iconSizeMedium`, `borderRadiusMedium`, `animationDuration`, etc.). For text styles, use `theme.textTheme.bodyMedium` etc. — see `docs/theme_system.md`.

Don't write derived sizes (`iconSizeLarge * 0.7`). If no existing constant fits, add one.

### Database

- UUID for character IDs (with legacy migration for old int IDs).
- Migrations live in `lib/data/database_migrations.dart` — append new migrations, never modify old ones.

## SVG Theming

**Never use `SvgPicture.asset()` directly.** All SVG assets are centralized in `lib/utils/asset_config.dart`.

### ThemedSvg (`lib/utils/themed_svg.dart`)

```dart
ThemedSvg(assetKey: 'MOVE', width: iconSizeMedium)
ThemedSvg(assetKey: 'ATTACK', width: iconSizeMedium, color: Colors.red)
ThemedSvg(assetKey: 'MOVE', width: iconSizeMedium, showPlusOneOverlay: true)
```

### ClassIconSvg (`lib/ui/widgets/class_icon_svg.dart`)

```dart
ClassIconSvg(playerClass: myClass, width: iconSizeXL, height: iconSizeXL)
```

### Adding a new SVG icon

1. Add the SVG file under `images/`.
2. For theme-aware parts, use `fill="currentColor"` in the SVG.
3. Add an entry to `asset_config.dart`:
   ```dart
   'MY_ICON': AssetConfig('subfolder/my_icon.svg', themeMode: CurrentColorTheme())
   ```
4. Use it: `ThemedSvg(assetKey: 'MY_ICON', width: iconSizeMedium)`.

Class icons use `ClassCodes` constants as keys, never string literals like `'br'`.

## Localization (i18n)

Flutter's `gen_l10n` system. Currently English (default) and Portuguese.

To add a string: edit `lib/l10n/app_en.arb` (template), translate in `app_pt.arb`, run `flutter gen-l10n`.

**Not localized by design**: `strings.dart` (markdown w/ inline icons), `perks_repository.dart` (perk text w/ placeholders), discount marker symbols (`†`, `‡`, `§`, `*`).

## Documentation

Project docs live in `/docs`. Key reference files:

- `docs/technical_debt.md` — current debt landscape, refactor history.
- `docs/database_schema.md`, `docs/models_reference.md`, `docs/viewmodels_reference.md`, `docs/shared_prefs_keys.md` — code references.
- `docs/enhancement_rules.md`, `docs/perk_format_reference.md`, `docs/game_text_parser.md` — domain rules.
- `docs/calculator_widgets.md`, `docs/dialogs.md`, `docs/screens.md`, `docs/theme_system.md` — feature/widget docs.
- `docs/TODO.md` — task tracking.
- `docs/releases.md` — release history.

When creating new docs: place in `/docs`, use `snake_case.md`. `README.md` and `CLAUDE.md` stay at project root.

## Tips for AI Assistants

1. **NEVER commit or push without explicit instructions.** No `git commit`, `git push`, or PRs unless asked.
2. **Work directly on `dev`**, not `master`, with no feature branches. Pushes to `dev` auto-deploy to internal testing.
3. **Push back on bad ideas.** If a request isn't technically sound, suggest a better approach instead of just executing.
4. **Run `dart format .` and `flutter test`** after code changes. Run targeted tests for the area touched (`test/models/`, `test/viewmodels/`, `test/widgets/`).
5. **Pre-push doc & test audit.** Before pushing to `dev`, check that modified models/methods are reflected in `docs/models_reference.md` and `docs/viewmodels_reference.md`, and that tests cover new/changed methods. Flag gaps.
6. **Responsive design.** UI must adapt down to ~5" phones. Use `MediaQuery`, `LayoutBuilder`, or constrained relative sizing — never assume a viewport.
