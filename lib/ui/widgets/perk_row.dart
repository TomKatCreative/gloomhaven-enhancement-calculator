import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/check_row_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:provider/provider.dart';

import '../../data/constants.dart';
import '../../models/perk/perk.dart';
import '../../utils/utils.dart';
import '../../viewmodels/characters_model.dart';

class PerkRow extends StatefulWidget {
  final Character character;
  final List<Perk> perks;

  const PerkRow({super.key, required this.character, required this.perks});

  @override
  PerkRowState createState() => PerkRowState();
}

class PerkRowState extends State<PerkRow> {
  final List<String?> perkIds = [];
  double height = 0;

  /// Safely finds the CharacterPerk for a given perk ID.
  /// Returns null if not found (defensive against data inconsistency).
  CharacterPerk? _findCharacterPerk(String perkId) {
    return widget.character.characterPerks.firstWhereOrNull(
      (element) => element.associatedPerkId == perkId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use targeted select to only rebuild when isEditMode changes,
    // not during PageView transitions or other model updates
    final isEditMode = context.select<CharactersModel, bool>(
      (m) => m.isEditMode,
    );
    final charactersModel = context.read<CharactersModel>();

    // Build perkIds if not already done
    if (perkIds.isEmpty) {
      for (final Perk perk in widget.perks) {
        perkIds.add(perk.perkId);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        children: <Widget>[
          widget.perks[0].grouped
              ? _buildGroupedCheckboxes(context, charactersModel, isEditMode)
              : Row(
                  children: List.generate(widget.perks.length, (index) {
                    final characterPerk = _findCharacterPerk(
                      widget.perks[index].perkId,
                    );
                    if (characterPerk == null) return const SizedBox.shrink();
                    return ConditionalCheckbox(
                      value: characterPerk.characterPerkIsSelected,
                      isEditMode: isEditMode,
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
                  height: height,
                  color: Theme.of(context).dividerTheme.color,
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
                    widget.perks.first.perkDetails,
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

  Widget _buildGroupedCheckboxes(
    BuildContext context,
    CharactersModel charactersModel,
    bool isEditMode,
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
            onChanged: isEditMode && !widget.character.isRetired
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
