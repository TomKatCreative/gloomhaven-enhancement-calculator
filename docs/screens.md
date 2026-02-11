# Screen Documentation

## Create Character Screen

> **File**: `lib/ui/screens/create_character_screen.dart`

The character creation flow uses a full-page route with `Scaffold` and `AppBar`.

### Invocation Pattern

Use the static `show()` method:
```dart
await CreateCharacterScreen.show(context, charactersModel);
```

### Form Fields (top to bottom)

1. **Game Edition** — 3-way `SegmentedButton` (GH / GH2E / FH) with info button. Placed at top since it affects other fields' behavior.
2. **Name** — Text field with random name generator (faker dice icon). Inline **Retirements** +/- counter (0–99) to the right.
3. **Class** — Read-only field that opens `ClassSelectorScreen`. Shows class icon to the right. Create button is disabled until a class is selected.
4. **Personal Quest** — *(gated by `kPersonalQuestsEnabled`)* Read-only field that opens PQ selector dialog. Only enabled for Gloomhaven edition; dimmed with "Coming soon" hint for other editions.
5. **Party** — *(gated by `kTownSheetEnabled`)* Read-only field that opens party assignment bottom sheet. Hidden when no active campaign exists.
6. **Prosperity** — `SfSlider` (1–9) with `PROSPERITY` SVG icon via `SectionLabel`. Shows real-time gold display (GOLD SVG + amount) for GH2E and Frosthaven editions.
7. **Starting Level** — `SfSlider` (1–9) with `LEVEL` SVG icon. Shows warning icon when level exceeds `edition.maxStartingLevel(prosperity)`. Shows real-time gold display for Gloomhaven edition.

### Gold Calculation Display

A real-time gold display (GOLD SVG icon + calculated amount) appears inline with either the level slider (GH) or prosperity slider (GH2E/FH), depending on which parameter drives gold for that edition. Uses `GameEdition.startingGold(level:, prosperityLevel:)` and updates reactively as sliders change.

---

## Selector Screens

The app uses two full-page selector screens with consistent styling for searching and selecting items.

### Shared Components

**SearchSectionHeader** (`lib/ui/widgets/search_section_header.dart`):
A reusable section divider with optional icon:
```
─────────── [Icon] Title ───────────
```

### ClassSelectorScreen

> **File**: `lib/ui/screens/class_selector_screen.dart`

Full-page screen for selecting a player class during character creation.

**Layout:**
```
┌─────────────────────────────────────┐
│ [←]  [🔍 Search...]                 │  ← AppBar with search
├─────────────────────────────────────┤
│ [GH] [JotL] [FH] [MP] ...           │  ← Filter chips
│ Hide locked classes            [✓]  │  ← Toggle
├─────────────────────────────────────┤
│ ──────── Gloomhaven ────────        │  ← Section header
│ [Icon] Brute / Bruiser              │
│ [Icon] Tinkerer                     │
│ ──────── Jaws of the Lion ────────  │
│ ...                                 │
└─────────────────────────────────────┘
```

**Features:**
- Search filters by class name or variant names (e.g., "Bruiser" finds Brute)
- Category filter chips for game editions
- "Hide locked classes" toggle
- Section headers group classes by `ClassCategory`
- Variant selection dialog for multi-edition classes
- Custom class warning dialog for community content

**Invocation:**
```dart
final result = await ClassSelectorScreen.show(context);
if (result != null) {
  // result.playerClass - the PlayerClass
  // result.variant - the Variant (base, gloomhaven2E, etc.)
}
```

### EnhancementTypeSelectorScreen

> **File**: `lib/ui/screens/enhancement_type_selector_screen.dart`

Full-page screen for selecting enhancement types in the calculator.

