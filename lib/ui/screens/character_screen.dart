import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/resources_repository.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/resource_field.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/add_subtract_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/masteries_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perks_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({required this.character, super.key});
  final Character character;

  // Bottom sheet size (must match element_tracker_sheet.dart)
  static const double _sheetExpandedSize = 0.85;
  // Base padding for FAB clearance when sheet is collapsed
  static const double _baseFabPadding = 82.0;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CharactersModel>();
    final isSheetExpanded = model.isElementSheetExpanded;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate bottom padding based on sheet state
    // When collapsed: just enough for FAB
    // When expanded: sheet covers most of the screen
    final double bottomPadding = isSheetExpanded
        ? screenHeight * _sheetExpandedSize
        : _baseFabPadding;

    return SingleChildScrollView(
      controller: context.read<CharactersModel>().charScreenScrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: smallPadding),
        child: Column(
          children: <Widget>[
            // NAME and CLASS
            Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: smallPadding,
                  right: smallPadding,
                  bottom: mediumPadding,
                  top: extraLargePadding,
                ),
                child: _NameAndClassSection(character: character),
              ),
            ),
            // STATS
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: smallPadding,
                  right: smallPadding,
                  top: smallPadding,
                  bottom: largePadding,
                ),
                child: _StatsSection(character: character),
              ),
            ),
            // BATTLE GOAL CHECKMARKS & PREVIOUS RETIREMENTS (edit mode only)
            if (model.isEditMode && !character.isRetired)
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(smallPadding),
                  child: _CheckmarksAndRetirementsRow(character: character),
                ),
              ),
            // RESOURCES
            Padding(
              padding: EdgeInsets.only(
                left: smallPadding,
                right: smallPadding,
                top: smallPadding,
                bottom: model.isEditMode ? largePadding : smallPadding,
              ),
              child: _ResourcesSection(character: character),
            ),
            // NOTES
            Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.only(
                  left: smallPadding,
                  right: smallPadding,
                  bottom: smallPadding,
                  top: model.isEditMode ? largePadding : smallPadding,
                ),
                child:
                    character.notes.isNotEmpty ||
                        context.read<CharactersModel>().isEditMode
                    ? _NotesSection(character: character)
                    : const SizedBox(),
              ),
            ),
            // PERKS
            Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: PerksSection(character: character),
            ),
            // MASTERIES
            if (character.characterMasteries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: MasteriesSection(
                  character: character,
                  charactersModel: context.watch<CharactersModel>(),
                ),
              ),
            // PADDING FOR FAB AND BOTTOM SHEET
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

