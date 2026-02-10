# SharedPreferences Keys Reference

> **File**: `lib/shared_prefs.dart`

This document provides a comprehensive reference for all SharedPreferences keys used in the app, organized by category.

## Overview

The app uses a singleton `SharedPrefs` class with getter/setter properties backed by SharedPreferences. All keys are accessed via instance properties rather than string literals.

```dart
// Usage
final prefs = SharedPrefs();
await prefs.init();  // Call once at app startup

// Reading
bool isDark = prefs.darkTheme;

// Writing
prefs.darkTheme = true;
```

---

## App State & Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `clearOldPrefs` | bool | true | Flag for cleanup on legacy versions |
| `darkTheme` | bool | false | Dark mode toggle |
| `useDefaultFonts` | bool | false | Font preference (default vs custom) |

---

## Character Management

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `showRetiredCharacters` | bool | true | Show/hide retired characters in list |
| `customClasses` | bool | false | Enable custom class creation |
| `hideCustomClassesWarningMessage` | bool | false | Suppress custom class warning dialog |
| `{classCode}` | bool | false | Per-class unlock status (dynamic) |

### Per-Class Unlock Keys

Class unlock status uses the class code as the key:

```dart
// Accessing
bool isUnlocked = prefs.getPlayerClassIsUnlocked('br');  // Brute

// Setting
prefs.setPlayerClassIsUnlocked('br', true);
```

---

## Town State

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `activeWorldId` | String? | null | UUID of the currently active world |
| `activeCampaignId` | String? | null | UUID of the currently active campaign |
| `showAllCharacters` | bool | true | Show all characters vs filter by active campaign |

---

## Enhancement Calculator State

### Core State

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `gameEdition` | int | 0 | Selected game edition (enum index) |
| `enhancementType` | int | 0 | Selected enhancement type index |
| `enhancementsOnTargetAction` | int | 0 | Previous enhancement count (0-9) |
| `targetCardLvl` | int | 0 | Card level (0-indexed, displayed as 1-9) |

### Toggle States

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `disableMultiTargetsSwitch` | bool | false | Lock multi-target toggle |
| `multipleTargetsSelected` | bool | false | Multi-target mode active |
| `temporaryEnhancementMode` | bool | false | Temporary enhancement mode |

### Edition-Specific Toggles

| Key | Type | Default | Edition | Description |
|-----|------|---------|---------|-------------|
| `lostNonPersistent` | bool | false | GH2E/FH | Lost action modifier (×0.5) |
| `persistent` | bool | false | FH | Persistent modifier (×3) |
| `partyBoon` | bool | false | GH/GH2E | Party boon toggle |

---

## Enhancer Building System (Frosthaven Only)

The enhancer levels (Building 44) implement a **cascading lock system** where higher levels depend on lower levels.

### Keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enhancerLvl1` | bool | false | Level 1 (baseline enhancement access) |
| `enhancerLvl2` | bool | false | Level 2 (reduces enhancement costs) |
| `enhancerLvl3` | bool | false | Level 3 (reduces card level penalties) |
| `enhancerLvl4` | bool | false | Level 4 (reduces previous enhancement penalties) |

### Cascading Logic

**Upgrading (setting true)**: Automatically enables all lower levels

```dart
// Setting Level 3 = true
enhancerLvl3 = true;
// Cascade: Lvl2 → true, Lvl1 → true

// Setting Level 4 = true
enhancerLvl4 = true;
// Cascade: Lvl3 → true, Lvl2 → true, Lvl1 → true
```

**Downgrading (setting false)**: Automatically disables all higher levels

```dart
// Setting Level 2 = false
enhancerLvl2 = false;
// Cascade: Lvl3 → false, Lvl4 → false

// Setting Level 1 = false
enhancerLvl1 = false;
// Cascade: Lvl2 → false, Lvl3 → false, Lvl4 → false
```

### Implementation Detail

```dart
set enhancerLvl2(bool value) {
  _prefs.setBool('enhancerLvl2', value);
  if (value) {
    // Upgrading: enable lower level
    enhancerLvl1 = true;
  } else {
    // Downgrading: disable higher levels
    enhancerLvl3 = false;
    enhancerLvl4 = false;
  }
}
```