**Layout:**
```
┌─────────────────────────────────────┐
│ [←]  [🔍 Search...]                 │  ← AppBar with search
├─────────────────────────────────────┤
│ ──────── [+1] +1 Stats ────────     │  ← Section header with icon
│ [MOVE] +1 Move                 30g  │
│ [ATK]  +1 Attack               50g  │
│ ──────── [◇] Elements ────────      │
│ [FIRE] Fire                    50g  │
│ ...                                 │
└─────────────────────────────────────┘
```

**Features:**
- Search filters by enhancement name
- Section headers with category icons group by `EnhancementCategory`
- Cost display shows base cost and discounted cost (with strikethrough)
- Edition-aware: only shows enhancements available in selected `GameEdition`
- Highlights currently selected enhancement

**Invocation:**
```dart
await EnhancementTypeSelector.show(
  context,
  currentSelection: model.enhancement,
  edition: model.edition,
  onSelected: model.enhancementSelected,
);
```

### Design Patterns

Both selectors follow these conventions:
- **AppBar search**: Search field in AppBar title with transparent background
- **SafeArea**: Bottom-only SafeArea for device navigation buttons
- **Static show()**: Invoked via static method returning `Future<T?>`
- **Section headers**: Use `SearchSectionHeader` widget for category grouping

---

## Settings Screen

> **File**: `lib/ui/screens/settings_screen.dart`

The settings screen uses a composition-based architecture with extracted section widgets for maintainability.

### Structure

```
lib/ui/
├── screens/
│   └── settings_screen.dart              # ~260 lines (composition + bottom sheet)
├── widgets/
│   └── settings/
│       ├── settings_section_header.dart  # Section title widget
│       ├── gameplay_settings_section.dart
│       ├── display_settings_section.dart
│       ├── backup_settings_section.dart
│       └── debug_settings_section.dart
├── dialogs/
│   ├── envelope_puzzle_dialog.dart       # Used by gameplay section
│   ├── backup_dialog.dart
│   └── restore_dialog.dart
└── utils/
    └── settings_helpers.dart             # Storage permission, URL launcher, device info
```

### Section Widgets

Each section is a StatelessWidget that receives an `onSettingsChanged` callback:

```dart
GameplaySettingsSection(onSettingsChanged: _onSettingsChanged)
DisplaySettingsSection(onSettingsChanged: _onSettingsChanged)
const BackupSettingsSection()  // No callback needed
const DebugSettingsSection()   // Only shown in kDebugMode
```

### SettingsSectionHeader

Reusable section header with themed styling:

```dart
SettingsSectionHeader(title: AppLocalizations.of(context).gameplay)
```

### Bottom Sheet

The settings screen includes a persistent bottom sheet with:
- Support links (Discord, Instagram, Email)
- Buy Me a Coffee button (Android US region only)
- Version number and changelog link
- License link

---

## Home Screen

> **File**: `lib/ui/screens/home.dart`

The main container/shell for the app, managing navigation between Town, Characters, and Enhancement Calculator pages.

### Structure

```
┌─────────────────────────────────────┐
│ [≡] Title            [⚙] Settings  │  ← GHCAnimatedAppBar
├─────────────────────────────────────┤
│                                     │
│       PageView (swipe disabled)     │
│                                     │
│   Page 0: TownScreen                │
│   Page 1: CharactersScreen          │
│   Page 2: EnhancementCalculatorScreen│
│                                     │
├─────────────────────────────────────┤
│   [Town]  [Characters]  [Calculator]│  ← GHCNavigationBar (M3)
└─────────────────────────────────────┘
                              [FAB] ←── Dynamic action button
```

> **Feature flag**: The Town page (Page 0) and its "Town" nav destination are gated by `kTownSheetEnabled`. When disabled, the PageView only has two pages: Characters (index 0) and Calculator (index 1). Page indices and navigation destinations shift accordingly.

### Initialization

- Loads characters on init via `CharactersModel.loadCharacters()`
- Loads campaigns on init via `TownModel.loadCampaigns()` (only when `kTownSheetEnabled`)
- Shows update dialogs (v4.4.0) if flag set in SharedPrefs
- Uses `FutureBuilder` with loading spinner while characters load

