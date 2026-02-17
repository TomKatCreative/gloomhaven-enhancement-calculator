import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// Dialog for configuring Enhancer building levels (Frosthaven Building 44).
///
/// Each level unlocks additional discounts for enhancement costs.
class EnhancerDialog extends StatefulWidget {
  final EnhancementCalculatorModel model;

  const EnhancerDialog({super.key, required this.model});

  @override
  State<EnhancerDialog> createState() => _EnhancerDialogState();
}

class _EnhancerDialogState extends State<EnhancerDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Center(
        child: Text(l10n.enhancer, style: theme.textTheme.headlineMedium),
      ),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EnhancerLevelTile(
                level: 1,
                subtitle: l10n.buyEnhancements,
                value: true,
                enabled: false,
              ),
              _EnhancerLevelTile(
                level: 2,
                subtitle: l10n.reduceEnhancementCosts,
                value: widget.model.enhancerLvl2,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      widget.model.enhancerLvl2 = val;
                    });
                  }
                },
              ),
              _EnhancerLevelTile(
                level: 3,
                subtitle: l10n.reduceLevelPenalties,
                value: widget.model.enhancerLvl3,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      widget.model.enhancerLvl3 = val;
                    });
                  }
                },
              ),
              _EnhancerLevelTile(
                level: 4,
                subtitle: l10n.reduceRepeatPenalties,
                value: widget.model.enhancerLvl4,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      widget.model.enhancerLvl4 = val;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

/// A single enhancer level checkbox tile.
class _EnhancerLevelTile extends StatelessWidget {
  final int level;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool?>? onChanged;

  const _EnhancerLevelTile({
    required this.level,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = value;

    final subtitleText = Text(
      subtitle,
      style: theme.textTheme.titleMedium?.copyWith(
        color: isActive ? null : theme.colorScheme.onSurfaceVariant,
      ),
    );

    // Animate blur for levels 2-4 (spoiler protection)
    final subtitleWidget = level > 1
        ? TweenAnimationBuilder<double>(
            tween: Tween(end: isActive ? 0 : 6),
            duration: animationDuration,
            curve: Curves.easeOut,
            builder: (context, sigma, child) => ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
            child: subtitleText,
          )
        : subtitleText;

    return CheckboxListTile(
      title: Text(_getLevelLabel(context), style: theme.textTheme.bodyLarge),
      subtitle: subtitleWidget,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  String _getLevelLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (level) {
      case 1:
        return l10n.lvl1;
      case 2:
        return l10n.lvl2;
      case 3:
        return l10n.lvl3;
      case 4:
        return l10n.lvl4;
      default:
        return '';
    }
  }
}