This ensures users can only have contiguous levels (can't have L3 without L1-L2).

---

## Localization & Regional Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `isUSRegion` | bool | false | US vs international (affects some UI) |
| `hailsDiscount` | bool | false | Hail's House discount modifier |

---

## UI Navigation & State

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `initialPage` | int | 0 | Home screen tab on app launch |
| `generalExpanded` | bool | true | General section expansion |
| `personalQuestExpanded` | bool | false | Personal Quest section expansion |

---

## Envelope Unlocks

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `envelopeX` | bool | false | Envelope X (Bladeswarm) unlocked |
| `envelopeV` | bool | false | Envelope V (Artificer) unlocked |

---

## Backup Management

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `backup` | String | '' | JSON backup string of database |

Used by `DatabaseHelper.generateBackup()` and `restoreBackup(String)`.

---

## Update Dialog Flags

One-time flags to show update dialogs on first launch after update.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `showUpdate440Dialog` | bool | true | Show v4.4.0 update dialog |

---

## Element Tracker State

Element states for the Gloomhaven 2E+ element tracker sheet.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `elementEarthState` | int | 0 | Earth element state |
| `elementFireState` | int | 0 | Fire element state |
| `elementIceState` | int | 0 | Ice element state |
| `elementLightState` | int | 0 | Light element state |
| `elementDarkState` | int | 0 | Dark element state |
| `elementAirState` | int | 0 | Air element state |

### State Values

| Value | State | Visual |
|-------|-------|--------|
| 0 | Gone | Grayed out |
| 1 | Strong | Fully lit/glowing |
| 2 | Waning | Fading/dimmed |

---

## Game Edition Migration

The `gameEdition` getter includes backward-compatible migration from a legacy boolean key.

### Migration Logic

```dart
GameEdition get gameEdition {
  // Check new key first
  int? editionIndex = _prefs.getInt('gameEdition');
  if (editionIndex != null && editionIndex < GameEdition.values.length) {
    return GameEdition.values[editionIndex];
  }

  // Fallback to legacy key
  bool? legacyGloomhavenMode = _prefs.getBool('gloomhavenMode');
  if (legacyGloomhavenMode != null) {
    GameEdition edition = legacyGloomhavenMode
        ? GameEdition.gloomhaven
        : GameEdition.frosthaven;

    // Migrate and cleanup
    gameEdition = edition;
    _prefs.remove('gloomhavenMode');
    return edition;
  }

  // Default
  return GameEdition.gloomhaven;
}
```

This ensures one-time automatic migration for users upgrading from older app versions.

---

## Utility Methods

### Public Methods

| Method | Description |
|--------|-------------|
| `init()` | Async initialization (call in main.dart) |
| `remove(String key)` | Delete single preference |
| `removeAll()` | Clear all preferences |
| `getPlayerClassIsUnlocked(String classCode)` | Query per-class unlock |
| `setPlayerClassIsUnlocked(String classCode, bool value)` | Set per-class unlock |

### Example Usage

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  runApp(MyApp());
}

// In widgets
final prefs = SharedPrefs();

// Check enhancement calculator state
if (prefs.temporaryEnhancementMode) {
  // Apply temporary enhancement discount
}

// Toggle setting
prefs.darkTheme = !prefs.darkTheme;

// Check class unlock
if (prefs.getPlayerClassIsUnlocked(ClassCodes.sunkeeper)) {
  // Show Sunkeeper in class list
}
```

---

## Backup Integration

SharedPreferences data is included as an optional third element in the JSON backup file, alongside the SQLite database tables and data.

### Backup Format

```json
[tableNames, tableData, { "settings": {...}, "calculator": {...}, "enhancerLevels": {...}, "classUnlocks": {...}, "town": {...} }]
```

Old backups (2 elements) are fully supported — the third element is simply absent and SharedPrefs are left unchanged on restore.

### Included Keys (by category)

| Category | Keys |
|----------|------|
| `settings` | darkTheme, useDefaultFonts, primaryClassColor, showRetiredCharacters, showAllCharacters, customClasses, hideCustomClassesWarningMessage, envelopeX, envelopeV |
| `calculator` | gameEdition, enhancementType, enhancementsOnTargetAction, targetCardLvl, disableMultiTargetsSwitch, multipleTargetsSelected, temporaryEnhancementMode, partyBoon, lostNonPersistent, persistent, hailsDiscount |
| `enhancerLevels` | enhancerLvl1, enhancerLvl2, enhancerLvl3, enhancerLvl4 |
| `classUnlocks` | Dynamic keys (class codes) for locked classes only |
| `town` | activeWorldId, activeCampaignId |

### Excluded Keys

| Key | Reason |
|-----|--------|
| `clearOldPrefs` | Legacy cleanup flag, not user state |
| `initialPage` | Transient navigation state |
| `generalExpanded` | Transient UI state |
| `personalQuestExpanded` | Transient UI state |
| `showUpdate*Dialog` | One-time dialog flags |
| `isUSRegion` | Device-specific locale detection |
| `gloomhavenMode` | Legacy key (migrated to `gameEdition`) |
| `element*State` | Transient game session state |

### Enhancer Level Cascade Bypass

During import, enhancer levels are written directly via `_sharedPrefs.setBool()` instead of using the property setters. This bypasses the cascading logic (where setting lvl3=true auto-enables lvl1 and lvl2) because the backup data is already self-consistent.

### Methods

| Method | Description |
|--------|-------------|
| `exportForBackup()` | Returns categorized `Map<String, dynamic>` of all backed-up prefs |
| `importFromBackup(Map<String, dynamic>)` | Applies backup data; missing categories are skipped |

---

## Key Naming Conventions

- **Booleans**: Descriptive name (e.g., `darkTheme`, `showRetiredCharacters`)
- **Integers**: Descriptive name (e.g., `targetCardLvl`, `enhancementType`)
- **Enums**: Stored as int index (e.g., `gameEdition`)
- **Dynamic keys**: Use pattern (e.g., class codes for unlock status)
- **Legacy keys**: Migrated automatically (e.g., `gloomhavenMode` → `gameEdition`)
