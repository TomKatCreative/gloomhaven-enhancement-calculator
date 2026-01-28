import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// The body content for the Previous Enhancements selector card.
///
/// Contains a segmented button for selecting 0-3 previous enhancements.
class PreviousEnhancementsBody extends StatelessWidget {
  final EnhancementCalculatorModel model;

  const PreviousEnhancementsBody({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment<int>(value: 0, label: Text('None')),
          ButtonSegment<int>(value: 1, label: Text('1')),
          ButtonSegment<int>(value: 2, label: Text('2')),
          ButtonSegment<int>(value: 3, label: Text('3')),
        ],
        selected: {model.previousEnhancements},
        onSelectionChanged: (Set<int> selected) {
          model.previousEnhancements = selected.first;
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
