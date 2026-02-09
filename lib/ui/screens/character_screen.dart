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
import 'package:gloomhaven_enhancement_calc/ui/widgets/character_section_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/masteries_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perks_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/personal_quest_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Indices for section navigation chips.
enum _Section { general, quest, notes, perks, masteries }

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({required this.character, super.key});
  final Character character;

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  // Bottom sheet size (must match element_tracker_sheet.dart)
  static const double _sheetExpandedSize = 0.85;
  // Base padding for FAB clearance when sheet is collapsed
  static const double _baseFabPadding = 82.0;

  // Section keys for scroll-to and scroll-spy
  final _sectionKeys = {for (final s in _Section.values) s: GlobalKey()};

  _Section _activeSection = _Section.general;

  late ScrollController _scrollController;
  bool _isScrollSpyEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController = context
        .read<CharactersModel>()
        .charScreenScrollController;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_isScrollSpyEnabled) return;
    _updateActiveSection();
  }

  void _updateActiveSection() {
    if (!_scrollController.hasClients) return;

    // Threshold: just below the pinned headers
    const headerOffset = 160.0 + chipBarHeight;

    _Section? closest;
    double closestDistance = double.infinity;

    for (final entry in _sectionKeys.entries) {
      final key = entry.value;
      if (key.currentContext == null) continue;

      // Skip masteries if not present
      if (entry.key == _Section.masteries &&
          widget.character.characterMasteries.isEmpty) {
        continue;
      }

      final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero);
      final distance = (position.dy - headerOffset).abs();

      // Prefer the section whose top is closest to (but not far below) the
      // threshold
      if (position.dy <= headerOffset + 50 || closest == null) {
        if (distance < closestDistance || position.dy <= headerOffset + 50) {
          closest = entry.key;
          closestDistance = distance;
        }
      }
    }

    if (closest != null && closest != _activeSection) {
      setState(() => _activeSection = closest!);
    }
  }

  Future<void> _scrollToSection(_Section section) async {
    final key = _sectionKeys[section]!;
    if (key.currentContext == null) return;
    if (!_scrollController.hasClients) return;

    // Temporarily disable scroll spy while programmatic scroll is in progress
    _isScrollSpyEnabled = false;
    setState(() => _activeSection = section);

    // Use ensureVisible to compute the exact offset (it correctly handles
    // collapsing pinned headers), then back off by mediumPadding for breathing
    // room between the chip bar and the section card.
    final startOffset = _scrollController.offset;
    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration.zero,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
    final exactTarget = _scrollController.offset;

    // Jump back to where we were, then animate to the adjusted target.
    _scrollController.jumpTo(startOffset);
    final target = (exactTarget - mediumPadding).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    await _scrollController.animateTo(
      target,
      duration: animationDuration,
      curve: Curves.easeInOut,
    );

    _isScrollSpyEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CharactersModel>();
    final isSheetExpanded = model.isElementSheetExpanded;
    final screenHeight = MediaQuery.of(context).size.height;

    final double bottomPadding = isSheetExpanded
        ? screenHeight * _sheetExpandedSize
        : _baseFabPadding;

    final hasMasteries = widget.character.characterMasteries.isNotEmpty;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // PINNED HEADER: Character name, level, class
        SliverPersistentHeader(
          pinned: true,
          delegate: _CharacterHeaderDelegate(
            character: widget.character,
            isEditMode: model.isEditMode,
          ),
        ),
        // CHIP NAV BAR
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionNavBarDelegate(
            character: widget.character,
            activeSection: _activeSection,
            onSectionTapped: _scrollToSection,
            hasMasteries: hasMasteries,
          ),
        ),
        // GENERAL CARD (stats + resources)
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                smallPadding,
                mediumPadding,
                smallPadding,
                smallPadding,
              ),
              child: CollapsibleSectionCard(
                sectionKey: _sectionKeys[_Section.general],
                title: AppLocalizations.of(context).general,
                icon: Icons.bar_chart_rounded,
                initiallyExpanded: SharedPrefs().generalExpanded,
                onExpansionChanged: (value) =>
                    SharedPrefs().generalExpanded = value,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      largePadding,
                      0,
                      largePadding,
                      largePadding,
                    ),
                    child: Column(
                      children: [
                        _StatsSection(character: widget.character),
                        if (model.isEditMode &&
                            !widget.character.isRetired) ...[
                          const Divider(height: largePadding * 2),
                          _CheckmarksAndRetirementsRow(
                            character: widget.character,
                          ),
                        ],
                        const Divider(height: largePadding * 2),
                        _ResourcesContent(character: widget.character),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // QUEST CARD
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: Container(
                key: _sectionKeys[_Section.quest],
                constraints: const BoxConstraints(maxWidth: 400),
                child: PersonalQuestSection(character: widget.character),
              ),
            ),
          ),
        ),
        // NOTES CARD
        if (widget.character.notes.isNotEmpty || model.isEditMode)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: CharacterSectionCard(
                  sectionKey: _sectionKeys[_Section.notes],
                  title: AppLocalizations.of(context).notes,
                  icon: Icons.notes_rounded,
                  child: _NotesSection(character: widget.character),
                ),
              ),
            ),
          ),
        // PERKS CARD
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: CharacterSectionCard(
                sectionKey: _sectionKeys[_Section.perks],
                title: AppLocalizations.of(context).perks,
                icon: Icons.auto_awesome_rounded,
                trailing: _PerksCountBadge(character: widget.character),
                child: PerksSection(character: widget.character),
              ),
            ),
          ),
        ),
        // MASTERIES CARD
        if (hasMasteries)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: CharacterSectionCard(
                  sectionKey: _sectionKeys[_Section.masteries],
                  title: AppLocalizations.of(context).masteries,
                  icon: Icons.military_tech_rounded,
                  child: MasteriesSection(
                    character: widget.character,
                    charactersModel: model,
                  ),
                ),
              ),
            ),
          ),
        // BOTTOM PADDING
        SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned Character Header Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _CharacterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CharacterHeaderDelegate({required this.character, required this.isEditMode});

  final Character character;
  final bool isEditMode;

  static const double _maxHeight = 160.0;
  static const double _minHeight = 56.0;

  @override
  double get maxExtent => _maxHeight;

  @override
  double get minExtent =>
      isEditMode && !character.isRetired ? _maxHeight : _minHeight;

  @override
  bool shouldRebuild(covariant _CharacterHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final range = maxExtent - minExtent;
    final progress = range > 0 ? (shrinkOffset / range).clamp(0.0, 1.0) : 0.0;

    return Material(
      elevation: progress * 2,
      color: colorScheme.surface,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Faded class icon background
            Positioned(
              right: -20,
              top: -20,
              bottom: -20,
              width: 200,
              child: Opacity(
                opacity: (0.08 * (1 - progress)).clamp(0.0, 0.08),
                child: ClassIconSvg(
                  playerClass: character.playerClass,
                  color: character
                      .getEffectiveColor(theme.brightness)
                      .withValues(alpha: 1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: largePadding),
              child: _buildContent(context, progress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double progress) {
    return Stack(
      children: [
        // Expanded content fades out
        Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0),
          child: _buildExpandedContent(context, progress),
        ),
        // Collapsed content fades in
        Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: _buildCollapsedContent(context),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final model = context.read<CharactersModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name
        if (isEditMode && !character.isRetired)
          Flexible(
            child: TextFormField(
              key: ValueKey('name_${character.uuid}'),
              initialValue: character.name,
              autocorrect: false,
              onChanged: (String value) {
                model.updateCharacter(character..name = value);
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).name,
              ),
              maxLines: 1,
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
            ),
          )
        else
          AutoSizeText(
            character.name,
            maxLines: 1,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: smallPadding),
        // Level + class subtitle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LevelBadge(character: character),
            const SizedBox(width: smallPadding),
            Flexible(
              child: AutoSizeText(
                character.classSubtitle,
                maxLines: 1,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: nyala,
                ),
              ),
            ),
          ],
        ),
        // Traits (view mode only, frosthaven classes)
        if (character.shouldShowTraits && !isEditMode) ...[
          const SizedBox(height: smallPadding),
          Opacity(
            opacity: 1.0 - progress,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemedSvg(assetKey: 'TRAIT', width: iconSizeSmall),
                const SizedBox(width: smallPadding),
                Flexible(
                  child: AutoSizeText(
                    '${character.playerClass.traits[0]} · ${character.playerClass.traits[1]} · ${character.playerClass.traits[2]}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (character.isRetired) Text(AppLocalizations.of(context).retired),
      ],
    );
  }

  Widget _buildCollapsedContent(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: iconSizeXL,
          height: iconSizeXL,
          child: ClassIconSvg(
            playerClass: character.playerClass,
            color: character
                .getEffectiveColor(theme.brightness)
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: smallPadding),
        Expanded(
          child: Text(
            character.name,
            maxLines: 1,
            style: theme.textTheme.titleLarge,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        const SizedBox(width: smallPadding),
        _LevelBadge(character: character),
        if (character.isRetired) ...[
          const SizedBox(width: smallPadding),
          Text(
            AppLocalizations.of(context).retired,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Navigation Chip Bar Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _SectionNavBarDelegate extends SliverPersistentHeaderDelegate {
  _SectionNavBarDelegate({
    required this.character,
    required this.activeSection,
    required this.onSectionTapped,
    required this.hasMasteries,
  });

  final Character character;
  final _Section activeSection;
  final ValueChanged<_Section> onSectionTapped;
  final bool hasMasteries;

  @override
  double get maxExtent => chipBarHeight;

  @override
  double get minExtent => chipBarHeight;

  @override
  bool shouldRebuild(covariant _SectionNavBarDelegate oldDelegate) =>
      activeSection != oldDelegate.activeSection ||
      hasMasteries != oldDelegate.hasMasteries;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primaryColor = theme.contrastedPrimary;

    final sections = [
      (_Section.general, l10n.general),
      (_Section.quest, l10n.quest),
      (_Section.notes, l10n.notes),
      (_Section.perks, l10n.perks),
      if (hasMasteries) (_Section.masteries, l10n.masteries),
    ];

    return Container(
      height: chipBarHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: smallPadding),
        child: Row(
          children: [
            for (final (section, label) in sections)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: tinyPadding),
                child: ChoiceChip(
                  label: Text(label),
                  selected: activeSection == section,
                  onSelected: (_) => onSectionTapped(section),
                  selectedColor: theme
                      .extension<AppThemeExtension>()!
                      .characterPrimary
                      .withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: activeSection == section
                        ? primaryColor
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: activeSection == section
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: activeSection == section
                      ? BorderSide(color: primaryColor.withValues(alpha: 0.3))
                      : null,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Badge (shared between expanded and collapsed header)
// ─────────────────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: const Alignment(0, 0.3),
      children: [
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
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Perks Count Badge (shown in card header trailing area)
// ─────────────────────────────────────────────────────────────────────────────

class _PerksCountBadge extends StatelessWidget {
  const _PerksCountBadge({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverLimit =
        character.numOfSelectedPerks > Character.maximumPerks(character);

    return Text(
      '${character.numOfSelectedPerks}/${Character.maximumPerks(character)}',
      style: theme.textTheme.titleSmall?.copyWith(
        color: isOverLimit ? Colors.red : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Widgets (content within cards)
// ─────────────────────────────────────────────────────────────────────────────

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
                    iconSize: iconSizeSmall,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(smallPadding),
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
                    iconSize: iconSizeSmall,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(smallPadding),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: iconSizeSmall,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(smallPadding),
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
                      iconSize: iconSizeSmall,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(smallPadding),
                      icon: const Icon(Icons.add_box_rounded),
                      onPressed: character.checkMarks < 18 && !isRetired
                          ? () => charactersModel.increaseCheckmark(character)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                        _goldController.text = value == 0
                            ? ''
                            : value.toString();
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

class _ResourcesContent extends StatelessWidget {
  const _ResourcesContent({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    final cards = _buildResourceCards(context, character, charactersModel);
    return LayoutBuilder(
      builder: (context, constraints) {
        const minCardWidth = 100.0;
        final crossAxisCount = (constraints.maxWidth / minCardWidth)
            .floor()
            .clamp(3, cards.length);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: smallPadding,
          crossAxisSpacing: smallPadding,
          childAspectRatio: _resourceCardAspectRatio(context),
          children: cards,
        );
      },
    );
  }

  double _resourceCardAspectRatio(BuildContext context) {
    final canEdit =
        context.read<CharactersModel>().isEditMode && !character.isRetired;
    // Match original ResourceCard proportions: 100 wide × 100 or 75 tall
    return canEdit ? 100 / 100 : 100 / 75;
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
          final updatedCharacter = character;
          fieldData.setter(updatedCharacter, fieldData.getter(character) + 1);
          charactersModel.updateCharacter(updatedCharacter);
        },
        onDecrease: () {
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

    return isEditMode
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
              hintText: AppLocalizations.of(context).addNotes,
              border: InputBorder.none,
            ),
          )
        : Text(character.notes);
  }
}
