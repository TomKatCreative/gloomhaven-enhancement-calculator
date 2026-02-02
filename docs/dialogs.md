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

## Best Practices

- Use `ConfirmationDialog` for simple yes/no confirmations
- Create specialized dialogs (like `CustomClassWarningDialog`) for complex, reusable patterns
- All dialog buttons automatically use `theme.contrastedPrimary` for accessibility
- Always check `context.mounted` before using context after `await`
