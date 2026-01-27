import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: mediumPadding),
        child: Column(
          children: <Widget>[
            // NAME and CLASS
            Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(mediumPadding),
                child: _NameAndClassSection(character: character),
              ),
            ),
            // STATS
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(mediumPadding),
                child: _StatsSection(character: character),
              ),
            ),
            // PREVIOUS RETIREMENTS (edit mode only)
            if (model.isEditMode && !character.isRetired)
              Padding(
                padding: const EdgeInsets.all(mediumPadding),
                child: _PreviousRetirementsSection(character: character),
              ),
            // RESOURCES
            Padding(
              padding: const EdgeInsets.all(mediumPadding),
              child: _ResourcesSection(character: character),
            ),
            // NOTES
            Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(mediumPadding),
                child:
                    character.notes.isNotEmpty ||
                        context.read<CharactersModel>().isEditMode
                    ? _NotesSection(character: character)
                    : const SizedBox(),
              ),
            ),
            // BATTLE GOAL CHECKMARKS
            if (context.read<CharactersModel>().isEditMode &&
                !character.isRetired)
              _BattleGoalCheckmarksSection(character: character),
            // PERKS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: mediumPadding),
              child: PerksSection(character: character),
            ),
            const SizedBox(height: mediumPadding),
            // MASTERIES
            if (character.characterMasteries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: mediumPadding - 3,
                ),
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

class _PreviousRetirementsSection extends StatelessWidget {
  const _PreviousRetirementsSection({required this.character});
  final Character character;
  @override
  Widget build(BuildContext context) {
    final charactersModel = context.read<CharactersModel>();
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: TextFormField(
        key: ValueKey('previous_retirements_${character.uuid}'),
        initialValue: character.previousRetirements.toString(),
        textAlign: TextAlign.center,
        enableInteractiveSelection: false,
        onChanged: (String value) => charactersModel.updateCharacter(
          character..previousRetirements = value.isEmpty ? 0 : int.parse(value),
        ),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).previousRetirements,
          border: const OutlineInputBorder(),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[\\.|\\,|\\ |\\-]')),
        ],
        keyboardType: TextInputType.number,
      ),
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
                  label: Text(AppLocalizations.of(context).name),
                  border: const OutlineInputBorder(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: const Alignment(0, 0.3),
              children: <Widget>[
                SvgPicture.asset(
                  'images/ui/level.svg',
                  width: iconSize * 1.5,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  '${Character.level(character.xp)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: titleFontSize - 7,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: mediumPadding),
            Flexible(
              child: AutoSizeText(
                character.getClassSubtitle(),
                maxLines: 1,
                style: const TextStyle(fontSize: titleFontSize),
              ),
            ),
          ],
        ),
        if (character.showTraits()) ...[
          const SizedBox(height: mediumPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'images/ui/trait.svg',
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: mediumPadding),
              Flexible(
                child: AutoSizeText(
                  '${character.playerClass.traits[0]} · ${character.playerClass.traits[1]} · ${character.playerClass.traits[2]}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
        if (character.isRetired)
          Text(
            AppLocalizations.of(context).retired,
            style: const TextStyle(fontSize: 20),
          ),
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
    _xpController = TextEditingController(text: widget.character.xp.toString());
    _goldController = TextEditingController(
      text: widget.character.gold.toString(),
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
    CharactersModel charactersModel = context.read<CharactersModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Tooltip(
          message: AppLocalizations.of(context).xp,
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                'images/ui/xp.svg',
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: mediumPadding),
              context.watch<CharactersModel>().isEditMode &&
                      !widget.character.isRetired
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 75),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: _xpController,
                            enableInteractiveSelection: false,
                            onChanged: (String value) {
                              charactersModel.updateCharacter(
                                widget.character
                                  ..xp = value == '' ? 0 : int.parse(value),
                              );
                            },
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp('[\\.|\\,|\\ |\\-]'),
                              ),
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: Text(AppLocalizations.of(context).xp),
                              border: const OutlineInputBorder(),
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
                                charactersModel.updateCharacter(
                                  widget.character
                                    ..xp = value
                                        .clamp(0, double.infinity)
                                        .toInt(),
                                );
                                _xpController.text = value.toString();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Text(
                      widget.character.xp.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              Consumer<CharactersModel>(
                builder: (_, charactersModel, _) => Text(
                  ' / ${Character.xpForNextLevel(Character.level(widget.character.xp))}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize:
                        Theme.of(context).textTheme.bodyMedium?.fontSize != null
                        ? Theme.of(context).textTheme.bodyMedium!.fontSize! / 2
                        : Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).gold,
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                'images/ui/gold.svg',
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              context.watch<CharactersModel>().isEditMode &&
                      !widget.character.isRetired
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 75),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _goldController,
                            enableInteractiveSelection: false,
                            onChanged: (String value) =>
                                charactersModel.updateCharacter(
                                  widget.character
                                    ..gold = value == '' ? 0 : int.parse(value),
                                ),
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp('[\\.|\\,|\\ |\\-]'),
                              ),
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: Text(AppLocalizations.of(context).gold),
                              border: const OutlineInputBorder(),
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
                                _goldController.text = value.toString();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Text(
                      ' ${widget.character.gold}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).battleGoalCheckmarks,
          child: SizedBox(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SvgPicture.asset(
                  'images/ui/goal.svg',
                  width: iconSize,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(
                  width: 5,
                  child: Text(widget.character.checkMarkProgress().toString()),
                ),
                Text(
                  '/3',
                  softWrap: false,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(letterSpacing: 4),
                ),
              ],
            ),
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).pocketItemsAllowed(
            (Character.level(widget.character.xp) / 2).round(),
          ),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              SvgPicture.asset(
                'images/equipment_slots/pocket.svg',
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.5),
                child: Text(
                  '${(Character.level(widget.character.xp) / 2).round()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surface,
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
          color: Theme.of(context).colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(4),
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
              padding: const EdgeInsets.only(bottom: mediumPadding),
              child: Wrap(
                runSpacing: mediumPadding,
                spacing: mediumPadding,
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
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context).notes,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: mediumPadding),
        context.watch<CharactersModel>().isEditMode && !character.isRetired
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
                  label: Text(AppLocalizations.of(context).notes),
                  border: const OutlineInputBorder(),
                ),
              )
            : Text(character.notes),
      ],
    );
  }
}

class _BattleGoalCheckmarksSection extends StatelessWidget {
  const _BattleGoalCheckmarksSection({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();
    return charactersModel.isEditMode
        ? Padding(
            padding: const EdgeInsets.all(mediumPadding),
            child: Column(
              children: <Widget>[
                AutoSizeText(
                  AppLocalizations.of(context).battleGoalCheckmarks,
                  textAlign: TextAlign.center,
                  minFontSize: titleFontSize,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: character.checkMarks > 0 && !character.isRetired,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () =>
                            charactersModel.decreaseCheckmark(character),
                      ),
                    ),
                    Text(
                      '${character.checkMarks} / 18',
                      style: const TextStyle(fontSize: titleFontSize),
                    ),
                    Visibility(
                      visible:
                          character.checkMarks < 18 && !character.isRetired,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.add_circle),
                        onPressed: () =>
                            charactersModel.increaseCheckmark(character),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container();
  }
}
