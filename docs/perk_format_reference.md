# Perk Format Reference

This document describes the format for defining perks in `perks_repository.dart`.

## Perk Class Structure

```dart
Perk(
  'perk text with KEYWORDS for icons',
  quantity: 1,      // Number of checkboxes (default: 1)
  grouped: false,   // If true, grouped with previous perk (default: false)
)
```

- **quantity**: How many checkboxes appear next to this perk (usually 1-3)
- **grouped**: When `true`, this perk shares checkboxes with the previous perk (both must be checked together). Used for multi-part perks like "Take 2 of these 3 options"

## Perks Wrapper Class

```dart
Perks([
  Perk(...),
  Perk(...),
], variant: Variant.base)
```

Each class can have multiple variants:
- `Variant.base` - Original version
- `Variant.frosthavenCrossover` - Frosthaven crossover version
- `Variant.gloomhaven2E` - Gloomhaven 2nd Edition version
- `Variant.v2`, `Variant.v3`, `Variant.v4` - For classes with multiple versions

## Inline Icon Keywords

Keywords are replaced with inline icons in the UI. Use ALL_CAPS for most icons.

### Action Verbs (use string constants)
| Constant | Value | Usage |
|----------|-------|-------|
| `$_add` | "Add" | Adding cards |
| `$_remove` | "Remove" | Removing cards |
| `$_replace` | "Replace" | Replacing cards |

### Numbers (use string constants)
| Constant | Value |
|----------|-------|
| `$_one` | "one" |
| `$_two` | "two" |
| `$_three` | "three" |
| `$_four` | "four" |

### Card Terms
| Keyword | Description |
|---------|-------------|
| `$_card` | "card" (singular) |
| `$_cards` | "cards" (plural) |
| `$_rolling` | "Rolling" - for rolling modifier cards |
| `$_shuffle` | "SHUFFLE" - shuffle icon |
| `$_null` | "NULL" - null attack modifier |
| `$_loss` | "LOSS" - loss icon |

### Attack Modifier Values
| Keyword | Description |
|---------|-------------|
| `$_plusZero` | "pluszero" - +0 modifier icon |
| `$_plusOne` | "plusone" - +1 modifier icon |
| `$_plusTwo` | "plustwo" - +2 modifier icon |

### Conditions/Effects (ALL_CAPS become icons)
| Keyword | Icon |
|---------|------|
| `$_stun` | STUN |
| `$_disarm` | DISARM |
| `$_muddle` | MUDDLE |
| `$_wound` | WOUND |
| `$_poison` | POISON |
| `$_immobilize` | IMMOBILIZE |
| `$_curse` | CURSE |
| `$_bless` | BLESS |
| `$_strengthen` | STRENGTHEN |
| `$_invisible` | INVISIBLE |
| `$_regenerate` | REGENERATE |
| `$_ward` | WARD |
| `$_brittle` | BRITTLE |
| `$_impair` | IMPAIR |
| `$_rupture` | RUPTURE |
| `$_enfeeble` | ENFEEBLE |
| `$_empower` | EMPOWER |
| `$_safeguard` | SAFEGUARD |

### Combat Keywords
| Keyword | Icon |
|---------|------|
| `$_attack` | ATTACK |
| `$_damage` | DAMAGE |
| `$_heal` | HEAL |
| `$_shield` | SHIELD |
| `$_retaliate` | RETALIATE |
| `$_pierce` | PIERCE |
| `$_push` | PUSH |
| `$_pull` | PULL |
| `$_range` | RANGE |
| `$_move` | MOVE |
| `$_teleport` | TELEPORT |
| `$_flying` | FLYING |
| `$_loot` | LOOT |
| `$_recover` | RECOVER |
| `$_refresh` | REFRESH |

### Target Icons
| Keyword | Description |
|---------|-------------|
| `$_targetCircle` | TARGET_CIRCLE - circular target icon |
| `$_targetDiamond` | TARGET_DIAMOND - diamond target icon |

### Elements
| Keyword | Icon |
|---------|------|
| `$_fire` | FIRE |
| `$_ice` | ICE |
| `$_earth` | EARTH |
| `$_air` | AIR |
| `$_light` | LIGHT |
| `$_dark` | DARK |
| `$_wildElement` | Wild_Element |
| `$_consume` | consume_ (prefix for consuming elements) |

### Equipment Slots
| Keyword | Icon |
|---------|------|
| `$_body` | Body |
| `$_pocket` | Pocket |
| `$_oneHand` | One_Hand |
| `$_twoHand` | Two_Hand |

