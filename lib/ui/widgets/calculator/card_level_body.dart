import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// The body content for the Card Level selector card.
///
/// Contains a slider for selecting card levels 1-9 (stored internally as 0-8).
class CardLevelBody extends StatelessWidget {
  final EnhancementCalculatorModel model;

  const CardLevelBody({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Convert internal 0-8 to display 1-9
    final displayLevel = (model.cardLevel + 1).toDouble();

    return SfSlider(
      min: 1.0,
      max: 9.0,
      value: displayLevel,
      interval: 1,
      stepSize: 1,
      showLabels: true,
      labelFormatterCallback: (dynamic actualValue, String formattedText) {
        if ((actualValue as double).round() == 1) {
          return '1/X';
        }
        return formattedText;
      },
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      onChanged: (dynamic value) {
        // Convert display 1-9 back to internal 0-8
        model.cardLevel = (value as double).round() - 1;
      },
    );
  }
}
