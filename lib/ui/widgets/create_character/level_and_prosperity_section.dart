import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_label.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// Combined prosperity slider, level slider, and gold display section.
///
/// Gold display appears inline with either the level slider (GH) or
/// prosperity slider (GH2E/FH), depending on which parameter drives
/// gold for that edition.
class LevelAndProsperitySection extends StatelessWidget {
  final GameEdition edition;
  final int level;
  final int prosperityLevel;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<int> onProsperityChanged;

  const LevelAndProsperitySection({
    super.key,
    required this.edition,
    required this.level,
    required this.prosperityLevel,
    required this.onLevelChanged,
    required this.onProsperityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProsperitySlider(context),
        const SizedBox(height: formFieldSpacing),
        _buildLevelSlider(context),
      ],
    );
  }

  Widget _buildProsperitySlider(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionLabel(
              label:
                  '${AppLocalizations.of(context).prosperityLevel}: $prosperityLevel',
              svgAssetKey: 'PROSPERITY',
              iconSize: iconSizeMedium,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (edition != GameEdition.gloomhaven) ..._buildGoldDisplay(theme),
          ],
        ),
        const SizedBox(height: smallPadding),
        SfSlider(
          min: 1.0,
          max: 9.0,
          value: prosperityLevel.toDouble(),
          interval: 1,
          stepSize: 1,
          showLabels: true,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onChanged: (dynamic value) {
            onProsperityChanged((value as double).round());
          },
        ),
      ],
    );
  }

  Widget _buildLevelSlider(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final maxLevel = edition.maxStartingLevel(prosperityLevel);
    final exceedsProsperity = level > maxLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ThemedSvg(
              assetKey: 'LEVEL',
              width: iconSizeMedium,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: smallPadding),
            IntrinsicWidth(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Text(
                      '${l10n.startingLevel}: 9',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${l10n.startingLevel}: $level',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (exceedsProsperity) ...[
              const SizedBox(width: smallPadding),
              Tooltip(
                message: l10n.levelExceedsProsperity(maxLevel),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: iconSizeSmall,
                  color: Colors.amber,
                ),
              ),
            ],
            if (edition == GameEdition.gloomhaven) ..._buildGoldDisplay(theme),
          ],
        ),
        const SizedBox(height: smallPadding),
        SfSlider(
          min: 1.0,
          max: 9.0,
          value: level.toDouble(),
          interval: 1,
          stepSize: 1,
          showLabels: true,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          onChanged: (dynamic value) {
            onLevelChanged((value as double).round());
          },
        ),
      ],
    );
  }

  List<Widget> _buildGoldDisplay(ThemeData theme) {
    return [
      const Spacer(),
      ThemedSvg(
        assetKey: 'GOLD',
        width: iconSizeSmall,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: tinyPadding),
      IntrinsicWidth(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Opacity(
              opacity: 0,
              child: Text('150', style: theme.textTheme.bodyMedium),
            ),
            Text(
              '${edition.startingGold(level: level, prosperityLevel: prosperityLevel)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: smallPadding),
    ];
  }
}
