# Game Text Parser Documentation

## Overview

The Game Text Parser is a robust, token-based system for parsing and rendering rich game text with icons, formatting, and special effects. It follows a clean separation of concerns architecture.

## Architecture

### File Organization

The parser is split across three files:

| File | Contents |
|------|----------|
| `game_text_tokens.dart` | Token type definitions (`GameTextToken`, `BoldToken`, `IconToken`, `StackedElementToken`, `ItalicToken`, `PlainTextToken`, `PunctuationToken`) |
| `game_text_tokenizer.dart` | Parsing logic (`ParsedWord`, `GameTextTokenizer`) |
| `game_text_parser.dart` | Public API facade (`GameTextRenderer`, `GameTextParser`) + barrel re-exports |

Consumers only need to import `game_text_parser.dart` — it re-exports the token types and tokenizer.

### Components

1. **GameTextToken** - Abstract base class for all token types
2. **GameTextTokenizer** - Converts strings to tokens
3. **GameTextRenderer** - Converts tokens to Flutter widgets
4. **GameTextParser** - Public API facade

### Design Principles

- **Separation of Concerns**: Parsing logic is separate from rendering logic
- **Extensibility**: Easy to add new token types without modifying existing code
- **Testability**: Each component can be tested independently
- **Documentation**: Well-documented syntax and usage patterns

## Supported Syntax

### Bold Text
```
**Text within double asterisks becomes bold**
```
**Examples:**
- `**Rested and Ready:**` → **Rested and Ready:**
- `**My new stuff**: Normal text **and more bold**` → **My new stuff:** Normal text **and more bold**

### Icons
```
UPPERCASE_WORDS or PascalCase words that match asset names
```
**Examples:**
- `ATTACK` → 🗡️ (attack icon)
- `MOVE` → 👟 (move icon)
- `HEAL` → ❤️ (heal icon)
- `FIRE` → 🔥 (fire element icon)
- `Berserker` → Berserker class icon
- `Rolling` → Rolling modifier icon

**Important:** Icon tokens must use UPPERCASE or PascalCase. All-lowercase words are treated as plain text, even if they match an asset key. This prevents common English words like "be", "hex", or "hive" from being incorrectly replaced with class icons (Berserker's code is `be`, Hive's code is `hive`, etc.).

### XP Values
```
xpN where N is a number
```
**Examples:**
- `xp8` → XP icon with "8" overlay
- `xp12` → XP icon with "12" overlay

### Stacked Elements
```
ELEMENT&ELEMENT
```
**Examples:**
- `FIRE&ICE` → Fire and ice icons stacked
- `AIR&EARTH` → Air and earth icons stacked

### Italic Text
```
*Text within single asterisks becomes italic*
```
**Examples:**
- `*potion*` → *potion*
- `*Reviving Ether*` → *Reviving Ether*

### Text Replacements
```
Special words converted to symbols
```
**Examples:**
- `plusone` → `+1`
- `plustwo` → `+2`
- `pluszero` → `+0`

## Usage

### Basic Usage

```dart
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';

// Parse game text
final spans = GameTextParser.parse(
  context,
  '**Rested and Ready:** Whenever you long rest, add +1 MOVE',
  darkTheme: true,
);

// Display in a RichText widget
RichText(
  text: TextSpan(children: spans),
);
```

### In Existing Code

All call sites use `GameTextParser.parse()` directly:

```dart
RichText(
  text: TextSpan(
    style: theme.textTheme.bodyMedium,
    children: GameTextParser.parse(context, text, isDark),
  ),
)
```

## Adding New Features

### Adding a New Token Type

1. **Create a new token class**:

```dart
class MyNewToken extends GameTextToken {
  final String data;
  
  const MyNewToken(this.data);
  
  @override
  InlineSpan toSpan(BuildContext context, bool darkTheme) {
    // Return your custom widget/span
    return TextSpan(text: data);
  }
}
```

2. **Add detection logic in GameTextTokenizer**:

```dart
// In _tokenizeWords method
if (word.startsWith('@')) {
  tokens.add(MyNewToken(word.substring(1)));
  continue;
}
```

3. **Document your new syntax in this README**

### Adding a New Asset

Simply add it to `asset_config.dart`:

```dart
const standardAssets = {
  // ... existing assets

  // For icons where parts using `currentColor` should change with theme:
  'MY_THEMED_ASSET': AssetConfig('my_themed_asset.svg', themeMode: CurrentColorTheme()),

  // For icons that look good as-is on both light and dark backgrounds:
  'MY_COLORFUL_ASSET': AssetConfig('my_colorful_asset.svg'),
};
```

**Color behavior options:**
- `themeMode: CurrentColorTheme()` - Sets the SVG's `currentColor` based on theme (for icons with themed parts)
- No themeMode - Renders SVG exactly as defined with no color modification