### FAB Logic

The FAB visibility and action changes based on context:

| Page | Condition | Visible? | Action |
|------|-----------|----------|--------|
| Town (0) | No campaigns exist | Hidden | - |
| Town (0) | Campaigns exist | Visible | Toggle edit mode |
| Characters (1) | Element sheet fully expanded | Hidden | - |
| Characters (1) | No characters exist | Visible | Create character |
| Characters (1) | Characters exist | Visible | Toggle edit mode |
| Calculator (2) | Cost sheet expanded OR no cost | Hidden | - |
| Calculator (2) | Has cost to clear | Visible | Reset cost |

### State Reset on Navigation

When switching pages:
- Edit mode is disabled (both Characters and Town)
- Element sheet expansion states are reset
- Prevents stale UI state between pages

### Key Features

- `NeverScrollableScrollPhysics` on PageView (manual nav only via bottom bar)
- `ScaffoldMessengerKey` for snackbars
- Watches all four main models: `AppModel`, `CharactersModel`, `EnhancementCalculatorModel`, `TownModel`
- `AnimatedSwitcher` for smooth FAB icon transitions

---

## Town Screen

> **File**: `lib/ui/screens/town_screen.dart`
>
> **Gated by** `kTownSheetEnabled` — the entire Town tab is hidden from navigation when this flag is `false`.

The Town tab for managing game campaigns and parties.

### Structure

