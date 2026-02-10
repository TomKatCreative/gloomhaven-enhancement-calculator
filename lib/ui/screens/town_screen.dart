import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_campaign_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_world_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/campaign_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/prosperity_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/sanctuary_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/town_empty_state.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';

/// The Town tab screen for managing worlds and campaigns.
class TownScreen extends StatelessWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final townModel = context.watch<TownModel>();
    final l10n = AppLocalizations.of(context);

    // Empty state: no worlds
    if (townModel.worlds.isEmpty) {
      return TownEmptyState(
        onCreateWorld: () => CreateWorldScreen.show(context, townModel),
      );
    }

    final world = townModel.activeWorld;
    if (world == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: largePadding,
        vertical: mediumPadding,
      ),
      children: [
        // Prosperity section
        Center(
          child: ProsperitySection(
            world: world,
            isEditMode: townModel.isEditMode,
            onIncrement: () => townModel.incrementProsperity(),
            onDecrement: () => townModel.decrementProsperity(),
          ),
        ),
        const SizedBox(height: largePadding),

        // Sanctuary donation section
        Center(
          child: SanctuarySection(
            world: world,
            isEditMode: townModel.isEditMode,
            onIncrement: () async {
              final justCompleted = await townModel.incrementDonatedGold();
              if (justCompleted && context.mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(content: Text(l10n.openEnvelopeB)));
              }
              return justCompleted;
            },
            onDecrement: () => townModel.decrementDonatedGold(),
          ),
        ),
        const SizedBox(height: largePadding),

        // Campaign section
        if (townModel.activeCampaign != null)
          Center(
            child: CampaignSection(
              campaign: townModel.activeCampaign!,
              isEditMode: townModel.isEditMode,
              onIncrementReputation: () => townModel.incrementReputation(),
              onDecrementReputation: () => townModel.decrementReputation(),
            ),
          )
        else
          // No campaign prompt
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Text(
                    l10n.noCampaignsYet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: mediumPadding),
                  FilledButton.tonal(
                    onPressed: () =>
                        CreateCampaignScreen.show(context, townModel),
                    child: Text(l10n.createCampaign),
                  ),
                ],
              ),
            ),
          ),

        // Campaign selector (when multiple campaigns exist)
        if (townModel.campaigns.length > 1) ...[
          const SizedBox(height: mediumPadding),
          Center(
            child: Wrap(
              spacing: smallPadding,
              children: townModel.campaigns.map((campaign) {
                final isActive = campaign.id == townModel.activeCampaign?.id;
                return ChoiceChip(
                  label: Text(campaign.name),
                  selected: isActive,
                  onSelected: (_) => townModel.setActiveCampaign(campaign),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: extraLargePadding),
      ],
    );
  }
}
