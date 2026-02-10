import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/mastery_row.dart';

class MasteriesSection extends StatelessWidget {
  final Character character;

  const MasteriesSection({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final masteries = character.masteries;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...masteries.map(
          (mastery) => Padding(
            padding: const EdgeInsets.symmetric(vertical: tinyPadding),
            child: MasteryRow(character: character, mastery: mastery),
          ),
        ),
      ],
    );
  }
}
