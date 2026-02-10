import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/update_440_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/characters_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_calculator_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_animated_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/town_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_navigation_bar.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Character>> future;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    future = context.read<CharactersModel>().loadCharacters();
    if (SharedPrefs().showUpdate440Dialog) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (context) => const Update440Dialog(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final enhancementModel = context.watch<EnhancementCalculatorModel>();

    // Hide FAB when:
    // - On town page (0)
    // - On enhancement calculator page (2) when cost chip is expanded or nothing to clear
    // - On characters page (1) when element sheet is fully expanded
    final hideFab =
        appModel.page == 0 ||
        (appModel.page == 2 &&
            (enhancementModel.isSheetExpanded || !enhancementModel.showCost)) ||
        (appModel.page == 1 && charactersModel.isElementSheetFullExpanded);

    return Scaffold(
      // this is necessary to make notched FAB background transparent, effectively
      // extendBody: true,
      key: scaffoldMessengerKey,
      appBar: const GHCAnimatedAppBar(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: context.read<AppModel>().pageController,
        onPageChanged: (index) {
          charactersModel.isEditMode = false;
          context.read<AppModel>().page = index;
          // Reset sheet expanded states when navigating between pages
          context.read<EnhancementCalculatorModel>().isSheetExpanded = false;
          charactersModel.isElementSheetExpanded = false;
          setState(() {});
        },
        children: [
          const TownScreen(),
          FutureBuilder<List<Character>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return const CharactersScreen();
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).pleaseWait),
                      const SizedBox(height: smallPadding),
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
              }
            },
          ),
          const EnhancementCalculatorScreen(),
        ],
      ),
      floatingActionButton: IgnorePointer(
        ignoring: hideFab,
        child: AnimatedScale(
          scale: hideFab ? 0.0 : 1.0,
          duration: animationDuration,
          child: _buildFab(appModel, charactersModel, enhancementModel),
        ),
      ),
      bottomNavigationBar: const GHCNavigationBar(),
    );
  }

  Widget _buildFab(
    AppModel appModel,
    CharactersModel charactersModel,
    EnhancementCalculatorModel enhancementModel,
  ) {
    // Calculator page: clear FAB
    if (appModel.page == 2) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => enhancementModel.resetCost(),
        child: const Icon(Icons.clear_rounded),
      );
    }

    // Characters page with no characters: add FAB
    if (charactersModel.characters.isEmpty) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => CreateCharacterScreen.show(context, charactersModel),
        child: const Icon(Icons.add),
      );
    }

    // Characters page with characters: edit mode toggle FAB
    return FloatingActionButton(
      heroTag: null,
      onPressed: () => charactersModel.isEditMode = !charactersModel.isEditMode,
      child: Icon(
        charactersModel.isEditMode
            ? Icons.edit_off_rounded
            : Icons.edit_rounded,
      ),
    );
  }
}