```
┌─────────────────────────────────────┐
│   [PROSPERITY] Campaign Name (Ed.)  │  ← CollapsibleSectionCard (svgAssetKey: 'PROSPERITY')
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │ Prosperity    Level 3       │    │
│  │ ████████░░░░  10/16         │    │  ← ProsperitySection
│  │         [-]          [+]    │    │     (+/- in edit mode)
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👥 Adventure Party     [⇄] │    │  ← PartySection (trailing icon)
│  │ Reputation: +5              │    │     ⇄ = swap (2+ parties)
│  │         [-]          [+]    │    │     ➕ = add (1 party)
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Display States

| State | Display |
|-------|---------|
| No campaigns | `TownEmptyState` — castle icon + "Create a campaign" prompt + button |
| Campaign, no parties | Campaign selector + prosperity section + "Create a party" prompt |
| Campaign + 1 party | Campaign selector + prosperity + party section (trailing: add-party icon) |
| Campaign + 2+ parties | Campaign selector + prosperity + party section (trailing: swap icon → bottom sheet) |

### Edit Mode

Controlled by `townModel.isEditMode` (toggled via FAB):

| Feature | View Mode | Edit Mode |
|---------|-----------|-----------|
| Prosperity | Level + progress bar | + checkmark/- steppers |
| Reputation | Numeric display | +/- steppers |
| Party trailing icon | Swap (2+ parties) or Add (1 party) | Same |
| App bar actions | — | Delete party, delete campaign buttons |

### Section Widgets

| Widget | File | Purpose |
|--------|------|---------|
| `TownEmptyState` | `lib/ui/widgets/town/town_empty_state.dart` | Empty state with create button |
| `ProsperitySection` | `lib/ui/widgets/town/prosperity_section.dart` | Level display + progress bar + edit steppers |
| `PartySection` | `lib/ui/widgets/town/party_section.dart` | Reputation display + edit steppers; optional `trailing` widget (forwarded to `SectionCard`) |
| `CampaignSelector` | `lib/ui/widgets/town/campaign_selector.dart` | Bottom sheet for switching/creating campaigns |

### Party Switching

Party switching uses an inline bottom sheet built in `_showPartySwitcher()` (in `town_screen.dart`), triggered by the swap icon in the `PartySection` header:

- **1 party**: Trailing icon is `group_add_rounded` → opens `CreatePartyScreen`
- **2+ parties**: Trailing icon is `swap_horiz_rounded` → opens bottom sheet with party list + "Create new" button
- **Bottom sheet pattern**: Title row ("Switch party" + "Create" button), divider, `ListTile` per party (active highlighted)

---

## Create Campaign Screen

> **File**: `lib/ui/screens/create_campaign_screen.dart`

Pushed route for creating a new game campaign.

### Invocation

```dart
await CreateCampaignScreen.show(context, townModel);
```

### Form Fields

1. **Name** — Text field for campaign name
2. **Edition** — SegmentedButton (GH / GH2E / FH)
3. **Starting Prosperity** — Numeric input (0-65, defaults to 0)

---

## Create Party Screen

> **File**: `lib/ui/screens/create_party_screen.dart`

Pushed route for creating a new party within the active campaign.

### Invocation

```dart
await CreatePartyScreen.show(context, townModel);
```

### Form Fields

1. **Party Name** — Text field for party name
2. **Starting Reputation** — Numeric input (-20 to +20, defaults to 0)

---

## Character Screen

> **File**: `lib/ui/screens/character_screen.dart`

Displays and edits a single character's stats, perks, masteries, and resources. Embedded within `CharactersScreen` as a PageView child.

### Architecture

Uses a `CustomScrollView` with slivers for efficient scrolling and pinned headers:

```
┌─────────────────────────────────────┐
│ Character Name          [Lvl Badge] │  ← SliverPersistentHeader (pinned)
│ Class Name • (retired)              │     Collapses from 160px → 56px
├─────────────────────────────────────┤
│ [General] [Quest] [Notes] [Perks]   │  ← SliverPersistentHeader (pinned)
│                           [Master.] │     Chip nav bar with scroll-spy
├─────────────────────────────────────┤
│ ▼ General (collapsible)             │  ← CollapsibleSectionCard
│   XP: 45/95    Gold: 120            │
│   Resources: Hide 5, Metal 3, ...   │
├─────────────────────────────────────┤
│ ▼ Personal Quest (collapsible)      │  ← PersonalQuestSection
│   515 - Lawbringer         [swap]   │     (CollapsibleSectionCard internally)
│   ● Kill 20 Bandits...    12/20    │
├─────────────────────────────────────┤
│ Notes                               │  ← SectionCard
│ "Remember to buy boots..."          │     (hidden when empty + view mode)
├─────────────────────────────────────┤
│ Perks                     (3/9)     │  ← SectionCard + badge
│ [✓] Remove two -1 cards             │
│ [ ] Add one rolling PUSH 2          │
├─────────────────────────────────────┤
│ Masteries                           │  ← SectionCard
│ [✓] Complete 3 scenarios without... │     (conditional: FH/CS only)
└─────────────────────────────────────┘
```

### Pinned Header

`_CharacterHeaderDelegate` — a `SliverPersistentHeaderDelegate` that:
- Expands to 160px (name, class info, traits, level badge, faded class icon background)
- Collapses to 56px (name only) on scroll
- In edit mode with non-retired character: stays at max height (name `TextFormField`)
- Elevation increases with scroll progress

### Chip Nav Bar

`_SectionNavBarDelegate` — a pinned `SliverPersistentHeaderDelegate` containing a horizontal row of `ChoiceChip` widgets:
- Labels: General, Quest & Notes, Perks, Masteries (Masteries hidden if class has none). When `kPersonalQuestsEnabled` is `false`, the label is just "Notes" instead of "Quest & Notes". When `kTownSheetEnabled` is `true`, the General section title and chip label show "General" (since it includes the party assignment row); when `false`, they show "Stats".
- **Scroll-spy**: `_onScroll` listener updates `_activeSection` based on which section key is closest to the top
- **Tap-to-scroll**: `_scrollToSection` uses `Scrollable.ensureVisible` to compute target offset, then animates smoothly
- Pinned below the character header

### Section Cards

Two card widgets from `lib/ui/widgets/section_card.dart`:

- **`SectionCard`** — static card with title row (icon + text) and child content. Used for Notes, Perks, Masteries on the character screen, and all three sections on the calculator screen.
- **`CollapsibleSectionCard`** — card with `ExpansionTile` for collapsible sections. Used for General section. Expansion state persisted via `SharedPrefs().generalExpanded`.

Both accept either a Material `icon` (IconData) or an `svgAssetKey` (String) for the title row icon. When `svgAssetKey` is provided (and `icon` is null), a `ThemedSvg` widget renders the SVG icon at `iconSizeSmall` in `contrastedPrimary` color. Both also support an optional `titleWidget` to replace the default `Text` title, and an optional `trailing` widget.

Both use `surfaceContainerLow` background, `outlineVariant` border, `borderRadiusMedium` corners, `contrastedPrimary` title color, and a default `maxWidth: 500`.

### Edit Mode vs View Mode

Controlled by `charactersModel.isEditMode`:

| Section | View Mode | Edit Mode |
|---------|-----------|-----------|
| Name | AutoSizeText | Editable TextFormField |
| Traits | Visible | Hidden |
| XP/Gold | Inline display (gold struck through if retired) | Text fields + add/subtract buttons |
| Checkmarks/Retirements | Hidden | Visible with +/- controls |
| Personal Quest | Progress text (e.g., "12/20") | +/- buttons per requirement, swap quest |
| Resources | Read-only cards | Cards with +/- callbacks |
| Notes | Plain text | Multiline text field |
| Retired badge | Shows if retired | Hidden |

### Content Widgets

- `_StatsSection` — XP, gold (with `StrikethroughText` for retired), battle goals, pocket items
- `_CheckmarksAndRetirementsRow` — edit-mode only row with +/- controls
- `_ResourcesContent` — 9 `ResourceCard` widgets for all resource types
- `PersonalQuestSection` — PQ progress with retirement prompt (see below)
- `_NotesSection` — User notes (hidden when empty and not editing)
- `PerksSection` — Perk checkboxes with parsed game text
- `MasteriesSection` — Mastery checkboxes (conditional display)
- `_PerksCountBadge` — Shows checked/total perk count in Perks card title

### Personal Quest Section

> **File**: `lib/ui/widgets/personal_quest_section.dart`

Three display states:
1. **Quest assigned** — `CollapsibleSectionCard` with quest title, unlock icon in header row, requirements list with progress
2. **No quest + not retired** — `OutlinedButton` "Select a Personal Quest" prompt
3. **No quest + retired** — `SizedBox.shrink()` (hidden)

**Retirement flow** (on PQ completion):
1. `updatePersonalQuestProgress` returns `true` when quest transitions from incomplete → complete
2. Confetti pop via `ConfettiWidget` overlay from bottom-center
3. SnackBar: "Personal quest complete!" with "Retire" action (deduplicated via `isRetirementSnackBarVisible` flag)
4. Tapping "Retire" opens `ConfirmationDialog` with full details
5. Confirming retires the character and updates the theme

### Key Features

- Uses `context.watch<CharactersModel>()` for reactive rebuilds
- Retired characters have disabled edit controls and strikethrough gold
- Bottom padding adjusts for element sheet expansion state
- `ValueKey` on form fields keyed to character UUID
- Max-width constraints (400px) on section cards for responsive design
- Scroll controller from `CharactersModel` for app bar animations

---

## Enhancement Calculator Screen

> **File**: `lib/ui/screens/enhancement_calculator_screen.dart`

Full-page calculator for computing Gloomhaven/Frosthaven enhancement costs.

### Layout

```
┌─────────────────────────────────────┐
│ Enhancement Type                [i] │
│ [MOVE +1]            30g → 25g  ‡*  │  ← Type card with markers
├─────────────────────────────────────┤
│ Card Details                        │
│ ├─ Card Level            [i]        │
│ │  [========○=] 5     +100g  (§*)   │
│ ├─ Previous Enhancements [i]        │
│ │  [0][1][2●][3][4]   +150g  (†*)   │
│ ├─ Multiple Targets      [i]  [OFF] │
│ ├─ Lost Action (GH2E)    [i]  [ON]  │
│ └─ Persistent (FH)       [i]  [OFF] │
├─────────────────────────────────────┤
│ Discounts                           │
│ ├─ Temporary Enhancement  †   [OFF] │
│ ├─ Hail's Discount        ‡   [ON]  │
│ ├─ Party Boon (GH/GH2E)   §   [OFF] │
│ └─ Building 44 (FH)       * → [⚙]   │
└─────────────────────────────────────┘
              [Cost Chip: 275g] ←── Expandable with breakdown
