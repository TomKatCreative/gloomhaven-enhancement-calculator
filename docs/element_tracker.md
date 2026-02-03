# Element Tracker Sheet

> **File**: `lib/ui/widgets/element_tracker_sheet.dart`

The Characters screen includes a draggable bottom sheet for tracking the 6 Gloomhaven elements (FIRE, ICE, AIR, EARTH, LIGHT, DARK). Each element cycles through states when tapped: gone → strong → waning → gone.

## Architecture

**Files involved:**
- `lib/ui/widgets/element_tracker_sheet.dart` - The draggable sheet with three expansion states
- `lib/ui/widgets/animated_element_icon.dart` - Animated element icons with glow effects
- `lib/ui/screens/characters_screen.dart` - Contains scrim overlay for full expansion
- `lib/viewmodels/characters_model.dart` - State for sheet expansion, collapse notifier

## Sheet States

The sheet has three snap positions:
- **Collapsed** (6.5%): Icons in a compact row, minimal state representation
- **Expanded** (14%): Icons in a spaced row, interactive with animations
- **Full Expanded** (85%): Icons in 2x3 grid with responsive spacing

## Element Icon States

> **File**: `lib/ui/widgets/animated_element_icon.dart`

**Static (collapsed sheet):**
- Gone: 30% opacity
- Strong: 100% opacity
- Waning: Bisected horizontally (top dim, bottom bright) with sharp line

**Animated (expanded sheet):**
- Gone: 30% opacity, no glow
- Strong: Element-specific animated glow effect
- Waning: Bisected with animated glow on bottom half

## Animation System (Config-Driven)

Element animations use a centralized configuration system via `ElementAnimationConfig`. All animation parameters are defined in config objects, keeping the rendering logic generic.

**Architecture:**
- 2-3 `AnimationController`s per element combined via `Listenable.merge`
- Controllers: base (slow), secondary (faster), optional tertiary (fastest - FIRE only)
- 250ms crossfade for all state transitions (hardcoded)
- Waning state derived from strong with multipliers (0.85 intensity, 0.6 size)

**Glow Layer Structure (all elements):**
1. Outer glow - BoxShadow, largest radius, lowest intensity
2. Middle glow - BoxShadow, medium radius
3. Inner core - RadialGradient, smallest, highest intensity
4. Icon - SVG on top

## ElementAnimationConfig Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `baseDuration` | Primary controller duration | 2000-3000ms |
| `secondaryDuration` | Secondary controller duration | 800-1800ms |
| `tertiaryDuration` | Optional third controller | null or ~800ms |
| `outerGlowColor` | Outer shadow color | Element-specific |
| `middleGlowColor` | Middle shadow color | Element-specific |
| `innerGradientColors` | 4-color gradient for core | Element-specific |
| `outerSizeOffset` | Added to baseSize for outer | 8-18 |
| `middleSizeOffset` | Added to baseSize for middle | 4-10 |
| `outerBlurRadius` | Base blur for outer glow | 12-28 |
| `middleBlurRadius` | Base blur for middle glow | 8-16 |
| `baseIntensity` | Minimum glow intensity | 0.25-0.7 |
| `intensityVariation` | How much intensity varies | 0.15-0.45 |
| `sizeVariation` | Max size pulse amount | 1.5-5 |
| `isThemeAware` | Use theme-dependent colors | false (AIR=true) |

## Animation Styles

Each style has unique mathematical behavior preserved in `_compute*Animation()` methods:

| Style | Character | Math Behavior |
|-------|-----------|---------------|
| `fire` | Breathing, warm | Eased sine waves, 3 layers combined |
| `ice` | Crystalline, sharp | Multi-freq (4x,7x,11x) with abs() |
| `air` | Flowing, gentle | Cosine undulation, minimal variation |
| `earth` | Tremor, crunchy | High-freq (11x,17x,23x) + threshold cracks |
| `light` | Steady, radiant | Smooth breathing |
| `dark` | Drifting, eerie | Horizontal cosine drift for cloud effect |

## Adding/Modifying Element Animations

**Stay within these bounds** - modifications should only adjust `ElementAnimationConfig` values:

1. Add/modify a factory constructor in `ElementAnimationConfig` (e.g., `ElementAnimationConfig.fire()`)
2. Update the `_configs` map if adding a new element
3. Adjust timing, colors, sizes, and intensity within the documented ranges

**Requires special consideration** (discuss before implementing):
- Adding a new animation style (new enum value + new `_compute*Animation()` method)
- Adding new config parameters beyond the existing ones
- Changing the 3-layer glow structure
- Modifying the 250ms crossfade duration
- Adding element-specific rendering logic in `_buildStrongGlow()` or `_buildWaningGlow()`

The goal is to keep all elements rendering through the same generic code paths, with only config values differentiating them.

## Crossfade Transitions

All elements use a shared fade controller (250ms) for smooth transitions:
- `_fadeController` handles: gone↔strong, strong↔waning, sheet expand/collapse
- `_buildFadeToGone()` handles fade-out to gone state specifically

## Key Implementation Details

1. **Responsive grid spacing**: In full-expanded mode, icon spacing adapts to screen width using 45% of remaining horizontal space (clamped 24-80px)

2. **Scrim overlay**: When fully expanded, a semi-transparent scrim blocks interaction with content behind. Tapping the scrim collapses to partially expanded.

3. **Collapse communication**: Uses `ValueNotifier<int>` pattern - `CharactersModel.collapseElementSheetNotifier` is incremented to trigger collapse from outside the sheet widget (e.g., when navigating away from the Characters screen).

4. **State persistence**: Element states are stored in SharedPreferences (`fireState`, `iceState`, etc.)
