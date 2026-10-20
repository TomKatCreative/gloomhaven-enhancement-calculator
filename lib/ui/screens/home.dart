import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/update_450_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/database_open_error_view.dart';
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
    // Select only what the FAB needs, so changes elsewhere in these models
    // (e.g. every calculator tap) don't rebuild the whole Scaffold.
    final page = context.select<AppModel, int>((m) => m.page);
    final hasCharacters = context.select<CharactersModel, bool>(
      (m) => m.characters.isNotEmpty,
    );
    final charactersEditMode = context.select<CharactersModel, bool>(
      (m) => m.isEditMode,
    );
    final calculatorFabHidden = context
        .select<EnhancementCalculatorModel, bool>(
          (m) => m.isSheetExpanded || !m.showCost,
        );
    // TownModel is lazy; only subscribe to it when the Town tab exists.
    final hasCampaigns =
        kTownSheetEnabled &&
        context.select<TownModel, bool>((m) => m.campaigns.isNotEmpty);
    final townEditMode =
        kTownSheetEnabled &&
        context.select<TownModel, bool>((m) => m.isEditMode);

    // Hide FAB when:
    // - On town page with no campaigns
    // - On characters page with no characters (empty state has inline button)
    // - On enhancement calculator page when cost chip is expanded or nothing to clear
    final hideFab =
        (kTownSheetEnabled && page == kTownPageIndex && !hasCampaigns) ||
        (page == kCharactersPageIndex && !hasCharacters) ||
        (page == kCalculatorPageIndex && calculatorFabHidden);

    return Scaffold(
      // this is necessary to make notched FAB background transparent, effectively
      // extendBody: true,
      key: scaffoldMessengerKey,
      appBar: const GHCAnimatedAppBar(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: context.read<AppModel>().pageController,
        onPageChanged: (index) {
          context.read<CharactersModel>().isEditMode = false;
          if (kTownSheetEnabled) context.read<TownModel>().isEditMode = false;
          context.read<AppModel>().page = index;
          // Reset the cost chip's expanded state when navigating between pages
          context.read<EnhancementCalculatorModel>().isSheetExpanded = false;
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
                return DatabaseOpenErrorView(error: snapshot.error!);
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
            page: page,
            hasCampaigns: hasCampaigns,
            townEditMode: townEditMode,
            charactersEditMode: charactersEditMode,
          ),
        ),
      ),
      bottomNavigationBar: const GHCNavigationBar(),
    );
  }

  Widget _buildFab({
    required int page,
    required bool hasCampaigns,
    required bool townEditMode,
    required bool charactersEditMode,
  }) {
    // Town page: edit mode toggle FAB
    if (kTownSheetEnabled && page == kTownPageIndex && hasCampaigns) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () {
          final townModel = context.read<TownModel>();
          townModel.isEditMode = !townModel.isEditMode;
        },
        child: Icon(townEditMode ? Icons.edit_off_rounded : Icons.edit_rounded),
      );
    }

    // Calculator page: clear FAB
    if (page == kCalculatorPageIndex) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => context.read<EnhancementCalculatorModel>().resetCost(),
        child: const Icon(Icons.clear_rounded),
      );
    }

    // Characters page: edit mode toggle FAB
    return FloatingActionButton(
      heroTag: null,
      onPressed: () {
        final charactersModel = context.read<CharactersModel>();
        charactersModel.isEditMode = !charactersModel.isEditMode;
      },
      child: Icon(
        charactersEditMode ? Icons.edit_off_rounded : Icons.edit_rounded,
      ),
    );
  }
}
