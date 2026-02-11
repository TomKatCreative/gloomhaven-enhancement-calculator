import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
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
    if (context.watch<CharactersModel>().characters.isEmpty) {
      final l10n = AppLocalizations.of(context);
      final textTheme = Theme.of(context).textTheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(extraLargePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.createCharacterPrompt(
                  charactersModel.retiredCharactersAreHidden
                      ? l10n.articleA
                      : l10n.articleYourFirst,
                ),
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: extraLargePadding),
              FilledButton.icon(
                onPressed: () =>
                    CreateCharacterScreen.show(context, charactersModel),
                icon: const Icon(Icons.add),
                label: Text(l10n.createCharacter),
              ),
              if (charactersModel.retiredCharactersAreHidden) ...[
                const SizedBox(height: largePadding),
                TextButton(
                  onPressed: () => charactersModel.toggleShowRetired(),
                  child: Text(
                    l10n.showRetiredCharacters,
                    style: TextStyle(
                      color: Theme.of(context).contrastedPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // TODO: Performance improvements to investigate if swiping is still not smooth:
      // 1. Add `allowImplicitScrolling: true` to PageView.builder to preload adjacent pages
      // 2. Change `context.watch<CharactersModel>()` on line 37 to more targeted selectors
      //    or move it to child widgets to reduce unnecessary rebuilds
      // 3. Consider wrapping entire CharacterScreen in RepaintBoundary if needed
      // 4. Profile with Flutter DevTools Performance overlay to identify actual jank
      // 5. Consider caching the rasterized class icon background image
      return PageView.builder(
        controller: charactersModel.pageController,
        onPageChanged: (index) {
          charactersModel.onPageChanged(index);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        },
        itemCount: charactersModel.characters.length,
        itemBuilder: (context, int index) {
          final character = charactersModel.characters[index];

          return Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: CharacterScreen(character: character),
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
