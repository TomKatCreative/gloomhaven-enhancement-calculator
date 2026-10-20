# Calculator Widgets

## Expandable Cost Chip

> **File**: `lib/ui/widgets/expandable_cost_chip.dart`

The enhancement calculator displays a floating chip that shows the total cost and expands into a full breakdown card when tapped.

### Architecture

The widget uses a `Stack` with two layers:
1. **Scrim** - Semi-transparent overlay (50% black) when expanded, tapping collapses
2. **Expandable chip/card** - Morphs between collapsed chip and expanded card states

### States

**Collapsed (Chip)**:
- 56dp tall, dynamically sized width
- Centered icon + cost with expand arrow on right
- Positioned 16dp from bottom
- Background matches navigation bar color

**Expanded (Card)**:
- 85% of available screen height
- Max width 468dp, horizontally centered
- Header with centered icon + cost, close button on right
- Scrollable breakdown list below divider
- Tapping anywhere on the card collapses it

### Animation

- 300ms duration with `easeOutCubic` (expand) / `easeInCubic` (collapse)
- Interpolates: width, height, border radius, elevation
- Scrim fades in/out with expansion
- Content switches at 50% animation progress

### Key Implementation Details

1. **FAB alignment**: Chip is positioned 16dp from bottom to align with the FAB

2. **Scrim interaction**: The scrim uses `GestureDetector` to collapse on tap. Returns `SizedBox.shrink()` when fully collapsed to avoid blocking touches.

3. **Tap to close**: The expanded card is wrapped in a `GestureDetector` with `HitTestBehavior.opaque` so tapping anywhere (including empty space) closes it. The `ListView` still scrolls normally.

4. **FAB visibility**: Updates `EnhancementCalculatorModel.isSheetExpanded` when toggling, which the home screen uses to hide the FAB when expanded.

5. **Blur bar drag-through**: The frosted glass blur bar at the bottom accepts an optional `scrollController` parameter. Vertical drags on the blur area are forwarded to the scroll controller, allowing users to scroll the calculator content even when touching the blur area. Taps are absorbed (do nothing). Note: This implementation uses `jumpTo()` so momentum/flick scrolling is not supported.

### Dimensions

```dart
// Chip (collapsed)
_chipHeight = 56.0
_chipBorderRadius = 24.0

// Card (expanded)
_cardTopRadius = 28.0
_cardBottomRadius = 24.0
_cardMaxWidth = 468.0
_cardExpandedFraction = 0.85  // of available height

// Positioning
_bottomOffset = 16.0
_horizontalPadding = 16.0
```

---

## Calculator Section Cards

> **Directory**: `lib/ui/widgets/calculator/`

The enhancement calculator uses `SectionCard` (from `lib/ui/widgets/section_card.dart`) for consistent card styling that matches the character screen. Each section is wrapped in a `SectionCard` with a title, icon (either Material `icon` or `svgAssetKey` for SVG icons via `ThemedSvg`), and customizable content padding.

### Screen Layout

The calculator screen is organized into three `SectionCard` sections:

```
┌─ Enhancement ─────────────────────┐
│ ★ Enhancement                     │  ← SectionCard title
│ [i]  [Enhancement Type Dropdown]  │
│      [Cost Display]               │
└───────────────────────────────────┘

┌─ Card Details ────────────────────┐
│ 🎴 Card details                   │  ← SectionCard title
│ [i] Card Level (slider)           │
│ ─────────────────────────────────  │
│ [i] Previous Enhancements (0-3)   │
│ ─────────────────────────────────  │
│ [i] Multiple Targets [toggle]     │
│ ─────────────────────────────────  │
│ [i] Loss Non-Persistent [toggle]* │
│ ─────────────────────────────────  │
│ [i] Persistent [toggle]*          │
└───────────────────────────────────┘
* GH2E/FH only

┌─ Discounts ───────────────────────┐
│ 🏷️ Discounts                      │  ← SectionCard title
│ [i] Temporary Enhancement † [sw]  │
│ ─────────────────────────────────  │
│ [i] Hail's Discount ‡ [sw]       │
│ ─────────────────────────────────  │
│ [i] Scenario 114 Reward [sw]*    │
│ ─────────────────────────────────  │
│ [i] Building 44 * [dialog]*      │
└───────────────────────────────────┘
* Edition-specific
```

