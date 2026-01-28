import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/update_430_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/characters_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_calculator_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_animated_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_bottom_navigation_bar.dart';
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
    if (SharedPrefs().showUpdate430Dialog) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (context) => const Update430Dialog(),
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
    // - On enhancement calculator page (1) when cost chip is expanded or nothing to clear
    // - On characters page (0) when element sheet is fully expanded
    final hideFab =
        (appModel.page == 1 &&
            (enhancementModel.isSheetExpanded || !enhancementModel.showCost)) ||
        (appModel.page == 0 && charactersModel.isElementSheetFullExpanded);

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
                      const SizedBox(height: mediumPadding),
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
      floatingActionButton: hideFab
          ? null
          : FloatingActionButton(
              heroTag: null,
              onPressed: appModel.page == 1
                  ? () => enhancementModel.resetCost()
                  : charactersModel.characters.isEmpty
                  ? () => CreateCharacterScreen.show(context, charactersModel)
                  : () => charactersModel.isEditMode =
                        !charactersModel.isEditMode,
              child: Icon(
                appModel.page == 1
                    ? Icons.clear_rounded
                    : charactersModel.characters.isEmpty
                    ? Icons.add
                    : charactersModel.isEditMode
                    ? Icons.edit_off_rounded
                    : Icons.edit_rounded,
              ),
            ),
      bottomNavigationBar: const GHCBottomNavigationBar(),
    );
  }
}
