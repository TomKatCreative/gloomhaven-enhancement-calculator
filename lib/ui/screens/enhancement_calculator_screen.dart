import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_cost_chip.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class EnhancementCalculatorScreen extends StatefulWidget {
  const EnhancementCalculatorScreen({super.key});

  @override
  State<EnhancementCalculatorScreen> createState() =>
      _EnhancementCalculatorScreenState();
}

class _EnhancementCalculatorScreenState
    extends State<EnhancementCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .watch<EnhancementCalculatorModel>();
    // Watch ThemeProvider to rebuild when theme changes
    final themeProvider = context.watch<ThemeProvider>();
    enhancementCalculatorModel.calculateCost(notify: false);
    final darkTheme = themeProvider.useDarkMode;
    final edition = enhancementCalculatorModel.edition;

    return Stack(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.contentMaxWidth(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: smallPadding),
            child: ListView(
              controller: context
                  .read<CharactersModel>()
                  .enhancementCalcScrollController,
              padding: EdgeInsets.only(
                // Extra padding when chip and FAB are present
                bottom: enhancementCalculatorModel.showCost ? 90 : largePadding,
              ),
              children: <Widget>[
                const SizedBox(height: mediumPadding),

                // 1. ENHANCEMENT TYPE
                EnhancementTypeCard(
                  edition: edition,
                  model: enhancementCalculatorModel,
                ),

                const SizedBox(height: mediumPadding),

                // 2. CARD DETAILS & MODIFIERS
                CardDetailsGroupCard(
                  edition: edition,
                  model: enhancementCalculatorModel,
                  darkTheme: darkTheme,
                ),

                const SizedBox(height: mediumPadding),

                // 3. DISCOUNTS
                DiscountsGroupCard(
                  edition: edition,
                  enhancementCalculatorModel: enhancementCalculatorModel,
                  darkTheme: darkTheme,
                  onSettingChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ),
        // Cost chip overlay with animated appearance
        AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: enhancementCalculatorModel.showCost
              ? ExpandableCostChip(
                  key: const ValueKey('cost-chip'),
                  totalCost: enhancementCalculatorModel.totalCost,
                  steps: enhancementCalculatorModel.getCalculationBreakdown(),
                  enhancement: enhancementCalculatorModel.enhancement,
                  scrollController: context
                      .read<CharactersModel>()
                      .enhancementCalcScrollController,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}
