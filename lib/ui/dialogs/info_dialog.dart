import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

class InfoDialog extends StatefulWidget {
  final String? title;
  final RichText? message;
  final EnhancementCategory? category;

  const InfoDialog({super.key, this.title, this.message, this.category});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  RichText? _bodyText;
  List<Enhancement> _titleIcons = [];
  List<Enhancement> _eligibleForIcons = [];
  bool _isConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Configure content based on category (only runs once, not on every rebuild)
    // Must use didChangeDependencies instead of initState because we need context
    if (!_isConfigured && widget.category != null) {
      _configureForCategory();
      _isConfigured = true;
    }
  }

  /// Configures dialog content based on the enhancement category.
  ///
  /// Sets [_bodyText], [_titleIcons], and [_eligibleForIcons] based on
  /// the category type. Called once from [initState].
  void _configureForCategory() {
    final darkTheme = SharedPrefs().darkTheme;
    final edition = SharedPrefs().gameEdition;

    switch (widget.category) {
      case EnhancementCategory.charPlusOne:
      case EnhancementCategory.target:
        _configureCharPlusOne(edition, darkTheme);
        break;

      case EnhancementCategory.summonPlusOne:
        _configureSummonPlusOne(edition, darkTheme);
        break;

      case EnhancementCategory.negEffect:
        _configureNegEffect(edition, darkTheme);
        break;

      case EnhancementCategory.posEffect:
        _configurePosEffect(edition, darkTheme);
        break;

      case EnhancementCategory.jump:
        _configureJump(darkTheme);
        break;

      case EnhancementCategory.specElem:
        _configureSpecificElement(edition, darkTheme);
        break;

      case EnhancementCategory.anyElem:
        _configureAnyElement(edition, darkTheme);
        break;

      case EnhancementCategory.hex:
        _configureHex(darkTheme);
        break;

      default:
        break;
    }
  }

  void _configureCharPlusOne(dynamic edition, bool darkTheme) {
    _bodyText = Strings.plusOneCharacterInfoBody(context, edition, darkTheme);
    _eligibleForIcons = EnhancementData.enhancements
        .where(
          (element) =>
              element.category == EnhancementCategory.charPlusOne ||
              element.category == EnhancementCategory.target,
        )
        .toList();
  }

  void _configureSummonPlusOne(dynamic edition, bool darkTheme) {
    _bodyText = Strings.plusOneSummonInfoBody(context, edition, darkTheme);
    _eligibleForIcons = EnhancementData.enhancements
        .where(
          (element) => element.category == EnhancementCategory.summonPlusOne,
        )
        .toList();
  }

  void _configureNegEffect(dynamic edition, bool darkTheme) {
    _bodyText = Strings.negEffectInfoBody(context, darkTheme);
    _titleIcons = EnhancementData.enhancements
        .where((element) => element.category == EnhancementCategory.negEffect)
        .toList();

    // Remove enhancements not available in the current edition
    _titleIcons.removeWhere(
      (element) => !EnhancementData.isAvailableInEdition(element, edition),
    );

    _eligibleForIcons =
        EnhancementData.enhancements
            .where(
              (enhancement) =>
                  enhancement.category == EnhancementCategory.negEffect ||
                  ['Attack', 'Push', 'Pull'].contains(enhancement.name) &&
                      enhancement.category != EnhancementCategory.summonPlusOne,
            )
            .toList()
          ..add(
            Enhancement(
              EnhancementCategory.negEffect,
              'Stun',
              ghCost: 0,
              assetKey: 'STUN',
            ),
          );
  }

  void _configurePosEffect(dynamic edition, bool darkTheme) {
    _bodyText = Strings.posEffectInfoBody(context, darkTheme);
    _titleIcons = EnhancementData.enhancements
        .where((element) => element.category == EnhancementCategory.posEffect)
        .toList();
    _eligibleForIcons =
        EnhancementData.enhancements
            .where(
              (element) =>
                  element.category == EnhancementCategory.posEffect ||
                  [
                    'Heal',
                    'Retaliate',
                    'Shield',
                    'Ward',
                  ].contains(element.name),
            )
            .toList()
          ..removeWhere(
            (element) =>
                !EnhancementData.isAvailableInEdition(element, edition),
          )
          ..add(
            Enhancement(
              EnhancementCategory.posEffect,
              'Invisible',
              ghCost: 0,
              assetKey: 'INVISIBLE',
            ),
          );
  }

  void _configureJump(bool darkTheme) {
    _bodyText = Strings.jumpInfoBody(context, darkTheme);
    _titleIcons = EnhancementData.enhancements
        .where((element) => element.category == EnhancementCategory.jump)
        .toList();
    _eligibleForIcons = EnhancementData.enhancements
        .where(
          (element) =>
              element.name == 'Move' &&
              element.category != EnhancementCategory.summonPlusOne,
        )
        .toList();
  }

  void _configureSpecificElement(dynamic edition, bool darkTheme) {
    _bodyText = Strings.specificElementInfoBody(context, edition, darkTheme);
    _titleIcons = [
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'AIR',
      ),
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'EARTH',
      ),
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'FIRE',
      ),
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'ICE',
      ),
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'DARK',
      ),
      Enhancement(
        EnhancementCategory.specElem,
        'Specific Element',
        ghCost: 100,
        assetKey: 'LIGHT',
      ),
    ];
    _eligibleForIcons =
        EnhancementData.enhancements
            .where(
              (element) =>
                  element.category == EnhancementCategory.negEffect ||
                  element.category == EnhancementCategory.posEffect ||
                  [
                        'Move',
                        'Attack',
                        'Shield',
                        'Heal',
                        'Retaliate',
                        'Push',
                        'Pull',
                      ].contains(element.name) &&
                      element.category != EnhancementCategory.summonPlusOne,
            )
            .toList()
          ..add(
            Enhancement(
              EnhancementCategory.posEffect,
              'Invisible',
              ghCost: 0,
              assetKey: 'INVISIBLE',
            ),
          );
  }

  void _configureAnyElement(dynamic edition, bool darkTheme) {
    _bodyText = Strings.anyElementInfoBody(context, edition, darkTheme);
    _titleIcons = EnhancementData.enhancements
        .where((element) => element.category == EnhancementCategory.anyElem)
        .toList();
    _eligibleForIcons =
        EnhancementData.enhancements
            .where(
              (element) =>
                  element.category == EnhancementCategory.negEffect ||
                  element.category == EnhancementCategory.posEffect ||
                  [
                        'Move',
                        'Attack',
                        'Shield',
                        'Heal',
                        'Retaliate',
                        'Push',
                        'Pull',
                      ].contains(element.name) &&
                      element.category != EnhancementCategory.summonPlusOne,
            )
            .toList()
          ..add(
            Enhancement(
              EnhancementCategory.posEffect,
              'Invisible',
              ghCost: 0,
              assetKey: 'INVISIBLE',
            ),
          );
  }

  void _configureHex(bool darkTheme) {
    _bodyText = Strings.hexInfoBody(context, darkTheme);
    _titleIcons = [
      EnhancementData.enhancements.firstWhere(
        (element) => element.category == EnhancementCategory.hex,
      ),
    ];
    _eligibleForIcons = [
      EnhancementData.enhancements.firstWhere(
        (element) => element.category == EnhancementCategory.hex,
      ),
    ];
  }

  /// Creates a list of icon widgets for display in the dialog.
  List<Widget> _createIconsListForDialog(List<Enhancement>? list) {
    if (list == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: tinyPadding),
          child: ThemedSvg(
            assetKey: 'plus_one',
            height: iconSizeLarge,
            width: iconSizeLarge,
          ),
        ),
      ];
    }

    return list
        .map(
          (enhancement) => Padding(
            padding: const EdgeInsets.only(right: tinyPadding),
            child: ThemedSvg(
              assetKey: enhancement.assetKey!,
              height: iconSizeLarge,
              width: iconSizeLarge,
            ),
          ),
        )
        .toList();
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
              // If title isn't provided, display eligible enhancements section
              if (widget.title == null) _buildEligibleForSection(context),
              widget.message ?? _bodyText ?? const SizedBox.shrink(),
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
    if (widget.title == null) {
      // Category mode: show title icons
      return Center(
        child: Wrap(
          runSpacing: smallPadding,
          spacing: smallPadding,
          alignment: WrapAlignment.center,
          children: _createIconsListForDialog(_titleIcons),
        ),
      );
    }

    // Title/message mode: show text title
    return Center(
      child: Text(
        widget.title!,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
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
          children: _createIconsListForDialog(_eligibleForIcons),
        ),
        const Padding(
          padding: EdgeInsets.only(top: smallPadding, bottom: smallPadding),
        ),
      ],
    );
  }
}
