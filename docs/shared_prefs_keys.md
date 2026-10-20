# SharedPreferences Keys Reference

> **File**: `lib/shared_prefs.dart`

This document provides a comprehensive reference for all SharedPreferences keys used in the app, organized by category.

## Overview

The app uses a singleton `SharedPrefs` class with getter/setter properties backed by SharedPreferences. All keys are accessed via instance properties rather than string literals. The stored key strings are private constants in `_Keys` (named after the property; several values differ for historical reasons, e.g. `previousEnhancements` → `enhancementsOnTargetAction`) and never appear outside `shared_prefs.dart`.

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
| `activeCampaignId` | String? | null | UUID of the currently active campaign |
| `activePartyId` | String? | null | UUID of the currently active party |
| `showAllCharacters` | bool | true | Reserved for the Town party filter; not currently read. Still included in backups |

---

## Enhancement Calculator State

### Core State

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `gameEdition` | int | 0 | Selected game edition (enum index) |
| `enhancementKey` | String? | null | Selected enhancement as `Enhancement.key` (`'<category>:<name>'`, e.g. `charPlusOne:Move`) |
| `enhancementType` | int? | null | **Legacy.** Selected enhancement as a list index (0 = no selection). Read once, migrated to `enhancementKey`, then removed |
| `enhancementsOnTargetAction` | int | 0 | Previous enhancement count (0-3) |
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

### Level Rule

The `SharedPrefs` setters are plain writes. `EnhancementCalculatorModel._setEnhancerLevel` keeps the levels contiguous (no L3 without L1–L2) and writes all four keys:

- **Turning a level on** turns on every lower level (L3 on → L1, L2 on). Higher levels are unchanged.
- **Turning a level off** turns off every higher level (L2 off → L3, L4 off). Lower levels are unchanged.

The enhancer dialog only toggles L2–L4. `enhancerLvl1` is written on every L2–L4 toggle, so it stays in backups. The untouched levels are read from SharedPrefs, not the model cache, so a restore that skipped `reloadFromPrefs()` is not overwritten by the next toggle.

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
| `initialPage` | int | `kCharactersPageIndex` | Home screen tab on app launch, stored as a raw page index |
| `currentCharacterIndex` | int | 0 | Selected character page index |
| `generalExpanded` | bool | true | General section expansion |
| `questAndNotesExpanded` | bool | true | Quest & Notes section expansion |
| `perksAndMasteriesExpanded` | bool | true | Perks & Masteries section expansion |
| `townDetailsExpanded` | bool | true | Town details section expansion |
| `partyDetailsExpanded` | bool | true | Party details section expansion |

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
| `showUpdate450Dialog` | bool | true | Show v4.5.0 update dialog |

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
| `clearEnhancementSelection()` | Remove `enhancementKey` and the legacy `enhancementType` |
| `resetCalculatorInputs()` | Remove the per-card calculator inputs (card level, previous enhancements, selection, both multi-target keys, lost, persistent) for `resetCost()`; edition, party boon, temporary mode, Hail's discount and enhancer levels are kept |
| `removeAll()` | Clear all preferences |
| `getPlayerClassIsUnlocked(String classCode)` | Query per-class unlock |
| `setPlayerClassIsUnlocked(String classCode, bool value)` | Set per-class unlock |

### Example Usage

```dart
// In main.dart — SharedPrefs().init() is awaited inside runZonedGuarded with a
// try/catch, so a failure shows DiagnosticErrorView instead of a blank screen.
// See main.dart for the full startup guard.
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPrefs().init();
    runApp(const GloomhavenApp());
  }, (error, stack) => debugPrint('$error\n$stack'));
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
| `settings` | darkTheme, useDefaultFonts, primaryClassColor, showRetiredCharacters, showAllCharacters, hideCustomClassesWarningMessage, envelopeX, envelopeV |
| `calculator` | gameEdition, enhancementKey (legacy backups: enhancementType), enhancementsOnTargetAction, targetCardLvl, disableMultiTargetsSwitch, multipleTargetsSelected, temporaryEnhancementMode, partyBoon, lostNonPersistent, persistent, hailsDiscount |
| `enhancerLevels` | enhancerLvl1, enhancerLvl2, enhancerLvl3, enhancerLvl4 |
| `classUnlocks` | Dynamic keys (class codes) for locked classes only |
| `town` | activeCampaignId, activePartyId |

### Excluded Keys

| Key | Reason |
|-----|--------|
| `clearOldPrefs` | Legacy cleanup flag, not user state |
| `initialPage` | Transient navigation state |
| `generalExpanded` | Transient UI state |
| `questAndNotesExpanded` | Transient UI state |
| `perksAndMasteriesExpanded` | Transient UI state |
| `townDetailsExpanded` | Transient UI state |
| `partyDetailsExpanded` | Transient UI state |
| `currentCharacterIndex` | Transient navigation state |
| `showUpdate*Dialog` | One-time dialog flags |
| `isUSRegion` | Device-specific locale detection |
| `gloomhavenMode` | Legacy key (migrated to `gameEdition`) |

### Enhancer Levels on Import

Import writes enhancer levels exactly as stored. It does not go through the calculator model, so the level rule (where turning on lvl3 also turns on lvl1 and lvl2) is not applied, because the backup data is already self-consistent.

### Methods

| Method | Description |
|--------|-------------|
| `exportForBackup()` | Returns categorized `Map<String, dynamic>` of all backed-up prefs |
| `BackupPrefs.parse(Map<String, dynamic>)` | Validates backup prefs without writing; throws `BackupException` on a wrong-typed value or a category that isn't a map |
| `applyBackupPrefs(BackupPrefs)` | Writes validated prefs |
| `importFromBackup(Map<String, dynamic>)` | `parse` then `apply`; missing categories are skipped |

### Import Validation

`restoreBackup` calls `BackupPrefs.parse` before touching the database and applies the result only after the database transaction commits, so a bad settings value rejects the whole restore.

- A wrong-typed value rejects the import.
- Unknown keys are ignored, including `classUnlocks` keys that aren't locked classes this version knows.
- Out-of-range `gameEdition`, `targetCardLvl` (0–8) and `enhancementsOnTargetAction` (0–3) values are skipped and keep their current value.

---

## Key Naming Conventions

- **Booleans**: Descriptive name (e.g., `darkTheme`, `showRetiredCharacters`)
- **Integers**: Descriptive name (e.g., `targetCardLvl`, `enhancementType`)
- **Enums**: Stored as int index (e.g., `gameEdition`)
- **Dynamic keys**: Use pattern (e.g., class codes for unlock status)
- **Legacy keys**: Migrated automatically (e.g., `gloomhavenMode` → `gameEdition`)
