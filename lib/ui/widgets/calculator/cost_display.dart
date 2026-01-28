import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';

/// Configuration for displaying cost with optional discount.
class CostDisplayConfig {
  /// The base cost before any discounts.
  final int baseCost;

  /// The actual cost after discounts. If different from [baseCost],
  /// the base cost will be shown with strikethrough.
  final int? discountedCost;

  /// Optional marker to display after the cost (e.g., '†' for temporary enhancements).
  final String? marker;

  const CostDisplayConfig({
    required this.baseCost,
    this.discountedCost,
    this.marker,
  });

  /// Whether there's a discount (discounted cost differs from base cost).
  bool get hasDiscount => discountedCost != null && discountedCost != baseCost;

  /// The cost to display as the final/current cost.
  int get displayCost => discountedCost ?? baseCost;
}

/// A chip-style widget that displays a cost value with optional strikethrough
/// for discounted prices.
///
/// Used consistently across all calculator cards to show section-specific costs.
class CostDisplay extends StatelessWidget {
  final CostDisplayConfig config;

  const CostDisplay({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildCostContent(theme, colorScheme);
  }

  Widget _buildCostContent(ThemeData theme, ColorScheme colorScheme) {
    if (config.baseCost == 0 && !config.hasDiscount) {
      return Text(
        '0g',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (config.hasDiscount) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StrikethroughText(
            '${config.baseCost}g',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${config.displayCost}g',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (config.marker != null)
            Text(
              ' ${config.marker}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }

    return Text(
      '${config.baseCost}g',
      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
    );
  }
}
