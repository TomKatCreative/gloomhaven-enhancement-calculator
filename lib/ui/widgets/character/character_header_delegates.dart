import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Indices for section navigation chips.
enum CharacterSection { general, questAndNotes, perksAndMasteries }

// ─────────────────────────────────────────────────────────────────────────────
// Pinned Character Header Delegate
// ─────────────────────────────────────────────────────────────────────────────

class CharacterHeaderDelegate extends SliverPersistentHeaderDelegate {
  CharacterHeaderDelegate({
    required this.character,
    required this.isEditMode,
    required this.scrollOffsetNotifier,
  });

  final Character character;
  final bool isEditMode;
  final ValueNotifier<double> scrollOffsetNotifier;

  static const double maxHeight = 180.0;
  static const double editModeHeight = 90.0;
  static const double minHeight = 56.0;

  // In edit mode (non-retired) the header is fixed-height: maxExtent ==
  // minExtent, so the sliver never collapses. This means overlapsContent
  // snaps immediately on the first scroll pixel — handled by the chip bar's
  // showOpaqueBar logic.
  @override
  double get maxExtent =>
      isEditMode && !character.isRetired ? editModeHeight : maxHeight;

  @override
  double get minExtent =>
      isEditMode && !character.isRetired ? editModeHeight : minHeight;

  @override
  bool shouldRebuild(covariant CharacterHeaderDelegate oldDelegate) => true;

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

    // Tint only when content is actually scrolling behind the pinned headers,
    // not during the header's collapse animation. The first pinned sliver never
    // receives overlapsContent, so we listen to scrollOffsetNotifier instead.
    // This also fires on metrics-only corrections (e.g. section collapse).
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffsetNotifier,
      builder: (context, scrollOffset, child) {
        final isContentBehind = scrollOffset > range;
        return TweenAnimationBuilder<double>(
          key: ValueKey(character.uuid),
          tween: Tween<double>(end: isContentBehind ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, tintProgress, child) {
            return Material(
              color: Color.lerp(
                colorScheme.surface,
                AppBarUtils.getTintedBackground(colorScheme),
                tintProgress,
              ),
              child: child,
            );
          },
          child: child,
        );
      },
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Faded class icon background (matches Stack icon position/size).
            // Hidden in edit mode where the header is fully opaque.
            if (!isEditMode || character.isRetired)
              Positioned(
                right: -32,
                top: -45,
                height: maxHeight + chipBarHeight + 75,
                width: 260,
                child: Opacity(
                  opacity: (0.15 * (1 - progress)).clamp(0.0, 0.15),
                  child: ClassIconSvg(
                    playerClass: character.playerClass,
                    color: ColorUtils.ensureContrast(
                      character.getEffectiveColor(theme.brightness),
                      colorScheme.surface,
                    ),
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
        if (!isEditMode || character.isRetired) ...[
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
        ],
        // Traits (view mode only, frosthaven classes)
        if (character.shouldShowTraits &&
            (!isEditMode || character.isRetired)) ...[
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
        if (character.isRetired) ...[
          const SizedBox(height: smallPadding),
          Text(AppLocalizations.of(context).retired),
        ],
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
            color: ColorUtils.ensureContrast(
              character.getEffectiveColor(theme.brightness),
              theme.colorScheme.surface,
            ).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: smallPadding),
        Expanded(
          child: Text(
            character.name,
            maxLines: 1,
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 31),
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

class SectionNavBarDelegate extends SliverPersistentHeaderDelegate {
  SectionNavBarDelegate({
    required this.character,
    required this.activeSectionNotifier,
    required this.scrollOffsetNotifier,
    required this.onSectionTapped,
    required this.hasMasteries,
    required this.hasQuestOrNotes,
    required this.isEditMode,
  });

  final Character character;
  final ValueNotifier<CharacterSection> activeSectionNotifier;
  final ValueNotifier<double> scrollOffsetNotifier;
  final ValueChanged<CharacterSection> onSectionTapped;
  final bool hasMasteries;
  final bool hasQuestOrNotes;
  final bool isEditMode;

  @override
  double get maxExtent => chipBarHeight;

  @override
  double get minExtent => chipBarHeight;

  @override
  bool shouldRebuild(covariant SectionNavBarDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final sections = [
      (
        CharacterSection.general,
        kTownSheetEnabled ? l10n.general : l10n.statsAndResources,
      ),
      if (hasQuestOrNotes) (CharacterSection.questAndNotes, l10n.questAndNotes),
      (
        CharacterSection.perksAndMasteries,
        hasMasteries ? l10n.perksAndMasteries : l10n.perks,
      ),
    ];

    // Opacity follows scroll position directly (no animation delay) so the
    // bar goes transparent as soon as the header starts re-expanding.
    // Tint color still fades in smoothly via TweenAnimationBuilder.
    // Header collapse range: 180 − 56 = 124. In edit mode (fixed header) = 0.
    final headerRange = isEditMode
        ? 0.0
        : CharacterHeaderDelegate.maxHeight - CharacterHeaderDelegate.minHeight;

    return ValueListenableBuilder<double>(
      valueListenable: scrollOffsetNotifier,
      builder: (context, scrollOffset, child) {
        final isOpaque = isEditMode || scrollOffset >= headerRange;
        return TweenAnimationBuilder<double>(
          key: ValueKey(character.uuid),
          tween: Tween<double>(end: overlapsContent ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, tintProgress, child) {
            final color = isOpaque
                ? Color.lerp(
                    theme.colorScheme.surface,
                    AppBarUtils.getTintedBackground(theme.colorScheme),
                    tintProgress,
                  )
                : Colors.transparent;
            return Container(
              height: chipBarHeight,
              decoration: BoxDecoration(color: color),
              child: child,
            );
          },
          child: child,
        );
      },
      child: ValueListenableBuilder<CharacterSection>(
        valueListenable: activeSectionNotifier,
        builder: (context, activeSection, _) {
          final primaryColor = theme.contrastedPrimary;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: smallPadding),
            child: Row(
              children: [
                for (final (section, label) in sections)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: tinyPadding,
                    ),
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
                      ),
                      side: activeSection == section
                          ? BorderSide(
                              color: primaryColor.withValues(alpha: 0.3),
                            )
                          : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          );
        },
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
