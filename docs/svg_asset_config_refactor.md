# SVG Asset Config Refactoring

This document describes the refactoring done to centralize all SVG asset definitions in `asset_config.dart`.

## Overview

Previously, SVG assets were loaded in various ways throughout the codebase:
- Direct `SvgPicture.asset()` calls with hardcoded paths
- Inconsistent theming approaches
- `PlayerClass.icon` field duplicating information already in `classCode`

This refactoring centralizes all SVG asset definitions in `asset_config.dart` and uses `ThemedSvg` widget everywhere for consistent theming.

## Changes Made

### 1. Removed `PlayerClass.icon` Field

**Files modified:**
- `lib/models/player_class.dart` - Removed `icon` field from class definition
- `lib/data/player_classes/player_class_constants.dart` - Removed all `icon:` lines (71 definitions)

The `classCode` field now serves double duty:
1. Unique identifier for the class
2. Key for looking up the class icon in `asset_config.dart`

### 2. Added Assets to `asset_config.dart`

**New sections added:**

```dart
// branding/
'BMC_BUTTON': AssetConfig('branding/bmc-button.svg'),

// ui/ (new entries)
'GOAL': AssetConfig('ui/goal.svg', themeMode: CurrentColorTheme()),
'TRAIT': AssetConfig('ui/trait.svg', themeMode: CurrentColorTheme()),

// class_icons/ (keyed by ClassCodes constants)
ClassCodes.brute: AssetConfig('class_icons/brute.svg', ...),
ClassCodes.tinkerer: AssetConfig('class_icons/tinkerer.svg', ...),
// ... all 71 classes

// resources/
'lumber': AssetConfig('resources/lumber.svg', themeMode: CurrentColorTheme()),
'metal': AssetConfig('resources/metal.svg', themeMode: CurrentColorTheme()),
// ... all 9 resources
```

### 3. Created `ClassIconSvg` Widget

**New file:** `lib/ui/widgets/class_icon_svg.dart`

A convenience widget for rendering player class icons:

```dart
ClassIconSvg(
  playerClass: myClass,
  width: 24,
  height: 24,
  color: Colors.red,  // Optional, defaults to primaryColor
)
```

Uses `playerClass.classCode` as the asset key automatically.

### 4. Updated Resource Icon References

**File modified:** `lib/data/player_classes/resources_repository.dart`

Changed from full paths to asset keys:
```dart
// Before
Resource('Lumber', 'images/resources/lumber.svg'),

// After
Resource('Lumber', 'lumber'),
```

### 5. Updated UI Files

| File | Changes |
|------|---------|
| `element_stack_icon.dart` | 6 `SvgPicture.asset` → `ThemedSvg` |
| `character_screen.dart` | 8 icon changes to `ThemedSvg` |
| `characters_screen.dart` | 1 background icon → `ClassIconSvg` |
| `class_selector_screen.dart` | 1 → `ClassIconSvg` |
| `create_character_screen.dart` | 1 → `ClassIconSvg` |
| `variant_selector_dialog.dart` | 1 → `ClassIconSvg` |
| `settings_screen.dart` | 1 BMC button → `ThemedSvg` |
| `resource_card.dart` | 1 → `ThemedSvg` |

## Benefits

1. **Single source of truth** - All SVG assets defined in `asset_config.dart`
2. **Consistent theming** - Every SVG goes through `ThemedSvg` or `ClassIconSvg`
3. **Type safety** - Class icons use `ClassCodes` constants as keys
4. **No redundant data** - `PlayerClass.icon` eliminated; `classCode` serves both purposes
5. **Easy maintenance** - Adding a new class requires: ClassCode + asset_config entry + PlayerClass definition

## How to Add a New Class Icon

1. Add the SVG file to `images/class_icons/`
2. Add a constant to `ClassCodes` in `character_constants.dart`:
   ```dart
   static const newClass = 'newclass';
   ```
3. Add entry to `asset_config.dart`:
   ```dart
   ClassCodes.newClass: AssetConfig(
     'class_icons/new_class.svg',
     themeMode: CurrentColorTheme(),
   ),
   ```
4. Add the `PlayerClass` definition in `player_class_constants.dart`

## How to Add a New Resource Icon

1. Add the SVG file to `images/resources/`
2. Add entry to `asset_config.dart`:
   ```dart
   'resourcename': AssetConfig(
     'resources/resource_name.svg',
     themeMode: CurrentColorTheme(),
   ),
   ```
3. Add to `ResourcesRepository.resources`:
   ```dart
   Resource('ResourceName', 'resourcename'),
   ```
