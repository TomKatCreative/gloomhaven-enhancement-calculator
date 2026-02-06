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