### Class-Specific Keywords
| Keyword | Class |
|---------|-------|
| `EXPERIMENT` | Alchemancer vial icon |
| `Vial_Wild` | Alchemancer wild vial triangle icon |
| `$_song` | SONG (Soothsinger) |
| `$_doom` | DOOM (Doomstalker) |
| `$_bear` | BEAR (Wildfury) |
| `$_command` | COMMAND (Wildfury) |
| `$_rift` | RIFT (Cassandra) |
| `$_resolve` | RESOLVE (Hail) |
| `$_reaver` | REAVER (Incarnate) |
| `$_ritualist` | RITUALIST (Incarnate) |
| `$_conqueror` | CONQUEROR (Incarnate) |
| `$_hail` | HAIL |
| `$_supplies` | SUPPLIES (Quartermaster) |
| `$_prescription` | PRESCRIPTION (Sawbones) |
| `$_tear` | TEAR (Nightshroud) |
| `$_critters` | CRITTERS |
| `$_project` | PROJECT |
| `$_barrierPlus` | BARRIER_PLUS |

## Common Perk Phrases

### Scenario/Item Effects
```dart
'Ignore negative item effects'
'Ignore negative item effects and add ...'
'Ignore negative item effects and remove ...'
'Ignore negative scenario effects'
'Ignore negative scenario effects and add ...'
'Ignore scenario effects'
'Ignore scenario effects and add ...'
'Ignore item item_minus_one effects'
'Ignore item item_minus_one effects and add ...'
```

### Timing Triggers
```dart
'At the start of each scenario'
'At the end of each scenario'
'Once each scenario'
'Once per scenario'
'Whenever you long rest'
'Whenever you short rest'
```

### Named Perks (Frosthaven Crossover style)
Use **bold** markdown for named perks:
```dart
'**Perk Name:** Description of the perk effect'
```

## Example Perk Lists

### Simple Class (Single Variant)
```dart
ClassCodes.className: [
  Perks([
    Perk('Remove two -1 cards'),
    Perk('Replace one -1 card with one +1 card', quantity: 2),
    Perk('Add one +2 FIRE card'),
    Perk('Add one Rolling STUN card'),
    Perk('Ignore negative scenario effects'),
  ], variant: Variant.base),
],
```

### Class with Multiple Variants
```dart
ClassCodes.className: [
  // Base version
  Perks([
    Perk('Remove two -1 cards'),
    Perk('Add one +2 card'),
  ], variant: Variant.base),

  // Frosthaven Crossover version
  Perks([
    Perk('Replace one -1 card with one +1 card'),
    Perk('**Named Perk:** Special ability description'),
  ], variant: Variant.frosthavenCrossover),

  // Gloomhaven 2E version
  Perks([
    Perk('Replace one -2 card with one +0 card'),
    Perk('Once each scenario, during your turn, you may perform: HEAL 2, Self'),
  ], variant: Variant.gloomhaven2E),
],
```

### Grouped Perks Example
When multiple perk lines share checkboxes (e.g., "choose 2 of these 3"):
```dart
Perk('Option A: some effect', quantity: 2, grouped: true),
Perk('Option B: some effect', grouped: true),
Perk('Option C: some effect', grouped: true),
```

## Formatting Guidelines

1. **Capitalization**:
   - Action verbs (Add, Remove, Replace) are capitalized
   - Numbers written as words (one, two, three) are lowercase
   - Keywords for icons are ALL_CAPS (STUN, FIRE, etc.)

2. **Punctuation**:
   - No period at end of perk text
   - Use commas to separate multiple effects
   - Use "and" before the last item in a list

3. **Quotation marks**:
   - Use double quotes for effects that apply as a unit: `"HEAL 2, Self"`
   - Use single quotes for card names: `*Reviving Ether*`

4. **Compound elements**:
   - Use `/` for either/or elements: `FIRE/ICE`
   - Use "and" for both: `FIRE and ICE`

5. **Self-targeting**:
   - Append ", Self" or ", self" for self-targeting effects
   - Example: `"SHIELD 1, Self"`

## Adding a New Class

1. Add class code to `character_constants.dart`:
   ```dart
   static const newClass = 'newclass';
   ```

2. Add perks to `perks_repository.dart`:
   ```dart
   ClassCodes.newClass: [
     Perks([
       // List of Perk objects
     ], variant: Variant.base),
   ],
   ```

3. Add class definition to `player_class_constants.dart`

4. Add class icon SVG to `images/class_icons/`
