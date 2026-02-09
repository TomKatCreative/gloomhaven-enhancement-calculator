# CLAUDE.md - Project Context for AI Assistants

## Project Overview

**Gloomhaven Enhancement Calculator** - A Flutter mobile app (iOS/Android) for the Gloomhaven board game series. It provides:
- Character sheet management (create, track, retire characters)
- Enhancement cost calculator
- Perk and mastery tracking
- Resource tracking (gold, XP, checkmarks, etc.)

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Generate launcher icons
dart run flutter_launcher_icons

# Analyze code
flutter analyze

# Format code (run after making changes)
dart format .

# Run all tests
flutter test

# Run a specific test file
flutter test test/widgets/perk_widgets_test.dart

# Run tests matching a name pattern
flutter test --name "PerkRow"
```

## Git Branching Strategy

**IMPORTANT:** Always start new development work by branching from `dev`, not `master`.

- **`master`** - Production-ready code only. Should always be in a deployable state. Only merge into master when preparing a production release.
- **`dev`** - Main development branch. Pushes here auto-deploy to Google Play's internal testing track. Merge feature branches here for QA testing.
- **Feature branches** - Branch from `dev` for new features or fixes. Merge back to `dev` when complete.

```bash
# Starting new work
git checkout dev
git pull origin dev
git checkout -b feature/my-new-feature

# When feature is complete
git checkout dev
git merge feature/my-new-feature
git push origin dev  # Auto-deploys to internal testing
```

### Common Git Commands

**IMPORTANT:** Git options (like `--stat`, `--oneline`) must come BEFORE file arguments, not after.

```bash
# ✅ Correct - options before file arguments
git diff --stat lib/ui/screens/file.dart
git log --oneline main..HEAD
git diff --name-only HEAD~1

