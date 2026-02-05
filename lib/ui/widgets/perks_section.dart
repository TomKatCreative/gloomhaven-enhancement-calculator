import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perk_row.dart';

class PerksSection extends StatelessWidget {
  final Character character;

  const PerksSection({super.key, required this.character});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Perks:', style: Theme.of(context).textTheme.headlineMedium),
            IntrinsicWidth(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Text(
                      '99',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(
                    '${character.numOfSelectedPerks}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color:
                          Character.maximumPerks(character) >=
                              character.numOfSelectedPerks
                          ? null
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Text('/', style: Theme.of(context).textTheme.headlineMedium),
            IntrinsicWidth(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Text(
                      '99',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(
                    '${Character.maximumPerks(character)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: smallPadding),
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _generatePerkRows(),
        ),
      ],
    );
  }

  List<PerkRow> _generatePerkRows() {
    if (character.perks.isEmpty) return [];
    List<PerkRow> perkRows = [];
    String currentPerkDetails = '';
    List<Perk> currentRowPerks = [];

    for (Perk perk in character.perks) {
      // If this is the first perk or details changed, start a new row
      if (currentRowPerks.isEmpty || currentPerkDetails != perk.perkDetails) {
        // Add previous row if it exists
        if (currentRowPerks.isNotEmpty) {
          perkRows.add(
            PerkRow(
              character: character,
              perks: List.from(currentRowPerks), // Create defensive copy
            ),
          );
        }

        // Start new row
        currentRowPerks = [perk];
        currentPerkDetails = perk.perkDetails;
      } else {
        // Same details, add to current row
        currentRowPerks.add(perk);
      }
    }

    // Add the final row
    if (currentRowPerks.isNotEmpty) {
      perkRows.add(
        PerkRow(character: character, perks: List.from(currentRowPerks)),
      );
    }
    return perkRows;
  }
}
