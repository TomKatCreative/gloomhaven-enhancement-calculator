import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// Information dialog with two display modes:
/// - **Title/message mode**: pass [title] and [message] to render a custom
///   text title with a RichText body.
/// - **Category mode**: pass [category] to render an icon-based title and
///   the canned body text + "Eligible for" icon list for that enhancement
///   category. Requires an [EnhancementCalculatorModel] in the widget tree
///   so the dialog can query the active [GameEdition].
class InfoDialog extends StatefulWidget {
  final String? title;
  final RichText? message;
  final EnhancementCategory? category;

  const InfoDialog({super.key, this.title, this.message, this.category});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

/// Resolved content for category mode: body text + icon lists for the title
/// row and the "Eligible for" row.
typedef _CategoryContent = ({
  RichText? bodyText,
  List<Enhancement> titleIcons,
  List<Enhancement> eligibleForIcons,
});

class _InfoDialogState extends State<InfoDialog> {
  _CategoryContent? _content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve category content once; depends on context (Theme + Provider).
    if (_content == null && widget.category != null) {
      final darkTheme = Theme.of(context).brightness == Brightness.dark;
      final edition = context.read<EnhancementCalculatorModel>().edition;
      _content = _resolveCategoryContent(
        widget.category!,
        context,
        edition,
        darkTheme,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(context),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Title/message mode hides the eligible-for section.
              if (widget.title == null) _buildEligibleForSection(context),
              widget.message ?? _content?.bodyText ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context).gotIt,
            style: TextStyle(color: Theme.of(context).contrastedPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.title != null) {
      return Center(
        child: Text(
          widget.title!,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
      child: Wrap(
        runSpacing: smallPadding,
        spacing: smallPadding,
        alignment: WrapAlignment.center,
        children: _enhancementIcons(_content?.titleIcons ?? const []),
      ),
    );
  }

  Widget _buildEligibleForSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context).eligibleFor,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Padding(
          padding: EdgeInsets.only(top: smallPadding, bottom: smallPadding),
        ),
        Wrap(
          runSpacing: smallPadding,
          spacing: smallPadding,
          alignment: WrapAlignment.center,
          children: _enhancementIcons(_content?.eligibleForIcons ?? const []),
        ),
        const Padding(
          padding: EdgeInsets.only(top: smallPadding, bottom: smallPadding),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Category content resolution
// ────────────────────────────────────────────────────────────────────────────

/// Resolves the per-category content (body text + icon rows). One switch with
/// each case calling a small named builder — easier to scan than the previous
/// nine `_configureX` methods that mutated three pieces of state each.
_CategoryContent _resolveCategoryContent(
  EnhancementCategory category,
  BuildContext context,
  GameEdition edition,
  bool darkTheme,
) {
  switch (category) {
    case EnhancementCategory.charPlusOne:
    case EnhancementCategory.target:
      return (
        bodyText: Strings.plusOneCharacterInfoBody(context, edition, darkTheme),
        titleIcons: const [],
        eligibleForIcons: _enhancementsByCategories(const [
          EnhancementCategory.charPlusOne,
          EnhancementCategory.target,
        ]),
      );

    case EnhancementCategory.summonPlusOne:
      return (
        bodyText: Strings.plusOneSummonInfoBody(context, edition, darkTheme),
        titleIcons: const [],
        eligibleForIcons: _enhancementsByCategories(const [
          EnhancementCategory.summonPlusOne,
        ]),
      );

    case EnhancementCategory.negEffect:
      return (
        bodyText: Strings.negEffectInfoBody(context, darkTheme),
        titleIcons: _enhancementsAvailableInEdition(
          _enhancementsByCategories(const [EnhancementCategory.negEffect]),
          edition,
        ),
        eligibleForIcons: [
          ...EnhancementData.enhancements.where(
            (e) =>
                e.category == EnhancementCategory.negEffect ||
                ['Attack', 'Push', 'Pull'].contains(e.name) &&
                    e.category != EnhancementCategory.summonPlusOne,
          ),
          Enhancement(
            EnhancementCategory.negEffect,
            'Stun',
            ghCost: 0,
            assetKey: 'STUN',
          ),
        ],
      );

    case EnhancementCategory.posEffect:
      return (
        bodyText: Strings.posEffectInfoBody(context, darkTheme),
        titleIcons: _enhancementsByCategories(const [
          EnhancementCategory.posEffect,
        ]),
        eligibleForIcons: _enhancementsAvailableInEdition([
          ...EnhancementData.enhancements.where(
            (e) =>
                e.category == EnhancementCategory.posEffect ||
                ['Heal', 'Retaliate', 'Shield', 'Ward'].contains(e.name),
          ),
          Enhancement(
            EnhancementCategory.posEffect,
            'Invisible',
            ghCost: 0,
            assetKey: 'INVISIBLE',
          ),
        ], edition),
      );

    case EnhancementCategory.jump:
      return (
        bodyText: Strings.jumpInfoBody(context, darkTheme),
        titleIcons: _enhancementsByCategories(const [EnhancementCategory.jump]),
        eligibleForIcons: EnhancementData.enhancements
            .where(
              (e) =>
                  e.name == 'Move' &&
                  e.category != EnhancementCategory.summonPlusOne,
            )
            .toList(),
      );

    case EnhancementCategory.specElem:
      return (
        bodyText: Strings.specificElementInfoBody(context, edition, darkTheme),
        titleIcons: _specificElementTitleIcons,
        eligibleForIcons: _basicAttackEnhancementsWithInvisible,
      );

    case EnhancementCategory.anyElem:
      return (
        bodyText: Strings.anyElementInfoBody(context, edition, darkTheme),
        titleIcons: _enhancementsByCategories(const [
          EnhancementCategory.anyElem,
        ]),
        eligibleForIcons: _basicAttackEnhancementsWithInvisible,
      );

    case EnhancementCategory.hex:
      final hex = EnhancementData.enhancements.firstWhere(
        (e) => e.category == EnhancementCategory.hex,
      );
      return (
        bodyText: Strings.hexInfoBody(context, darkTheme),
        titleIcons: [hex],
        eligibleForIcons: [hex],
      );
  }
}

/// Returns enhancements whose category is in the given set.
List<Enhancement> _enhancementsByCategories(List<EnhancementCategory> cats) =>
    EnhancementData.enhancements
        .where((e) => cats.contains(e.category))
        .toList();

/// Filters out enhancements that aren't available in the given edition.
List<Enhancement> _enhancementsAvailableInEdition(
  List<Enhancement> source,
  GameEdition edition,
) => source
    .where((e) => EnhancementData.isAvailableInEdition(e, edition))
    .toList();

/// Title row for the "Specific Element" info dialog: one icon per element.
final List<Enhancement> _specificElementTitleIcons = [
  for (final element in const ['AIR', 'EARTH', 'FIRE', 'ICE', 'DARK', 'LIGHT'])
    Enhancement(
      EnhancementCategory.specElem,
      'Specific Element',
      ghCost: 100,
      assetKey: element,
    ),
];

/// "Eligible for" row used by Specific and Any element dialogs: standard
/// attack-related enhancements plus Invisible.
final List<Enhancement> _basicAttackEnhancementsWithInvisible = [
  ...EnhancementData.enhancements.where(
    (e) =>
        e.category == EnhancementCategory.negEffect ||
        e.category == EnhancementCategory.posEffect ||
        [
              'Move',
              'Attack',
              'Shield',
              'Heal',
              'Retaliate',
              'Push',
              'Pull',
            ].contains(e.name) &&
            e.category != EnhancementCategory.summonPlusOne,
  ),
  Enhancement(
    EnhancementCategory.posEffect,
    'Invisible',
    ghCost: 0,
    assetKey: 'INVISIBLE',
  ),
];

/// Builds the icon row widgets shown in the dialog title and eligible-for
/// section. Empty list renders an empty row.
List<Widget> _enhancementIcons(List<Enhancement> enhancements) {
  return enhancements
      .map(
        (e) => Padding(
          padding: const EdgeInsets.only(right: tinyPadding),
          child: ThemedSvg(
            assetKey: e.assetKey!,
            height: iconSizeLarge,
            width: iconSizeLarge,
          ),
        ),
      )
      .toList();
}
