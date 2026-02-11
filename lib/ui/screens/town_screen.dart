import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_party_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_campaign_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/party_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/prosperity_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/sanctuary_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/town_empty_state.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';

/// The Town tab screen for managing campaigns and parties.
class TownScreen extends StatefulWidget {
  const TownScreen({super.key});

  @override
  State<TownScreen> createState() => _TownScreenState();
}

class _TownScreenState extends State<TownScreen> {
  @override
  Widget build(BuildContext context) {
    final townModel = context.watch<TownModel>();
    final l10n = AppLocalizations.of(context);

    // Empty state: no campaigns
    if (townModel.campaigns.isEmpty) {
      return TownEmptyState(
        onCreateCampaign: () => CreateCampaignScreen.show(context, townModel),
      );
    }

    final campaign = townModel.activeCampaign;
    if (campaign == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: largePadding,
        vertical: mediumPadding,
      ),
      children: [
        // Town details: prosperity + sanctuary in a collapsible card
        Center(
          child: CollapsibleSectionCard(
            title: campaign.name,
            icon: Icons.location_city,
            initiallyExpanded: SharedPrefs().townDetailsExpanded,
            onExpansionChanged: (v) => SharedPrefs().townDetailsExpanded = v,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  largePadding,
                  0,
                  largePadding,
                  largePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProsperitySection(
                      embedded: true,
                      campaign: campaign,
                      isEditMode: townModel.isEditMode,
                      onIncrement: () => townModel.incrementProsperity(),
                      onDecrement: () => townModel.decrementProsperity(),
                    ),
                    const Divider(height: extraLargePadding),
                    // Sub-header for sanctuary
                    Row(
                      children: [
                        ThemedSvg(
                          assetKey: 'GOLD',
                          width: iconSizeSmall,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: smallPadding),
                        Text(
                          l10n.donatedGold,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: smallPadding),
                    SanctuarySection(
                      embedded: true,
                      campaign: campaign,
                      isEditMode: townModel.isEditMode,
                      onIncrement: () async {
                        final justCompleted = await townModel
                            .incrementDonatedGold();
                        if (justCompleted && context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text(l10n.openEnvelopeB)),
                            );
                        }
                        return justCompleted;
                      },
                      onDecrement: () => townModel.decrementDonatedGold(),
                      onIncrementSmall: () async {
                        final justCompleted = await townModel
                            .incrementDonatedGold(amount: 1);
                        if (justCompleted && context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text(l10n.openEnvelopeB)),
                            );
                        }
                        return justCompleted;
                      },
                      onDecrementSmall: () =>
                          townModel.decrementDonatedGold(amount: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: largePadding),

        // Party section
        if (townModel.activeParty != null)
          Center(
            child: PartySection(
              party: townModel.activeParty!,
              isEditMode: townModel.isEditMode,
              trailing: townModel.isEditMode
                  ? townModel.parties.length > 1
                        ? IconButton(
                            icon: const Icon(Icons.swap_horiz_rounded),
                            tooltip: l10n.switchParty,
                            onPressed: () =>
                                _showPartySwitcher(context, townModel),
                          )
                        : IconButton(
                            icon: const Icon(Icons.group_add_rounded),
                            tooltip: l10n.createParty,
                            onPressed: () =>
                                CreatePartyScreen.show(context, townModel),
                          )
                  : null,
              onIncrementReputation: () => townModel.incrementReputation(),
              onDecrementReputation: () => townModel.decrementReputation(),
              onLocationChanged: (v) => townModel.updatePartyLocation(v),
              onNotesChanged: (v) => townModel.updatePartyNotes(v),
              onToggleAchievement: (v) => townModel.toggleAchievement(v),
            ),
          )
        else
          // No party prompt
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Text(
                    l10n.noPartiesYet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: mediumPadding),
                  FilledButton.tonal(
                    onPressed: () => CreatePartyScreen.show(context, townModel),
                    child: Text(l10n.createParty),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: extraLargePadding),
      ],
    );
  }

  void _showPartySwitcher(BuildContext context, TownModel townModel) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                largePadding,
                largePadding,
                largePadding,
                smallPadding,
              ),
              child: Row(
                children: [
                  Text(l10n.switchParty, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      CreatePartyScreen.show(context, townModel);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.create),
                  ),
                ],
              ),
            ),
            const Divider(height: dividerThickness),
            ...townModel.parties.map(
              (party) => ListTile(
                leading: Icon(
                  Icons.groups,
                  color: party.id == townModel.activeParty?.id
                      ? theme.colorScheme.primary
                      : null,
                ),
                title: Text(party.name),
                selected: party.id == townModel.activeParty?.id,
                onTap: () {
                  Navigator.pop(context);
                  townModel.setActiveParty(party);
                },
              ),
            ),
            const SizedBox(height: smallPadding),
          ],
        ),
      ),
    );
  }
}
