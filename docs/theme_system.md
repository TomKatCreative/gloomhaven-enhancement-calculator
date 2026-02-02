# Theme System

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
