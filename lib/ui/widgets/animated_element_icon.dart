import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/element_state.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

// Animated element icon for the 6 Gloomhaven elements (FIRE, ICE, AIR, EARTH,
// LIGHT, DARK). Config-driven; see `docs/element_tracker.md` for the animation
// architecture, layer structure, and per-element style descriptions.

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

/// A widget that renders an element icon with animated glow effects.
///
/// Supports three visual states:
/// - [ElementState.gone]: Low opacity (30%), no glow
/// - [ElementState.strong]: Full animated glow (element-specific)
/// - [ElementState.waning]: Subtle pulsing glow, top half dim, bottom half glowing
///
/// Set [animated] to true when the element tracker sheet is expanded to
/// enable glow animations. When false, shows static opacity-based states.
class AnimatedElementIcon extends StatefulWidget {
  /// The asset key for the element (e.g., 'EARTH', 'FIRE', 'ICE', 'LIGHT', 'DARK', 'AIR')
  final String assetKey;

  /// The current state of the element
  final ElementState state;

  /// The size of the icon (width and height)
  final double size;

  /// Whether to show animations (only when sheet is expanded)
  final bool animated;

  const AnimatedElementIcon({
    super.key,
    required this.assetKey,
    required this.state,
    required this.size,
    this.animated = false,
  });

  /// Ring/glow sizing relative to icon size
  static const double ringPadding = 2.0;

  @override
  State<AnimatedElementIcon> createState() => _AnimatedElementIconState();
}

