import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/update_440_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/characters_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_calculator_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_fab.dart';
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
    if (SharedPrefs().showUpdate440Dialog) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (context) => const Update440Dialog(),
        );
      });
    }
  }

  Future<void> _handleRetire(
    BuildContext context,
    CharactersModel charactersModel,
    AppModel appModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final String message =
        '${charactersModel.currentCharacter!.name} ${charactersModel.currentCharacter!.isRetired ? l10n.unretire.toLowerCase() : l10n.retire.toLowerCase()}d';
    Character? character = charactersModel.currentCharacter;
    await charactersModel.retireCurrentCharacter();
    appModel.updateTheme();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          persist: false,
          action: charactersModel.showRetired
              ? null
              : SnackBarAction(
                  label: 'Show',
                  onPressed: () {
                    charactersModel.toggleShowRetired(character: character);
                  },
                ),
        ),
      );
  }

  Future<void> _handleDelete(
    BuildContext context,
    CharactersModel charactersModel,
  ) async {
    final bool? result = await ConfirmationDialog.show(
      context: context,
      content: const Text('Are you sure? This cannot be undone'),
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );

    if (result == true && context.mounted) {
      final String characterName = charactersModel.currentCharacter!.name;
      await charactersModel.deleteCurrentCharacter();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('$characterName deleted')));
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
      floatingActionButton: hideFab
          ? null
          : _buildFab(appModel, charactersModel, enhancementModel),
      bottomNavigationBar: const GHCBottomNavigationBar(),
    );
  }

  Widget _buildFab(
    AppModel appModel,
    CharactersModel charactersModel,
    EnhancementCalculatorModel enhancementModel,
  ) {
    // Calculator page: simple clear FAB
    if (appModel.page == 1) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => enhancementModel.resetCost(),
        child: const Icon(Icons.clear_rounded),
      );
    }

    // Characters page with no characters: simple add FAB
    if (charactersModel.characters.isEmpty) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () => CreateCharacterScreen.show(context, charactersModel),
        child: const Icon(Icons.add),
      );
    }

    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isRetired = charactersModel.currentCharacter?.isRetired ?? false;

    // Characters page with characters: expandable FAB
    return ExpandableFab(
      isOpen: charactersModel.isEditMode,
      onToggle: (open) => charactersModel.isEditMode = open,
      openIcon: const Icon(Icons.edit_rounded),
      closeIcon: const Icon(Icons.edit_off_rounded),
      children: [
        ActionButton(
          tooltip: isRetired ? l10n.unretire : l10n.retire,
          icon: Icon(isRetired ? Icons.directions_walk : Icons.assist_walker),
          color: colorScheme.surfaceContainerHighest,
          iconColor: colorScheme.onSurface,
          onPressed: () => _handleRetire(context, charactersModel, appModel),
        ),
        ActionButton(
          tooltip: l10n.delete,
          icon: const Icon(Icons.delete_rounded),
          color: colorScheme.errorContainer,
          iconColor: colorScheme.onErrorContainer,
          onPressed: () => _handleDelete(context, charactersModel),
        ),
      ],
    );
  }
}
