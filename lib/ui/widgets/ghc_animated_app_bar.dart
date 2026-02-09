import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/settings_screen.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// The main AppBar for the Home screen.
///
/// For pushed routes (Settings, CreateCharacter, etc.), use [GHCAppBar]
/// or [GHCSearchAppBar] instead.
class GHCAnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GHCAnimatedAppBar({super.key});

  @override
  State<GHCAnimatedAppBar> createState() => _GHCAnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

class _GHCAnimatedAppBarState extends State<GHCAnimatedAppBar> {
  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .read<EnhancementCalculatorModel>();
    final appModel = context.read<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      centerTitle: true,
      title:
          context.watch<AppModel>().page == 0 &&
              charactersModel.characters.length > 1
          ? SmoothPageIndicator(
              controller: charactersModel.pageController,
              count: charactersModel.characters.length,
              effect: ScrollingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: colorScheme.onSurface,
              ),
            )
          : context.watch<AppModel>().page == 1
          ? SegmentedButton<GameEdition>(
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<GameEdition>(
                  value: GameEdition.gloomhaven,
                  label: Text('GH'),
                ),
                ButtonSegment<GameEdition>(
                  value: GameEdition.gloomhaven2e,
                  label: Text('GH2e'),
                ),
                ButtonSegment<GameEdition>(
                  value: GameEdition.frosthaven,
                  label: Text('FH'),
                ),
              ],
              selected: {SharedPrefs().gameEdition},
              onSelectionChanged: (Set<GameEdition> selection) {
                SharedPrefs().gameEdition = selection.first;
                Provider.of<EnhancementCalculatorModel>(
                  context,
                  listen: false,
                ).gameVersionToggled();
                setState(() {});
              },
            )
          : Container(),
      actions: <Widget>[
        if (!charactersModel.isEditMode && appModel.page == 0)
          Tooltip(
            message: 'New Character',
            child: IconButton(
              icon: const Icon(Icons.person_add_rounded),
              onPressed: () async {
                await CreateCharacterScreen.show(context, charactersModel);
              },
            ),
          ),
        Tooltip(
          message: 'Settings',
          child: IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              charactersModel.isEditMode = false;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    enhancementCalculatorModel: enhancementCalculatorModel,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