/// Combined section showing Previous Retirements and Battle Goal Checkmarks.
/// Layout: Row with two columns side by side.
class _CheckmarksAndRetirementsRow extends StatelessWidget {
  const _CheckmarksAndRetirementsRow({required this.character});
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
                    padding: EdgeInsets.zero,
                    iconSize: iconSizeMedium,
                    icon: const Icon(Icons.indeterminate_check_box_rounded),
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
                    padding: EdgeInsets.zero,
                    iconSize: iconSizeMedium,
                    icon: const Icon(Icons.add_box_rounded),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: iconSizeMedium,
                    icon: const Icon(Icons.indeterminate_check_box_rounded),
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
                    padding: EdgeInsets.zero,
                    iconSize: iconSizeMedium,
                    icon: const Icon(Icons.add_box_rounded),
                    onPressed: character.checkMarks < 18 && !isRetired
                        ? () => charactersModel.increaseCheckmark(character)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NameAndClassSection extends StatelessWidget {
  const _NameAndClassSection({required this.character});
  final Character character;
  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    return Column(
      children: <Widget>[
        context.watch<CharactersModel>().isEditMode && !character.isRetired
            ? TextFormField(
                key: ValueKey('name_${character.uuid}'),
                initialValue: character.name,
                autocorrect: false,
                onChanged: (String value) {
                  charactersModel.updateCharacter(character..name = value);
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).name,
                ),
                minLines: 1,
                maxLines: 2,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
              )
            : AutoSizeText(
                character.name,
                maxLines: 2,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
        const SizedBox(height: largePadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: const Alignment(0, 0.3),
              children: <Widget>[
                ThemedSvg(assetKey: 'LEVEL', width: iconSizeXL),
                Text(
                  '${Character.level(character.xp)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: smallPadding),
            Flexible(
              child: AutoSizeText(
                character.classSubtitle,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontFamily: nyala),
              ),
            ),
          ],
        ),
        if (character.shouldShowTraits &&
            !context.watch<CharactersModel>().isEditMode) ...[
          const SizedBox(height: largePadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemedSvg(assetKey: 'TRAIT', width: iconSizeSmall),
              const SizedBox(width: smallPadding),
              Flexible(
                child: AutoSizeText(
                  '${character.playerClass.traits[0]} · ${character.playerClass.traits[1]} · ${character.playerClass.traits[2]}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
        if (character.isRetired) Text(AppLocalizations.of(context).retired),
      ],
    );
  }
}

class _StatsSection extends StatefulWidget {
  const _StatsSection({required this.character});
  final Character character;

  @override
  State<_StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<_StatsSection> {
  late TextEditingController _xpController;
  late TextEditingController _goldController;

  @override
  void initState() {
    super.initState();
    _xpController = TextEditingController(
      text: widget.character.xp == 0 ? '' : widget.character.xp.toString(),
    );
    _goldController = TextEditingController(
      text: widget.character.gold == 0 ? '' : widget.character.gold.toString(),
    );
  }

  @override
  void dispose() {
    _xpController.dispose();
    _goldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersModel = context.read<CharactersModel>();
    final isEditMode =
        context.watch<CharactersModel>().isEditMode &&
        !widget.character.isRetired;

    // Edit mode: Show XP and Gold with external labels, plus Battle Goals and Pocket
    if (isEditMode) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // XP field with inline icon
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xpController,
                    enableInteractiveSelection: false,
                    onChanged: (String value) {
                      charactersModel.updateCharacter(
                        widget.character
                          ..xp = value == '' ? 0 : int.parse(value),
                      );
                    },
                    textAlign: TextAlign.start,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp('[\\.|\\,|\\ |\\-]'),
                      ),
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemedSvg(assetKey: 'XP', width: iconSizeSmall),
                          const SizedBox(width: tinyPadding),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).xp,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: tinyPadding),
                  child: Text(
                    '/ ${Character.xpForNextLevel(Character.level(widget.character.xp))}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exposure),
                  onPressed: () async {
                    int? value = await showDialog<int?>(
                      context: context,
                      builder: (_) => AddSubtractDialog(
                        widget.character.xp,
                        AppLocalizations.of(context).xp,
                      ),
                    );
                    if (value != null) {
                      final clampedValue = value
                          .clamp(0, double.infinity)
                          .toInt();
                      charactersModel.updateCharacter(
                        widget.character..xp = clampedValue,
                      );
                      _xpController.text = clampedValue == 0
                          ? ''
                          : clampedValue.toString();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: smallPadding),
          // Gold field with inline icon
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goldController,
                    enableInteractiveSelection: false,
                    onChanged: (String value) =>
                        charactersModel.updateCharacter(
                          widget.character
                            ..gold = value == '' ? 0 : int.parse(value),
                        ),
                    textAlign: TextAlign.start,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp('[\\.|\\,|\\ |\\-]'),
                      ),
                      LengthLimitingTextInputFormatter(4),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemedSvg(assetKey: 'GOLD', width: iconSizeSmall),
                          const SizedBox(width: tinyPadding),
                          Text(AppLocalizations.of(context).gold),
                        ],
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exposure),
                  onPressed: () async {
                    int? value = await showDialog<int?>(
                      context: context,
                      builder: (_) => AddSubtractDialog(
                        widget.character.gold,
                        AppLocalizations.of(context).gold,
                      ),
                    );
                    if (value != null) {
                      charactersModel.updateCharacter(
                        widget.character..gold = value,
                      );
                      _goldController.text = value == 0 ? '' : value.toString();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    // View mode: Original inline layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Tooltip(
          message: AppLocalizations.of(context).xp,
          child: Row(
            children: <Widget>[
              ThemedSvg(assetKey: 'XP', width: iconSizeMedium),
              const SizedBox(width: smallPadding),
              Text(
                widget.character.xp.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Consumer<CharactersModel>(
                builder: (_, charactersModel, _) => Text(
                  ' / ${Character.xpForNextLevel(Character.level(widget.character.xp))}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).gold,
          child: Row(
            children: <Widget>[
              ThemedSvg(assetKey: 'GOLD', width: iconSizeMedium),
              const SizedBox(width: smallPadding),
              Text(
                '${widget.character.gold}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).battleGoals,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ThemedSvg(assetKey: 'GOAL', width: iconSizeMedium),
              SizedBox(width: smallPadding),
              Text(
                '${widget.character.checkMarkProgress.toString()}/3',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(
            context,
          ).pocketItemsAllowed(widget.character.pocketItemsAllowed),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ThemedSvg(assetKey: 'Pocket', width: iconSizeMedium),
              Transform.translate(
                offset: const Offset(0, 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.5),
                  child: Text(
                    '${widget.character.pocketItemsAllowed}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResourcesSection extends StatefulWidget {
  const _ResourcesSection({required this.character});
  final Character character;
  @override
  State<_ResourcesSection> createState() => _ResourcesSectionState();
}

class _ResourcesSectionState extends State<_ResourcesSection> {
  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).colorScheme.primary,
          onExpansionChanged: (value) =>
              SharedPrefs().resourcesExpanded = value,
          initiallyExpanded: SharedPrefs().resourcesExpanded,
          title: Text(AppLocalizations.of(context).resources),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: smallPadding),
              child: Wrap(
                runSpacing: smallPadding,
                spacing: smallPadding,
                alignment: WrapAlignment.spaceEvenly,
                children: _buildResourceCards(
                  context,
                  widget.character,
                  charactersModel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResourceCards(
    BuildContext context,
    Character character,
    CharactersModel charactersModel,
  ) {
    return resourceFields.entries.map((entry) {
      final ResourceFieldData fieldData = entry.value;
      return ResourceCard(
        resource: ResourcesRepository.resources[fieldData.resourceIndex],
        color: Theme.of(context)
            .extension<AppThemeExtension>()!
            .characterPrimary
            .withValues(alpha: 0.1),
        count: fieldData.getter(character),
        onIncrease: () {
          // Create a copy of the character and update it
          final updatedCharacter = character;
          fieldData.setter(updatedCharacter, fieldData.getter(character) + 1);
          charactersModel.updateCharacter(updatedCharacter);
        },
        onDecrease: () {
          // Create a copy of the character and update it
          final updatedCharacter = character;
          fieldData.setter(updatedCharacter, fieldData.getter(character) - 1);
          charactersModel.updateCharacter(updatedCharacter);
        },
        canEdit: charactersModel.isEditMode && !character.isRetired,
      );
    }).toList();
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    final isEditMode =
        context.watch<CharactersModel>().isEditMode && !character.isRetired;

    return Column(
      children: <Widget>[
        // Hide header in edit mode since the text field has a floating label
        if (!isEditMode) ...[
          Text(
            AppLocalizations.of(context).notes,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: smallPadding),
        ],
        isEditMode
            ? TextFormField(
                key: ValueKey('notes_${character.uuid}'),
                initialValue: character.notes,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (String value) {
                  charactersModel.updateCharacter(character..notes = value);
                },
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).notes,
                ),
              )
            : Text(character.notes),
      ],
    );
  }
}
