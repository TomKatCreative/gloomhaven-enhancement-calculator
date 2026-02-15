import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Combined section showing Previous Retirements and Battle Goal Checkmarks.
/// Layout: Row with two columns side by side.
class CheckmarksAndRetirementsRow extends StatelessWidget {
  const CheckmarksAndRetirementsRow({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final charactersModel = context.watch<CharactersModel>();
    final theme = Theme.of(context);
    final isRetired = character.isRetired;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Previous Retirements (left column)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                AppLocalizations.of(context).previousRetirements,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 10,
              ),
              const SizedBox(height: tinyPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: iconSizeSmall,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(tinyPadding),
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: character.previousRetirements > 0 && !isRetired
                        ? () => charactersModel.updateCharacter(
                            character
                              ..previousRetirements =
                                  character.previousRetirements - 1,
                          )
                        : null,
                  ),
                  IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Opacity(opacity: 0, child: Text('99')),
                        Text('${character.previousRetirements}'),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: iconSizeSmall,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(tinyPadding),
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: !isRetired
                        ? () => charactersModel.updateCharacter(
                            character
                              ..previousRetirements =
                                  character.previousRetirements + 1,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Vertical divider (matches CheckRowDivider style from perk rows)
        Container(
          width: 1,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: largePadding),
          color: theme.dividerTheme.color,
        ),
        // Battle Goal Checkmarks (right column)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      AppLocalizations.of(context).battleGoals,
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  ),
                  const Text(' ('),
                  IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Opacity(opacity: 0, child: Text('3')),
                        Text('${character.checkMarkProgress}'),
                      ],
                    ),
                  ),
                  const Text('/3)'),
                ],
              ),
              const SizedBox(height: tinyPadding),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: iconSizeSmall,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(tinyPadding),
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: character.checkMarks > 0 && !isRetired
                          ? () => charactersModel.decreaseCheckmark(character)
                          : null,
                    ),
                    IntrinsicWidth(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          // We use 16 here because it's the widest of the numbers
                          // between 0-18
                          const Opacity(opacity: 0, child: Text('16')),
                          Text('${character.checkMarks}'),
                        ],
                      ),
                    ),
                    const Text('/18'),
                    IconButton(
                      iconSize: iconSizeSmall,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(tinyPadding),
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: character.checkMarks < 18 && !isRetired
                          ? () => charactersModel.increaseCheckmark(character)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
