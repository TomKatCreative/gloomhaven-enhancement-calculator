# Enhancement Cost Rules by Game Edition

This document outlines the enhancement cost calculation rules for each supported game edition.

## Supported Editions

| Edition | Abbreviation | Description |
|---------|--------------|-------------|
| Gloomhaven | GH | Original Gloomhaven (1st Edition) |
| Gloomhaven 2E | GH 2E | Gloomhaven Second Edition |
| Frosthaven | FH | Frosthaven |

## Base Cost

Each enhancement has a base cost that varies by edition. Select the appropriate edition in the app to see the correct costs.

GH 2E and Frosthaven use identical base costs.

## Cost Modifiers

### Multiple Targets

If an ability targets multiple figures or tiles, the base cost is **doubled**.

| Edition | Applies to |
|---------|-----------|
| Gloomhaven | All enhancement types (except Hex) |
| Gloomhaven 2E | All except Target, Hex, and Element enhancements |
| Frosthaven | All except Target, Hex, and Element enhancements |

### Card Level

Add **25 gold** for each level of the ability card above level 1.

**Party Boon** (GH and GH 2E only): If unlocked, reduces this penalty by 5 gold per level.

### Previous Enhancements

Add **75 gold** for each enhancement already on the same action.

**Enhancer Level 4** (FH only): Reduces this penalty by 25 gold per previous enhancement.

### Lost Action

**Halves** the base cost when applicable.

| Edition | Rule | Summon Stat Enhancements |
|---------|------|--------------------------|
| Gloomhaven | N/A | N/A |
| Gloomhaven 2E | Lost icon AND not a summon action | **Excluded** (always) |
| Frosthaven | Lost icon AND no persistent icon | Allowed (if action is lost but not persistent) |

**Key Difference:** In GH 2E, summon stat enhancements never get the lost discount because they're always on summon actions. In Frosthaven, the exclusion is based on the persistent icon, so a lost non-persistent summon could theoretically get the discount.

**UI Note:** In GH 2E, the toggle shows only the Lost icon and is disabled for summon stat enhancements. In Frosthaven, the toggle shows both Lost and "not Persistent" icons.

### Persistent Action

If the action has a Persistent icon, **triple** the base cost. Does not apply to summon stat enhancements.

| Edition | Available |
|---------|-----------|
| Gloomhaven | No |
| Gloomhaven 2E | No |
| Frosthaven | Yes |

**Note:** Lost and Persistent modifiers are mutually exclusive in the calculator. An action cannot benefit from the Lost discount if it has the Persistent icon (since persistent actions triple the cost instead).

## Enhancement Availability by Edition

| Enhancement | GH | GH 2E | FH |
|-------------|:--:|:-----:|:--:|
| Disarm | ✓ | ✗ | ✗ |
| Ward | ✗ | ✓ | ✓ |
| All others | ✓ | ✓ | ✓ |

## Frosthaven-Only Features

These features are only available when Frosthaven edition is selected:

- **Enhancer Building Levels**: Unlock discounts at the Enhancer building
  - Level 2: -10 gold from base enhancement cost
  - Level 3: -10 gold per card level penalty
  - Level 4: -25 gold per previous enhancement penalty
- **Temporary Enhancement Mode**: 20% discount, reduced previous enhancement penalty

## Gloomhaven / GH 2E Features

- **Party Boon**: When unlocked, reduces the card level penalty by 5 gold per level

## All Editions

- **Hail's Discount**: 5 gold reduction from enhancement base cost (Hail character perk, indicated by ‡)

## Area-of-Effect Hex Costs

Hex enhancement costs are calculated as **200 gold ÷ number of existing hexes**, with rounding depending on edition:

| Edition | Rounding |
|---------|----------|
| Gloomhaven | Rounded **down** (floor) |
| Gloomhaven 2E | Rounded **up** (ceiling) |
| Frosthaven | Rounded **up** (ceiling) |

This means some hex costs differ between GH and GH2E/FH (e.g., 6 hexes = 33g in GH, 34g in GH2E/FH).

## Quick Reference

| Rule | GH | GH 2E | FH |
|------|:--:|:-----:|:--:|
| Party Boon discount | ✓ | ✓ | ✗ |
| Lost action halves cost | ✗ | ✓ | ✓ |
| Lost discount on summon stats | ✗ | ✗ | ✓ |
| Persistent triples cost | ✗ | ✗ | ✓ |
| Enhancer building levels | ✗ | ✗ | ✓ |
| Hail's Discount (-5g) | ✓ | ✓ | ✓ |
| Multi-target on Target | ✓ | ✗ | ✗ |
| Multi-target on Elements | ✓ | ✗ | ✗ |
| Hex costs rounded up | ✗ | ✓ | ✓ |
