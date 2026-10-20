import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/character_header_delegates.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/class_icon_backdrop.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/perks_and_masteries_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/quest_and_notes_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/stats_and_resources_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({required this.character, super.key});
  final Character character;

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with AutomaticKeepAliveClientMixin {
  // Section keys for scroll-to and scroll-spy (one per chip)
  final _sectionKeys = {
    for (final s in CharacterSection.values) s: GlobalKey(),
  };

  // Extra keys for scroll-spy on sub-sections that map to a grouped chip
  final GlobalKey _notesKey = GlobalKey();
  final GlobalKey _masteriesKey = GlobalKey();

  final ValueNotifier<CharacterSection> _activeSectionNotifier = ValueNotifier(
    CharacterSection.general,
  );

  // Each page owns its scroll state: pages are kept alive across swipes, so a
  // shared controller would end up attached to several scroll views at once.
  final ScrollController _scrollController = ScrollController();

  // This page's offset, driving its own header, chip bar and background icon.
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);

  // The model's offset notifier drives the app bar, which belongs to whichever
  // page is current, so only the current page writes to it.
  late final ValueNotifier<double> _appBarOffsetNotifier;
  bool _isCurrentPage = false;
  bool _isScrollSpyEnabled = true;

  @override
  void initState() {
    super.initState();
    _appBarOffsetNotifier = context
        .read<CharactersModel>()
        .charScrollOffsetNotifier;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    _activeSectionNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _scrollOffsetNotifier.value = _scrollController.offset;
    if (_isCurrentPage) _appBarOffsetNotifier.value = _scrollController.offset;
    if (!_isScrollSpyEnabled) return;
    _updateActiveSection();
  }

  /// Hands this page's offset to the app bar when the page becomes current,
  /// since a kept-alive page may come back already scrolled.
  void _syncCurrentPage(CharactersModel model) {
    final isCurrent = model.currentCharacter?.uuid == widget.character.uuid;
    if (isCurrent == _isCurrentPage) return;
    _isCurrentPage = isCurrent;
    if (!isCurrent) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isCurrentPage) {
        _appBarOffsetNotifier.value = _scrollOffsetNotifier.value;
      }
    });
  }

  void _updateActiveSection() {
    if (!_scrollController.hasClients) return;

    // Threshold: max header height + chip bar = the bottom edge of the two
    // pinned headers. Sections whose top is at or above this Y coordinate are
    // considered "scrolled to the top" for scroll-spy purposes.
    final headerOffset =
        CharacterHeaderDelegate.viewModeMaxHeight(widget.character) +
        chipBarHeight;

    // All keys to check: chip section keys + sub-section keys mapped to their
    // parent chip section.
    final allKeys = <GlobalKey, CharacterSection>{
      for (final entry in _sectionKeys.entries) entry.value: entry.key,
      _notesKey: CharacterSection.questAndNotes,
      _masteriesKey: CharacterSection.perksAndMasteries,
    };

    CharacterSection? closest;
    double closestY = double.negativeInfinity;

    for (final entry in allKeys.entries) {
      final key = entry.key;
      if (key.currentContext == null) continue;

      // Skip masteries key if not present
      if (key == _masteriesKey && widget.character.characterMasteries.isEmpty) {
        continue;
      }

      final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero);

      // Among sections at or above the threshold, pick the one closest to it
      // (largest Y). This is the most recently scrolled-to-top section.
      if (position.dy <= headerOffset + scrollSpyThresholdBuffer &&
          position.dy > closestY) {
        closest = entry.value;
        closestY = position.dy;
      }
    }

    if (closest != null && closest != _activeSectionNotifier.value) {
      _activeSectionNotifier.value = closest;
    }
  }

  Future<void> _scrollToSection(CharacterSection section) async {
    final key = _sectionKeys[section]!;
    if (key.currentContext == null) return;
    if (!_scrollController.hasClients) return;

    // Disable scroll spy during the programmatic scroll so intermediate
    // positions don't fight the chip we just activated.
    _isScrollSpyEnabled = false;
    _activeSectionNotifier.value = section;

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

    // Re-enable scroll spy now that the animation has settled.
    _isScrollSpyEnabled = true;
  }

  // Without this, PageView disposes/rebuilds this page's whole subtree
  // (including perk checkboxes) on every swipe past the cache extent.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = context.watch<CharactersModel>();
    _syncCurrentPage(model);
    final hasMasteries = widget.character.characterMasteries.isNotEmpty;
    final hasQuestOrNotes =
        !widget.character.isRetired ||
        widget.character.personalQuest != null ||
        widget.character.notes.isNotEmpty;

    return Stack(
      children: [
        // Background class icon — extends through transparent header and nav bar.
        // Fades out as the header collapses. `range` is the header's collapse
        // distance (maxExtent − minExtent); `progress` is how far through that
        // range the user has scrolled. Hidden in edit mode (non-retired) where
        // the header + chip bar are fully opaque.
        ListenableBuilder(
          listenable: _scrollOffsetNotifier,
          builder: (context, _) {
            final isFixedHeader =
                model.isEditMode && !widget.character.isRetired;
            final headerHeight = CharacterHeaderDelegate.viewModeMaxHeight(
              widget.character,
            );
            final range = headerHeight - CharacterHeaderDelegate.minHeight;
            final progress = (_scrollOffsetNotifier.value / range).clamp(
              0.0,
              1.0,
            );
            return ClassIconBackdrop(
              character: widget.character,
              headerHeight: headerHeight,
              collapseProgress: isFixedHeader ? 1.0 : progress,
            );
          },
        ),
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _onScroll();
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // PINNED HEADER: Character name, level, class
              SliverPersistentHeader(
                pinned: true,
                delegate: CharacterHeaderDelegate(
                  character: widget.character,
                  isEditMode: model.isEditMode,
                  scrollOffsetNotifier: _scrollOffsetNotifier,
                ),
              ),
              // CHIP NAV BAR
              SliverPersistentHeader(
                pinned: true,
                delegate: SectionNavBarDelegate(
                  character: widget.character,
                  activeSectionNotifier: _activeSectionNotifier,
                  scrollOffsetNotifier: _scrollOffsetNotifier,
                  onSectionTapped: _scrollToSection,
                  hasMasteries: hasMasteries,
                  hasQuestOrNotes: hasQuestOrNotes,
                  isEditMode: model.isEditMode && !widget.character.isRetired,
                ),
              ),
              // STATS & RESOURCES
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      smallPadding,
                      mediumPadding,
                      smallPadding,
                      smallPadding,
                    ),
                    child: StatsAndResourcesCard(
                      sectionKey: _sectionKeys[CharacterSection.general],
                      character: widget.character,
                    ),
                  ),
                ),
              ),
              // QUEST & NOTES CARD
              if (hasQuestOrNotes)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(smallPadding),
                      child: QuestAndNotesCard(
                        sectionKey:
                            _sectionKeys[CharacterSection.questAndNotes],
                        notesKey: _notesKey,
                        character: widget.character,
                      ),
                    ),
                  ),
                ),
              // PERKS & MASTERIES CARD
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(smallPadding),
                    child: PerksAndMasteriesCard(
                      sectionKey:
                          _sectionKeys[CharacterSection.perksAndMasteries],
                      masteriesKey: _masteriesKey,
                      character: widget.character,
                      hasMasteries: hasMasteries,
                    ),
                  ),
                ),
              ),
              // BOTTOM PADDING
              SliverToBoxAdapter(child: SizedBox(height: fabBottomClearance)),
            ],
          ),
        ),
      ],
    );
  }
}
