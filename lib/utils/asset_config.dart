// ============================================================================
// SVG THEME MODE
// ============================================================================

/// Defines how an SVG asset's colors should adapt to the app theme.
///
/// Uses a sealed class hierarchy to make invalid states unrepresentable.
/// Previously this was two mutually-exclusive booleans.
sealed class SvgThemeMode {
  const SvgThemeMode();
}

/// No theming - renders SVG exactly as defined in the file.
///
/// Use this for:
/// - Icons that look good on both light and dark backgrounds as-is
/// - Colorful icons that don't need theme adaptation
class NoTheme extends SvgThemeMode {
  const NoTheme();
}

/// Modern approach: only `currentColor` parts change with theme.
///
/// Parts of the SVG that use `fill="currentColor"` or `stroke="currentColor"`
/// will change based on the theme:
/// - In dark mode: `currentColor` parts become white
/// - In light mode: `currentColor` parts become black
///
/// Other colors in the SVG are preserved.
///
/// This works for both **monochrome icons** (where the entire icon uses
/// `currentColor`) and **multi-color icons** (where only specific parts like
/// borders use `currentColor` while other colors stay fixed).
///
/// Examples:
/// - Move icon, Attack icon - entire icon uses `fill="currentColor"`
/// - Wild element icon - colorful pie chart stays the same, but the border
///   uses `currentColor` and adapts to the theme
class CurrentColorTheme extends SvgThemeMode {
  const CurrentColorTheme();
}

// ============================================================================
// ASSET CONFIG
// ============================================================================

/// Configuration for how an SVG asset should be rendered and themed.
class AssetConfig {
  /// The file path to the SVG asset (relative to images/ directory).
  /// Used for dark theme, or both themes if [lightPath] is null.
  final String path;

  /// Optional alternate path for light theme.
  /// If null, [path] is used for both themes.
  final String? lightPath;

  /// How the SVG's colors should adapt to the app theme.
  final SvgThemeMode themeMode;

  /// Width multiplier for non-square icons.
  /// Default is 1.0 (square). Use 1.5, 2.0, 3.0 for wider icons.
  final double widthMultiplier;

  const AssetConfig(
    this.path, {
    this.lightPath,
    this.themeMode = const NoTheme(),
    this.widthMultiplier = 1.0,
  });

  /// Returns the appropriate path based on theme.
  String pathForTheme(bool darkTheme) => darkTheme ? path : (lightPath ?? path);

  /// Convenience getter for checking if asset uses currentColor theming.
  bool get usesCurrentColor => themeMode is CurrentColorTheme;
}

// ============================================================================
// ASSET MAP
// ============================================================================

