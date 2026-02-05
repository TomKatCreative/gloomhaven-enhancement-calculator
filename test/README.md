# Test Suite

454 tests across 16 files covering models, viewmodels, and widgets.

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/models/enhancement_test.dart

# Run tests matching a name pattern
flutter test --name "EnhancementCalculatorModel"
```

## Directory Structure

```
test/
├── helpers/
│   ├── fake_database_helper.dart   # In-memory IDatabaseHelper implementation
│   ├── test_data.dart              # Factory methods for test fixtures
│   └── test_helpers.dart           # MockThemeProvider, wrapWithProviders(), etc.
├── models/
│   ├── calculation_step_test.dart  # CalculationStep data class
│   ├── character_mastery_test.dart # CharacterMastery model
│   ├── character_perk_test.dart    # CharacterPerk model
│   ├── character_test.dart         # Character model (level, XP, gold, retirement)
│   ├── enhancement_data_test.dart  # EnhancementData static list & availability
│   ├── enhancement_test.dart       # Enhancement cost logic & EnhancementCategory
│   └── game_edition_test.dart      # GameEdition enum flags & display names
├── viewmodels/
│   ├── characters_model_test.dart          # Character CRUD, perk/mastery state
│   └── enhancement_calculator_model_test.dart  # Calculator cost logic
└── widgets/
    ├── calculator_toggle_group_card_test.dart   # Toggle group card component
    ├── character_screen_test.dart               # Full character screen integration
    ├── cost_display_test.dart                   # Cost display component
    ├── enhancement_calculator_screen_test.dart  # Full calculator screen
    ├── mastery_widgets_test.dart                # MasteryRow & MasteriesSection
    ├── perk_widgets_test.dart                   # PerkRow & PerksSection
    └── retirement_widgets_test.dart             # RetirementSection
