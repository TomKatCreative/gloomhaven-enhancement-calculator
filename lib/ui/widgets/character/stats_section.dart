import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/resource_field.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/add_subtract_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_stepper_sheet.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({required this.character, super.key});
  final Character character;

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
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
      return Padding(
        padding: const EdgeInsets.only(top: smallPadding),
        child: Row(
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
                      textAlign: TextAlign.end,
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
                        contentPadding: const EdgeInsets.fromLTRB(
                          mediumPadding,
                          smallPadding,
                          0,
                          smallPadding,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: tinyPadding,
                    ),
                    child: Text(
                      '/',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${Character.xpForNextLevel(Character.level(widget.character.xp))}',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                        final clampedValue = value.clamp(0, 999);
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
                        LengthLimitingTextInputFormatter(3),
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
                        final clampedValue = value.clamp(0, 999);
                        charactersModel.updateCharacter(
                          widget.character..gold = clampedValue,
                        );
                        _goldController.text = clampedValue == 0
                            ? ''
                            : clampedValue.toString();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              ThemedSvg(assetKey: 'GOLD', width: iconSizeMedium),
              const SizedBox(width: smallPadding),
              if (widget.character.isRetired && widget.character.gold > 0)
                StrikethroughText(
                  '${widget.character.gold}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
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
              ThemedSvg(assetKey: 'Pocket', width: iconSizeLarge),
              Transform.translate(
                offset: Offset(
                  0,
                  switch (widget.character.pocketItemsAllowed) {
                    1 || 2 => 3,
                    _ => 2,
                  }.toDouble(),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.5),
                  child: Text(
                    '${widget.character.pocketItemsAllowed}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

class ResourcesContent extends StatelessWidget {
  const ResourcesContent({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final charactersModel = context.read<CharactersModel>();
    final canEdit = charactersModel.isEditMode && !character.isRetired;
    final iconColor = ColorUtils.ensureContrast(
      theme.extension<AppThemeExtension>()!.characterPrimary,
      theme.colorScheme.surfaceContainerHigh,
    );
    final cards = _buildResourceCards(
      context,
      character,
      charactersModel,
      iconColor: iconColor,
      canEdit: canEdit,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const minCardWidth = 75.0;
        final crossAxisCount = (constraints.maxWidth / minCardWidth)
            .floor()
            .clamp(3, cards.length);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: smallPadding,
          crossAxisSpacing: smallPadding,
          children: cards,
        );
      },
    );
  }

  List<Widget> _buildResourceCards(
    BuildContext context,
    Character character,
    CharactersModel charactersModel, {
    required Color iconColor,
    required bool canEdit,
  }) {
    return resourceFields.map((fieldData) {
      return ResourceCard(
        name: fieldData.name,
        assetKey: fieldData.assetKey,
        iconColor: iconColor,
        count: fieldData.getter(character),
        onTap: canEdit
            ? () => ResourceStepperSheet.show(
                context: context,
                name: fieldData.name,
                assetKey: fieldData.assetKey,
                iconColor: iconColor,
                initialCount: fieldData.getter(character),
                onCountChanged: (newCount) {
                  fieldData.setter(character, newCount);
                  charactersModel.updateCharacter(character);
                },
              )
            : null,
      );
    }).toList();
  }
}