/// All asset configurations.
///
/// For assets that need different files per theme, use [lightPath].
/// For assets that adapt via SVG theming, use [themeMode].
const Map<String, AssetConfig> assets = {
  // ===========================================================================
  // actions/
  // ===========================================================================
  'ATTACK': AssetConfig('actions/attack.svg', themeMode: CurrentColorTheme()),
  'FLYING': AssetConfig('actions/flying.svg', themeMode: CurrentColorTheme()),
  'HEAL': AssetConfig('actions/heal.svg', themeMode: CurrentColorTheme()),
  'JUMP': AssetConfig('actions/jump.svg', themeMode: CurrentColorTheme()),
  'LOOT': AssetConfig('actions/loot.svg', themeMode: CurrentColorTheme()),
  'MOVE': AssetConfig('actions/move.svg', themeMode: CurrentColorTheme()),
  'PIERCE': AssetConfig('actions/pierce.svg'),
  'PULL': AssetConfig('actions/pull.svg'),
  'PUSH': AssetConfig('actions/push.svg'),
  'RANGE': AssetConfig('actions/range.svg', themeMode: CurrentColorTheme()),
  'RETALIATE': AssetConfig(
    'actions/retaliate.svg',
    themeMode: CurrentColorTheme(),
  ),
  'SHIELD': AssetConfig('actions/shield.svg', themeMode: CurrentColorTheme()),
  'TARGET_CIRCLE': AssetConfig(
    'actions/target_circle.svg',
    themeMode: CurrentColorTheme(),
  ),
  'TARGET_DIAMOND': AssetConfig('actions/target.svg'),
  'TELEPORT': AssetConfig(
    'actions/teleport.svg',
    themeMode: CurrentColorTheme(),
  ),

  // ===========================================================================
  // attack_modifiers/
  // ===========================================================================
  'NULL': AssetConfig('attack_modifiers/null.svg'),
  '-2': AssetConfig('attack_modifiers/minus_2.svg'),
  '-1': AssetConfig('attack_modifiers/minus_1.svg'),
  '+0': AssetConfig('attack_modifiers/plus_0.svg'),
  '+1': AssetConfig('attack_modifiers/plus_1.svg'),
  '+2': AssetConfig('attack_modifiers/plus_2.svg'),
  '+3': AssetConfig('attack_modifiers/plus_3.svg'),
  '+4': AssetConfig('attack_modifiers/plus_4.svg'),
  '+X': AssetConfig('attack_modifiers/plus_x.svg'),
  '2x': AssetConfig('attack_modifiers/2_x.svg'),

  // ===========================================================================
  // card_mechanics/
  // ===========================================================================
  'LOSS': AssetConfig(
    'card_mechanics/loss.svg',
    themeMode: CurrentColorTheme(),
  ),
  'PERSIST': AssetConfig(
    'card_mechanics/persist.svg',
    themeMode: CurrentColorTheme(),
  ),
  'PERSISTENT': AssetConfig(
    'card_mechanics/persistent.svg',
    lightPath: 'card_mechanics/persistent_light.svg',
  ),
  'RECOVER': AssetConfig(
    'card_mechanics/recover_card.svg',
    themeMode: CurrentColorTheme(),
  ),
  'REFRESH': AssetConfig(
    'card_mechanics/refresh.svg',
    lightPath: 'card_mechanics/refresh_light.svg',
  ),
  'Rolling': AssetConfig('card_mechanics/rolling.svg'),
  'SHUFFLE': AssetConfig(
    'card_mechanics/shuffle.svg',
    themeMode: CurrentColorTheme(),
  ),
  'SPENT': AssetConfig(
    'card_mechanics/spent.svg',
    lightPath: 'card_mechanics/spent_light.svg',
  ),

  // ===========================================================================
  // class_abilities/
  // ===========================================================================
  'ALL_STANCES': AssetConfig(
    'class_abilities/incarnate_all_stances.svg',
    widthMultiplier: 3.0,
  ),
  'BARRIER_PLUS': AssetConfig(
    'class_abilities/barrier_plus.svg',
    themeMode: CurrentColorTheme(),
  ),
  'CONQUEROR': AssetConfig('class_abilities/conqueror.svg'),
  'CRITTERS': AssetConfig(
    'class_abilities/critters.svg',
    themeMode: CurrentColorTheme(),
  ),
  'CRYSTALLIZE': AssetConfig(
    'class_abilities/crystallize.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Cultivate': AssetConfig(
    'class_abilities/cultivate.svg',
    themeMode: CurrentColorTheme(),
  ),
  'EXPERIMENT': AssetConfig('class_abilities/experiment.svg'),
  'Glow': AssetConfig('class_abilities/glow.svg'),
  'INFUSION': AssetConfig('class_abilities/infusion.svg'),
  'Ladder': AssetConfig(
    'class_abilities/ladder.svg',
    themeMode: CurrentColorTheme(),
  ),
  'LUMINARY_HEXES': AssetConfig(
    'class_abilities/luminary_hexes.svg',
    widthMultiplier: 1.5,
  ),
  'PRESSURE_GAIN': AssetConfig('class_abilities/pressure_gain.svg'),
  'PRESSURE_HIGH': AssetConfig('class_abilities/pressure_high.svg'),
  'PRESSURE_LOSE': AssetConfig('class_abilities/pressure_lose.svg'),
  'PRESSURE_LOW': AssetConfig('class_abilities/pressure_low.svg'),
  'PROJECT': AssetConfig(
    'class_abilities/project.svg',
    themeMode: CurrentColorTheme(),
  ),
  'REAVER': AssetConfig('class_abilities/reaver.svg'),
  'RESOLVE': AssetConfig(
    'class_abilities/resolve.svg',
    themeMode: CurrentColorTheme(),
  ),
  'RESONANCE': AssetConfig('class_abilities/resonance.svg'),
  'RITUALIST': AssetConfig('class_abilities/ritualist.svg'),
  'SATED': AssetConfig('class_abilities/sated.svg'),
  'SHADOW': AssetConfig('class_abilities/shadow.svg'),
  'Shrug_Off': AssetConfig(
    'class_abilities/shrug_off.svg',
    themeMode: CurrentColorTheme(),
  ),
  'SPARK': AssetConfig(
    'class_abilities/spark.svg',
    themeMode: CurrentColorTheme(),
  ),
  'consume_SPARK': AssetConfig(
    'class_abilities/spark.svg',
    themeMode: CurrentColorTheme(),
  ),
  'SWING': AssetConfig('class_abilities/swing.svg'),
  'TIDE': AssetConfig('class_abilities/tide.svg'),
  'TIME_TOKEN': AssetConfig('class_abilities/time_token.svg'),
  'TRANSFER': AssetConfig('class_abilities/transfer.svg', widthMultiplier: 2.0),
  'TROPHY': AssetConfig('class_abilities/trophy.svg'),
  'Vial_Wild': AssetConfig(
    'class_abilities/vial_wild.svg',
    themeMode: CurrentColorTheme(),
  ),
  'VOID': AssetConfig('class_abilities/void.svg'),
  'VOIDSIGHT': AssetConfig(
    'class_abilities/voidsight.svg',
    themeMode: CurrentColorTheme(),
  ),

  // ===========================================================================
  // class_icons/
  // ===========================================================================
  'Berserker': AssetConfig(
    'class_icons/berserker.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Bladeswarm': AssetConfig(
    'class_icons/bladeswarm.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Boneshaper': AssetConfig(
    'class_icons/boneshaper.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Chieftain': AssetConfig(
    'class_icons/chieftain.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Doomstalker': AssetConfig(
    'class_icons/doomstalker.svg',
    themeMode: CurrentColorTheme(),
  ),
  'HAIL': AssetConfig('class_icons/hail.svg', themeMode: CurrentColorTheme()),
  'Projectile': AssetConfig(
    'class_icons/bombard.svg',
    themeMode: CurrentColorTheme(),
  ),
  'RAGE': AssetConfig(
    'class_icons/vanquisher.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Shackle': AssetConfig(
    'class_icons/chainguard.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Shackled': AssetConfig(
    'class_icons/chainguard.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Spirit': AssetConfig(
    'class_icons/spirit_caller.svg',
    themeMode: CurrentColorTheme(),
  ),

  // ===========================================================================
  // elements/
  // ===========================================================================
  'CONSUME': AssetConfig(
    'elements/consume.svg',
    themeMode: CurrentColorTheme(),
  ),
  'AIR': AssetConfig('elements/elem_air.svg', themeMode: CurrentColorTheme()),
  'consume_AIR': AssetConfig(
    'elements/elem_air.svg',
    themeMode: CurrentColorTheme(),
  ),
  'DARK': AssetConfig('elements/elem_dark.svg', themeMode: CurrentColorTheme()),
  'consume_DARK': AssetConfig(
    'elements/elem_dark.svg',
    themeMode: CurrentColorTheme(),
  ),
  'EARTH': AssetConfig(
    'elements/elem_earth.svg',
    themeMode: CurrentColorTheme(),
  ),
  'consume_EARTH': AssetConfig(
    'elements/elem_earth.svg',
    themeMode: CurrentColorTheme(),
  ),
  'FIRE': AssetConfig('elements/elem_fire.svg', themeMode: CurrentColorTheme()),
  'consume_FIRE': AssetConfig(
    'elements/elem_fire.svg',
    themeMode: CurrentColorTheme(),
  ),
  'ICE': AssetConfig('elements/elem_ice.svg', themeMode: CurrentColorTheme()),
  'consume_ICE': AssetConfig(
    'elements/elem_ice.svg',
    themeMode: CurrentColorTheme(),
  ),
  'LIGHT': AssetConfig(
    'elements/elem_light.svg',
    themeMode: CurrentColorTheme(),
  ),
  'consume_LIGHT': AssetConfig(
    'elements/elem_light.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Wild_Element': AssetConfig(
    'elements/elem_wild.svg',
    themeMode: CurrentColorTheme(),
  ),
  'consume_Wild_Element': AssetConfig(
    'elements/elem_wild.svg',
    themeMode: CurrentColorTheme(),
  ),
  // Element combinations
  'AIR/DARK': AssetConfig(
    'elements/elem_air_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'consume_AIR/DARK': AssetConfig(
    'elements/elem_air_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'AIR/EARTH': AssetConfig(
    'elements/elem_air_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'consume_AIR/EARTH': AssetConfig(
    'elements/elem_air_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'AIR/LIGHT': AssetConfig(
    'elements/elem_air_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'consume_AIR/LIGHT': AssetConfig(
    'elements/elem_air_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'EARTH/DARK': AssetConfig(
    'elements/elem_earth_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'consume_EARTH/DARK': AssetConfig(
    'elements/elem_earth_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'EARTH/LIGHT': AssetConfig(
    'elements/elem_earth_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'consume_EARTH/LIGHT': AssetConfig(
    'elements/elem_earth_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/AIR': AssetConfig(
    'elements/elem_fire_or_air.svg',
    widthMultiplier: 2.0,
  ),
  'consume_FIRE/AIR': AssetConfig(
    'elements/elem_fire_or_air.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/DARK': AssetConfig(
    'elements/elem_fire_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'consume_FIRE/DARK': AssetConfig(
    'elements/elem_fire_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/EARTH': AssetConfig(
    'elements/elem_fire_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'consume_FIRE/EARTH': AssetConfig(
    'elements/elem_fire_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/ICE': AssetConfig(
    'elements/elem_fire_or_ice.svg',
    widthMultiplier: 2.0,
  ),
  'consume_FIRE/ICE': AssetConfig(
    'elements/elem_fire_or_ice.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/LIGHT': AssetConfig(
    'elements/elem_fire_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'consume_FIRE/LIGHT': AssetConfig(
    'elements/elem_fire_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'ICE/AIR': AssetConfig('elements/elem_ice_or_air.svg', widthMultiplier: 2.0),
  'consume_ICE/AIR': AssetConfig(
    'elements/elem_ice_or_air.svg',
    widthMultiplier: 2.0,
  ),
  'ICE/DARK': AssetConfig(
    'elements/elem_ice_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'consume_ICE/DARK': AssetConfig(
    'elements/elem_ice_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'ICE/EARTH': AssetConfig(
    'elements/elem_ice_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'consume_ICE/EARTH': AssetConfig(
    'elements/elem_ice_or_earth.svg',
    widthMultiplier: 2.0,
  ),
  'ICE/LIGHT': AssetConfig(
    'elements/elem_ice_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'consume_ICE/LIGHT': AssetConfig(
    'elements/elem_ice_or_light.svg',
    widthMultiplier: 2.0,
  ),
  'LIGHT/DARK': AssetConfig(
    'elements/elem_light_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'consume_LIGHT/DARK': AssetConfig(
    'elements/elem_light_or_dark.svg',
    widthMultiplier: 2.0,
  ),
  'FIRE/ICE/EARTH': AssetConfig(
    'elements/elem_fire_ice_earth.svg',
    themeMode: CurrentColorTheme(),
    widthMultiplier: 3.0,
  ),

  // ===========================================================================
  // equipment_slots/
  // ===========================================================================
  'Body': AssetConfig(
    'equipment_slots/body.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Head': AssetConfig(
    'equipment_slots/head.svg',
    themeMode: CurrentColorTheme(),
  ),
  'One_Hand': AssetConfig(
    'equipment_slots/one_handed.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Pocket': AssetConfig(
    'equipment_slots/pocket.svg',
    themeMode: CurrentColorTheme(),
  ),
  'Two_Hand': AssetConfig(
    'equipment_slots/two_handed.svg',
    themeMode: CurrentColorTheme(),
  ),

  // ===========================================================================
  // pips/
  // ===========================================================================
  'pip_circle': AssetConfig('pips/circle.svg'),
  'pip_diamond': AssetConfig('pips/diamond.svg'),
  'pip_diamond_plus': AssetConfig('pips/diamond_plus.svg'),
  'pip_hex': AssetConfig('pips/hex.svg'),
  'pip_plus_one': AssetConfig('pips/pip_plus_one.svg'),
  'pip_square': AssetConfig('pips/square.svg'),

  // ===========================================================================
  // status_effects/
  // ===========================================================================
  'BANE': AssetConfig('status_effects/bane.svg'),
  'BLESS': AssetConfig('status_effects/bless.svg'),
  'BRITTLE': AssetConfig('status_effects/brittle.svg'),
  'CHILL': AssetConfig('status_effects/chill.svg'),
  'CURSE': AssetConfig('status_effects/curse.svg'),
  'DISARM': AssetConfig('status_effects/disarm.svg'),
  'DODGE': AssetConfig('status_effects/dodge.svg'),
  'EMPOWER': AssetConfig('status_effects/empower.svg'),
  'ENFEEBLE': AssetConfig('status_effects/enfeeble.svg'),
  'IMMOBILIZE': AssetConfig('status_effects/immobilize.svg'),
  'IMPAIR': AssetConfig('status_effects/impair.svg'),
  'INFECT': AssetConfig('status_effects/infect.svg'),
  'INVISIBLE': AssetConfig('status_effects/invisible.svg'),
  'MUDDLE': AssetConfig('status_effects/muddle.svg'),
  'POISON': AssetConfig('status_effects/poison.svg'),
  'PROVOKE': AssetConfig('status_effects/provoke.svg'),
  'REGENERATE': AssetConfig('status_effects/regenerate.svg'),
  'RUPTURE': AssetConfig('status_effects/rupture.svg'),
  'SAFEGUARD': AssetConfig('status_effects/safeguard.svg'),
  'STRENGTHEN': AssetConfig('status_effects/strengthen.svg'),
  'STUN': AssetConfig('status_effects/stun.svg'),
  'WARD': AssetConfig('status_effects/ward.svg'),
  'WOUND': AssetConfig('status_effects/wound.svg'),

  // ===========================================================================
  // ui/
  // ===========================================================================
  'CLASS': AssetConfig('ui/class.svg', themeMode: CurrentColorTheme()),
  'DAMAGE': AssetConfig('ui/damage.svg', lightPath: 'ui/damage_light.svg'),
  'hex': AssetConfig('ui/hex.svg'),
  'HP': AssetConfig('ui/hp.svg', themeMode: CurrentColorTheme()),
  'LEVEL': AssetConfig('ui/level.svg', themeMode: CurrentColorTheme()),
  'item_minus_one': AssetConfig(
    'ui/item_minus_one.svg',
    lightPath: 'ui/item_minus_one_light.svg',
    widthMultiplier: 1.5,
  ),
  'plus_one': AssetConfig(
    'ui/plus_one.svg',
    lightPath: 'ui/plus_one_light.svg',
  ),
  'SECTION': AssetConfig('ui/section.svg', themeMode: CurrentColorTheme()),
  'xp': AssetConfig('ui/xp.svg', themeMode: CurrentColorTheme()),
};

/// Get asset configuration for a given asset key.
///
/// This function cleans the input string and returns the appropriate
/// asset configuration. Use [AssetConfig.pathForTheme] to get the correct
/// path for light/dark themes.
///
/// Special handling for XP values (xp8, xp10, etc. -> ui/xp.svg).
///
/// Throws [AssertionError] if no configuration is found.
AssetConfig getAssetConfig(String element) {
  // Clean the input string - remove punctuation
  String cleanElement = element.replaceAll(
    RegExp(
      r"[,.:()"
      "'"
      '"'
      "]",
    ),
    '',
  );

  // Handle XP pattern (xp8, xp10, etc.)
  if (RegExp(r'^xp\d+$').hasMatch(cleanElement)) {
    return const AssetConfig('ui/xp.svg', themeMode: CurrentColorTheme());
  }

  // Check assets by key
  final asset = assets[cleanElement];
  if (asset != null) {
    return asset;
  }

  // No configuration found - this indicates a missing asset definition
  throw AssertionError(
    'No asset configuration found for "$cleanElement". '
    'Add it to standardAssets in asset_config.dart.',
  );
}

/// Try to get asset configuration, returning null if not found.
///
/// Use this when checking if a string might be an asset key (e.g., parsing
/// text that may contain icons). Use [getAssetConfig] when you know the
/// asset should exist.
AssetConfig? tryGetAssetConfig(String element) {
  // Clean the input string - remove punctuation
  String cleanElement = element.replaceAll(
    RegExp(
      r"[,.:()"
      "'"
      '"'
      "]",
    ),
    '',
  );

  // Handle XP pattern (xp8, xp10, etc.)
  if (RegExp(r'^xp\d+$').hasMatch(cleanElement)) {
    return const AssetConfig('ui/xp.svg', themeMode: CurrentColorTheme());
  }

  // Check assets by key
  return assets[cleanElement];
}
