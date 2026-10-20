# ViewModels Reference

> **Directory**: `lib/viewmodels/`

This document provides a comprehensive reference for the app's ChangeNotifier-based state management using Provider.

## Provider Dependency Tree

The app uses Provider with five main models set up in `main.dart`:

```
┌─────────────────────────────────────────────────────────────┐
│                      MultiProvider                          │
│                                                             │
│  ┌─────────────────┐                                        │
│  │  ThemeProvider  │  ← No dependencies                     │
│  └────────┬────────┘                                        │
│           │                                                 │
│  ┌────────▼────────┐                                        │
│  │    AppModel     │  ← No dependencies                     │
│  └────────┬────────┘                                        │
│           │                                                 │
│  ┌────────▼─────────────────────┐                           │
│  │ EnhancementCalculatorModel   │  ← Uses SharedPrefs       │
│  └────────┬─────────────────────┘                           │
│           │                                                 │
│  ┌────────▼─────────────────────┐                           │
│  │      TownModel               │  ← Uses DatabaseHelper    │
│  └────────┬─────────────────────┘                           │
│           │                                                 │
│  ┌────────▼─────────────────────┐                           │
│  │    CharactersModel           │  ← reads ThemeProvider    │
│  │    (writes seed color to it) │    once, in create        │
│  └──────────────────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

### Usage in Widgets

```dart
// Reactive rebuilds (use in build methods)
final model = context.watch<CharactersModel>();
final theme = context.watch<ThemeProvider>();

// One-time reads (use in callbacks)
final model = context.read<CharactersModel>();
```

### App Entry & Startup Guard

`main()` (in `main.dart`) is a synchronous function that wraps the whole startup in `runZonedGuarded`:

- **`ErrorWidget.builder`** is replaced with `DiagnosticErrorView` (`lib/ui/widgets/diagnostic_error_view.dart`) — a dependency-free, screenshot-able error screen (no `Theme`/`MediaQuery`/providers, since any of those may be the failure). Any build-phase exception now renders the actual error + stack trace instead of the default blank/grey rectangle.
- **`SharedPrefs().init()`** and the startup side effects run inside a `try/catch`; a failure shows `DiagnosticErrorView` via a minimal `MaterialApp` rather than leaving a blank screen before `runApp()`.
- The `MultiProvider` was extracted out of `main()` into a **`GloomhavenApp`** root `StatelessWidget`, so an exception thrown while a provider is *constructed* (e.g. `EnhancementCalculatorModel` reading a bad persisted value) happens during build and is caught by `ErrorWidget.builder`.

The five models are still declared inside `GloomhavenApp.build()`; the dependency tree above is unchanged.

---

## ThemeProvider

> **File**: `lib/theme/theme_provider.dart`

Manages app theme (light/dark mode), font preferences, and dynamic character colors.

### Responsibilities

- Dark/light mode switching
- Font family selection (default vs. custom)
- Character-based color theming
- Providing theme data to MaterialApp

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `themeMode` | `ThemeMode` | Current theme (light/dark/system) |
| `useDefaultFonts` | `bool` | Whether to use default or custom fonts |
| `primaryColor` | `Color` | Current primary theme color |

### State Persistence

Theme preferences are persisted via SharedPrefs:
- `darkTheme` key for dark mode
- `useDefaultFonts` key for font preference

---

## AppModel

> **File**: `lib/viewmodels/app_model.dart`

Handles app-level navigation state and page management.

### Responsibilities

- Page navigation state (Characters vs Calculator)
- PageController management
- App-level UI coordination

### Key Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `pageController` | `PageController` | created | Controls PageView navigation |
| `page` | `int` | from SharedPrefs | Current page index: `kTownPageIndex`, `kCharactersPageIndex` or `kCalculatorPageIndex` (`lib/data/constants.dart`). Restored from `initialPage`, clamped to `kCalculatorPageIndex` |

Theme mode and font preference are owned by `ThemeProvider`, not `AppModel`.

### State Persistence

- `initialPage` key in SharedPrefs for startup page

---

## EnhancementCalculatorModel

> **File**: `lib/viewmodels/enhancement_calculator_model.dart`

Thin state management layer that delegates cost calculations to `EnhancementCostCalculator`.

### Architecture

```
UI ← watches → EnhancementCalculatorModel (state + SharedPrefs persistence)
                        ↓ delegates
                EnhancementCostCalculator (pure, immutable computation)
