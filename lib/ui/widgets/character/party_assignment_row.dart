import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/create_party_sheet.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/party_assignment_sheet.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:provider/provider.dart';

class PartyAssignmentRow extends StatelessWidget {
  const PartyAssignmentRow({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final townModel = context.watch<TownModel>();
    final charactersModel = context.read<CharactersModel>();

    final party = _resolveParty(townModel);

    // No party assigned: show outlined button (like "Select a Personal Quest")
    if (party == null) {
      final primaryColor = theme.contrastedPrimary;
      return Center(
        child: OutlinedButton.icon(
          onPressed: () => _onTap(context, townModel, charactersModel),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
          ),
          icon: const Icon(Icons.groups_3_rounded, size: iconSizeSmall),
          label: Text(l10n.assignToParty),
        ),
      );
    }

    // Party assigned: show tappable row with party name
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      onTap: () => _onTap(context, townModel, charactersModel),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: smallPadding),
        child: Row(
          children: [
            Icon(
              Icons.groups_3_rounded,
              size: iconSizeMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: mediumPadding),
            Expanded(child: Text(party.name, style: theme.textTheme.bodyLarge)),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Party? _resolveParty(TownModel townModel) {
    if (character.partyId == null) return null;
    for (final party in townModel.parties) {
      if (party.id == character.partyId) return party;
    }
    return null;
  }

  void _onTap(
    BuildContext context,
    TownModel townModel,
    CharactersModel charactersModel,
  ) {
    if (townModel.activeCampaign == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).createCampaignFirst),
        ),
      );
      return;
    }

    PartyAssignmentSheet.show(
      context: context,
      parties: townModel.parties,
      currentPartyId: character.partyId,
      onPartySelected: (partyId) {
        charactersModel.assignCharacterToParty(character, partyId);
      },
      onCreateParty: () async {
        final created = await CreatePartySheet.show(context, townModel);
        if (created == true && townModel.activeParty != null) {
          charactersModel.assignCharacterToParty(
            character,
            townModel.activeParty!.id,
          );
        }
      },
    );
  }
}
