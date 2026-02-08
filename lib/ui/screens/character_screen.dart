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
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/add_subtract_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/blurred_expansion_container.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/masteries_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perks_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/personal_quest_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({required this.character, super.key});
  final Character character;

  // Bottom sheet size (must match element_tracker_sheet.dart)
  static const double _sheetExpandedSize = 0.85;
  // Base padding for FAB clearance when sheet is collapsed
  static const double _baseFabPadding = 82.0;

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CharactersModel>();
    final isSheetExpanded = model.isElementSheetExpanded;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate bottom padding based on sheet state
    final double bottomPadding = isSheetExpanded
        ? screenHeight * CharacterScreen._sheetExpandedSize
        : CharacterScreen._baseFabPadding;

    final l10n = AppLocalizations.of(context);

    return NestedScrollView(
      controller: context.read<CharactersModel>().charScreenScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // NAME and CLASS — scrolls away
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: smallPadding),
            child: Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: smallPadding,
                  right: smallPadding,
                  bottom: mediumPadding,
                  top: extraLargePadding,
                ),
                child: _NameAndClassSection(character: widget.character),
              ),
            ),
          ),
        ),
        // TAB BAR — pinned
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            tabBar: TabBar(
              controller: _tabController,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadiusPill),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: smallPadding,
              ),
              splashBorderRadius: BorderRadius.circular(borderRadiusPill),
              tabs: [
                Tab(
                  child: Text(
                    l10n.tabStatsAndResources,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.1),
                  ),
                ),
                Tab(
                  child: Text(
                    l10n.tabPerksAndMasteries,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.1),
                  ),
                ),
                Tab(
                  child: Text(
                    l10n.tabQuestAndNotes,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatsAndResourcesTab(
            character: widget.character,
            bottomPadding: bottomPadding,
          ),
          _PerksAndMasteriesTab(
            character: widget.character,
            bottomPadding: bottomPadding,
          ),
          _QuestAndNotesTab(
            character: widget.character,
            bottomPadding: bottomPadding,
          ),
        ],
      ),
    );
  }
}

/// Delegate for the pinned tab bar in the sliver header.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate({required this.tabBar});

  double get _totalHeight => tabBar.preferredSize.height + smallPadding * 2;

  @override
  double get minExtent => _totalHeight;

  @override
  double get maxExtent => _totalHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // Ease tint in over the first 20px of scroll, matching the app bar feel
    final progress = (shrinkOffset / 20).clamp(0.0, 1.0);
    final tinted = AppBarUtils.getTintedBackground(colorScheme);
    final color = tinted.withValues(alpha: progress);

    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: smallPadding),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => true;
}

// ──────────────────────────────────────────────────────────────────────────
// Tab 0: Stats & Resources
// ──────────────────────────────────────────────────────────────────────────

class _StatsAndResourcesTab extends StatefulWidget {
  const _StatsAndResourcesTab({
    required this.character,
    required this.bottomPadding,
  });
  final Character character;
  final double bottomPadding;

  @override
  State<_StatsAndResourcesTab> createState() => _StatsAndResourcesTabState();
}

class _StatsAndResourcesTabState extends State<_StatsAndResourcesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = context.watch<CharactersModel>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding),
      children: [
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
            child: _StatsSection(character: widget.character),
          ),
        ),
        // BATTLE GOAL CHECKMARKS & PREVIOUS RETIREMENTS (edit mode only)
        if (model.isEditMode && !widget.character.isRetired)
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: _CheckmarksAndRetirementsRow(character: widget.character),
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
          child: _ResourcesSection(character: widget.character),
        ),
        // PADDING FOR FAB AND BOTTOM SHEET
        SizedBox(height: widget.bottomPadding),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Tab 1: Perks & Masteries
// ──────────────────────────────────────────────────────────────────────────

class _PerksAndMasteriesTab extends StatefulWidget {
  const _PerksAndMasteriesTab({
    required this.character,
    required this.bottomPadding,
  });
  final Character character;
  final double bottomPadding;

  @override
  State<_PerksAndMasteriesTab> createState() => _PerksAndMasteriesTabState();
}

class _PerksAndMasteriesTabState extends State<_PerksAndMasteriesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding),
      children: [
        // PERKS
        Padding(
          padding: const EdgeInsets.all(smallPadding),
          child: PerksSection(character: widget.character),
        ),
        // MASTERIES
        if (widget.character.characterMasteries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(smallPadding),
            child: MasteriesSection(
              character: widget.character,
              charactersModel: context.watch<CharactersModel>(),
            ),
          ),
        // PADDING FOR FAB AND BOTTOM SHEET
        SizedBox(height: widget.bottomPadding),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Tab 2: Quest & Notes
// ──────────────────────────────────────────────────────────────────────────

class _QuestAndNotesTab extends StatefulWidget {
  const _QuestAndNotesTab({
    required this.character,
    required this.bottomPadding,
  });
  final Character character;
  final double bottomPadding;

  @override
  State<_QuestAndNotesTab> createState() => _QuestAndNotesTabState();
}

class _QuestAndNotesTabState extends State<_QuestAndNotesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding),
      children: [
        // PERSONAL QUEST
        Padding(
          padding: const EdgeInsets.all(smallPadding),
          child: PersonalQuestSection(character: widget.character),
        ),
        // NOTES
        Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.only(
              left: smallPadding,
              right: smallPadding,
              bottom: smallPadding,
              top: context.read<CharactersModel>().isEditMode
                  ? largePadding
                  : smallPadding,
            ),
            child:
                widget.character.notes.isNotEmpty ||
                    context.read<CharactersModel>().isEditMode
                ? _NotesSection(character: widget.character)
                : const SizedBox(),
          ),
        ),
        // PADDING FOR FAB AND BOTTOM SHEET
        SizedBox(height: widget.bottomPadding),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Existing section widgets (unchanged)
// ──────────────────────────────────────────────────────────────────────────

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
                        const Opacity(opacity: 0, child: Text('0')),
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
                ThemedSvg(assetKey: 'LEVEL', width: iconSizeXL + tinyPadding),
                Padding(
                  padding: EdgeInsets.only(
                    top: switch (Character.level(character.xp)) {
                      1 || 2 || 8 => tinyPadding,
                      5 => 3,
                      6 => 4,
                      _ => 0.0,
                    },
                  ),
                  child: Text(
                    '${Character.level(character.xp)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
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
                        mediumPadding,
                        0,
                        mediumPadding,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: tinyPadding),
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

class _ResourcesSection extends StatelessWidget {
  const _ResourcesSection({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    return BlurredExpansionContainer(
      constraints: const BoxConstraints(maxWidth: 400),
      initiallyExpanded: SharedPrefs().resourcesExpanded,
      onExpansionChanged: (value) => SharedPrefs().resourcesExpanded = value,
      title: Text(AppLocalizations.of(context).resources),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: smallPadding),
          child: Wrap(
            runSpacing: smallPadding,
            spacing: smallPadding,
            alignment: WrapAlignment.spaceEvenly,
            children: _buildResourceCards(context, character, charactersModel),
          ),
        ),
      ],
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
