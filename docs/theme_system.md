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
- **`ColorUtils.ensureTextContrast()`** - Calculates and adjusts colors for proper contrast
- **`theme.contrastedPrimary`** - Pre-calculated contrasted primary color available throughout the app
- **Theme extension** - Contrast calculated once at theme build time for performance

**Where contrast is applied:**
- TextButton foreground color (all buttons app-wide)
- Bottom navigation bar selected items
- Dialog action buttons
- Section headers and primary-colored text
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
    color: ColorUtils.ensureTextContrast(
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

3. **Colors used**: Uses `surfaceContainer` from the cached theme to match the bottom navigation bar:
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
