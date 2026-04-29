import 'package:flutter/material.dart';

// Per-element animation configuration for AnimatedElementIcon. Each element
// (FIRE, ICE, AIR, EARTH, LIGHT, DARK) carries its own timing, gradient, and
// intensity values; the widget treats them as opaque data. See
// `docs/element_tracker.md` for the visual architecture.
//
// Element colors here are *identity* colors (Fire is always orange, Ice is
// always blue, etc.) — they intentionally do NOT track the app theme. Only
// AIR is theme-aware (controlled via `isThemeAware`); its colors are
// overridden at render time based on the active brightness.

/// Animation style presets - each element has its own named style
enum ElementAnimationStyle { fire, ice, air, earth, light, dark }

/// Configuration for element glow animations.
///
/// Centralizes all configurable parameters for an element's animation.
/// Use factory constructors to get preset configurations for each element.
class ElementAnimationConfig {
  // Timing
  final Duration baseDuration;
  final Duration secondaryDuration;
  final Duration? tertiaryDuration; // Optional (FIRE uses 3 controllers)

  // Colors for strong state
  final Color outerGlowColor;
  final Color middleGlowColor;
  final List<Color> innerGradientColors; // 4 colors: core -> transparent
  final List<double> innerGradientStops;

  // Size offsets (added to baseSize)
  final double outerSizeOffset;
  final double middleSizeOffset;

  // Blur radii
  final double outerBlurRadius;
  final double middleBlurRadius;

  // Intensity parameters
  final double baseIntensity;
  final double intensityVariation;
  final double sizeVariation;

  // Animation style for unique math behavior
  final ElementAnimationStyle style;

  // Whether this element uses theme-aware colors (AIR)
  final bool isThemeAware;

  const ElementAnimationConfig({
    required this.baseDuration,
    required this.secondaryDuration,
    this.tertiaryDuration,
    required this.outerGlowColor,
    required this.middleGlowColor,
    required this.innerGradientColors,
    required this.innerGradientStops,
    required this.outerSizeOffset,
    required this.middleSizeOffset,
    required this.outerBlurRadius,
    required this.middleBlurRadius,
    required this.baseIntensity,
    required this.intensityVariation,
    required this.sizeVariation,
    required this.style,
    this.isThemeAware = false,
  });

  /// FIRE: Breathing, warm, layered orange/amber glow
  factory ElementAnimationConfig.fire() => const ElementAnimationConfig(
    baseDuration: Duration(milliseconds: 2000),
    secondaryDuration: Duration(milliseconds: 1300),
    tertiaryDuration: Duration(milliseconds: 800),
    outerGlowColor: Colors.deepOrange,
    middleGlowColor: Colors.orange,
    innerGradientColors: [
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.transparent,
    ],
    innerGradientStops: [0.0, 0.35, 0.65, 1.0],
    outerSizeOffset: 16,
    middleSizeOffset: 8,
    outerBlurRadius: 20,
    middleBlurRadius: 12,
    baseIntensity: 0.6,
    intensityVariation: 0.4,
    sizeVariation: 4,
    style: ElementAnimationStyle.fire,
  );

  /// ICE: Sharp, crystalline shimmer (cyan/lightBlue/white)
  static ElementAnimationConfig ice() => ElementAnimationConfig(
    baseDuration: const Duration(milliseconds: 2200),
    secondaryDuration: const Duration(milliseconds: 800),
    outerGlowColor: Colors.cyan,
    middleGlowColor: Colors.lightBlue.shade200,
    innerGradientColors: [
      Colors.white,
      Colors.lightBlue.shade100,
      Colors.cyan.shade300,
      Colors.transparent,
    ],
    innerGradientStops: const [0.0, 0.25, 0.5, 1.0],
    outerSizeOffset: 14,
    middleSizeOffset: 6,
    outerBlurRadius: 16,
    middleBlurRadius: 8,
    baseIntensity: 0.55,
    intensityVariation: 0.45,
    sizeVariation: 5,
    style: ElementAnimationStyle.ice,
  );