### Cost Markers

The calculator displays markers on cost chips to indicate which discounts are applied:
- **†** (dagger) - Temporary Enhancement mode active
- **‡** (double-dagger) - Hail's Discount active
- **§** (section sign) - Scenario 114 Reward active (Gloomhaven/GH2E only)
- **\*** (asterisk) - Building 44 discount active (Frosthaven only)

Markers can combine (e.g., `†*` if both temp enhancement and Building 44 L4 apply).

### Building 44 Dialog (Frosthaven Spoiler Protection)

The Building 44 dialog shows enhancer upgrade levels with spoiler protection:
- Level 1 text is always visible (always unlocked)
- Levels 2-4 have their subtitle text blurred with `ImageFiltered` until checked
- Uses `ImageFilter.blur(sigmaX: 6, sigmaY: 6)` for the blur effect
- Checking a level reveals the discount description immediately

### File Structure

```
lib/ui/widgets/calculator/
├── calculator.dart                 # Barrel export file
├── calculator_toggle_group_card.dart # Column of toggle rows (used in Discounts section)
├── info_button_config.dart         # Configuration for info buttons
├── cost_display.dart               # Standardized cost chip with strikethrough
├── card_level_body.dart            # SfSlider for card level selection
├── previous_enhancements_body.dart # Segmented button (0-3)
├── enhancement_type_body.dart      # Dropdown selector
└── enhancement_icon.dart           # EnhancementIcon: element stack or SVG with +1 badge
```

`EnhancementIcon(enhancement:, size:)` is the one place that draws an enhancement's icon. The type body, the selector screen and the cost chip all use it, so the "Element" stack and the +1 badge stay consistent. It also pins the icon colour to `onSurface`, so a selected `ListTile` (or any other inherited `IconTheme`) never tints it with the theme colour.

Note: The Card Details section (`_CardDetailsGroupCard` in `enhancement_calculator_screen.dart`) combines Card Level, Previous Enhancements, and modifier toggles in a single `SectionCard` with internal dividers. The `CalculatorToggleGroupCard` renders a `Column` of toggle rows (no longer wraps in its own `Card`, since the outer `SectionCard` provides the container).

### CalculatorToggleGroupCard

A column of toggle items with dividers, used inside a `SectionCard` for the Discounts section:

```dart
SectionCard(
  title: l10n.discounts,
  icon: Icons.discount_rounded,
  contentPadding: EdgeInsets.only(bottom: smallPadding),
  child: CalculatorToggleGroupCard(items: [...]),
)
```

### InfoButtonConfig

Two ways to configure info buttons:

```dart
// Option 1: Title + pre-built RichText message
InfoButtonConfig.titleMessage(
  title: 'Card Level',
  message: Strings.cardLevelInfoBody(context, darkTheme),
)

// Option 2: Auto-configure based on enhancement category
InfoButtonConfig.category(category: EnhancementCategory.posEffect)
```

### CostDisplay

Standardized cost chip with optional strikethrough for discounts:

```dart
CostDisplayConfig(
  baseCost: 100,
  discountedCost: 75,    // Optional - shows strikethrough when different
  marker: '†',           // Optional suffix (e.g., for temporary enhancements)
)
```

### SfSlider (Card Level)

The card level selector uses `syncfusion_flutter_sliders` package for a cleaner slider with built-in labels:

```dart
SfSlider(
  min: 1.0,
  max: 9.0,
  value: displayLevel,
  interval: 1,
  stepSize: 1,
  showLabels: true,
  activeColor: colorScheme.primary,
  onChanged: (value) => model.cardLevel = value.round() - 1,
)
```

### Adding a New Calculator Section

1. Create a body widget in `lib/ui/widgets/calculator/` if needed
2. Wrap in `SectionCard(title: ..., icon: ..., child: ...)` in the calculator screen
3. Configure `InfoButtonConfig` for info dialogs within the section
4. Add `CostDisplayConfig` if the section has associated costs
