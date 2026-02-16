import 'package:flutter/widgets.dart';

// =============================================================================
// DESIGN CONSTANTS
// Always use these instead of hardcoding pixel values. See CLAUDE.md for details.
// =============================================================================

// Font Sizes - Scaled M3 Type Scale
// Prefer using theme.textTheme styles. These constants are for edge cases
// where BuildContext is unavailable (e.g., game_text_parser.dart).
// Based on M3 type scale, with body/label/title sizes scaled up for readability.
const double fontSizeDisplayLarge = 59.0;
const double fontSizeDisplayMedium = 47.0;
const double fontSizeDisplaySmall = 38.0;
const double fontSizeHeadlineLarge = 34.0;
const double fontSizeHeadlineMedium = 30.0;
const double fontSizeHeadlineSmall = 26.0;
const double fontSizeTitleLarge = 24.0;
const double fontSizeTitleMedium = 20.0;
const double fontSizeTitleSmall = 18.0;
const double fontSizeBodyLarge = 24.0;
const double fontSizeBodyMedium = 22.0;
const double fontSizeBodySmall = 20.0;
const double fontSizeLabelLarge = 18.0;
const double fontSizeLabelMedium = 16.0;
const double fontSizeLabelSmall = 14.0;

// Padding - use these for all spacing (never hardcode values like 4, 8, 16)
const double tinyPadding = 4.0; // Minimal spacing, tight layouts
const double smallPadding = 8.0; // Standard tight spacing
const double mediumPadding = 12.0; // Standard comfortable spacing
const double largePadding = 16.0; // Section spacing, card padding
const double extraLargePadding = 24.0; // Major section breaks, screen padding

// Border Radius - use these for all rounded corners
const double borderRadiusSmall = 4.0; // Small rounded corners (checkboxes)
const double borderRadiusMedium = 8.0; // Standard input/card corners
const double borderRadiusLarge = 16.0; // Larger rounded elements
const double borderRadiusPill = 24.0; // Full pill shape (chips, FABs)
const double borderRadiusCard = 28.0; // Card top corners

// Divider/Line Dimensions
const double hairlineThickness = 0.5; // Thin dividers
const double dividerThickness = 1.0; // Standard divider line

// Animation Duration - standard duration for all animations
const Duration animationDuration = Duration(milliseconds: 250);

// Blur - backdrop blur sigma for expanded sections over the class icon
const double expansionBlurSigma = 12.0;

// Layout Constraints
const double chipBarHeight = 60.0; // Section nav chip bar height
const double blurBarHeight = 100.0; // Blur bar at bottom of calculator
const double elementTrackerClearance =
    80.0; // Bottom clearance for element tracker
const double formFieldSpacing = 28.0; // Vertical spacing between form fields
const double sheetExpandedSize = 0.85; // Bottom sheet expanded fraction
const double fabBottomClearance =
    82.0; // FAB clearance padding at screen bottom
const double scrollSpyThresholdBuffer = 50.0; // Scroll-spy position tolerance

// Icon Sizes - use these for all icons (never hardcode or derive sizes)
const double iconSizeTiny = 14.0; // Decorative overlays (+1 badge)
const double iconSizeSmall =
    20.0; // Form inputs, collapsed states, stacked elements
const double iconSizeMedium =
    26.0; // Inline text icons (perks), section headers
const double iconSizeLarge = 32.0; // Navigation, calculator, dialog buttons
const double iconSizeXL = 36.0; // Class icons in lists/dialogs
const double iconSizeHero = 48.0; // Hero elements (level badge)

// Font Families
const String nyala = 'Nyala', pirataOne = 'PirataOne', inter = 'Inter';

// Responsive Breakpoints (Material 3 window size classes)
const double _compactBreakpoint = 600.0;
const double _mediumBreakpoint = 840.0;

/// Provides responsive max-width constraints based on screen size.
///
/// Uses Material 3 window size classes:
/// - Compact (<600dp): phones — no constraint, content fills width
/// - Medium (600–839dp): small tablets — moderate cap
/// - Expanded (840dp+): large tablets — wider cap
class ResponsiveLayout {
  ResponsiveLayout._();

  /// Max width for general content (calculator, settings, town sections).
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _compactBreakpoint) return double.infinity;
    if (width < _mediumBreakpoint) return 560;
    return 700;
  }

  /// Max width for character screen pages.
  static double characterMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _compactBreakpoint) return double.infinity;
    if (width < _mediumBreakpoint) return 700;
    return 840;
  }

  /// Max width for dialog content containers.
  static double dialogMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _compactBreakpoint) return 400;
    if (width < _mediumBreakpoint) return 480;
    return 560;
  }
}

// Feature flags — set to `true` to enable unreleased features.
const bool kTownSheetEnabled = false;
