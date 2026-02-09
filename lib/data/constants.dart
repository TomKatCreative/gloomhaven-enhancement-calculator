import 'dart:ui';

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
const double maxWidth = 500;
const double maxDialogWidth = 400;
const double navBarIconContainerHeight = 35.0; // Navigation bar item height
const double chipBarHeight = 52.0; // Section nav chip bar height
const double blurBarHeight = 100.0; // Blur bar at bottom of calculator
const double elementTrackerClearance =
    80.0; // Bottom clearance for element tracker
const double formFieldSpacing = 28.0; // Vertical spacing between form fields

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

/// Game edition-specific colors used for branding elements like edition toggles.
/// These are intentionally hardcoded as they represent game brand colors,
/// not character-specific theming.
class GameEditionColors {
  static const Color gloomhavenPrimary = Color(0xff005cb2);
  static const Color gloomhavenLight = Color(0xff6ab7ff);
  static const Color frosthavenPrimary = Color(0xffa98274);
}