class _AnimatedElementIconState extends State<AnimatedElementIcon>
    with TickerProviderStateMixin {
  // Fade controller for smooth animation transitions (all elements)
  late AnimationController _fadeController;

  // Track state for fade-out-to-gone transitions
  ElementState? _fadeFromState;
  bool _isFadingToGone = false;

  // Shared animation controllers (initialized from config)
  late AnimationController _baseController;
  late AnimationController _secondaryController;
  AnimationController? _tertiaryController; // Only for elements that need it

  // Current config (cached for efficiency)
  ElementAnimationConfig? _config;

  /// Opacity values for each state
  static const double _goneOpacity = 0.3;
  static const double _ringStrokeWidth = 1.5;

  /// Waning state multipliers (derived from strong state)
  static const double _waningIntensityMultiplier = 0.5;
  static const double _waningSizeMultiplier = 0.6;

  @override
  void initState() {
    super.initState();

    // Get config for current element
    _config = ElementAnimationConfig.forAssetKey(widget.assetKey);

    // Fade controller for animation transitions (250ms for all)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeController.addStatusListener(_onFadeStatusChanged);

    // Start faded in if already animated and in an active state
    if (widget.animated && widget.state != ElementState.gone) {
      _fadeController.value = 1.0;
    }

    // Initialize controllers from config
    _initControllersFromConfig();
  }

  /// Initialize animation controllers based on element config
  void _initControllersFromConfig() {
    final config = _config;
    if (config == null) {
      // Fallback for unknown elements
      _baseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(reverse: true);
      _secondaryController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat(reverse: true);
      return;
    }

    // Base controller (slow)
    _baseController = AnimationController(
      vsync: this,
      duration: config.baseDuration,
    )..repeat(reverse: true);

    // Secondary controller (faster)
    _secondaryController = AnimationController(
      vsync: this,
      duration: config.secondaryDuration,
    )..repeat(reverse: true);

    // Tertiary controller (fastest - only if config specifies it)
    if (config.tertiaryDuration != null) {
      _tertiaryController = AnimationController(
        vsync: this,
        duration: config.tertiaryDuration,
      )..repeat(reverse: true);
    }
  }

  /// Resets fade-to-gone state when animation completes
  void _onFadeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _isFadingToGone) {
      setState(() {
        _isFadingToGone = false;
        _fadeFromState = null;
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedElementIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if asset key changed (rare but possible)
    if (oldWidget.assetKey != widget.assetKey) {
      // Re-init controllers with new config
      _disposeControllers();
      _config = ElementAnimationConfig.forAssetKey(widget.assetKey);
      _initControllersFromConfig();
    }

    // Handle fade transitions for known elements
    if (_config != null) {
      final wasAnimated = oldWidget.animated;
      final isAnimated = widget.animated;
      final oldState = oldWidget.state;
      final newState = widget.state;

      // Sheet expand/collapse transitions
      if (!wasAnimated && isAnimated && newState != ElementState.gone) {
        // Sheet expanded with active element - fade in
        _fadeController.forward();
      } else if (wasAnimated && !isAnimated) {
        // Sheet collapsed - fade out
        _fadeController.reverse();
      }
      // State change transitions (while animated)
      else if (isAnimated && oldState != newState) {
        if (oldState == ElementState.gone) {
          // gone → strong: fade in
          _fadeController.forward(from: 0.0);
        } else if (newState == ElementState.gone) {
          // waning/strong → gone: fade out the glow/color
          setState(() {
            _fadeFromState = oldState;
            _isFadingToGone = true;
          });
          _fadeController.reverse(from: 1.0);
        } else {
          // strong → waning: crossfade (reset and fade in new animation)
          _fadeController.forward(from: 0.0);
        }
      }
    }
  }

  void _disposeControllers() {
    _baseController.dispose();
    _secondaryController.dispose();
    _tertiaryController?.dispose();
  }

  @override
  void dispose() {
    _fadeController.removeStatusListener(_onFadeStatusChanged);
    _fadeController.dispose();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    final assetConfig = getAssetConfig(widget.assetKey);
    final fullPath = 'images/${assetConfig.pathForTheme(darkTheme)}';

    // Total size includes padding for ring/glow
    final totalSize = widget.size + (AnimatedElementIcon.ringPadding * 2);

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: widget.animated
          ? _buildAnimatedIcon(fullPath, darkTheme, assetConfig)
          : _buildStaticIcon(fullPath, darkTheme, assetConfig),
    );
  }

  /// Static icon display (when collapsed) - minimalist state representation
  Widget _buildStaticIcon(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
  ) {
    switch (widget.state) {
      case ElementState.gone:
        return Center(
          child: Opacity(
            opacity: _goneOpacity,
            child: _buildSvg(fullPath, darkTheme, assetConfig),
          ),
        );

      case ElementState.strong:
        return Center(child: _buildSvg(fullPath, darkTheme, assetConfig));

      case ElementState.waning:
        // Bisected: top half dim, bottom half bright with sharp horizontal line
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base layer: full icon at dim opacity
              Opacity(
                opacity: _goneOpacity,
                child: _buildSvg(fullPath, darkTheme, assetConfig),
              ),
              // Top layer: bright icon masked to bottom portion only (sharp cut)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.0, 0.5, 0.5, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.85,
                  child: _buildSvg(fullPath, darkTheme, assetConfig),
                ),
              ),
            ],
          ),
        );
    }
  }

  /// Animated icon display (when expanded)
  Widget _buildAnimatedIcon(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
  ) {
    final ringColor = darkTheme
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.4);
    final glowColor = darkTheme
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.15);

    // Handle fade-to-gone transition
    if (_isFadingToGone && _config != null) {
      return _buildFadeToGone(
        fullPath,
        darkTheme,
        assetConfig,
        glowColor,
        ringColor,
      );
    }

    return switch (widget.state) {
      ElementState.gone => _buildGoneIcon(fullPath, darkTheme, assetConfig),
      ElementState.strong => _buildStrongState(
        fullPath,
        darkTheme,
        assetConfig,
        glowColor,
      ),
      ElementState.waning => _buildWaningState(
        fullPath,
        darkTheme,
        assetConfig,
        ringColor,
      ),
    };
  }

  /// Builds crossfade from animated state to gone state
  Widget _buildFadeToGone(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    Color glowColor,
    Color ringColor,
  ) {
    // Build the animation we're fading FROM
    final Widget fadingOutWidget;
    if (_fadeFromState == ElementState.strong) {
      fadingOutWidget = _buildStrongGlow(
        fullPath,
        darkTheme,
        assetConfig,
        _config!,
      );
    } else {
      fadingOutWidget = _buildWaningGlow(
        fullPath,
        darkTheme,
        assetConfig,
        _config!,
      );
    }

    // The gone state we're fading TO
    final goneWidget = _buildGoneIcon(fullPath, darkTheme, assetConfig);

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final fadeValue = _fadeController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Gone state fades in
            Opacity(opacity: 1.0 - fadeValue, child: goneWidget),
            // Animated glow fades out
            Opacity(opacity: fadeValue, child: fadingOutWidget),
          ],
        );
      },
    );
  }

  /// Build strong state with fade wrapper
  Widget _buildStrongState(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    Color glowColor,
  ) {
    if (_config != null) {
      return _wrapWithFade(
        _buildStrongGlow(fullPath, darkTheme, assetConfig, _config!),
        fullPath,
        darkTheme,
        assetConfig,
        glowColor,
      );
    }
    return _buildFallbackStrongIcon(
      fullPath,
      darkTheme,
      assetConfig,
      glowColor,
    );
  }

  /// Build waning state with fade wrapper
  Widget _buildWaningState(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    Color ringColor,
  ) {
    if (_config != null) {
      return _wrapWithFade(
        _buildWaningGlow(fullPath, darkTheme, assetConfig, _config!),
        fullPath,
        darkTheme,
        assetConfig,
        null,
        ringColor,
      );
    }
    return _buildFallbackWaningIcon(
      fullPath,
      darkTheme,
      assetConfig,
      ringColor,
    );
  }

  /// Wraps animated icons with fade transition
  Widget _wrapWithFade(
    Widget animatedChild,
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig, [
    Color? glowColor,
    Color? ringColor,
  ]) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final fadeValue = _fadeController.value;

        if (fadeValue < 1.0) {
          // Determine which fallback to show
          final fallback = glowColor != null
              ? _buildFallbackStrongIcon(
                  fullPath,
                  darkTheme,
                  assetConfig,
                  glowColor,
                )
              : _buildFallbackWaningIcon(
                  fullPath,
                  darkTheme,
                  assetConfig,
                  ringColor!,
                );

          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 1.0 - fadeValue, child: fallback),
              Opacity(opacity: fadeValue, child: animatedChild),
            ],
          );
        }

        return animatedChild;
      },
    );
  }

  /// Renders the icon with low opacity, no ring (inactive state)
  Widget _buildGoneIcon(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
  ) {
    return Center(
      child: Opacity(
        opacity: _goneOpacity,
        child: _buildSvg(fullPath, darkTheme, assetConfig),
      ),
    );
  }

  /// Fallback strong icon (used during fade transitions)
  Widget _buildFallbackStrongIcon(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    Color glowColor,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: widget.size + AnimatedElementIcon.ringPadding,
          height: widget.size + AnimatedElementIcon.ringPadding,
          decoration: BoxDecoration(shape: BoxShape.circle, color: glowColor),
        ),
        _buildSvg(fullPath, darkTheme, assetConfig),
      ],
    );
  }

  /// Fallback waning icon (used during fade transitions)
  Widget _buildFallbackWaningIcon(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    Color ringColor,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: widget.size + AnimatedElementIcon.ringPadding,
          height: widget.size + AnimatedElementIcon.ringPadding,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: _ringStrokeWidth),
          ),
        ),
        _buildSvg(fullPath, darkTheme, assetConfig),
      ],
    );
  }

  // ============================================================================
  // GENERIC ANIMATION BUILDERS
  // ============================================================================

  /// Compute animation values for the current element style
  ({double combined, double shimmer, double cloudPosition})
  _computeAnimationValues(ElementAnimationConfig config) {
    final baseValue = _baseController.value;
    final secondaryValue = _secondaryController.value;
    final tertiaryValue = _tertiaryController?.value ?? 0.0;

    switch (config.style) {
      case ElementAnimationStyle.fire:
        return _computeFireAnimation(baseValue, secondaryValue, tertiaryValue);
      case ElementAnimationStyle.ice:
        return _computeIceAnimation(baseValue, secondaryValue);
      case ElementAnimationStyle.air:
        return _computeAirAnimation(baseValue, secondaryValue);
      case ElementAnimationStyle.earth:
        return _computeEarthAnimation(baseValue, secondaryValue);
      case ElementAnimationStyle.light:
        return _computeLightAnimation(baseValue, secondaryValue);
      case ElementAnimationStyle.dark:
        return _computeDarkAnimation(baseValue, secondaryValue);
    }
  }

  /// FIRE: Eased sine waves, 3 layers combined
  ({double combined, double shimmer, double cloudPosition})
  _computeFireAnimation(double base, double secondary, double tertiary) {
    final baseCurve = Curves.easeInOut.transform(base);
    final basePulse = math.sin(baseCurve * math.pi);
    final flareCurve = Curves.easeInOut.transform(secondary);
    final flare = math.sin(flareCurve * math.pi) * 0.6;
    final shimmer = math.sin(tertiary * math.pi) * 0.15;
    final combined = (basePulse * 0.5) + (flare * 0.35) + shimmer;
    return (combined: combined, shimmer: shimmer, cloudPosition: 0.0);
  }

  /// ICE: Multi-frequency (4x, 7x, 11x) with abs() for crystalline feel
  ({double combined, double shimmer, double cloudPosition})
  _computeIceAnimation(double base, double secondary) {
    final baseCurve = Curves.easeOut.transform(base);
    final basePulse = math.sin(baseCurve * math.pi * 1.5);
    final shimmerRaw = secondary;
    final shimmer =
        (math.sin(shimmerRaw * math.pi * 4) * 0.5 +
                math.sin(shimmerRaw * math.pi * 7) * 0.3)
            .abs();
    final flicker = math.sin(shimmerRaw * math.pi * 11) * 0.2;
    final combined = (basePulse * 0.4) + (shimmer * 0.4) + flicker;
    return (combined: combined, shimmer: shimmer, cloudPosition: 0.0);
  }

  /// AIR: Cosine undulation, minimal variation
  ({double combined, double shimmer, double cloudPosition})
  _computeAirAnimation(double base, double secondary) {
    final flow = math.cos(base * math.pi * 2) * 0.5 + 0.5;
    final gust = math.sin(secondary * math.pi * 2) * 0.3;
    final combined = (flow * 0.7) + (gust * 0.3);
    return (combined: combined, shimmer: 0.0, cloudPosition: 0.0);
  }

  /// EARTH: High-freq (11x, 17x, 23x) + threshold cracks
  ({double combined, double shimmer, double cloudPosition})
  _computeEarthAnimation(double base, double secondary) {
    final baseCurve = Curves.easeInOut.transform(base);
    final basePulse = math.sin(baseCurve * math.pi);
    final tremorRaw = secondary;
    final crunch1 = (math.sin(tremorRaw * math.pi * 11) * 0.5).abs();
    final crunch2 = (math.sin(tremorRaw * math.pi * 17) * 0.3).abs();
    final crunch3 = (math.sin(tremorRaw * math.pi * 23) * 0.2).abs();
    final crackRaw = math.sin(tremorRaw * math.pi * 3);
    final crack = crackRaw > 0.7 ? (crackRaw - 0.7) * 3.3 : 0.0;
    final crunch = crunch1 + crunch2 + crunch3;
    final combined = (basePulse * 0.4) + (crunch * 0.35) + (crack * 0.25);
    return (combined: combined, shimmer: crunch, cloudPosition: 0.0);
  }

  /// LIGHT: Smooth breathing, steady radiance
  ({double combined, double shimmer, double cloudPosition})
  _computeLightAnimation(double base, double secondary) {
    final baseCurve = Curves.easeInOut.transform(base);
    final basePulse = math.sin(baseCurve * math.pi);
    final secondaryCurve = Curves.easeInOut.transform(secondary);
    final secondaryPulse = math.sin(secondaryCurve * math.pi) * 0.3;
    final combined = (basePulse * 0.7) + (secondaryPulse * 0.3);
    return (combined: combined, shimmer: secondaryPulse, cloudPosition: 0.0);
  }

  /// DARK: Horizontal cosine drift for cloud effect
  ({double combined, double shimmer, double cloudPosition})
  _computeDarkAnimation(double base, double secondary) {
    final driftX = math.cos(base * math.pi * 2) * 0.4;
    final drift2X = math.cos(secondary * math.pi * 2 + 1.5) * 0.3;
    final cloudPosition = driftX + drift2X;
    final basePulse = math.sin(base * math.pi) * 0.3;
    final flicker = math.sin(secondary * math.pi * 7) * 0.06;
    final combined = basePulse + flicker;
    return (combined: combined, shimmer: 0.0, cloudPosition: cloudPosition);
  }

  /// Get theme-aware colors for AIR element
  ({Color outer, Color middle, Color inner, Color innerFade}) _getAirColors(
    bool darkTheme,
  ) {
    return (
      outer: darkTheme ? Colors.white : Colors.blueGrey.shade400,
      middle: darkTheme ? Colors.blueGrey.shade100 : Colors.blueGrey.shade300,
      inner: darkTheme ? Colors.white : Colors.blueGrey.shade200,
      innerFade: darkTheme ? Colors.grey.shade100 : Colors.blueGrey.shade100,
    );
  }

  /// Build strong glow animation using config
  Widget _buildStrongGlow(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    ElementAnimationConfig config,
  ) {
    final listenables = <Listenable>[_baseController, _secondaryController];
    if (_tertiaryController != null) {
      listenables.add(_tertiaryController!);
    }

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, child) {
        final values = _computeAnimationValues(config);
        final combined = values.combined;

        // Calculate intensities
        final glowIntensity =
            config.baseIntensity + (combined * config.intensityVariation);
        final outerGlowIntensity =
            (config.baseIntensity - 0.2).clamp(0.0, 1.0) +
            (combined * (config.intensityVariation - 0.1).clamp(0.0, 1.0));

        // Calculate sizes
        final sizeVariation = combined * config.sizeVariation;
        final baseSize = widget.size + AnimatedElementIcon.ringPadding;

        // Get colors (theme-aware for AIR)
        final Color outerColor;
        final Color middleColor;
        final List<Color> innerColors;

        if (config.isThemeAware) {
          final airColors = _getAirColors(darkTheme);
          outerColor = airColors.outer;
          middleColor = airColors.middle;
          innerColors = [
            airColors.inner,
            airColors.innerFade,
            Colors.transparent,
            Colors.transparent,
          ];
        } else {
          outerColor = config.outerGlowColor;
          middleColor = config.middleGlowColor;
          innerColors = config.innerGradientColors;
        }

        // Build the glow stack
        final children = <Widget>[
          // Outer glow
          Container(
            width: baseSize + config.outerSizeOffset + sizeVariation,
            height: baseSize + config.outerSizeOffset + sizeVariation,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: outerColor.withValues(alpha: outerGlowIntensity * 0.7),
                  blurRadius: config.outerBlurRadius + (combined * 6),
                  spreadRadius: 2 + (combined * 2),
                ),
              ],
            ),
          ),
          // Middle glow
          Container(
            width: baseSize + config.middleSizeOffset + (sizeVariation * 0.6),
            height: baseSize + config.middleSizeOffset + (sizeVariation * 0.6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: middleColor.withValues(alpha: glowIntensity * 0.8),
                  blurRadius: config.middleBlurRadius + (combined * 4),
                  spreadRadius: 4 + (combined * 2),
                ),
              ],
            ),
          ),
        ];

        // Inner core gradient - style-specific adjustments
        if (config.style == ElementAnimationStyle.dark) {
          // DARK: Horizontally-drifting gradient center
          children.add(
            Container(
              width: baseSize + (sizeVariation * 0.3),
              height: baseSize + (sizeVariation * 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(values.cloudPosition * 0.3, 0),
                  colors: [
                    innerColors[0].withValues(alpha: glowIntensity * 0.75),
                    innerColors[1].withValues(alpha: glowIntensity * 0.55),
                    innerColors[2].withValues(alpha: glowIntensity * 0.35),
                    Colors.transparent,
                  ],
                  stops: config.innerGradientStops,
                ),
              ),
            ),
          );
          // Drifting shadow cloud
          final cloudOffset = values.cloudPosition * (baseSize * 0.4);
          children.add(
            Transform.translate(
              offset: Offset(cloudOffset, 0),
              child: Container(
                width: baseSize * 0.8,
                height: baseSize * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.deepPurple.shade900.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Standard inner core gradient
          children.add(
            Container(
              width: baseSize + (sizeVariation * 0.3),
              height: baseSize + (sizeVariation * 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    innerColors[0].withValues(alpha: glowIntensity),
                    innerColors[1].withValues(alpha: glowIntensity * 0.7),
                    innerColors[2].withValues(alpha: glowIntensity * 0.3),
                    Colors.transparent,
                  ],
                  stops: config.innerGradientStops,
                ),
              ),
            ),
          );
        }

        // Icon on top
        children.add(child!);

        return Stack(alignment: Alignment.center, children: children);
      },
      child: _buildSvg(fullPath, darkTheme, assetConfig),
    );
  }

  /// Build waning glow animation using config (derived from strong with multipliers)
  Widget _buildWaningGlow(
    String fullPath,
    bool darkTheme,
    AssetConfig assetConfig,
    ElementAnimationConfig config,
  ) {
    final totalSize = widget.size + (AnimatedElementIcon.ringPadding * 2);
    final listenables = <Listenable>[_baseController, _secondaryController];
    if (_tertiaryController != null) {
      listenables.add(_tertiaryController!);
    }

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, child) {
        final values = _computeAnimationValues(config);
        final combined = values.combined;

        // Waning uses reduced intensity and size variation
        final glowIntensity =
            (config.baseIntensity * _waningIntensityMultiplier) +
            (combined * config.intensityVariation * _waningIntensityMultiplier);
        final sizeVariation =
            combined * config.sizeVariation * _waningSizeMultiplier;
        final baseSize = widget.size + AnimatedElementIcon.ringPadding;

        // Get colors (theme-aware for AIR)
        final Color outerColor;
        final Color middleColor;
        final List<Color> innerColors;

        if (config.isThemeAware) {
          final airColors = _getAirColors(darkTheme);
          outerColor = airColors.outer;
          middleColor = airColors.middle;
          innerColors = [
            airColors.inner,
            airColors.innerFade,
            middleColor,
            outerColor,
            Colors.transparent,
          ];
        } else {
          outerColor = config.outerGlowColor;
          middleColor = config.middleGlowColor;
          innerColors = config.innerGradientColors;
        }

        return SizedBox(
          width: totalSize,
          height: totalSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base layer: full icon at "gone" opacity (dim)
              Opacity(
                opacity: _goneOpacity,
                child: _buildSvg(fullPath, darkTheme, assetConfig),
              ),
              // Bottom half glow + icon with soft gradient mask
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white, Colors.white],
                    stops: [0.45, 0.55, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SizedBox(
                  width: totalSize,
                  height: totalSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow using gradient
                      Container(
                        width:
                            baseSize +
                            config.outerSizeOffset -
                            4 +
                            sizeVariation,
                        height:
                            baseSize +
                            config.outerSizeOffset -
                            4 +
                            sizeVariation,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: config.style == ElementAnimationStyle.dark
                                ? Alignment(values.cloudPosition * 0.25, 0)
                                : Alignment.center,
                            colors: config.isThemeAware
                                ? [
                                    innerColors[0].withValues(
                                      alpha: glowIntensity * 0.6,
                                    ),
                                    innerColors[1].withValues(
                                      alpha: glowIntensity * 0.4,
                                    ),
                                    innerColors[2].withValues(
                                      alpha: glowIntensity * 0.3,
                                    ),
                                    innerColors[3].withValues(
                                      alpha: glowIntensity * 0.2,
                                    ),
                                    Colors.transparent,
                                  ]
                                : [
                                    innerColors[0].withValues(
                                      alpha: glowIntensity * 0.7,
                                    ),
                                    innerColors[1].withValues(
                                      alpha: glowIntensity * 0.5,
                                    ),
                                    innerColors[2].withValues(
                                      alpha: glowIntensity * 0.3,
                                    ),
                                    Colors.transparent,
                                  ],
                            stops: config.isThemeAware
                                ? const [0.0, 0.25, 0.45, 0.7, 1.0]
                                : const [0.0, 0.35, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Icon at full opacity
                      _buildSvg(fullPath, darkTheme, assetConfig),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the SVG widget with proper theming.
  ///
  /// Delegates to [ThemedSvg] so the asset-key indirection rule is honored
  /// (see CLAUDE.md "SVG Theming"). The `fullPath` and `assetConfig` params
  /// are unused here but kept on the signature because callers compute them
  /// once for animation/gradient decisions and pass them down.
  Widget _buildSvg(String fullPath, bool darkTheme, AssetConfig assetConfig) {
    return ThemedSvg(
      assetKey: widget.assetKey,
      width: widget.size,
      height: widget.size,
    );
  }
}
