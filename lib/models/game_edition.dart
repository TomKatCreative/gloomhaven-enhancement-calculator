enum GameEdition {
  gloomhaven,
  gloomhaven2e,
  frosthaven;

  /// Returns true if this edition uses Gloomhaven-style rules for party boon
  bool get supportsPartyBoon =>
      this == GameEdition.gloomhaven || this == GameEdition.gloomhaven2e;

  /// Returns true if this edition has the lost action modifier (halves cost)
  bool get hasLostModifier =>
      this == GameEdition.gloomhaven2e || this == GameEdition.frosthaven;

  /// Returns true if this edition has the persistent action modifier (triples cost)
  bool get hasPersistentModifier => this == GameEdition.frosthaven;

  /// Returns true if this edition supports enhancer building levels
  bool get hasEnhancerLevels => this == GameEdition.frosthaven;

  /// Returns true if multi-target applies to all enhancement types
  /// (GH applies to all, GH2E/FH excludes target, hex, and elements)
  bool get multiTargetAppliesToAll => this == GameEdition.gloomhaven;

  /// Maximum starting level allowed for a given prosperity level.
  ///
  /// - Gloomhaven: prosperity level
  /// - Gloomhaven 2e / Frosthaven: prosperity / 2 (rounded up)
  int maxStartingLevel(int prosperityLevel) {
    switch (this) {
      case GameEdition.gloomhaven:
        return prosperityLevel;
      case GameEdition.gloomhaven2e:
      case GameEdition.frosthaven:
        return (prosperityLevel / 2).ceil();
    }
  }

  /// Calculate starting gold based on edition rules.
  ///
  /// - Gloomhaven: 15 × (L + 1), where L is starting level
  /// - Gloomhaven 2e: 10 × P + 15, where P is prosperity level
  /// - Frosthaven: 10 × P + 20, where P is prosperity level
  int startingGold({int level = 1, int prosperityLevel = 0}) {
    switch (this) {
      case GameEdition.gloomhaven:
        return 15 * (level + 1);
      case GameEdition.gloomhaven2e:
        return 10 * prosperityLevel + 15;
      case GameEdition.frosthaven:
        return 10 * prosperityLevel + 20;
    }
  }

  String get displayName {
    switch (this) {
      case GameEdition.gloomhaven:
        return 'Gloomhaven';
      case GameEdition.gloomhaven2e:
        return 'Gloomhaven 2e';
      case GameEdition.frosthaven:
        return 'Frosthaven';
    }
  }
}