The parser will automatically recognize and render it!

## Examples

### Full Example - Perk Text

**Input:**
```dart
'**Rested and Ready:** Whenever you long rest, add plusone MOVE'
```

**Tokens Generated:**
1. `BoldToken("Rested and Ready:")`
2. `PlainTextToken(" ")`
3. `PlainTextToken("Whenever")`
4. `PlainTextToken(" ")`
5. `PlainTextToken("you")`
6. ... (more plain text tokens)
7. `PlainTextToken("+1")` (converted from "plusone")
8. `PlainTextToken(" ")`
9. `IconToken(element: "MOVE", ...)`

**Output:**
**Rested and Ready:** Whenever you long rest, add +1 👟

### Complex Example

**Input:**
```dart
'**Elemental Strike:** ATTACK xp8 FIRE&ICE or *consume* DARK'
```

**Output:**
**Elemental Strike:** 🗡️ 🎯8 🔥❄️ or *consume* 🌑

## Testing

### Unit Testing Tokens

```dart
test('BoldToken renders correctly', () {
  final token = BoldToken('Test');
  final span = token.toSpan(context, true);
  
  expect(span, isA<TextSpan>());
  expect((span as TextSpan).text, equals('Test'));
  expect(span.style?.fontWeight, equals(FontWeight.bold));
});
```

### Integration Testing

```dart
test('Parser handles complex text', () {
  final result = GameTextParser.parse(
    context,
    '**Bold** ATTACK xp8',
    true,
  );
  
  expect(result.length, equals(5)); // Bold, space, icon, space, xp
});
```

## Migration Guide

> **Note:** The migration from `[text]` to `**text**` syntax is complete. All perk data in the codebase now uses the Markdown-style syntax. This section is preserved for historical reference.

### Quick Migration Steps (Historical)

1. **Backup your perks_repository.dart file**
2. **Run find-and-replace** in your IDE:
   - Find: `\[([^\]]+)\]` (regex)
   - Replace: `**$1**`
   - This converts all `[text]` to `**text**`
3. **Manually update italic text**:
   - Change `~word ~word` to `*word word*` (wrap phrases)
   - Or keep individual: `~word` → `*word*`
4. **Test your perks** to make sure formatting looks correct

### Example Migration (Historical)

Before (old syntax):
```dart
'[Rested and Ready:] $_wheneverYouLongRest, if ~Reviving ~Ether is in your discard pile'
```

After (current syntax):
```dart
'**Rested and Ready:** $_wheneverYouLongRest, if *Reviving Ether* is in your discard pile'
```

**Note:** For italic text, you can now wrap entire phrases: `*Reviving Ether*` instead of `~Reviving ~Ether`

### From Old System

The old system had these issues:
- Bold only worked at the beginning of strings
- Non-standard syntax (`[bold]`, `~italic`)
- Logic was scattered across multiple methods
- Hard to add new patterns
- Difficult to test

### Changes Made

1. **Markdown syntax**: Now uses standard `**bold**` and `*italic*`
2. **Bold text now works anywhere**: `**Bold** text **more bold**`
3. **Cleaner code structure**: Tokenizer → Renderer separation
4. **Easy to extend**: Just add new token types
5. **Better documented**: Clear syntax specification

### What Stays the Same

- All existing perk data works without changes
- All call sites use `GameTextParser.parse()` directly (legacy `Utils.generateCheckRowDetails` wrapper removed)
- All asset configurations remain the same

## Performance Considerations

- **Tokenization**: O(n) where n is string length
- **Rendering**: O(t) where t is number of tokens
- **Caching**: Consider caching parsed results for frequently used strings

## Future Enhancements

Potential additions:
- Support for nested bold/italic
- Color customization syntax: `{red:text}`
- Tooltips: `{tooltip:text|explanation}`
- Custom animations: `{shake:ATTACK}`
- Conditional rendering: `{if:darkTheme:DARK|LIGHT}`

## Troubleshooting

### Icons Not Showing
- Verify asset exists in `asset_config.dart`
- Check that word is UPPERCASE or PascalCase (all-lowercase words are ignored)
- Ensure asset file exists in `images/` directory

### Unexpected Icon Appearing
- If a common word is being replaced with an icon, ensure it's lowercase in your text
- The parser skips all-lowercase words to prevent matching class codes that are English words (e.g., "be" → Berserker, "hive" → Hive class)

### Bold Not Working
- Verify double asterisks are properly paired: `**text**`
- Check for nested bold (not supported)

### XP Number Wrong
- Verify format is exactly `xpN` (no spaces)
- Number must be immediately after `xp`

### Spacing Issues
- Parser handles spaces automatically
- Don't add manual spaces in your text strings

## Support

For questions or issues:
1. Check this documentation
2. Review the inline code documentation
3. Look at existing perk examples in `perks_repository.dart`
4. Check the unit tests for examples