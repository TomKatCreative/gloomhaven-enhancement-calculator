import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_campaign_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_world_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/settings_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/world_selector.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
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

  Future<void> _handleDeleteWorld(
    BuildContext context,
    TownModel townModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? result = await ConfirmationDialog.show(
      context: context,
      content: Text(l10n.deleteWorldBody),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );

    if (result == true && context.mounted) {
      final worldName = townModel.activeWorld?.name ?? '';
      await townModel.deleteActiveWorld();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('$worldName deleted')));
    }
  }

  Future<void> _handleDeleteCampaign(
    BuildContext context,
    TownModel townModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? result = await ConfirmationDialog.show(
      context: context,
      content: Text(l10n.deleteCampaignBody),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );

    if (result == true && context.mounted) {
      final campaignName = townModel.activeCampaign?.name ?? '';
      await townModel.deleteActiveCampaign();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('$campaignName deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .read<EnhancementCalculatorModel>();
    final appModel = context.read<AppModel>();
    final charactersModel = context.watch<CharactersModel>();
    final townModel = context.watch<TownModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isRetired = charactersModel.currentCharacter?.isRetired ?? false;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      centerTitle: true,
      title:
          context.watch<AppModel>().page == 0 && townModel.activeWorld != null
          ? GestureDetector(
              onTap: () => WorldSelector.show(
                context: context,
                worlds: townModel.worlds,
                activeWorld: townModel.activeWorld,
                onWorldSelected: (w) => townModel.setActiveWorld(w),
                onCreateWorld: () => CreateWorldScreen.show(context, townModel),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    townModel.activeWorld!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Icon(Icons.arrow_drop_down, size: iconSizeSmall),
                ],
              ),
            )
          : context.watch<AppModel>().page == 1 &&
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
          : context.watch<AppModel>().page == 2
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
        // Town page: add campaign button
        if (!townModel.isEditMode &&
            appModel.page == 0 &&
            townModel.activeWorld != null)
          Tooltip(
            message: l10n.createCampaign,
            child: IconButton(
              icon: const Icon(Icons.group_add_rounded),
              onPressed: () async {
                await CreateCampaignScreen.show(context, townModel);
              },
            ),
          ),
        // Town page edit mode: delete actions
        if (townModel.isEditMode && appModel.page == 0) ...[
          if (townModel.activeCampaign != null)
            Tooltip(
              message: l10n.deleteCampaign,
              child: IconButton(
                icon: const Icon(Icons.group_remove_rounded),
                onPressed: () => _handleDeleteCampaign(context, townModel),
              ),
            ),
          Tooltip(
            message: l10n.deleteWorld,
            child: IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () => _handleDeleteWorld(context, townModel),
            ),
          ),
        ],
        if (!charactersModel.isEditMode && appModel.page == 1)
          Tooltip(
            message: 'New Character',
            child: IconButton(
              icon: const Icon(Icons.person_add_rounded),
              onPressed: () async {
                await CreateCharacterScreen.show(context, charactersModel);
              },
            ),
          ),
        if (charactersModel.isEditMode && appModel.page == 1) ...[
          Tooltip(
            message: isRetired ? l10n.unretire : l10n.retire,
            child: IconButton(
              icon: Icon(
                isRetired ? Icons.directions_walk : Icons.assist_walker,
              ),
              onPressed: () =>
                  _handleRetire(context, charactersModel, appModel),
            ),
          ),
          Tooltip(
            message: l10n.delete,
            child: IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () => _handleDelete(context, charactersModel),
            ),
          ),
        ],
        Tooltip(
          message: l10n.settings,
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