```

### Discount Markers System

Markers indicate which discounts apply to each cost component:

| Marker | Name | Edition | Effect |
|--------|------|---------|--------|
| `†` | Temporary Enhancement | All | -20g flat + ×0.8 |
| `‡` | Hail's Discount | All | -5g flat |
| `§` | Party Boon / Scenario 114 | GH/GH2E | Reduces card level penalty |
| `*` | Building 44 (Enhancer) | FH | Reduces costs at Lvl 2/3/4 |

Multiple markers can combine (e.g., `‡*` = Hail's + Building 44).

### Card Sections

**Enhancement Type Card** (`_EnhancementTypeCard`):
- Info button for category details
- Enhancement selection opens `EnhancementTypeSelectorScreen`
- Shows base cost, discounted cost, and applicable markers

**Card Details Group Card** (`_CardDetailsGroupCard`):
- Card Level slider (1-9) with base penalty (25×level)
- Previous Enhancements segmented buttons (0-9) with penalty (75×count)
- Multiple Targets toggle (×2 for eligible enhancements)
- Lost/Non-Persistent toggle (GH2E/FH: ×0.5)
- Persistent toggle (FH only: ×3)

**Discounts Group Card** (`_DiscountsGroupCard`):
- Toggle items for each discount type
- Building 44 toggle opens `EnhancerDialog` for level configuration

### Edition-Specific Features

| Feature | GH | GH2E | FH |
|---------|----|----|-----|
| Lost modifier | No | Yes (×0.5) | Yes (×0.5) |
| Persistent modifier | No | No | Yes (×3) |
| Party Boon / Scenario 114 | Yes | Yes | No |
| Building 44 (Enhancer) | No | No | Yes |
| Multi-target on Target/Elements | Yes | No | No |

### Cost Chip Overlay

The `ExpandableCostChip` widget shows:
- Final calculated cost
- Expandable breakdown with each calculation step
- Step-by-step formula explanation

### Key Features

- Watches both `EnhancementCalculatorModel` and `ThemeProvider`
- Dynamic calculation via `model.calculateCost(notify: false)`
- All toggles trigger cost recalculation
- Info buttons use `InfoDialog` with rich text from `Strings`
- Bottom padding adjusts for cost chip visibility

---

## Characters Screen

> **File**: `lib/ui/screens/characters_screen.dart`

Horizontal PageView container for browsing all characters.

### Structure

```
┌─────────────────────────────────────┐
│ ← CharacterScreen 1 →               │
│ ← CharacterScreen 2 →               │  ← Swipeable pages
│ ← CharacterScreen 3 →               │
├─────────────────────────────────────┤
│ [● ○ ○]                             │  ← Page indicator dots
└─────────────────────────────────────┘
```

### Features

- `PageView` with horizontal swipe navigation
- Page indicator dots showing current position
- Filters retired characters based on `showRetired` toggle
- Empty state prompts character creation
- Element tracker sheet overlay (slides up from bottom)
