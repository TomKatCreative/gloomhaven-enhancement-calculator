# CLAUDE.md - Project Context for AI Assistants

## Project Overview

**Gloomhaven Enhancement Calculator** - A Flutter mobile app (iOS/Android/Web) for the Gloomhaven board game series. Provides character sheet management, enhancement cost calculator, perk/mastery tracking, and resource tracking.

Standard Flutter workflow — see `pubspec.yaml` for dependencies, `flutter test` to run tests, `dart format .` after changes.

## Git Branching Strategy

**IMPORTANT:** Always start new development work by branching from `dev`, not `master`.

- **`master`** - Production-ready code only. Only merge in when preparing a production release.
- **`dev`** - Main development branch. Pushes auto-deploy to Google Play's internal testing track via `.github/workflows/deploy-internal.yml`.
- **Feature branches** - Branch from `dev`, merge back to `dev` when complete.

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

Five models registered in `main.dart`:

```
ThemeProvider              → Theme colors, dark mode, font preferences
AppModel                   → Page navigation, app-level UI state
EnhancementCalculatorModel → Calculator page state
TownModel                  → Campaign/party CRUD, prosperity, reputation
CharactersModel            → Character CRUD, perk/mastery state (via ProxyProvider)
```

### Data Persistence

- **SQLite** (`sqflite`) — Characters, perks, masteries, campaigns, parties (schema v19; see Feature Flags).
- **SharedPreferences** — App settings, theme, calculator state. Singleton wrapper at `lib/shared_prefs.dart`.

### Feature Flags

One compile-time constant in `lib/data/constants.dart` gates unreleased features:

```dart
const bool kTownSheetEnabled = false;
```

| Flag | What it gates |
|------|---------------|
| `kTownSheetEnabled` | Town tab in bottom nav, TownScreen page, Campaigns/Parties DB tables, TownModel initialization, page index mapping (characters=0→1, calculator=1→2) |

**Database versioning**: Production schema is v19 (Personal Quests with 24 GH + 23 FH quests; Perks/Masteries/PersonalQuests definition tables dropped — loaded from repositories). When `kTownSheetEnabled` is `true`, Campaigns/Parties tables and `PartyId` column on Characters are created on fresh installs (will need a numbered migration when the flag ships).

## Key Domain Concepts

### Game Editions (ClassCategory)

```dart
enum ClassCategory {
  gloomhaven,      // Original Gloomhaven
  jawsOfTheLion,   // Starter set
  frosthaven,      // Sequel
  crimsonScales,   // Fan expansion
  custom,          // User-created
  mercenaryPacks,  // Standalone character packs
}
```

### Class Variants

Some classes have different names/perks across game editions:

```dart
enum Variant { base, frosthavenCrossover, gloomhaven2E, v2, v3, v4 }
```

Example: "Brute" in base game → "Bruiser" in Gloomhaven 2e.

### Character Data Flow

1. `PlayerClass` — Static class definition (race, name, classCode, perks).
2. `Character` — Instance of a class (name, level, XP, gold, retirements).
3. `CharacterPerk` / `CharacterMastery` — Join tables tracking which perks/masteries are checked.

### Game Editions (GameEdition)

The enhancement calculator and character creation use `GameEdition` to apply edition-specific rules:

```dart
enum GameEdition { gloomhaven, gloomhaven2e, frosthaven }
```

**Starting Character Rules by Edition:**

| Edition | Max Starting Level | Starting Gold Formula |
|---------|-------------------|----------------------|
| Gloomhaven | Prosperity Level | 15 × (L + 1) |
| Gloomhaven 2e | Prosperity / 2 (rounded up) | 10 × P + 15 |
| Frosthaven | Prosperity / 2 (rounded up) | 10 × P + 20 |

Where L = starting level, P = prosperity level.

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

```dart
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

Text(AppLocalizations.of(context).close)
Text(AppLocalizations.of(context).pocketItemsAllowed(count))  // with parameters
```

To add a string: edit `lib/l10n/app_en.arb` (template), translate in `app_pt.arb`, run `flutter gen-l10n`.

**Not localized by design**: `strings.dart` (markdown w/ inline icons), `perks_repository.dart` (perk text w/ placeholders), discount marker symbols (`†`, `‡`, `§`, `*`).

## Documentation

Project docs live in `/docs`. Key reference files:

- `docs/technical_debt.md` — current debt landscape, refactor history.
- `docs/database_schema.md`, `docs/models_reference.md`, `docs/viewmodels_reference.md`, `docs/shared_prefs_keys.md` — code references.
- `docs/enhancement_rules.md`, `docs/perk_format_reference.md`, `docs/game_text_parser.md` — domain rules.
- `docs/element_tracker.md`, `docs/calculator_widgets.md`, `docs/dialogs.md`, `docs/screens.md`, `docs/theme_system.md` — feature/widget docs.
- `docs/TODO.md` — task tracking.
- `docs/releases.md` — release history.

When creating new docs: place in `/docs`, use `snake_case.md`. `README.md` and `CLAUDE.md` stay at project root.

## Tips for AI Assistants

1. **NEVER commit or push without explicit instructions.** No `git commit`, `git push`, or PRs unless asked.
2. **Branch from `dev`**, not `master`. Pushes to `dev` auto-deploy to internal testing.
3. **Push back on bad ideas.** If a request isn't technically sound, suggest a better approach instead of just executing.
4. **Run `dart format .` and `flutter test`** after code changes. Run targeted tests for the area touched (`test/models/`, `test/viewmodels/`, `test/widgets/`).
5. **Pre-push doc & test audit.** Before pushing to `dev`, check that modified models/methods are reflected in `docs/models_reference.md` and `docs/viewmodels_reference.md`, and that tests cover new/changed methods. Flag gaps.
6. **Responsive design.** UI must adapt down to ~5" phones. Use `MediaQuery`, `LayoutBuilder`, or constrained relative sizing — never assume a viewport.
