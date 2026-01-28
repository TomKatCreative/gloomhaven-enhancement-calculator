import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
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

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();

    // Build perkIds if not already done
    if (perkIds.isEmpty) {
      for (final Perk perk in widget.perks) {
        perkIds.add(perk.perkId);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: mediumPadding / 2),
      child: Row(
        children: <Widget>[
          widget.perks[0].grouped
              ? _buildGroupedCheckboxes(context, charactersModel)
              : Row(
                  children: List.generate(
                    widget.perks.length,
                    (index) => ConditionalCheckbox(
                      value: widget.character.characterPerks
                          .firstWhere(
                            (element) =>
                                element.associatedPerkId ==
                                widget.perks[index].perkId,
                          )
                          .characterPerkIsSelected,
                      isEditMode: charactersModel.isEditMode,
                      isRetired: widget.character.isRetired,
                      onChanged: (bool value) => charactersModel.togglePerk(
                        characterPerks: widget.character.characterPerks,
                        perk: widget.character.characterPerks.firstWhere(
                          (element) =>
                              element.associatedPerkId ==
                              widget.perks[index].perkId,
                        ),
                        value: value,
                      ),
                    ),
                  ),
                ),
          widget.perks[0].grouped
              ? const SizedBox(width: mediumPadding)
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(letterSpacing: 0.7),
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
  ) {
    final allSelected = _allPerksSelected();
    final borderColor = allSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerTheme.color!;

    return Container(
      margin: const EdgeInsets.only(right: 6, left: 1),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: List.generate(widget.perks.length, (index) {
          return Checkbox(
            visualDensity: VisualDensity.compact,
            value: widget.character.characterPerks
                .firstWhere(
                  (element) =>
                      element.associatedPerkId == widget.perks[index].perkId,
                )
                .characterPerkIsSelected,
            onChanged: charactersModel.isEditMode && !widget.character.isRetired
                ? (bool? value) {
                    if (value != null) {
                      charactersModel.togglePerk(
                        characterPerks: widget.character.characterPerks,
                        perk: widget.character.characterPerks.firstWhere(
                          (element) =>
                              element.associatedPerkId ==
                              widget.perks[index].perkId,
                        ),
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