```

The model caches an `EnhancementCostCalculator` instance, invalidating it on any state change. Computed properties (`totalCost`, `showCost`, `getCalculationBreakdown`) delegate to the cached calculator. The calculator is rebuilt lazily on first access after invalidation.

### Responsibilities

- State field management with SharedPrefs persistence
- Cached calculator delegation for cost computation
- Enhancement selection and edition-specific validation
- Thin API wrappers preserving backward compatibility

### Key Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `_gameEdition` | `GameEdition` | from SharedPrefs | Cached game edition |
| `_partyBoon` | `bool` | false | Cached party boon state |
| `_enhancerLvl2` | `bool` | false | Cached enhancer level 2 state |
| `_enhancerLvl3` | `bool` | false | Cached enhancer level 3 state |
| `_enhancerLvl4` | `bool` | false | Cached enhancer level 4 state |
| `_enhancement` | `Enhancement?` | null | Currently selected enhancement. Persisted as `Enhancement.key` (`enhancementKey` pref) and read via `_enhancementFromPrefs()`; an unknown key yields `null`. Falls back to the legacy `enhancementType` index (bounds-checked — an out-of-range index from older builds yields `null` instead of a `RangeError` during construction) and migrates it to a key. `resetCost()` and unavailable-in-edition selections clear both formats |
| `_cardLevel` | `int` | 0 | Target card level (0-8, displayed as 1-9) |
| `_previousEnhancements` | `int` | 0 | Count of previous enhancements (0-3) |
| `_multipleTargets` | `bool` | false | Multi-target multiplier enabled |
| `_lostNonPersistent` | `bool` | false | Lost action modifier (GH2E/FH) |
| `_persistent` | `bool` | false | Persistent modifier (FH only) |
| `_temporaryEnhancementMode` | `bool` | false | Temporary enhancement discount |
| `_hailsDiscount` | `bool` | false | Hail's special discount (-5g) |
| `_disableMultiTargetsSwitch` | `bool` | false | UI lock for multi-target toggle |
| `_isSheetExpanded` | `bool` | false | Cost chip expansion state |
| `totalCost` | `int` | 0 | Final calculated cost |
| `showCost` | `bool` | false | Whether to display cost UI |

### Getters and Setters

Each setter writes through to SharedPrefs, invalidates the cached calculator and notifies listeners **exactly once**, side effects included. Side effects (clearing lost/persistent, locking the multi-target switch) go through private `_write*` helpers that persist and assign without notifying, so a tap never triggers a cascade of rebuilds. UI files should use these setters instead of accessing SharedPrefs directly.

| Property | Type | Setter behavior |
|----------|------|-----------------|
| `edition` / `gameEdition=` | `GameEdition` | Write to SharedPrefs, update cache, run `gameVersionToggled()` |
| `partyBoon` | `bool` | Write to SharedPrefs, update cache, notify |
| `enhancerLvl2` / `enhancerLvl3` / `enhancerLvl4` | `bool` | Via `_setEnhancerLevel(level, value)`: turning a level on turns on every lower level, turning it off turns off every higher level; writes all four levels (L1 included) to SharedPrefs, updates the cache, notifies once |
| `enhancement` | `Enhancement?` | Read-only; set through `enhancementSelected()` |
| `cardLevel` | `int` | Card level (0-indexed internally) |
| `previousEnhancements` | `int` | Previous enhancement count |
| `multipleTargets` | `bool` | Multi-target state |
| `lostNonPersistent` | `bool` | Lost modifier state (clears persistent) |
| `persistent` | `bool` | Persistent modifier state (clears lost) |
| `temporaryEnhancementMode` | `bool` | Temporary mode state |
| `hailsDiscount` | `bool` | Hail's discount state |
| `disableMultiTargetsSwitch` | `bool` | Read-only multi-target toggle lock, set by `enhancementSelected()` |
| `isSheetExpanded` | `bool` | Cost chip expansion |

### Computed Getters

| Getter | Returns | Description |
|--------|---------|-------------|
| `partyBoonApplies` | `bool` | `edition.supportsPartyBoon && partyBoon` |
| `hasAnyEnhancerUpgrades` | `bool` | `enhancerLvl2 \|\| enhancerLvl3 \|\| enhancerLvl4` |
| `enhancerLvl2Applies` | `bool` | Whether Enhancer L2 affects enhancement cost |
| `enhancerLvl3Applies` | `bool` | Whether Enhancer L3 affects card level cost |
| `enhancerLvl4Applies` | `bool` | Whether Enhancer L4 affects previous enhancements cost |

### Core Methods

| Method | Description |
|--------|-------------|
| `resetCost()` | Clear the per-card inputs (card level, previous enhancements, selection, multi-target, lost, persistent) via `SharedPrefs().resetCalculatorInputs()`; edition, party boon, temporary mode, Hail's discount and enhancer levels are kept |
| `reloadFromPrefs()` | Re-read all fields from SharedPrefs (e.g. after backup restore); enhancement selection is read through the bounds-checked `_enhancementFromPrefs()` helper (tolerates an out-of-range persisted index) |
| `enhancementSelected(Enhancement)` | Handle enhancement selection with validation; one notify |
| `gameVersionToggled()` | Handle edition change with modifier validation and re-check the selection; one notify |
| `getCalculationBreakdown()` | Generate step-by-step cost breakdown (`List<CalculationStep>`) |
| `enhancementCost(Enhancement?)` | Base cost of any enhancement with multipliers and flat discounts (lets the type selector preview costs). Thin wrapper over `EnhancementCostCalculator.enhancementCost` |
| `cardLevelPenalty(int level)` | Card level penalty with discounts. Wrapper over `EnhancementCostCalculator.cardLevelPenalty` |
| `previousEnhancementsPenalty(int count)` | Previous enhancements penalty with discounts. Wrapper over `EnhancementCostCalculator.previousEnhancementsPenalty` |
| `eligibleForMultipleTargets(Enhancement, {edition})` | Static; delegates to `EnhancementCostCalculator.eligibleForMultipleTargets` |

### Cost Calculation Flow

```
1. Base Enhancement Cost
   └── Apply Enhancer L2 discount (FH)
   └── Apply Hail's discount (-5g)

