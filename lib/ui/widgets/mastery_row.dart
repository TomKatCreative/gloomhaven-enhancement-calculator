import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/check_row_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class MasteryRow extends StatefulWidget {
  final Character character;
  final Mastery mastery;

  const MasteryRow({super.key, required this.character, required this.mastery});

  @override
  MasteryRowState createState() => MasteryRowState();
}

class MasteryRowState extends State<MasteryRow> {
  double height = 0;

  /// Safely finds the CharacterMastery for this row's mastery.
  /// Returns null if not found (defensive against data inconsistency).
  CharacterMastery? get _characterMastery =>
      widget.character.characterMasteries.firstWhereOrNull(
        (mastery) => mastery.associatedMasteryId == widget.mastery.id,
      );

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        children: <Widget>[
          if (_characterMastery != null)
            ConditionalCheckbox(
              value: _characterMastery!.characterMasteryAchieved,
              isEditMode: charactersModel.isEditMode,
              isRetired: widget.character.isRetired,
              onChanged: (bool value) => charactersModel.toggleMastery(
                characterMasteries: widget.character.characterMasteries,
                mastery: _characterMastery!,
                value: value,
              ),
            ),
          CheckRowDivider(
            height: height,
            color: (_characterMastery?.characterMasteryAchieved ?? false)
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).dividerTheme.color,
          ),
          SizeProviderWidget(
            onChildSize: (Size? size) {
              if (size != null && context.mounted) {
                setState(() {
                  height = size.height * 0.9;
                });
              }
            },
            child: Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: Utils.generateCheckRowDetails(
                    context,
                    widget.mastery.masteryDetails,
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