```

## Test Infrastructure

### SharedPreferences

Every test that reads app settings must initialize SharedPreferences before running. Flutter's `SharedPreferences.setMockInitialValues()` replaces the platform channel with an in-memory map:

```dart
SharedPreferences.setMockInitialValues({
  'gameEdition': GameEdition.gloomhaven.index,
  'showRetiredCharacters': true,
});
await SharedPrefs().init();
```

The helper `setupSharedPreferences()` in `test_helpers.dart` handles common defaults. Calculator tests use their own `_setupPrefs()` helper to set edition-specific keys (enhancer levels, party boon, etc.).

### FakeDatabaseHelper

`FakeDatabaseHelper` is an in-memory implementation of `IDatabaseHelper` that replaces SQLite for testing. It provides:

- **In-memory storage** for characters, perks, and masteries
- **Call tracking** via `updateCalls`, `deleteCalls`, `perkUpdateCalls`, `masteryUpdateCalls`
- **Auto-generation** of perk/mastery definitions from `PerksRepository`/`MasteriesRepository` on `insertCharacter()`

Key behavior: When you insert a character, `FakeDatabaseHelper` automatically generates `CharacterPerk` and `CharacterMastery` records matching the real database behavior. To prevent this (e.g., when providing custom perk data), set `fakeDb.perksData = []` and `fakeDb.masteriesData = []` before inserting.

### TestData

`TestData` in `test_data.dart` provides factory methods for creating test fixtures:

- `TestData.createCharacter()` - character with sensible defaults
- `TestData.createPerk()` / `createPerkList()` - perk definitions
- `TestData.createMastery()` / `createMasteryList()` - mastery definitions
- `TestData.createCharacterPerksForPerks()` - join records linking characters to perks

All test UUIDs use the `test-` prefix for easy identification.

### MockThemeProvider

`MockThemeProvider` extends `ThemeProvider` with tracking for `updateSeedColor()` calls. It avoids real SharedPreferences writes in its `updateSeedColor` override.

### wrapWithProviders()

For widget tests that need Provider context, `wrapWithProviders()` wraps a widget in `MultiProvider` with `ThemeProvider` and `CharactersModel`:

```dart
await tester.pumpWidget(
  wrapWithProviders(
    charactersModel: model,
    withLocalization: true,
    themeData: ThemeData(
      dividerTheme: const DividerThemeData(color: Colors.grey),
    ),
    child: MyWidget(),
  ),
);
```

## Known Limitations

### SVG Assets Do Not Render in Tests

The app uses `ThemedSvg` (backed by `flutter_svg`) for icons like LOSS, PERSISTENT, MOVE, ATTACK, etc. These widgets call `SvgPicture.asset()` which requires actual SVG files on disk. In the test environment, **SVG assets are not available**, causing the widget subtree to fail silently.

This affects:

- **GH2E and Frosthaven calculator screen tests**: The lost action and persistent toggles use `ThemedSvg` for their title icons. When these toggles fail to render, any widgets below them in the scroll view (e.g., Discounts section) also don't appear.
- **Perk and mastery description text**: Perk descriptions contain inline SVG icons (e.g., `+1 ATTACK`). The `TestData` factories use SVG-safe text (no uppercase asset keywords) to avoid render failures.

**Workaround**: For features that depend on SVG rendering, tests verify behavior at the **model level** rather than through widget assertions:

```dart
// Instead of rendering the GH2E screen and finding 'Scenario 114 reward':
testWidgets('Party Boon configured for GH2E via model', (tester) async {
  await _setupPrefsOnly(edition: GameEdition.gloomhaven2e);
  expect(GameEdition.gloomhaven2e.supportsPartyBoon, isTrue);
});
```

The Gloomhaven (original) edition works for full widget rendering tests because it doesn't render lost/persistent SVG toggles.

### DividerThemeData Required

Widgets that use `GHCDivider` access `Theme.of(context).dividerTheme.color!`. A bare `MaterialApp()` doesn't provide this, causing a null assertion failure. Always include `DividerThemeData` in the test theme:

```dart
MaterialApp(
  theme: ThemeData(
    dividerTheme: const DividerThemeData(color: Colors.grey),
  ),
  // ...
)
```

### Finder Gotchas

- `find.byIcon(Icons.something)` finds the `Icon` widget, not `IconButton`. To check if a button is enabled/disabled, use `find.byType(IconButton)` and inspect `onPressed`.
- `find.byType(TextField)` matches both `TextField` and the internal `TextField` inside `TextFormField`. Filter by `keyboardType` or other properties to target a specific field.
- `scrollUntilVisible` throws "Too many elements" when multiple `Scrollable` widgets exist (e.g., inside `ExpansionTile`). Use `tester.ensureVisible(finder)` instead.
- `ensureVisible` throws `Bad state: No element` when the widget isn't in the tree at all (not just off-screen). Only use it for widgets you know exist but may be scrolled out of view.

## What's Tested

### Models (6 files)

| File | What it covers |
|------|----------------|
| `character_test.dart` | Constructor defaults, `level()` static method, XP thresholds, gold formulas per edition, retirement state |
| `character_perk_test.dart` | Constructor, `fromMap()` parsing, `isSelected` boolean mapping |
| `character_mastery_test.dart` | Constructor and field mapping |
| `game_edition_test.dart` | All 6 boolean flags (`supportsPartyBoon`, `hasLostModifier`, `hasPersistentModifier`, `hasEnhancerLevels`, `multiTargetAppliesToAll`) across all 3 editions, plus `displayName` |
| `enhancement_test.dart` | `cost(edition:)` returns correct cost per edition, `fhCost` fallback to `ghCost`, specific enhancement costs from `EnhancementData`, `EnhancementCategory.sectionTitle` and `sectionAssetKey` |
| `enhancement_data_test.dart` | Category counts, `isAvailableInEdition` (Disarm GH-only, Ward GH2E/FH-only), hex cost progression, all enhancements have `assetKey` |
| `calculation_step_test.dart` | Constructor, nullable `formula`/`modifier` fields, negative values |

### ViewModels (2 files)

| File | What it covers |
|------|----------------|
| `characters_model_test.dart` | Character CRUD, loading, selection, perk toggling, mastery toggling, checkmarks, retirement, theme sync, retired character filtering |
| `enhancement_calculator_model_test.dart` | Base cost, multi-target multiplier (edition-specific eligibility), lost modifier (halving), persistent modifier (tripling), flat discounts (Enhancer L2, Hail's), card level penalty (with Party Boon/Enhancer L3), previous enhancements penalty (with temp mode/Enhancer L4), end-to-end `calculateCost()`, `enhancementSelected()` side effects, `gameVersionToggled()`, `resetCost()`, `getCalculationBreakdown()` steps, `enhancerLvl*Applies` getters |

### Widgets (8 files)

| File | What it covers |
|------|----------------|
| `retirement_widgets_test.dart` | RetirementSection visibility, retire/unretire buttons, confirmation dialog |
| `perk_widgets_test.dart` | PerkRow rendering, checkbox toggling, grouped perks, PerksSection list, rebuild on state change |
| `mastery_widgets_test.dart` | MasteryRow rendering, checkbox toggling, MasteriesSection visibility by class |
| `character_screen_test.dart` | Full screen integration: section headers, XP/gold/checkmark inputs, perk and mastery sections, retired character disabled state |
| `cost_display_test.dart` | `CostDisplayConfig` logic (`hasDiscount`, `displayCost`), rendering base cost, strikethrough + discounted cost, marker text |
| `calculator_toggle_group_card_test.dart` | Toggle item rendering, dividers, switch state, disabled state, `onChanged`/`onTap` callbacks, custom trailing widget, info button enabled/disabled |
| `enhancement_calculator_screen_test.dart` | Section headers, info button state, card level label, previous enhancements segmented button, modifier toggle visibility per edition, discount toggle visibility per edition, cost chip appearance, cost recalculation on toggle |