2. Multipliers (applied to base)
   └── Multiple Targets (×2)
   └── Lost/Non-Persistent (×0.5)
   └── Persistent (×3)

3. Card Level Penalty
   └── Base: 25 × level
   └── Apply Party Boon discount (GH/GH2E)
   └── Apply Enhancer L3 discount (FH)

4. Previous Enhancements Penalty
   └── Base: 75 × count
   └── Apply Enhancer L4 discount (FH)

5. Temporary Enhancement Mode
   └── -20g flat
   └── ×0.8 multiplier

6. Final: max(0, total)
```

### Edition-Specific Rules

| Feature | GH | GH2E | FH |
|---------|----|----|-----|
| Lost modifier (×0.5) | No | Yes | Yes |
| Persistent modifier (×3) | No | No | Yes |
| Multi-target on Target/Elements | Yes | No | No |
| Party Boon (card level discount) | Yes | Yes | No |
| Enhancer Levels (L2/L3/L4) | No | No | Yes |

### State Persistence

All calculator state is persisted via SharedPrefs:
- `gameEdition` - Selected edition
- `enhancementKey` - Selected enhancement (`Enhancement.key`; legacy `enhancementType` index is migrated on first read)
- `targetCardLvl` - Card level
- `enhancementsOnTargetAction` - Previous enhancements count
- `multipleTargetsSelected` - Multi-target toggle
- `disableMultiTargetsSwitch` - Multi-target lock
- `temporaryEnhancementMode` - Temporary mode
- `lostNonPersistent` - Lost modifier
- `persistent` - Persistent modifier
- `hailsDiscount` - Hail's discount
- `partyBoon` - Party boon (GH/GH2E)
- `enhancerLvl1/2/3/4` - Enhancer levels (FH)

---

## CharactersModel

> **File**: `lib/viewmodels/characters_model.dart`

Manages character CRUD operations, perk/mastery state, and character list navigation.

### Architecture

```
UI ← watches → CharactersModel (state + navigation + notifications)
                        ↓ delegates
                PersonalQuestService (quest assignment, progress, completion)
