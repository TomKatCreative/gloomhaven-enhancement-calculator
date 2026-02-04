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
  late RichText _bodyText;
  List<Enhancement> _titleIcons = [];
  late List<Enhancement> _eligibleForIcons;

  /// Creates a list of icon widgets for display in the dialog
  List<Widget> _createIconsListForDialog(List<Enhancement>? list) {
    List<Widget> icons = [];

    if (list == null) {
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: tinyPadding),
          child: ThemedSvg(
            assetKey: 'plus_one',
            height: iconSizeLarge,
            width: iconSizeLarge,
          ),
        ),
      );
    } else {
      for (final Enhancement enhancement in list) {
        icons.add(
          Padding(
            padding: const EdgeInsets.only(right: tinyPadding),
            child: ThemedSvg(
              assetKey: enhancement.assetKey!,
              height: iconSizeLarge,
              width: iconSizeLarge,
            ),
          ),
        );
      }
    }

    return icons;
  }

  @override
  Widget build(BuildContext context) {
    // Cache theme settings used throughout the dialog
    final darkTheme = SharedPrefs().darkTheme;
    final edition = SharedPrefs().gameEdition;

    // Configure dialog content based on category
    if (widget.category != null) {
      switch (widget.category) {
        case EnhancementCategory.charPlusOne:
        case EnhancementCategory.target:
          _bodyText = Strings.plusOneCharacterInfoBody(
            context,
            edition,
            darkTheme,
          );
          _eligibleForIcons = EnhancementData.enhancements
              .where(
                (element) =>
                    element.category == EnhancementCategory.charPlusOne ||
                    element.category == EnhancementCategory.target,
              )
              .toList();
          break;

        case EnhancementCategory.summonPlusOne:
          _bodyText = Strings.plusOneSummonInfoBody(
            context,
            edition,
            darkTheme,
          );
          _eligibleForIcons = EnhancementData.enhancements
              .where(
                (element) =>
                    element.category == EnhancementCategory.summonPlusOne,
              )
              .toList();
          break;

        case EnhancementCategory.negEffect:
          _bodyText = Strings.negEffectInfoBody(context, darkTheme);
          _titleIcons = EnhancementData.enhancements
              .where(
                (element) => element.category == EnhancementCategory.negEffect,
              )
              .toList();

          // Remove enhancements not available in the current edition
          _titleIcons.removeWhere(
            (element) =>
                !EnhancementData.isAvailableInEdition(element, edition),
          );

          _eligibleForIcons =
              EnhancementData.enhancements
                  .where(
                    (enhancement) =>
                        enhancement.category == EnhancementCategory.negEffect ||
                        ['Attack', 'Push', 'Pull'].contains(enhancement.name) &&
                            enhancement.category !=
                                EnhancementCategory.summonPlusOne,
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
          break;

        case EnhancementCategory.posEffect:
          _bodyText = Strings.posEffectInfoBody(context, darkTheme);
          _titleIcons = EnhancementData.enhancements
              .where(
                (element) => element.category == EnhancementCategory.posEffect,
              )
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
          break;

        case EnhancementCategory.jump:
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
          break;

        case EnhancementCategory.specElem:
          _bodyText = Strings.specificElementInfoBody(
            context,
            edition,
            darkTheme,
          );
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
                            element.category !=
                                EnhancementCategory.summonPlusOne,
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
          break;

        case EnhancementCategory.anyElem:
          _bodyText = Strings.anyElementInfoBody(context, edition, darkTheme);
          _titleIcons = EnhancementData.enhancements
              .where(
                (element) => element.category == EnhancementCategory.anyElem,
              )
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
                            element.category !=
                                EnhancementCategory.summonPlusOne,
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
          break;

        case EnhancementCategory.hex:
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
          break;

        default:
          break;
      }
    }

    return AlertDialog(
      title: widget.title == null
          ? Center(
              child: Wrap(
                runSpacing: smallPadding,
                spacing: smallPadding,
                alignment: WrapAlignment.center,
                children: _createIconsListForDialog(_titleIcons),
              ),
            )
          : Center(
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: maxDialogWidth),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // If title isn't provided, display eligible enhancements
              if (widget.title == null)
                Column(
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).eligibleFor,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: smallPadding,
                        bottom: smallPadding,
                      ),
                    ),
                    Wrap(
                      runSpacing: smallPadding,
                      spacing: smallPadding,
                      alignment: WrapAlignment.center,
                      children: _createIconsListForDialog(_eligibleForIcons),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: smallPadding,
                        bottom: smallPadding,
                      ),
                    ),
                  ],
                ),
              widget.message ?? _bodyText,
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
}
