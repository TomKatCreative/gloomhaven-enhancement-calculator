import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/update_450_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/characters_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_calculator_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_animated_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/town_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_navigation_bar.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

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
    if (kTownSheetEnabled) context.read<TownModel>().loadCampaigns();
    if (SharedPrefs().showUpdate450Dialog) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (context) => const Update450Dialog(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final enhancementModel = context.watch<EnhancementCalculatorModel>();
    final townModel = context.watch<TownModel>();

    const charactersPage = kTownSheetEnabled ? 1 : 0;
    const calculatorPage = kTownSheetEnabled ? 2 : 1;

    // Hide FAB when:
    // - On town page (0) with no campaigns
    // - On characters page with no characters (empty state has inline button)
    // - On characters page when element sheet is fully expanded
    // - On enhancement calculator page when cost chip is expanded or nothing to clear
    final hideFab =
        (kTownSheetEnabled &&
            appModel.page == 0 &&
            townModel.campaigns.isEmpty) ||
        (appModel.page == charactersPage &&
            charactersModel.characters.isEmpty) ||
        (appModel.page == charactersPage &&
            charactersModel.isElementSheetFullExpanded) ||
        (appModel.page == calculatorPage &&
            (enhancementModel.isSheetExpanded || !enhancementModel.showCost));

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
          if (kTownSheetEnabled) townModel.isEditMode = false;
          context.read<AppModel>().page = index;
          // Reset sheet expanded states when navigating between pages
          context.read<EnhancementCalculatorModel>().isSheetExpanded = false;
          charactersModel.isElementSheetExpanded = false;
          setState(() {});
        },
        children: [
          if (kTownSheetEnabled) const TownScreen(),
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
          child: _buildFab(
            appModel,
            charactersModel,
            enhancementModel,
            townModel,
          ),
        ),
      ),
      bottomNavigationBar: const GHCNavigationBar(),
    );
  }

  Widget _buildFab(
    AppModel appModel,
    CharactersModel charactersModel,
    EnhancementCalculatorModel enhancementModel,
    TownModel townModel,
  ) {
    const calculatorPage = kTownSheetEnabled ? 2 : 1;

    // Town page: edit mode toggle FAB
    if (kTownSheetEnabled &&
        appModel.page == 0 &&
        townModel.campaigns.isNotEmpty) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => townModel.isEditMode = !townModel.isEditMode,
        child: Icon(
          townModel.isEditMode ? Icons.edit_off_rounded : Icons.edit_rounded,
        ),
      );
    }

    // Calculator page: clear FAB
    if (appModel.page == calculatorPage) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => enhancementModel.resetCost(),
        child: const Icon(Icons.clear_rounded),
      );
    }

    // Characters page: edit mode toggle FAB
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
