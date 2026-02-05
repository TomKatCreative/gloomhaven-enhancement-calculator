import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

import 'character_screen.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    CharactersModel charactersModel = context.read<CharactersModel>();
    return _buildContent(context, charactersModel);
    // TODO: consider returning this in a later release
    // return Stack(
    //   children: [
    //     // Main content (empty state or character PageView)
    //     _buildContent(context, charactersModel),
    //     // Element tracker sheet
    //     const ElementTrackerSheet(),
    //   ],
    // );
  }

  Widget _buildContent(BuildContext context, CharactersModel charactersModel) {
    // Use select to only rebuild when isEmpty actually changes (not on every model update)
    final hasNoCharacters = context.select<CharactersModel, bool>(
      (m) => m.characters.isEmpty,
    );
    if (hasNoCharacters) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(
              left: largePadding,
              right: largePadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).createCharacterPrompt(
                    charactersModel.retiredCharactersAreHidden
                        ? AppLocalizations.of(context).articleA
                        : AppLocalizations.of(context).articleYourFirst,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (charactersModel.retiredCharactersAreHidden) ...[
                  const SizedBox(height: smallPadding),
                  const Padding(
                    padding: EdgeInsets.only(top: smallPadding),
                    child: Divider(),
                  ),
                  TextButton(
                    onPressed: () {
                      charactersModel.toggleShowRetired();
                    },
                    child: Text(
                      AppLocalizations.of(context).showRetiredCharacters,
                      style: TextStyle(
                        color: Theme.of(context).contrastedPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } else {
      // NOTE: If swiping is still not smooth, consider:
      // - Wrapping entire CharacterScreen in RepaintBoundary
      // - Profiling with Flutter DevTools Performance overlay
      // - Caching the rasterized class icon background image
      return PageView.builder(
        controller: charactersModel.pageController,
        // Preload adjacent pages for smoother swiping
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          charactersModel.onPageChanged(index);
        },
        itemCount: charactersModel.characters.length,
        itemBuilder: (context, int index) {
          final character = charactersModel.characters[index];

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // RepaintBoundary isolates repaints of the expensive background SVG
              RepaintBoundary(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Container(
                      width: 500,
                      height: 500,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClassIconSvg(
                        playerClass: character.playerClass,
                        color: character
                            .getEffectiveColor(Theme.of(context).brightness)
                            .withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: CharacterScreen(character: character),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
