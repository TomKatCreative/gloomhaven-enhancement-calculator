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
- Discord server link for community content
- "Don't show again" checkbox (persisted to SharedPreferences)
- Custom stateful behavior for checkbox management

## VariantSelectorDialog

Dialog for selecting between class variants/editions.

**Usage:**
```dart
final variant = await VariantSelectorDialog.show(
  context: context,
  playerClass: selectedClass,
);

if (variant != null) {
  // Use selected variant (Variant.base, Variant.gloomhaven2E, etc.)
}
```

**Features:**
- Class icon and name in title
- Dynamic button generation for all available variants
- Supports unlimited variants (future-proof)
- Cancel option with contrast-adjusted styling

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
final result = await BackupDialog.show(context: context);

if (result?.action == BackupAction.saved) {
  // Show success message with result.savedPath
}
```

**Features:**
- Filename input with validation (filters special characters)
- Default filename with timestamp
- Platform-specific options:
  - Android: Save to Downloads OR Share
  - iOS: Share only
- Returns `BackupResult` with action type and saved path

## RestoreDialog

Handles the complete database restore workflow (not a traditional dialog widget).

**Usage:**
```dart
await RestoreDialog.show(context: context);
// If successful, characters model is reloaded and settings screen is popped
```

**Features:**
- Confirmation warning before proceeding
- Storage permission request (iOS)
- File picker for .txt backup files
- Progress indicator during restore
- Error dialog with copy-to-clipboard option
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
- Triggers `model.calculateCost()` on checkbox changes
- Cascading level logic enforced in SharedPrefs setters (see `docs/shared_prefs_keys.md`)

**Internal Widgets:**
- `_EnhancerLevelTile` - Individual level row with checkbox, title, and conditionally-blurred subtitle

**Design Notes:**
- Frosthaven-specific feature (only shown when edition = Frosthaven)
- Uses `ImageFiltered` with blur for spoiler prevention on locked levels
- AlertDialog with centered title, scrollable content, and close button

## Best Practices

- Use `ConfirmationDialog` for simple yes/no confirmations
- Create specialized dialogs (like `CustomClassWarningDialog`) for complex, reusable patterns
- All dialog buttons automatically use `theme.contrastedPrimary` for accessibility
- Always check `context.mounted` before using context after `await`
