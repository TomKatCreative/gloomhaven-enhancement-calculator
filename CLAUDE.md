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
│   │   └── calculator/      # Enhancement calculator card components
│   └── dialogs/             # Modal dialogs
├── theme/                   # Theme system (ThemeProvider, extensions)
├── utils/                   # Helpers, text parsing
└── shared_prefs.dart        # SharedPreferences wrapper (singleton)
```

### Data Persistence

- **SQLite** (`sqflite`) - Characters, perks, masteries (schema version 13)
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
1. `PlayerClass` - Static class definition (race, name, icon, perks)
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
- Screens: `*_screen.dart` or `*_page.dart`
- Widgets: Descriptive names (e.g., `perk_row.dart`, `resource_card.dart`)

### Widget Patterns
- Screens use `context.watch<Model>()` for reactive rebuilds
- One-time reads use `context.read<Model>()`
- Complex widgets are StatefulWidget with local controllers

### Spacing & Padding
Use constants from `lib/data/constants.dart` instead of hardcoded values:
- `smallPadding` (4) - use instead of `4`
- `mediumPadding` (8) - use instead of `8`
- `largePadding` (16) - use instead of `16`

### TextField Borders
TextField border styling is centralized in `InputDecorationTheme` (in `lib/theme/app_theme_builder.dart`). All TextFields automatically use `OutlineInputBorder()` unless explicitly overridden. Don't add `border: OutlineInputBorder()` to individual TextField decorations.

### Database
- UUID for character IDs (with legacy migration for old int IDs)
- Migrations in `database_migrations.dart` - append new migrations, don't modify old ones

## Known Technical Debt

1. **Large data files** - `perks_repository.dart` (3000+ lines) should be split by edition
2. **Oversized screens** - `settings_screen.dart` (1000+ lines) needs extraction
3. **Legacy files** - `*_legacy.dart` files exist for backward compatibility
4. **No tests** - Test suite needed for models and viewmodels

## Assets

- Class icons: `images/class_icons/*.svg`
- Attack modifiers: `images/attack_modifiers/`
- Custom fonts: PirataOne (headers), HighTower, Nyala, Roboto, OpenSans, Inter

## SVG Theming

The app uses `flutter_svg` for rendering SVG icons. Icons adapt to light/dark themes automatically.

### ThemedSvg Widget (`lib/utils/themed_svg.dart`)

Use the `ThemedSvg` widget to render theme-aware SVG icons:

```dart
// Basic usage - just pass an asset key
ThemedSvg(assetKey: 'MOVE', width: 24)

// With custom color override
ThemedSvg(assetKey: 'ATTACK', width: 24, color: Colors.red)

// With +1 overlay badge (for enhancements)
ThemedSvgWithPlusOne(assetKey: 'MOVE', width: 24)
```

The widget automatically:
- Looks up the asset key in `asset_config.dart` to get the file path
- Detects light/dark theme from `Theme.of(context)`
- Applies appropriate coloring based on the asset's configuration

### Asset Configuration (`lib/utils/asset_config.dart`)

All SVG assets are configured here with their file paths and theming behavior:

```dart
// SVG uses fill="currentColor" - only those parts change with theme
'MOVE': AssetConfig('move.svg', themeMode: CurrentColorTheme())

// No theming needed - renders as-is in both themes
'hex': AssetConfig('hex.svg')
```

### Adding a New SVG Icon

1. Add the SVG file to `images/`
2. Edit the SVG to use `currentColor` for theme-aware parts:
   - `fill="currentColor"` or `style="fill:currentColor"`
   - `stroke="currentColor"` for strokes
3. Add an entry in `asset_config.dart`:
   ```dart
   'MY_ICON': AssetConfig('my_icon.svg', themeMode: CurrentColorTheme())
   ```
4. Use it with `ThemedSvg(assetKey: 'MY_ICON', width: 24)`

### How It Works

- **`themeMode: CurrentColorTheme()`**: Uses `SvgTheme` so only SVG elements with `fill="currentColor"` change color. Other colors in the SVG are preserved. This is ideal for multi-color icons where only some parts should adapt to the theme.

## Android System Navigation Bar

The Android system navigation bar (soft buttons at bottom of screen) color is managed by `ThemeProvider`.

### Key Implementation Details

1. **Single source of truth**: `ThemeProvider._updateSystemUI()` is the only place that sets the navigation bar style. Don't duplicate this in `main.dart` or elsewhere.

2. **Post-frame callback required**: The system UI style must be set after the first frame renders, otherwise Flutter may override it during initialization:
   ```dart
   // In ThemeProvider constructor:
   SchedulerBinding.instance.addPostFrameCallback((_) {
     _updateSystemUI();
   });
   ```

3. **Colors used**:
   - Dark mode: `AppThemeBuilder.darkSurface` (0xff1c1b1f)
   - Light mode: `Colors.white`

4. **Icon brightness**: Set `systemNavigationBarIconBrightness` to ensure buttons are visible:
   - Dark mode: `Brightness.light` (white icons on dark background)
   - Light mode: `Brightness.dark` (dark icons on light background)

### Common Pitfalls

- **Don't set system UI in `main.dart`**: It will be overridden by Flutter before ThemeProvider initializes
- **Don't use transparent nav bar** unless you want app content to show through (requires edge-to-edge mode)
- **Always call `SystemChrome.setSystemUIOverlayStyle()`**: Creating a `SystemUiOverlayStyle` object without passing it to this method does nothing

## Localization (i18n)

The app uses Flutter's official `gen_l10n` system for internationalization. Currently supports English (default) and Portuguese.

### Configuration

- **`l10n.yaml`** (project root) - Localization settings
- **`pubspec.yaml`** - Requires `flutter_localizations` dependency and `generate: true`

### Using Localized Strings

```dart
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

// In build methods:
Text(AppLocalizations.of(context).close)
Text(AppLocalizations.of(context).gold)

// With parameters:
Text(AppLocalizations.of(context).pocketItemsAllowed(count))
Text(AppLocalizations.of(context).savedTo(filePath))
```

### Adding New Strings

1. Add the string to `lib/l10n/app_en.arb` (English template):
   ```json
   "myNewString": "Hello world",
   ```

2. For strings with parameters, add metadata:
   ```json
   "greeting": "Hello {name}!",
   "@greeting": {
     "placeholders": {
       "name": { "type": "String" }
     }
   }
   ```

3. Add translation to `lib/l10n/app_pt.arb`:
   ```json
   "myNewString": "Olá mundo",
   "greeting": "Olá {name}!"
   ```

4. Run `flutter pub get` or `flutter gen-l10n` to regenerate

### What's NOT Localized (By Design)

- **`strings.dart`** - Complex markdown content with inline icons (`{ATTACK}`, `{MOVE}`) used by `GameTextParser`. These are tightly coupled with icon rendering and should be localized in a future phase.
- **`perks_repository.dart`** - Perk descriptions with icon placeholders. Game-specific terminology that players recognize across languages.

### Adding a New Language

1. Create `lib/l10n/app_XX.arb` (where XX is the locale code)
2. Copy all keys from `app_en.arb` and translate values
3. Run `flutter pub get` - the language is automatically detected
4. For iOS: Add the language to Xcode project (Runner > Info > Localizations)

## Element Tracker Sheet (`lib/ui/widgets/element_tracker_sheet.dart`)

The Characters screen includes a draggable bottom sheet for tracking the 6 Gloomhaven elements (FIRE, ICE, AIR, EARTH, LIGHT, DARK). Each element cycles through states when tapped: gone → strong → waning → gone.

### Architecture

**Files involved:**
- `lib/ui/widgets/element_tracker_sheet.dart` - The draggable sheet with three expansion states
- `lib/ui/widgets/animated_element_icon.dart` - Animated element icons with glow effects
- `lib/ui/screens/characters_screen.dart` - Contains scrim overlay for full expansion
- `lib/viewmodels/characters_model.dart` - State for sheet expansion, collapse notifier

### Sheet States

The sheet has three snap positions:
- **Collapsed** (6.5%): Icons in a compact row, minimal state representation
- **Expanded** (18%): Icons in a spaced row, interactive with animations
- **Full Expanded** (85%): Icons in 2x3 grid with responsive spacing

### Element Icon States (`lib/ui/widgets/animated_element_icon.dart`)

**Static (collapsed sheet):**
- Gone: 30% opacity
- Strong: 100% opacity
- Waning: Bisected horizontally (top dim, bottom bright) with sharp line

**Animated (expanded sheet):**
- Gone: 30% opacity, no glow
- Strong: Element-specific animated glow effect
- Waning: Bisected with animated glow on bottom half

### Animation System (Config-Driven)

Element animations use a centralized configuration system via `ElementAnimationConfig`. All animation parameters are defined in config objects, keeping the rendering logic generic.

**Architecture:**
- 2-3 `AnimationController`s per element combined via `Listenable.merge`
- Controllers: base (slow), secondary (faster), optional tertiary (fastest - FIRE only)
- 250ms crossfade for all state transitions (hardcoded)
- Waning state derived from strong with multipliers (0.85 intensity, 0.6 size)

**Glow Layer Structure (all elements):**
1. Outer glow - BoxShadow, largest radius, lowest intensity
2. Middle glow - BoxShadow, medium radius
3. Inner core - RadialGradient, smallest, highest intensity
4. Icon - SVG on top

### ElementAnimationConfig Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `baseDuration` | Primary controller duration | 2000-3000ms |
| `secondaryDuration` | Secondary controller duration | 800-1800ms |
| `tertiaryDuration` | Optional third controller | null or ~800ms |
| `outerGlowColor` | Outer shadow color | Element-specific |
| `middleGlowColor` | Middle shadow color | Element-specific |
| `innerGradientColors` | 4-color gradient for core | Element-specific |
| `outerSizeOffset` | Added to baseSize for outer | 8-18 |
| `middleSizeOffset` | Added to baseSize for middle | 4-10 |
| `outerBlurRadius` | Base blur for outer glow | 12-28 |
| `middleBlurRadius` | Base blur for middle glow | 8-16 |
| `baseIntensity` | Minimum glow intensity | 0.25-0.7 |
| `intensityVariation` | How much intensity varies | 0.15-0.45 |
| `sizeVariation` | Max size pulse amount | 1.5-5 |
| `isThemeAware` | Use theme-dependent colors | false (AIR=true) |

### Animation Styles

Each style has unique mathematical behavior preserved in `_compute*Animation()` methods:

| Style | Character | Math Behavior |
|-------|-----------|---------------|
| `fire` | Breathing, warm | Eased sine waves, 3 layers combined |
| `ice` | Crystalline, sharp | Multi-freq (4x,7x,11x) with abs() |
| `air` | Flowing, gentle | Cosine undulation, minimal variation |
| `earth` | Tremor, crunchy | High-freq (11x,17x,23x) + threshold cracks |
| `light` | Steady, radiant | Smooth breathing |
| `dark` | Drifting, eerie | Horizontal cosine drift for cloud effect |

### Adding/Modifying Element Animations

**Stay within these bounds** - modifications should only adjust `ElementAnimationConfig` values:

1. Add/modify a factory constructor in `ElementAnimationConfig` (e.g., `ElementAnimationConfig.fire()`)
2. Update the `_configs` map if adding a new element
3. Adjust timing, colors, sizes, and intensity within the documented ranges

**Requires special consideration** (discuss before implementing):
- Adding a new animation style (new enum value + new `_compute*Animation()` method)
- Adding new config parameters beyond the existing ones
- Changing the 3-layer glow structure
- Modifying the 250ms crossfade duration
- Adding element-specific rendering logic in `_buildStrongGlow()` or `_buildWaningGlow()`

The goal is to keep all elements rendering through the same generic code paths, with only config values differentiating them.

### Crossfade Transitions

All elements use a shared fade controller (250ms) for smooth transitions:
- `_fadeController` handles: gone↔strong, strong↔waning, sheet expand/collapse
- `_buildFadeToGone()` handles fade-out to gone state specifically

### Key Implementation Details

1. **Responsive grid spacing**: In full-expanded mode, icon spacing adapts to screen width using 45% of remaining horizontal space (clamped 24-80px)

2. **Scrim overlay**: When fully expanded, a semi-transparent scrim blocks interaction with content behind. Tapping the scrim collapses to partially expanded.

3. **Collapse communication**: Uses `ValueNotifier<int>` pattern - `CharactersModel.collapseElementSheetNotifier` is incremented to trigger collapse from outside the sheet widget (e.g., when navigating away from the Characters screen).

4. **State persistence**: Element states are stored in SharedPreferences (`fireState`, `iceState`, etc.)

## Create Character Sheet (`lib/ui/dialogs/create_character_dialog.dart`)

The character creation flow uses a `DraggableScrollableSheet` modal bottom sheet.

### Invocation Pattern

Use the static `show()` method:
```dart
await CreateCharacterSheet.show(context, charactersModel);
```

### Form Fields

1. **Name** - Text field with random name generator (faker)
2. **Class** - Opens search delegate for class selection
3. **Starting Level** - SfSlider (1-9)
4. **Previous Retirements / Prosperity Level** - Two numeric fields in a row
5. **Game Edition** - 3-way SegmentedButton (GH / GH2E / FH)

### Edition-Specific Behavior

The prosperity level field is disabled when Gloomhaven is selected (original GH uses level-based gold, not prosperity). See "Game Editions (GameEdition)" section for the gold/level formulas.

## Expandable Cost Chip (`lib/ui/widgets/expandable_cost_chip.dart`)

The enhancement calculator displays a floating chip that shows the total cost and expands into a full breakdown card when tapped.

### Architecture

The widget uses a `Stack` with two layers:
1. **Scrim** - Semi-transparent overlay (50% black) when expanded, tapping collapses
2. **Expandable chip/card** - Morphs between collapsed chip and expanded card states

### States

**Collapsed (Chip)**:
- 48dp tall, 160dp wide pill shape
- Centered icon + cost with expand arrow on right
- Positioned 20dp from bottom (vertically centered with FAB)
- Background matches bottom navigation bar color

**Expanded (Card)**:
- 85% of available screen height
- Max width 468dp, horizontally centered
- Header with centered icon + cost, close button on right
- Scrollable breakdown list below divider
- Tapping anywhere on the card collapses it

### Animation

- 300ms duration with `easeOutCubic` (expand) / `easeInCubic` (collapse)
- Interpolates: width, height, border radius, elevation
- Scrim fades in/out with expansion
- Content switches at 50% animation progress

### Key Implementation Details

1. **FAB alignment**: Chip is positioned 20dp from bottom to vertically center-align with the 56dp FAB (which sits at 16dp offset)

2. **Scrim interaction**: The scrim uses `GestureDetector` to collapse on tap. Returns `SizedBox.shrink()` when fully collapsed to avoid blocking touches.

3. **Tap to close**: The expanded card is wrapped in a `GestureDetector` with `HitTestBehavior.opaque` so tapping anywhere (including empty space) closes it. The `ListView` still scrolls normally.

4. **FAB visibility**: Updates `EnhancementCalculatorModel.isSheetExpanded` when toggling, which the home screen uses to hide the FAB when expanded.

### Dimensions

```dart
// Chip (collapsed)
_chipHeight = 48.0
_chipWidth = 160.0
_chipBorderRadius = 24.0

// Card (expanded)
_cardTopRadius = 28.0
_cardBottomRadius = 24.0
_cardMaxWidth = 468.0
_cardExpandedFraction = 0.85  // of available height

// Positioning
_bottomOffset = 20.0
_horizontalPadding = 16.0
```

## Calculator Section Cards (`lib/ui/widgets/calculator/`)

The enhancement calculator uses a standardized card component system for consistent layout and styling across all calculator sections.

### File Structure

```
lib/ui/widgets/calculator/
├── calculator.dart                # Barrel export file
├── calculator_section_card.dart   # Main card component with layout variants
├── info_button_config.dart        # Configuration for info buttons
├── cost_display.dart              # Standardized cost chip with strikethrough
├── card_level_body.dart           # SfSlider for card level selection
├── previous_enhancements_body.dart # Segmented button (0-3)
└── enhancement_type_body.dart     # Dropdown selector
```

Note: Modifier toggles (Multi-target, Loss, Persistent) use the `toggle` layout variant directly in `enhancement_calculator_page.dart` rather than a separate body widget.

### CalculatorSectionCard

The main reusable card component with two layout variants:

**Standard Layout** (`CardLayoutVariant.standard`):
```
+--------------------------------------------------+
| [i] Title                                        |
|                                                  |
| [Body Widget - full width]                       |
|                                                  |
| [Cost Display Chip]                              |
+--------------------------------------------------+
```

**Toggle Layout** (`CardLayoutVariant.toggle`):
```
+--------------------------------------------------+
| [i]  Title                              [Toggle] |
|      Subtitle (optional)                         |
+--------------------------------------------------+
```

### Usage Example

```dart
// Standard card with slider body and cost display
CalculatorSectionCard(
  infoConfig: InfoButtonConfig.titleMessage(
    title: 'Card Level',
    message: richTextWidget,
  ),
  title: 'Card Level: 5',
  body: CardLevelBody(model: calculatorModel),
  costConfig: CostDisplayConfig(
    baseCost: 100,
    discountedCost: 75,  // Shows strikethrough when different
  ),
)

// Toggle card
CalculatorSectionCard(
  layout: CardLayoutVariant.toggle,
  infoConfig: InfoButtonConfig.titleMessage(
    title: 'Hail\'s Discount',
    message: richTextWidget,
  ),
  title: 'Hail\'s Discount',
  toggleValue: model.hailsDiscount,
  onToggleChanged: (value) => model.hailsDiscount = value,
)
```

### InfoButtonConfig

Two ways to configure info buttons:

```dart
// Option 1: Title + pre-built RichText message
InfoButtonConfig.titleMessage(
  title: 'Card Level',
  message: Strings.cardLevelInfoBody(context, darkTheme),
)

// Option 2: Auto-configure based on enhancement category
InfoButtonConfig.category(category: EnhancementCategory.posEffect)
```

### CostDisplay

Standardized cost chip with optional strikethrough for discounts:

```dart
CostDisplayConfig(
  baseCost: 100,
  discountedCost: 75,    // Optional - shows strikethrough when different
  marker: '†',           // Optional suffix (e.g., for temporary enhancements)
)
```

### SfSlider (Card Level)

The card level selector uses `syncfusion_flutter_sliders` package for a cleaner slider with built-in labels:

```dart
SfSlider(
  min: 1.0,
  max: 9.0,
  value: displayLevel,
  interval: 1,
  stepSize: 1,
  showLabels: true,
  activeColor: colorScheme.primary,
  onChanged: (value) => model.cardLevel = value.round() - 1,
)
```

### Adding a New Calculator Card

1. Create a body widget in `lib/ui/widgets/calculator/` if needed
2. Use `CalculatorSectionCard` with appropriate layout variant
3. Configure `InfoButtonConfig` for the info dialog
4. Add `CostDisplayConfig` if the section has associated costs

## CI/CD Pipeline

The project uses GitHub Actions to deploy Android app bundles to Google Play's internal test track.

### Triggering a Deploy

```bash
# Deploy using current pubspec.yaml version
gh workflow run deploy-internal.yml

# Deploy with a specific version name
gh workflow run deploy-internal.yml -f version_name=4.3.3
```

Or use the GitHub Actions web UI → Actions tab → "Deploy to Internal Track" → "Run workflow".

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

1. **Read before modifying** - Always read files before suggesting changes
2. **Check variants** - Many features branch based on `ClassCategory` or `Variant`
3. **SharedPrefs keys** - Settings stored in `shared_prefs.dart` - check existing keys before adding
4. **Database migrations** - New schema changes need migration code in `database_migrations.dart`
5. **Theme awareness** - Use `Theme.of(context)` and ThemeProvider for colors/styling
6. **SVG icons** - Use `ThemedSvg` widget with asset keys, not direct `SvgPicture` calls
7. **Localization** - Use `AppLocalizations.of(context).xxx` for UI strings, not hardcoded text. Add new strings to ARB files.
8. **User interaction** - When speaking with the developer who is working on this project, push back again their ideas if they aren't technically sound. Don't just do whatever they want - think about it in the context of the app and if you think there's a better way to do something, suggest it.
9. **Branching** - Always suggest starting new work from the `dev` branch, not `master`. Pushes to `dev` auto-deploy to internal testing.
10. **Responsive design** - UI must adapt to smaller screens (minimum ~5" phones). Avoid hardcoding pixel values for layout sizing. Use `MediaQuery`, `LayoutBuilder`, or relative sizing (percentages with minimum constraints) to ensure UI elements remain visible and usable on all screen sizes.
