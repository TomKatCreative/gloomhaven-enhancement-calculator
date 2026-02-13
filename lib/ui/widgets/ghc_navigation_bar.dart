import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class GHCNavigationBar extends StatelessWidget {
  const GHCNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: appModel.page,
      onDestinationSelected: (value) {
        appModel.page = value;
        appModel.pageController.animateToPage(
          value,
          duration: animationDuration,
          curve: Curves.easeInOut,
        );
        SharedPrefs().initialPage = value;
        final CharactersModel charactersModel = context.read<CharactersModel>();
        charactersModel.isScrolledToTop = true;
        charactersModel.isEditMode = false;
        charactersModel.isElementSheetExpanded = false;
      },
      destinations: [
        if (kTownSheetEnabled)
          NavigationDestination(
            icon: const Icon(Icons.castle_outlined),
            selectedIcon: const Icon(Icons.castle),
            label: l10n.town,
          ),
        NavigationDestination(
          icon: const Icon(Icons.history_edu_outlined),
          selectedIcon: const Icon(Icons.history_edu),
          label: l10n.characters,
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: const Icon(Icons.auto_awesome),
          label: l10n.enhancements,
        ),
      ],
    );
  }
}
