# Theme System

## Typography (Scaled M3 Type Scale)

The app uses a scaled version of Google's Material 3 type scale. Display and headline sizes use M3 defaults, while body/title/label sizes are scaled up (~1.3x) for better readability.

### Type Scale Reference

| Style | Size | M3 Default | Usage |
|-------|------|------------|-------|
| `displayLarge` | 59 | 57 | Hero text, splash screens |
| `displayMedium` | 47 | 45 | Character names (PirataOne in custom mode) |
| `displaySmall` | 38 | 36 | Major headers |
| `headlineLarge` | 34 | 32 | Screen titles |
| `headlineMedium` | 30 | 28 | Dialog titles, section headers |
| `headlineSmall` | 26 | 24 | Card titles, subsection headers |
| `titleLarge` | 24 | 22 | List item titles, prominent labels |
| `titleMedium` | 20 | 16 | Form field labels, tab labels |
| `titleSmall` | 18 | 14 | Metadata labels, timestamps |
| `bodyLarge` | 24 | 16 | Emphasized body text |
| `bodyMedium` | 22 | 14 | **Default body text** |
| `bodySmall` | 20 | 12 | Captions, helper text |
| `labelLarge` | 18 | 14 | Button text, prominent labels |
| `labelMedium` | 16 | 12 | Navigation labels, chips |
| `labelSmall` | 14 | 11 | Badges, tiny annotations |

Reference: https://m3.material.io/styles/typography/type-scale-tokens

### Font Families

The app supports two font modes (toggled in Settings):

| Mode | displayMedium | All Other Styles |
|------|---------------|------------------|
| Default | Inter | Inter |
| Custom | PirataOne (with letterSpacing: 1.5) | Nyala |

In custom mode, only `displayMedium` uses the decorative PirataOne font (for character names). All other text uses Nyala for readability.

### Usage Guidelines

**Always use TextTheme styles** instead of hardcoding font sizes:

```dart
// ✅ Correct - uses theme
Text('Hello', style: theme.textTheme.bodyMedium)
Text('Title', style: theme.textTheme.headlineMedium)

// ❌ Wrong - hardcoded size
Text('Hello', style: TextStyle(fontSize: 14))
```

**For cases without BuildContext** (e.g., `game_text_parser.dart`), use the constants from `constants.dart`:

```dart
// Only when theme is unavailable
TextStyle(fontSize: fontSizeBodyMedium, fontFamily: pirataOne)
```

### Key Files

- `lib/theme/app_theme_builder.dart` - TextTheme definitions for both font modes
- `lib/data/constants.dart` - Font size constants (for edge cases only)

---

## Color Contrast for Accessibility

The app uses a centralized contrast system to ensure text and UI elements meet WCAG AA accessibility standards (4.5:1 contrast ratio).

**Implementation:**
- **`ColorUtils.ensureContrast()`** - Calculates and adjusts colors for proper contrast
- **`theme.contrastedPrimary`** - Pre-calculated contrasted primary color available throughout the app
- **Theme extension** - Contrast calculated once at theme build time for performance

**Where contrast is applied:**
- TextButton foreground color (all buttons app-wide)
- Bottom navigation bar selected items
- Dialog action buttons
- Section headers and primary-colored text
- Create button in CreateCharacterScreen
- Any text using `theme.contrastedPrimary`

**Adding contrast to new components:**
```dart
// Option 1: Use theme extension (recommended)
Text(
  'My Text',
  style: TextStyle(color: Theme.of(context).contrastedPrimary),
)

// Option 2: Calculate manually (for one-off cases)
Text(
  'My Text',
  style: TextStyle(
    color: ColorUtils.ensureContrast(
      primaryColor,
      backgroundColor,
    ),
  ),
)
```

**Key files:**
- `lib/utils/color_utils.dart` - Contrast calculation utilities
- `lib/theme/theme_extensions.dart` - `AppThemeExtension` with `contrastedPrimary`
- `lib/theme/app_theme_builder.dart` - Theme-level contrast application

---

## ColorScheme & Component Themes

The app's `ColorScheme` maps `secondaryContainer`/`onSecondaryContainer` to match `primaryContainer`/`onPrimaryContainer`. This ensures M3 components that use secondary container colors (FilterChip selected state, SegmentedButton selected state) automatically get correct contrast with the character's primary color — no per-widget overrides needed.

### Component Theme Overrides

| Component | Override | Reason |
|-----------|----------|--------|
| `ChipThemeData` | `showCheckmark: false` | Hides checkmark on selected FilterChips |
| `PopupMenuThemeData` | `labelTextStyle: bodySmall` | Consistent popup menu text size |
| `SegmentedButtonThemeData` | None (M3 defaults) | Uses `secondaryContainer`/`onSecondaryContainer` from colorScheme |

---

## Scroll-Aware Tint

Pinned headers throughout the app use an M3-inspired scroll-aware tint to indicate when content is scrolling behind them. The tint is an 8% primary color overlay on the surface color.

### Implementation

**`AppBarUtils.getTintedBackground(colorScheme)`** (`lib/ui/widgets/app_bar_utils.dart`) returns `Color.alphaBlend(primary.withAlpha(0.08), surface)`. This is the single source of truth for the tinted background color.

### Where It's Applied

| Component | File | Behavior |
|-----------|------|----------|
| Character header (`CharacterHeaderDelegate`) | `character_header_delegates.dart` | Transparent when expanded; tints when content scrolls behind pinned header |
| Chip nav bar (`SectionNavBarDelegate`) | `character_header_delegates.dart` | Same — transparent when header expanding, tints when content overlaps |
| Calculator page app bar | `enhancement_calculator_screen.dart` | Tints when `CustomScrollView` content scrolls behind pinned app bar |
| Main app bar (`GHCAnimatedAppBar`) | `ghc_animated_app_bar.dart` | Tints in sync with character header on characters page; title flips vertically on page transitions |

### Animation Pattern

All tinted headers use the same `TweenAnimationBuilder<double>` pattern:

```dart
TweenAnimationBuilder<double>(
  key: ValueKey(character.uuid),  // resets on character switch
  tween: Tween<double>(end: overlapsContent ? 1.0 : 0.0),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  builder: (context, tintProgress, child) {
    final tinted = AppBarUtils.getTintedBackground(colorScheme);
    final color = Color.lerp(surface, tinted, tintProgress)!;
    // ...
  },
)
```

### Edit Mode Behavior

- **View mode** (and retired edit mode): Background opacity follows scroll position directly (transparent as long as header is expanding). Tint color fades in/out smoothly via the 300ms animation.
- **Edit mode** (non-retired): Always opaque. Tint animates in/out based on `overlapsContent` only.

---

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

3. **Colors used**: Uses `surfaceContainer` from the cached theme to match the navigation bar:
   ```dart
   final navBarColor = _config.useDarkMode
       ? _cachedDarkTheme!.colorScheme.surfaceContainer
       : _cachedLightTheme!.colorScheme.surfaceContainer;
   ```

4. **Icon brightness**: Set `systemNavigationBarIconBrightness` to ensure buttons are visible:
   - Dark mode: `Brightness.light` (white icons on dark background)
   - Light mode: `Brightness.dark` (dark icons on light background)

### Common Pitfalls

- **Don't set system UI in `main.dart`**: It will be overridden by Flutter before ThemeProvider initializes
- **Don't use transparent nav bar** unless you want app content to show through (requires edge-to-edge mode)
- **Always call `SystemChrome.setSystemUIOverlayStyle()`**: Creating a `SystemUiOverlayStyle` object without passing it to this method does nothing
