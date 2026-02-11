import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_campaign_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/settings_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/campaign_selector.dart';
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
    final theme = Theme.of(context);
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
                  textColor: ColorUtils.ensureContrast(
                    theme.colorScheme.primary,
                    theme.colorScheme.inverseSurface,
                  ),
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
    final theme = Theme.of(context);
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
          context.watch<AppModel>().page == 0 &&
              townModel.activeCampaign != null
          ? GestureDetector(
              onTap: () => CampaignSelector.show(
                context: context,
                campaigns: townModel.campaigns,
                activeCampaign: townModel.activeCampaign,
                onCampaignSelected: (c) => townModel.setActiveCampaign(c),
                onCreateCampaign: () =>
                    CreateCampaignScreen.show(context, townModel),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${townModel.activeCampaign!.name} ',
                    maxLines: 1,
                    style: theme.textTheme.headlineMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  Icon(Icons.swap_horiz_rounded),
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
        // Town page edit mode: delete campaign
        if (townModel.isEditMode && appModel.page == 0)
          Tooltip(
            message: l10n.deleteCampaign,
            child: IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () => _handleDeleteCampaign(context, townModel),
            ),
          ),
        if (!charactersModel.isEditMode &&
            appModel.page == 1 &&
            charactersModel.characters.isNotEmpty)
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