# ❌ Wrong - will fail with "fatal: option must come before non-option arguments"
git diff lib/ui/screens/file.dart --stat
git log main..HEAD --oneline
```

## Architecture

### State Management: Provider + ChangeNotifier

The app uses Provider with four main models set up in `main.dart`:

```
ThemeProvider          → Theme colors, dark mode, font preferences
AppModel               → Page navigation, app-level UI state
EnhancementCalculatorModel → Calculator page state
CharactersModel        → Character CRUD, perk/mastery state (uses ProxyProvider)
```

### Directory Structure

```
docs/                         # Project documentation (plans, references, TODOs)
lib/
├── main.dart                 # App entry, Provider setup
├── models/                   # Data models (Character, Perk, Mastery, etc.)
├── data/                     # Repositories, database, static game data
│   ├── database_helpers.dart # SQLite singleton (sqflite)
│   ├── database_migrations.dart
│   ├── perks/               # Perk definitions by class
│   ├── masteries/           # Mastery definitions
│   └── player_classes/      # Class definitions
├── l10n/                    # Localization (ARB files + generated code)
│   ├── app_en.arb           # English strings (template)
│   ├── app_pt.arb           # Portuguese translations
│   └── app_localizations.dart # Generated - do not edit
├── viewmodels/              # ChangeNotifier models
├── ui/
│   ├── screens/             # Full-page views
│   ├── widgets/             # Reusable components
│   │   ├── calculator/      # Enhancement calculator card components
│   │   └── settings/        # Settings screen section widgets
│   └── dialogs/             # Modal dialogs
├── theme/                   # Theme system (ThemeProvider, extensions)
├── utils/                   # Helpers, text parsing
└── shared_prefs.dart        # SharedPreferences wrapper (singleton)
test/
├── helpers/                  # Test infrastructure
│   ├── fake_database_helper.dart  # In-memory DB for testing
│   ├── test_data.dart        # Factory methods for test fixtures
│   └── test_helpers.dart     # MockThemeProvider, wrapWithProviders()
├── models/                   # Model unit tests
├── viewmodels/               # ViewModel unit tests
└── widgets/                  # Widget integration tests
```

### Data Persistence

- **SQLite** (`sqflite`) - Characters, perks, masteries (schema version 18)
- **SharedPreferences** - App settings, theme, calculator state

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
Example: "Brute" in base game → "Bruiser" in Gloomhaven 2E

### Character Data Flow
1. `PlayerClass` - Static class definition (race, name, classCode, perks)
2. `Character` - Instance of a class (name, level, XP, gold, retirements)
3. `CharacterPerk` / `CharacterMastery` - Join tables tracking which perks/masteries are checked

### Game Editions (GameEdition)
The enhancement calculator and character creation use `GameEdition` enum to apply edition-specific rules:
```dart
enum GameEdition { gloomhaven, gloomhaven2e, frosthaven }
```

**Starting Character Rules by Edition:**
| Edition | Max Starting Level | Starting Gold Formula |
|---------|-------------------|----------------------|
| Gloomhaven | Prosperity Level | 15 × (L + 1) |
| Gloomhaven 2E | Prosperity / 2 (rounded up) | 10 × P + 15 |
| Frosthaven | Prosperity / 2 (rounded up) | 10 × P + 20 |

Where L = starting level, P = prosperity level.

**Enhancement Calculator Differences:**
- **Gloomhaven**: Multi-target multiplier applies to all enhancement types including Target and elements
- **GH2E**: Has lost modifier (halves cost), no persistent modifier, multi-target excludes Target/hex/elements
- **Frosthaven**: Has lost modifier, persistent modifier (triples cost), enhancer building levels

## Conventions

### File Naming
- Models: `snake_case.dart` (e.g., `player_class.dart`)
- Screens: `*_screen.dart`
- Widgets: Descriptive names (e.g., `perk_row.dart`, `resource_card.dart`)

### Widget Patterns
- Screens use `context.watch<Model>()` for reactive rebuilds
- One-time reads use `context.read<Model>()`
- Complex widgets are StatefulWidget with local controllers

### Design Constants (IMPORTANT)

**NEVER hardcode pixel values for padding, icon sizes, border radii, or animation durations.** Always use the constants defined in `lib/data/constants.dart`. This ensures visual consistency and makes future adjustments easy.

#### Spacing & Padding

| Constant | Size | Usage |
|----------|------|-------|
| `tinyPadding` | 4 | Minimal spacing, tight layouts |
| `smallPadding` | 8 | Standard tight spacing |
| `mediumPadding` | 12 | Standard comfortable spacing |
| `largePadding` | 16 | Section spacing, card padding |
| `extraLargePadding` | 24 | Major section breaks, screen padding |

#### Icon Sizes

| Constant | Size | Usage |
|----------|------|-------|
| `iconSizeTiny` | 14 | Decorative overlays (+1 badge) |
| `iconSizeSmall` | 20 | Form inputs, element tracker collapsed, stacked elements |
| `iconSizeMedium` | 26 | Inline text icons (perks, masteries), section headers |
| `iconSizeLarge` | 32 | Primary navigation, calculator, dialog buttons |
| `iconSizeXL` | 36 | Class icons in lists/dialogs |
| `iconSizeHero` | 48 | Hero elements (level badge) |

#### Border Radius

| Constant | Size | Usage |
|----------|------|-------|
| `borderRadiusSmall` | 4 | Small rounded corners (checkboxes) |
| `borderRadiusMedium` | 8 | Standard input/card corners |
| `borderRadiusLarge` | 16 | Larger rounded elements |
| `borderRadiusPill` | 24 | Full pill shape (chips, FABs) |
| `borderRadiusCard` | 28 | Card top corners |

#### Font Sizes

The app uses Google's Material 3 type scale. **Always use `theme.textTheme` styles** (e.g., `bodyMedium`, `headlineSmall`) instead of hardcoding font sizes.

See `docs/theme_system.md` for the full type scale reference and usage guidelines.

#### Other Constants

| Constant | Value | Usage |
|----------|-------|-------|
| `hairlineThickness` | 0.5 | Thin dividers |
| `dividerThickness` | 1.0 | Standard divider line |
| `animationDuration` | 250ms | Standard animation duration |
| `navBarIconContainerHeight` | 35 | Navigation bar item height |
| `blurBarHeight` | 100 | Blur bar at bottom of calculator |
| `formFieldSpacing` | 28 | Vertical spacing between form fields |

#### Guidelines

1. **Always use constants** - Never write `padding: EdgeInsets.all(8)` or `width: 32`. Use `smallPadding` and `iconSizeLarge` instead.

2. **No derived sizes** - Don't use expressions like `iconSizeLarge * 0.5` or `iconSize - 2`. If you need a different size, use an existing constant or discuss adding a new one.

3. **Exceptions** - Local computed values for animations (like interpolating between two sizes) are acceptable as local variables.

4. **Adding new constants** - If none of the existing sizes fit your use case, consider whether the design should be adjusted to use an existing size. Only add new constants if there's a clear, recurring need.

```dart
// ✅ Correct
Padding(padding: EdgeInsets.all(smallPadding))
Icon(Icons.info, size: iconSizeSmall)
ThemedSvg(assetKey: 'MOVE', width: iconSizeLarge)
BorderRadius.circular(borderRadiusMedium)
Duration(milliseconds: animationDuration.inMilliseconds)

