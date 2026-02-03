# Screen Documentation

## Create Character Screen

> **File**: `lib/ui/screens/create_character_screen.dart`

The character creation flow uses a full-page route with `Scaffold` and `AppBar`.

### Invocation Pattern

Use the static `show()` method:
```dart
await CreateCharacterScreen.show(context, charactersModel);
```

### Form Fields

1. **Name** - Text field with random name generator (faker)
2. **Class** - Opens `ClassSelectorScreen` for class selection
3. **Starting Level** - SfSlider (1-9)
4. **Previous Retirements / Prosperity Level** - Two numeric fields in a row
5. **Game Edition** - 3-way SegmentedButton (GH / GH2E / FH)

### Edition-Specific Behavior

The prosperity level field is disabled when Gloomhaven is selected (original GH uses level-based gold, not prosperity). See CLAUDE.md "Game Editions (GameEdition)" section for the gold/level formulas.

---

## Selector Screens

The app uses two full-page selector screens with consistent styling for searching and selecting items.

### Shared Components

**SearchSectionHeader** (`lib/ui/widgets/search_section_header.dart`):
A reusable section divider with optional icon:
```
─────────── [Icon] Title ───────────
```

### ClassSelectorScreen

> **File**: `lib/ui/screens/class_selector_screen.dart`

Full-page screen for selecting a player class during character creation.

**Layout:**
```
┌─────────────────────────────────────┐
│ [←]  [🔍 Search...]                 │  ← AppBar with search
├─────────────────────────────────────┤
│ [GH] [JotL] [FH] [MP] ...           │  ← Filter chips
│ Hide locked classes            [✓]  │  ← Toggle
├─────────────────────────────────────┤
│ ──────── Gloomhaven ────────        │  ← Section header
│ [Icon] Brute / Bruiser              │
│ [Icon] Tinkerer                     │
│ ──────── Jaws of the Lion ────────  │
│ ...                                 │
└─────────────────────────────────────┘
```

**Features:**
- Search filters by class name or variant names (e.g., "Bruiser" finds Brute)
- Category filter chips for game editions
- "Hide locked classes" toggle
- Section headers group classes by `ClassCategory`
- Variant selection dialog for multi-edition classes
- Custom class warning dialog for community content

**Invocation:**
```dart
final result = await ClassSelectorScreen.show(context);
if (result != null) {
  // result.playerClass - the PlayerClass
  // result.variant - the Variant (base, gloomhaven2E, etc.)
}
```

### EnhancementTypeSelectorScreen

> **File**: `lib/ui/screens/enhancement_type_selector_screen.dart`

Full-page screen for selecting enhancement types in the calculator.

**Layout:**
```
┌─────────────────────────────────────┐
│ [←]  [🔍 Search...]                 │  ← AppBar with search
├─────────────────────────────────────┤
│ ──────── [+1] +1 Stats ────────     │  ← Section header with icon
│ [MOVE] +1 Move                 30g  │
│ [ATK]  +1 Attack               50g  │
│ ──────── [◇] Elements ────────      │
│ [FIRE] Fire                    50g  │
│ ...                                 │
└─────────────────────────────────────┘
```

**Features:**
- Search filters by enhancement name
- Section headers with category icons group by `EnhancementCategory`
- Cost display shows base cost and discounted cost (with strikethrough)
- Edition-aware: only shows enhancements available in selected `GameEdition`
- Highlights currently selected enhancement

**Invocation:**
```dart
await EnhancementTypeSelector.show(
  context,
  currentSelection: model.enhancement,
  edition: model.edition,
  onSelected: model.enhancementSelected,
);
```

### Design Patterns

Both selectors follow these conventions:
- **AppBar search**: Search field in AppBar title with transparent background
- **SafeArea**: Bottom-only SafeArea for device navigation buttons
- **Static show()**: Invoked via static method returning `Future<T?>`
- **Section headers**: Use `SearchSectionHeader` widget for category grouping

---

## Settings Screen

> **File**: `lib/ui/screens/settings_screen.dart`

The settings screen uses a composition-based architecture with extracted section widgets for maintainability.

### Structure

```
lib/ui/
├── screens/
│   └── settings_screen.dart              # ~260 lines (composition + bottom sheet)
├── widgets/
│   └── settings/
│       ├── settings_section_header.dart  # Section title widget
│       ├── gameplay_settings_section.dart
│       ├── display_settings_section.dart
│       ├── backup_settings_section.dart
│       └── debug_settings_section.dart
├── dialogs/
│   ├── envelope_puzzle_dialog.dart       # Used by gameplay section
│   ├── backup_dialog.dart
│   └── restore_dialog.dart
└── utils/
    └── settings_helpers.dart             # Storage permission, URL launcher, device info
```

### Section Widgets

Each section is a StatelessWidget that receives an `onSettingsChanged` callback:

```dart
GameplaySettingsSection(onSettingsChanged: _onSettingsChanged)
DisplaySettingsSection(onSettingsChanged: _onSettingsChanged)
const BackupSettingsSection()  // No callback needed
const DebugSettingsSection()   // Only shown in kDebugMode
```

### SettingsSectionHeader

Reusable section header with themed styling:

```dart
SettingsSectionHeader(title: AppLocalizations.of(context).gameplay)
```

### Bottom Sheet

The settings screen includes a persistent bottom sheet with:
- Support links (Discord, Instagram, Email)
- Buy Me a Coffee button (Android US region only)
- Version number and changelog link
- License link
