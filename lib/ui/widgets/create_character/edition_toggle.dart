import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';

/// Edition selector toggle (GH / GH2E / FH) with info button.
class EditionToggle extends StatelessWidget {
  final GameEdition selectedEdition;
  final ValueChanged<GameEdition> onEditionChanged;

  const EditionToggle({
    super.key,
    required this.selectedEdition,
    required this.onEditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) {
                  return InfoDialog(
                    title: Strings.newCharacterInfoTitle,
                    message: Strings.newCharacterInfoBody(
                      context,
                      edition: selectedEdition,
                      darkMode: theme.brightness == Brightness.dark,
                    ),
                  );
                },
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: iconSizeMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: smallPadding),
            Text(
              l10n.gameEdition,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: smallPadding),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<GameEdition>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: GameEdition.gloomhaven,
                label: const Text('GH'),
                tooltip: l10n.gloomhaven,
              ),
              ButtonSegment(
                value: GameEdition.gloomhaven2e,
                label: const Text('GH2e'),
                tooltip: 'Gloomhaven 2nd Edition',
              ),
              ButtonSegment(
                value: GameEdition.frosthaven,
                label: const Text('FH'),
                tooltip: l10n.frosthaven,
              ),
            ],
            selected: {selectedEdition},
            onSelectionChanged: (Set<GameEdition> selection) {
              onEditionChanged(selection.first);
            },
          ),
        ),
      ],
    );
  }
}
