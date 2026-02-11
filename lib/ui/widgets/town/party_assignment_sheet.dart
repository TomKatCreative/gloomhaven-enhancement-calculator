import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';

/// Bottom sheet for assigning a character to a party.
class PartyAssignmentSheet extends StatelessWidget {
  const PartyAssignmentSheet({
    super.key,
    required this.parties,
    required this.currentPartyId,
    required this.onPartySelected,
    required this.onCreateParty,
  });

  final List<Party> parties;
  final String? currentPartyId;
  final ValueChanged<String?> onPartySelected;
  final VoidCallback onCreateParty;

  /// Shows the party assignment sheet as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<Party> parties,
    required String? currentPartyId,
    required ValueChanged<String?> onPartySelected,
    required VoidCallback onCreateParty,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => PartyAssignmentSheet(
        parties: parties,
        currentPartyId: currentPartyId,
        onPartySelected: onPartySelected,
        onCreateParty: onCreateParty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
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
                Text(l10n.selectParty, style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCreateParty();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.create),
                ),
              ],
            ),
          ),
          const Divider(height: dividerThickness),
          // "No party" option
          ListTile(
            leading: Icon(
              Icons.person_off_outlined,
              color: currentPartyId == null ? theme.colorScheme.primary : null,
            ),
            title: Text(l10n.noParty),
            selected: currentPartyId == null,
            onTap: () {
              Navigator.pop(context);
              onPartySelected(null);
            },
          ),
          // Party list
          ...parties.map(
            (party) => ListTile(
              leading: Icon(
                Icons.groups,
                color: party.id == currentPartyId
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: Text(party.name),
              selected: party.id == currentPartyId,
              onTap: () {
                Navigator.pop(context);
                onPartySelected(party.id);
              },
            ),
          ),
          const SizedBox(height: smallPadding),
        ],
      ),
    );
  }
}
