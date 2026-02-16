import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/check_row_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/checkable_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class PerkRow extends StatefulWidget {
  final Character character;
  final List<Perk> perks;

  const PerkRow({super.key, required this.character, required this.perks});

  @override
  PerkRowState createState() => PerkRowState();
}

class PerkRowState extends State<PerkRow> {
  final List<String?> perkIds = [];

  /// Safely finds the CharacterPerk for a given perk ID.
  /// Returns null if not found (defensive against data inconsistency).
  CharacterPerk? _findCharacterPerk(String perkId) {
    return widget.character.characterPerks.firstWhereOrNull(
      (element) => element.associatedPerkId == perkId,
    );
  }

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();

    // Build perkIds if not already done
    if (perkIds.isEmpty) {
      for (final Perk perk in widget.perks) {
        perkIds.add(perk.perkId);
      }
    }

    return CheckableRow(
      details: widget.perks.first.perkDetails,
      leadingBuilder: (contentHeight) => [
        widget.perks[0].grouped
            ? _buildGroupedCheckboxes(context, charactersModel)
            : Row(
                children: List.generate(widget.perks.length, (index) {
                  final characterPerk = _findCharacterPerk(
                    widget.perks[index].perkId,
                  );
                  if (characterPerk == null) return const SizedBox.shrink();
                  return ConditionalCheckbox(
                    value: characterPerk.characterPerkIsSelected,
                    isEditMode: charactersModel.isEditMode,
                    isRetired: widget.character.isRetired,
                    onChanged: (bool value) => charactersModel.togglePerk(
                      characterPerks: widget.character.characterPerks,
                      perk: characterPerk,
                      value: value,
                    ),
                  );
                }),
              ),
        widget.perks[0].grouped
            ? const SizedBox(width: smallPadding)
            : CheckRowDivider(
                height: contentHeight,
                color: Theme.of(context).dividerTheme.color,
              ),
      ],
    );
  }

  Widget _buildGroupedCheckboxes(
    BuildContext context,
    CharactersModel charactersModel,
  ) {
    final allSelected = _allPerksSelected();
    final borderColor = allSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerTheme.color!;

    return Container(
      margin: const EdgeInsets.only(right: 6, left: 1),
      decoration: BoxDecoration(
        color: allSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : null,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      child: Column(
        children: List.generate(widget.perks.length, (index) {
          final characterPerk = _findCharacterPerk(widget.perks[index].perkId);
          if (characterPerk == null) return const SizedBox.shrink();
          return Checkbox(
            visualDensity: VisualDensity.compact,
            value: characterPerk.characterPerkIsSelected,
            onChanged: charactersModel.isEditMode && !widget.character.isRetired
                ? (bool? value) {
                    if (value != null) {
                      charactersModel.togglePerk(
                        characterPerks: widget.character.characterPerks,
                        perk: characterPerk,
                        value: value,
                      );
                    }
                  }
                : null,
          );
        }),
      ),
    );
  }

  bool _allPerksSelected() {
    return widget.character.characterPerks
        .where((element) => perkIds.contains(element.associatedPerkId))
        .every((element) => element.characterPerkIsSelected);
  }
}
