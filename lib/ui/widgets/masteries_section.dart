import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/mastery_row.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class MasteriesSection extends StatefulWidget {
  final CharactersModel charactersModel;
  final Character character;

  const MasteriesSection({
    super.key,
    required this.charactersModel,
    required this.character,
  });
  @override
  State<StatefulWidget> createState() => MasteriesSectionState();
}

class MasteriesSectionState extends State<MasteriesSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Masteries',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).contrastedPrimary,
          ),
        ),
        const SizedBox(height: mediumPadding),
        ...widget.character.masteries.map(
          (mastery) => Padding(
            padding: const EdgeInsets.symmetric(vertical: tinyPadding),
            child: MasteryRow(character: widget.character, mastery: mastery),
          ),
        ),
      ],
    );
  }
}
