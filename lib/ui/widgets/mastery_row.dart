import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/check_row_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/checkable_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class MasteryRow extends StatelessWidget {
  final Character character;
  final Mastery mastery;

  const MasteryRow({super.key, required this.character, required this.mastery});

  CharacterMastery? _findCharacterMastery() {
    return character.characterMasteries.firstWhereOrNull(
      (m) => m.associatedMasteryId == mastery.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();
    final characterMastery = _findCharacterMastery();

    return CheckableRow(
      details: mastery.masteryDetails,
      leadingBuilder: (contentHeight) => [
        if (characterMastery != null)
          ConditionalCheckbox(
            value: characterMastery.characterMasteryAchieved,
            isEditMode: charactersModel.isEditMode,
            isRetired: character.isRetired,
            onChanged: (bool value) => charactersModel.toggleMastery(
              characterMasteries: character.characterMasteries,
              mastery: characterMastery,
              value: value,
            ),
          ),
        CheckRowDivider(
          height: contentHeight,
          color: (characterMastery?.characterMasteryAchieved ?? false)
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).dividerTheme.color,
        ),
      ],
    );
  }
}