// ❌ Wrong - hardcoded values
Padding(padding: EdgeInsets.all(8))
Icon(Icons.info, size: 20)
ThemedSvg(assetKey: 'MOVE', width: 32)
BorderRadius.circular(8.0)
Duration(milliseconds: 250)

// ❌ Wrong - derived sizes
width: iconSizeLarge * 0.7
height: iconSize - 2.5
```

### Database
- UUID for character IDs (with legacy migration for old int IDs)
- Migrations in `database_migrations.dart` - append new migrations, don't modify old ones

## Known Technical Debt

1. **Legacy files** - `*_legacy.dart` files exist for backward compatibility

## Documentation Files

All project documentation (plans, reference docs, TODOs) lives in the `/docs` directory at the project root.

**Current files:**
- `docs/TODO.md` - Future feature plans and task tracking
- `docs/enhancement_rules.md` - Enhancement cost calculation rules by edition
- `docs/game_text_parser.md` - Game text parser syntax and usage
- `docs/perk_format_reference.md` - Perk definition format for perks_repository.dart
- `docs/svg_asset_config_refactor.md` - SVG asset centralization patterns and rationale
- `docs/database_schema.md` - Database schema and migration reference
- `docs/models_reference.md` - Data model class reference
- `docs/viewmodels_reference.md` - ViewModel/ChangeNotifier reference
- `docs/shared_prefs_keys.md` - SharedPreferences keys reference

**Widget/Feature documentation** (read when working on specific features):
- `docs/element_tracker.md` - Element tracker sheet and animation system
- `docs/screens.md` - Create character and selector screens
- `docs/dialogs.md` - Reusable dialog components
- `docs/calculator_widgets.md` - Expandable cost chip and calculator cards
- `docs/theme_system.md` - Color contrast and Android navigation bar

**When creating documentation:**
- Place all `.md` files in `/docs` (not scattered in `lib/`)
- Use `snake_case.md` naming
- Exception: `README.md` and `CLAUDE.md` stay at project root

## Assets

- Class icons: `images/class_icons/*.svg`
- Attack modifiers: `images/attack_modifiers/`
- Custom fonts: PirataOne (headers), HighTower, Nyala, Roboto, OpenSans, Inter

## SVG Theming

The app uses `flutter_svg` for rendering SVG icons. **All SVG assets are centralized in `asset_config.dart`** - never use `SvgPicture.asset()` directly.

### ThemedSvg Widget (`lib/utils/themed_svg.dart`)

```dart
// Basic usage - just pass an asset key
ThemedSvg(assetKey: 'MOVE', width: 24)

// With custom color override
ThemedSvg(assetKey: 'ATTACK', width: 24, color: Colors.red)

// With +1 overlay badge (for enhancements)
ThemedSvgWithPlusOne(assetKey: 'MOVE', width: 24)
```

### ClassIconSvg Widget (`lib/ui/widgets/class_icon_svg.dart`)

```dart
// Basic usage - uses playerClass.primaryColor automatically
ClassIconSvg(playerClass: myClass, width: 48, height: 48)

// With custom color override
ClassIconSvg(playerClass: myClass, width: 48, height: 48, color: Colors.grey)
```

### Adding a New SVG Icon

1. Add the SVG file to the appropriate `images/` subdirectory
2. Edit the SVG to use `currentColor` for theme-aware parts: `fill="currentColor"`
3. Add an entry in `asset_config.dart`:
   ```dart
   'MY_ICON': AssetConfig('subfolder/my_icon.svg', themeMode: CurrentColorTheme())
   ```
4. Use it with `ThemedSvg(assetKey: 'MY_ICON', width: 24)`

### Important Rules

1. **Never use `SvgPicture.asset()` directly** - always use `ThemedSvg` or `ClassIconSvg`
2. **All SVG assets must be in `asset_config.dart`** - this is the single source of truth
3. **Class icons use `ClassCodes` constants as keys** - not string literals like `'br'` or `'sc'`

## Localization (i18n)

The app uses Flutter's official `gen_l10n` system for internationalization. Currently supports English (default) and Portuguese.

### Using Localized Strings

```dart
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

// In build methods:
Text(AppLocalizations.of(context).close)
Text(AppLocalizations.of(context).gold)

// With parameters:
Text(AppLocalizations.of(context).pocketItemsAllowed(count))
```

### Adding New Strings

1. Add the string to `lib/l10n/app_en.arb` (English template)
2. For strings with parameters, add metadata with placeholders
3. Add translation to `lib/l10n/app_pt.arb`
4. Run `flutter pub get` or `flutter gen-l10n` to regenerate

### What's NOT Localized (By Design)

- **`strings.dart`** - Complex markdown content with inline icons used by `GameTextParser`
- **`perks_repository.dart`** - Perk descriptions with icon placeholders
- **Discount marker symbols** - The `†`, `‡`, `§`, and `*` markers are appended using unicode escapes

## CI/CD Pipeline

The project uses GitHub Actions to deploy Android app bundles to Google Play's internal test track.

### Triggering a Deploy

```bash
# Deploy using current pubspec.yaml version
gh workflow run deploy-internal.yml

# Deploy with a specific version name
gh workflow run deploy-internal.yml -f version_name=4.3.3
```

### How It Works

1. Triggered automatically on push to `dev` branch, or manually via `workflow_dispatch`
2. Sets up Java 17 and Flutter (version specified in workflow file)
3. Decodes keystore from GitHub secrets and creates `key.properties`
4. Auto-increments build number using `github.run_number + BUILD_NUMBER_OFFSET`
5. Builds release app bundle
6. Uploads to Play Store internal track via service account

### Configuration

- **Workflow file**: `.github/workflows/deploy-internal.yml`
- **Flutter version**: Update `FLUTTER_VERSION` env var when upgrading Flutter locally
- **Build number offset**: `BUILD_NUMBER_OFFSET` ensures build numbers exceed previous releases

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `KEYSTORE_BASE64` | Base64-encoded signing keystore |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_PASSWORD` | Key password |
| `KEY_ALIAS` | Key alias |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Base64-encoded Google Play service account JSON |

## Tips for AI Assistants

1. **NEVER commit or push without explicit instructions** - Do not run `git commit`, `git push`, or create pull requests unless the user explicitly asks you to. Always wait for the user to review changes and give the go-ahead before touching git history.
2. **Read before modifying** - Always read files before suggesting changes
3. **Check variants** - Many features branch based on `ClassCategory` or `Variant`
4. **SharedPrefs keys** - Settings stored in `shared_prefs.dart` - check existing keys before adding
5. **Database migrations** - New schema changes need migration code in `database_migrations.dart`
6. **Theme awareness** - Use `Theme.of(context)` and ThemeProvider for colors/styling
7. **SVG icons** - NEVER use `SvgPicture.asset()` directly. Always use:
   - `ThemedSvg` for general SVG icons (with asset keys from `asset_config.dart`)
   - `ClassIconSvg` for player class icons (uses `classCode` as asset key automatically)
   - All new SVG assets must be added to `asset_config.dart` first
   - Class icons use `ClassCodes` constants as keys, not string literals
8. **Localization** - Use `AppLocalizations.of(context).xxx` for UI strings, not hardcoded text. Add new strings to ARB files.
9. **User interaction** - When speaking with the developer who is working on this project, push back again their ideas if they aren't technically sound. Don't just do whatever they want - think about it in the context of the app and if you think there's a better way to do something, suggest it.
10. **Branching** - Always suggest starting new work from the `dev` branch, not `master`. Pushes to `dev` auto-deploy to internal testing.
11. **Responsive design** - UI must adapt to smaller screens (minimum ~5" phones). Avoid hardcoding pixel values for layout sizing. Use `MediaQuery`, `LayoutBuilder`, or relative sizing (percentages with minimum constraints) to ensure UI elements remain visible and usable on all screen sizes.
12. **Code formatting** - Always run `dart format .` after making changes to ensure consistent code style.
13. **Widget documentation** - For detailed widget docs, check the `/docs` directory (element_tracker.md, screens.md, dialogs.md, calculator_widgets.md, theme_system.md).
14. **Run tests after changes** - After modifying code in `lib/`, always run relevant tests with `flutter test` (or a specific test file if the scope is narrow). Ensure all tests pass before considering the work complete. If a change touches models or viewmodels, run the corresponding tests in `test/models/` or `test/viewmodels/`. If a change touches widgets (perk_row, perks_section, mastery_row, masteries_section, conditional_checkbox), also run `test/widgets/`.