```

Personal quest operations are delegated to `PersonalQuestService` (`lib/data/personal_quest_service.dart`), following the same delegation pattern as `EnhancementCostCalculator`. The service is independently testable (`test/data/personal_quest_service_test.dart`).

### Responsibilities

- Character list management (load, create, delete)
- Current character selection and navigation
- Edit mode toggling
- Perk and mastery state updates
- Personal quest management (via PersonalQuestService)
- Theme synchronization with character color
- Scroll state tracking

### Dependencies

- `ThemeProvider` (read once in `create`) - for color sync
- `DatabaseHelper` (singleton) - for persistence
- `PersonalQuestService` (created internally) - for quest operations

### Key Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `_characters` | `List<Character>` | [] | Internal character list |
| `currentCharacter` | `Character?` | null | Currently selected character |
| `databaseHelper` | `DatabaseHelper` | singleton | SQLite access |
| `themeProvider` | `ThemeProvider` | injected | Theme controller |
| `pageController` | `PageController` | created | Character PageView control |
| `enhancementCalcScrollController` | `ScrollController` | created | Calculator scroll |
| `charScrollOffsetNotifier` | `ValueNotifier<double>` | 0 | Current character page's scroll offset (drives app bar tint) |
| `showRetired` | `bool` | from prefs | Show/hide retired characters |
| `_isEditMode` | `bool` | false | Edit mode state |
| `isScrolledToTop` | `bool` | true | Scroll position tracking |

### Getters

| Getter | Returns | Description |
|--------|---------|-------------|
| `characters` | `List<Character>` | Filtered list (respects showRetired) |
| `isEditMode` | `bool` | Current edit mode state (also a setter — see [Edit Mode](#edit-mode)) |
| `retiredCharactersAreHidden` | `bool` | Inverse of showRetired |
| `revision` | `int` | Bumped on every notification except a page swipe (`onPageChanged`) or an edit-mode toggle, i.e. whenever character data changes. See [Character Page Rebuilds](#character-page-rebuilds) |

### Section Expansion State (passthrough to SharedPrefs)

These are simple getter/setter pairs that read/write directly to SharedPrefs without calling `notifyListeners()` — widgets manage their own local `_isExpanded` state via `setState`.

| Property | Default | Description |
|----------|---------|-------------|
| `generalExpanded` | true | Stats & Resources section |
| `questAndNotesExpanded` | true | Quest & Notes section |
| `perksAndMasteriesExpanded` | true | Perks & Masteries section |

### Character CRUD Methods

| Method | Description |
|--------|-------------|
| `loadCharacters()` | Load all characters from database with perks/masteries |
| `createCharacter(name, class, {initialLevel, previousRetirements, edition, prosperityLevel, variant, personalQuestId, partyId, showResources, jawsOfTheLionEdition})` | Create new character with gold calculated via `edition.startingGold()`. `showResources` (default `true`) seeds the Resources-section visibility flag — the create screen defaults it to `true` for Frosthaven, `false` otherwise. `jawsOfTheLionEdition` (default `false`) persists the JotL edition choice so PQ/resources stay hidden on the sheet even for non-JotL classes |
| `updateCharacter(Character)` | Save character changes to database |
| `deleteCurrentCharacter()` | Delete current character and navigate |
| `retireCurrentCharacter()` | Toggle retirement status |

### Navigation Methods

| Method | Description |
|--------|-------------|
| `onPageChanged(int)` | Handle page swipe navigation |
| `jumpToPage(int)` | Instant page jump |
| `toggleShowRetired()` | Toggle retired visibility with smart navigation |

### Personal Quest Methods (delegated to PersonalQuestService)

| Method | Returns | Description |
|--------|---------|-------------|
| `updatePersonalQuest(Character, String questId)` | `Future<void>` | Change quest and reset progress to zeros |
| `updatePersonalQuestProgress(Character, int index, int value)` | `Future<bool>` | Update a single requirement's progress. Returns `true` if quest just transitioned from incomplete → complete |
| `isPersonalQuestComplete(Character)` | `bool` | Check if all progress values meet their targets (delegates to `PersonalQuestService.isComplete`) |

### Party Methods

| Method | Description |
|--------|-------------|
| `assignCharacterToParty(Character, String? partyId)` | Link or unlink a character to a party |

### Perk/Mastery Methods

| Method | Description |
|--------|-------------|
| `togglePerk({characterPerks, perk, value})` | Set `characterPerkIsSelected` on every matching `CharacterPerk` and save |
| `toggleMastery({characterMasteries, mastery, value})` | Set `characterMasteryAchieved` on every matching `CharacterMastery` and save |
| `increaseCheckmark(Character)` | Increment check marks (max `Character.maxCheckMarks`, 18) |
| `decreaseCheckmark(Character)` | Decrement check marks (min 0) |

### Theme Synchronization

| Method | Description |
|--------|-------------|
| `updateThemeForCharacter(ThemeProvider)` | Sync the theme seed color to the current character's class color (black/white when retired, default seed when there are no characters) |

### Edit Mode

| Property | Description |
|----------|-------------|
| `isEditMode` | Getter/setter pair; the setter (`model.isEditMode = true`) updates the state and notifies listeners without bumping `revision`. There is no `setEditMode` method |

### Character Page Rebuilds

Character pages stay mounted across swipes, so widgets inside a page must not `watch<CharactersModel>()` (that rebuilt every visited page on each swipe). Instead:

| API | Description |
|-----|-------------|
| `context.watchCharacterPage(character)` | `BuildContext` extension (`CharacterPageWatch`). Selects `(this page is in edit mode, revision)`, so it rebuilds on data changes and when this page enters or leaves edit mode, but not on a swipe or another page's edit-mode toggle. Returns whether this page is in edit mode — pass that down rather than reading `model.isEditMode`. Use `read<CharactersModel>()` for the model itself |

### Toggle Retired Visibility Logic

When toggling `showRetired`, the model calculates the correct navigation target:

1. If current character is retired and hiding retired:
   - Navigate to next non-retired character
   - Or first non-retired if none after
2. If current character is active:
   - Stay on same character (recalculate index in filtered list)
3. Apply toggle and animate to target page

### State Persistence

- `showRetiredCharacters` key in SharedPrefs

---

## TownModel

> **File**: `lib/viewmodels/town_model.dart`

Manages campaign and party CRUD operations, prosperity/reputation state, and active selection persistence.

### Responsibilities

- Campaign list management (load, create, rename, delete)
- Party management within active campaign
- Active campaign/party selection (persisted to SharedPrefs)
- Prosperity checkmark increment/decrement
- Reputation increment/decrement with bounds (-20 to +20)
- Edit mode toggling

### Dependencies

- `DatabaseHelper` (injected) - for persistence
- `SharedPrefs` - for active campaign/party ID persistence

### Key Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `campaigns` | `List<Campaign>` | [] | All campaigns loaded from database |
| `parties` | `List<Party>` | [] | Parties for active campaign |
| `activeCampaign` | `Campaign?` | null | Currently selected campaign |
| `activeParty` | `Party?` | null | Currently selected party |
| `isEditMode` | `bool` | false | Edit mode state (property setter, notifies) |

### Section Expansion State (passthrough to SharedPrefs)

| Property | Default | Description |
|----------|---------|-------------|
| `townDetailsExpanded` | true | Town details (prosperity + sanctuary) section |
| `partyDetailsExpanded` | true | Party details section |

### Campaign Methods

| Method | Description |
|--------|-------------|
| `loadCampaigns()` | Load all campaigns from database, restore active selection from SharedPrefs |
| `createCampaign({name, edition, startingProsperityCheckmarks})` | Create campaign and set as active |
| `setActiveCampaign(Campaign)` | Switch active campaign, load its parties |
| `renameCampaign(String name)` | Rename the active campaign |
| `deleteActiveCampaign()` | Delete active campaign and its parties |

### Prosperity Methods

| Method | Description |
|--------|-------------|
| `setProsperityLevel(int level)` | Set checkmarks to the threshold for the given level (1–9) |
| `incrementProsperity()` | Add one checkmark (up to max threshold) |
| `decrementProsperity()` | Remove one checkmark (min 1) |

### Donated Gold Methods

| Method | Description |
|--------|-------------|
| `setDonatedGold(int value)` | Set donated gold directly (clamped 0–100); returns `true` when just reaching 100 |
| `incrementDonatedGold({int amount})` | Add gold (default 10, capped at 100); returns `true` when just reaching 100 |
| `decrementDonatedGold({int amount})` | Remove gold (default 10, min 0) |

### Party Methods

| Method | Description |
|--------|-------------|
| `createParty({name, startingReputation})` | Create party in active campaign, set as active |
| `setActiveParty(Party)` | Switch active party |
| `renameParty(String name)` | Rename the active party |
| `deleteActiveParty()` | Delete active party and unlink characters |
| `updatePartyLocation(String location)` | Set the active party's scenario location and save |
| `updatePartyNotes(String notes)` | Set the active party's notes and save |
| `toggleAchievement(String achievement)` | Add the achievement to the active party if absent, remove it if present, and save |

### Reputation Methods

| Method | Description |
|--------|-------------|
| `setReputation(int value)` | Set reputation to exact value, clamped to -20..+20 |
| `incrementReputation()` | Increase reputation by 1 (max +20) |
| `decrementReputation()` | Decrease reputation by 1 (min -20) |

### State Persistence

- `activeCampaignId` key in SharedPrefs (nullable String)
- `activePartyId` key in SharedPrefs (nullable String)

---

## Common Patterns

### Reactive Updates

All models extend `ChangeNotifier` and call `notifyListeners()` when state changes:

```dart
set cardLevel(int value) {
  _cardLevel = value;
  notifyListeners();
}
```

### One Notification per Action

When an action has side effects, apply them with private helpers that don't notify, then notify once at the end. `EnhancementCalculatorModel` does this:

```dart
void enhancementSelected(Enhancement selected) {
  _applyEnhancement(selected); // may clear lost/persistent, lock multi-target
  _changed(); // invalidate cached calculator + notifyListeners()
}
```

### ThemeProvider Dependency

`CharactersModel` writes the selected character's color into `ThemeProvider` but never reacts to theme changes, so it is a plain `ChangeNotifierProvider` that reads `ThemeProvider` once when created:

```dart
ChangeNotifierProvider(
  create: (context) => CharactersModel(
    showRetired: SharedPrefs().showRetiredCharacters,
    databaseHelper: DatabaseHelper.instance,
    themeProvider: context.read<ThemeProvider>(),
  ),
)
```

`ThemeProvider` must stay declared before it in the `MultiProvider`. The root `Builder` in `GloomhavenApp` is the only `MaterialApp` listener: it `context.watch`es `ThemeProvider` and rebuilds `MaterialApp` with the new themes.

### Scroll Controller Sharing

`enhancementCalcScrollController` is owned by `CharactersModel`. Each `CharacterScreen` owns its own `ScrollController` and offset notifier (pages are kept alive across swipes, so a shared controller would attach to several scroll views and break chip navigation); its header, chip bar and background icon listen to that page-local notifier. `charScrollOffsetNotifier` mirrors the offset of the **current** page only — `CharacterScreen._onScroll()` writes to it when the page is current (on both user scrolls and `ScrollMetricsNotification` from section collapse), and a page re-publishes its offset when it becomes current. `GHCAnimatedAppBar` listens to it for tint — this ensures tint clears even when Flutter's `correctPixels()` clamps the offset without firing `ScrollController` listeners.