  /// AIR: Gentle breeze, soft and flowing (theme-aware colors)
  factory ElementAnimationConfig.air() => const ElementAnimationConfig(
    baseDuration: Duration(milliseconds: 3000),
    secondaryDuration: Duration(milliseconds: 1800),
    // Colors are overridden based on theme in build methods
    outerGlowColor: Colors.white,
    middleGlowColor: Colors.grey,
    innerGradientColors: [
      Colors.white,
      Colors.grey,
      Colors.transparent,
      Colors.transparent,
    ],
    innerGradientStops: [0.0, 0.5, 1.0, 1.0],
    outerSizeOffset: 18,
    middleSizeOffset: 10,
    outerBlurRadius: 28,
    middleBlurRadius: 16,
    baseIntensity: 0.25,
    intensityVariation: 0.2,
    sizeVariation: 1.5,
    style: ElementAnimationStyle.air,
    isThemeAware: true,
  );

  /// EARTH: Crunchy tremor with deep rumble (brown/orange/amber)
  static ElementAnimationConfig earth() => ElementAnimationConfig(
    baseDuration: const Duration(milliseconds: 2800),
    secondaryDuration: const Duration(milliseconds: 1600),
    outerGlowColor: Colors.brown.shade800,
    middleGlowColor: Colors.orange.shade900,
    innerGradientColors: [
      Colors.amber.shade700,
      Colors.orange.shade800,
      Colors.brown.shade700,
      Colors.transparent,
    ],
    innerGradientStops: const [0.0, 0.35, 0.65, 1.0],
    outerSizeOffset: 14,
    middleSizeOffset: 8,
    outerBlurRadius: 18,
    middleBlurRadius: 12,
    baseIntensity: 0.5,
    intensityVariation: 0.45,
    sizeVariation: 4,
    style: ElementAnimationStyle.earth,
  );

  /// LIGHT: Steady, radiant divine shimmer (yellow/amber/white)
  static ElementAnimationConfig light() => ElementAnimationConfig(
    baseDuration: const Duration(milliseconds: 2200),
    secondaryDuration: const Duration(milliseconds: 1400),
    outerGlowColor: Colors.amber.shade300,
    middleGlowColor: Colors.yellow.shade200,
    innerGradientColors: [
      Colors.white,
      Colors.yellow.shade50,
      Colors.yellow.shade100,
      Colors.transparent,
    ],
    innerGradientStops: const [0.0, 0.25, 0.5, 1.0],
    outerSizeOffset: 8,
    middleSizeOffset: 4,
    outerBlurRadius: 12,
    middleBlurRadius: 8,
    baseIntensity: 0.7,
    intensityVariation: 0.15,
    sizeVariation: 2,
    style: ElementAnimationStyle.light,
  );

  /// DARK: Eerie drifting clouds across the moon (purple/deepPurple)
  static ElementAnimationConfig dark() => ElementAnimationConfig(
    baseDuration: const Duration(milliseconds: 2600),
    secondaryDuration: const Duration(milliseconds: 1700),
    outerGlowColor: Colors.deepPurple.shade900,
    middleGlowColor: Colors.purple.shade700,
    innerGradientColors: [
      Colors.purple.shade200,
      Colors.purple.shade400,
      Colors.deepPurple.shade700,
      Colors.transparent,
    ],
    innerGradientStops: const [0.0, 0.3, 0.6, 1.0],
    outerSizeOffset: 16,
    middleSizeOffset: 8,
    outerBlurRadius: 20,
    middleBlurRadius: 14,
    baseIntensity: 0.55,
    intensityVariation: 0.3,
    sizeVariation: 3,
    style: ElementAnimationStyle.dark,
  );

  /// Config lookup map by asset key
  static final Map<String, ElementAnimationConfig> _configs = {
    'FIRE': ElementAnimationConfig.fire(),
    'ICE': ElementAnimationConfig.ice(),
    'AIR': ElementAnimationConfig.air(),
    'EARTH': ElementAnimationConfig.earth(),
    'LIGHT': ElementAnimationConfig.light(),
    'DARK': ElementAnimationConfig.dark(),
  };

  /// Get config for an asset key, or null if not a known element
  static ElementAnimationConfig? forAssetKey(String assetKey) =>
      _configs[assetKey];
}
