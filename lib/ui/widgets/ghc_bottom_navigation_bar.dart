import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class GHCBottomNavigationBar extends StatelessWidget {
  const GHCBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const SizedBox(
            height: navBarIconContainerHeight,
            child: Icon(Icons.history_edu_rounded, size: iconSizeLarge),
          ),
          label: AppLocalizations.of(context).characters,
        ),
        BottomNavigationBarItem(
          icon: const SizedBox(
            height: navBarIconContainerHeight,
            child: Icon(Icons.auto_awesome_rounded, size: iconSizeLarge),
          ),
          label: AppLocalizations.of(context).enhancements,
        ),
      ],
      currentIndex: appModel.page,
      onTap: (value) {
        appModel.page = value;
        appModel.pageController.jumpToPage(value);
        final CharactersModel charactersModel = context.read<CharactersModel>();
        charactersModel.isScrolledToTop = true;
        charactersModel.isEditMode = false;
        charactersModel.isElementSheetExpanded = false;
      },
    );
  }
}
