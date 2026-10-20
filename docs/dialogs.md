# Reusable Dialog Components

> **Directory**: `lib/ui/dialogs/`

The app provides reusable dialog components for common interaction patterns. All dialogs use the centralized theme contrast system for accessibility.

## ConfirmationDialog

General-purpose confirmation dialog with customizable content and actions.

**Usage:**
```dart
final confirmed = await ConfirmationDialog.show(
  context: context,
  title: 'Delete Character?',  // Optional
  content: Text('This action cannot be undone.'),
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  showCancel: true,  // Default true
);

if (confirmed == true) {
  // User confirmed
}
```

**Features:**
- Optional title
- Scrollable content area (max width 468dp)
- Up to two action buttons with automatic contrast adjustment
- Static show() method returns `Future<bool?>`

## CustomClassWarningDialog

Specialized dialog for custom/community class warnings.

**Usage:**
```dart
final proceed = await CustomClassWarningDialog.show(context);
if (proceed == true) {
  // User accepted warning
}
```

**Features:**
- Returns `true` (Continue), `false` (Cancel) or `null` (dismissed)
- Discord server link for community content
- "Don't show again" checkbox (persisted to `SharedPrefs().hideCustomClassesWarningMessage`)
- Custom stateful behavior for checkbox management
- Fully localized (`customClasses`, `customClassesWarningBody`, `discordServer`, `dontShowAgain`, `cancel`, `continue_`)
- Shown from `ClassSelectorScreen` when picking a custom class

## AddSubtractDialog

Dialog for adding to or subtracting from a numeric stat. Used by the XP and gold `Icons.exposure` buttons in `StatsSection`.

**Usage:**
```dart
final value = await showDialog<int?>(
  context: context,
  builder: (_) => AddSubtractDialog(
    character.xp,                    // current value
    AppLocalizations.of(context).xp, // label
  ),
);
if (value != null) {
  // Caller clamps and saves the new value
}
```

**Features:**
- Digits-only, autofocused input; the add/subtract buttons are disabled until something is entered
- Pops with `currentValue ± input`, floored at 0 (no `show()` helper; returns `null` when dismissed)
- Shows the current value below the input
- Fully localized (`adjustValue`, `addSubtractPrompt`, `currentValue`, `add`, `subtract`). The label is lowercased mid-sentence unless it is an acronym such as XP

## EnvelopePuzzleDialog

Dialog for solving envelope puzzles (Envelope X and Envelope V) that require entering a secret answer.

**Usage:**
```dart
final solved = await EnvelopePuzzleDialog.show(
  context: context,
  promptText: AppLocalizations.of(context).enterSolution,
  inputLabel: AppLocalizations.of(context).solution,
  correctAnswer: 'bladeswarm',
  successButtonText: AppLocalizations.of(context).solve,
);

if (solved == true) {
  // Puzzle was solved correctly
}
```

**Features:**
- Text input with autofocus
- Case-insensitive answer validation
- Submit button disabled until correct answer entered
- Static show() method returns `Future<bool?>`

## BackupDialog

Dialog for creating and exporting database backups.

**Usage:**
```dart
await BackupDialog.show(context: context);
```

**Features:**
- Filename input with validation (filters special characters, shows `.json` suffix)
- Default filename: `ghc_backup`
- **Share/Export**: Opens the platform share sheet (`share_plus`) to send the
  backup via email, cloud, messaging, or iOS "Save to Files". Uses only the
  share/document APIs — no media-picker SDK — so no camera/photo/location
  privacy permissions are required.
- Returns `BackupResult` with action type (`shared` or `cancelled`)

## RestoreDialog

Handles the complete database restore workflow (not a traditional dialog widget).

**Usage:**
```dart
await RestoreDialog.show(context: context);
// If successful, characters model is reloaded and settings screen is popped
```

**Features:**
- Confirmation warning before proceeding
- Document picker (`file_selector`) for `.json`/`.txt` backup files
- Progress indicator during restore
- Calculator settings reload from the restored prefs as soon as the restore commits, before any later step can fail
- Error dialog with copy-to-clipboard option. A rejected or rolled-back restore changes nothing (`restoreErrorMessage`). If the restore committed but reloading the app failed, the dialog says the backup was restored (`restoreAppliedErrorMessage`). Either way, characters are reloaded so the UI matches the database
- Automatic navigation after success

## EnhancerDialog

Dialog for configuring Frosthaven Building 44 (Enhancer) levels, which provide progressive discounts on enhancement costs.

**Usage:**
```dart
// Typically opened from the Enhancement Calculator screen
EnhancerDialog.show(
  context: context,
  model: enhancementCalculatorModel,
);
```

**Features:**
- Four checkbox levels representing Enhancer building progression
- Level 1 is always enabled (baseline: ability to buy enhancements)
- Levels 2-4 have blurred subtitles when unchecked (spoiler prevention)
- Each level unlocks specific cost reductions:
  - **Level 2**: Reduces base enhancement costs
  - **Level 3**: Reduces card level penalties
  - **Level 4**: Reduces previous enhancement penalties
- State persisted via SharedPrefs (enhancerLvl2/3/4 keys)
- Writes through the model's `enhancerLvl2/3/4` setters, which recalculate and notify; the calculator screen underneath rebuilds from that
- Cascading level logic enforced in SharedPrefs setters (see `docs/shared_prefs_keys.md`)

**Internal Widgets:**
- `_EnhancerLevelTile` - Individual level row with checkbox, title, and conditionally-blurred subtitle

**Design Notes:**
- Frosthaven-specific feature (only shown when edition = Frosthaven)
- Uses `ImageFiltered` with blur for spoiler prevention on locked levels
- AlertDialog with centered title, scrollable content, and close button

## Update450Dialog

One-time "What's new in 4.5.0" announcement, shown by `Home` after the first frame while `SharedPrefs().showUpdate450Dialog` is true (default `true`).

**Features:**
- Sets `showUpdate450Dialog = false` in `initState`, so it appears only once
- Scrollable bullet list of release notes, with a "Buy Me a Coffee" mention in debug builds or on Android in the US region
- Single "Got it!" button
- Text is hardcoded English (not localized)

## Best Practices

- Use `ConfirmationDialog` for simple yes/no confirmations
- Create specialized dialogs (like `CustomClassWarningDialog`) for complex, reusable patterns
- All dialog buttons automatically use `theme.contrastedPrimary` for accessibility
- Always check `context.mounted` before using context after `await`
