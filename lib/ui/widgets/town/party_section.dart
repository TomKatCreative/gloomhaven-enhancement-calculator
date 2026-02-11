import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

/// Placeholder achievement labels for the party sheet.
const _achievementLabels = ['Achievement 1', 'Achievement 2', 'Achievement 3'];

/// Displays party info: reputation tracker, shop price modifier,
/// scenario location, notes, and achievements.
class PartySection extends StatefulWidget {
  const PartySection({
    super.key,
    required this.party,
    required this.isEditMode,
    this.trailing,
    required this.onIncrementReputation,
    required this.onDecrementReputation,
    required this.onLocationChanged,
    required this.onNotesChanged,
    required this.onToggleAchievement,
  });

  final Party party;
  final bool isEditMode;
  final Widget? trailing;
  final VoidCallback onIncrementReputation;
  final VoidCallback onDecrementReputation;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onToggleAchievement;

  @override
  State<PartySection> createState() => _PartySectionState();
}

class _PartySectionState extends State<PartySection> {
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.party.location);
    _notesController = TextEditingController(text: widget.party.notes);
  }

  @override
  void didUpdateWidget(covariant PartySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.party.id != widget.party.id) {
      _locationController.text = widget.party.location;
      _notesController.text = widget.party.notes;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SectionCard(
      title: widget.party.name,
      icon: Icons.groups,
      trailing: widget.trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reputation display with shop price modifier
          Row(
            children: [
              Text(l10n.reputation, style: theme.textTheme.titleMedium),
              const Spacer(),
              _ShopPriceLabel(
                modifier: widget.party.shopPriceModifier,
                label: l10n.shopPriceModifier,
                theme: theme,
              ),
              const SizedBox(width: largePadding),
              Text(
                _formatReputation(widget.party.reputation),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _reputationColor(widget.party.reputation, theme),
                ),
              ),
            ],
          ),
          // Edit mode stepper
          if (widget.isEditMode) ...[
            const SizedBox(height: mediumPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: widget.party.reputation > minReputation
                      ? widget.onDecrementReputation
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: largePadding),
                IconButton.filled(
                  onPressed: widget.party.reputation < maxReputation
                      ? widget.onIncrementReputation
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
          const Divider(height: extraLargePadding),
          // Scenario location
          if (widget.isEditMode)
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: l10n.scenarioLocation,
                border: const OutlineInputBorder(),
              ),
              onChanged: widget.onLocationChanged,
            )
          else if (widget.party.location.isNotEmpty) ...[
            Text(
              l10n.scenarioLocation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: tinyPadding),
            Text(widget.party.location, style: theme.textTheme.bodyLarge),
          ],
          // Party notes
          if (widget.isEditMode) ...[
            const SizedBox(height: largePadding),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.partyNotes,
                hintText: l10n.addPartyNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
              minLines: 2,
              onChanged: widget.onNotesChanged,
            ),
          ] else if (widget.party.notes.isNotEmpty) ...[
            const SizedBox(height: mediumPadding),
            Text(
              l10n.partyNotes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: tinyPadding),
            Text(widget.party.notes, style: theme.textTheme.bodyMedium),
          ],
          // Achievements
          const SizedBox(height: mediumPadding),
          Text(
            l10n.achievements,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: smallPadding),
          Wrap(
            spacing: smallPadding,
            runSpacing: tinyPadding,
            children: _achievementLabels.map((label) {
              final selected = widget.party.achievements.contains(label);
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: widget.isEditMode
                    ? (_) => widget.onToggleAchievement(label)
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatReputation(int reputation) {
    if (reputation > 0) return '+$reputation';
    return '$reputation';
  }

  Color _reputationColor(int reputation, ThemeData theme) {
    if (reputation > 0) return Colors.green;
    if (reputation < 0) return theme.colorScheme.error;
    return theme.colorScheme.onSurface;
  }
}

/// Displays the shop price modifier inline.
class _ShopPriceLabel extends StatelessWidget {
  const _ShopPriceLabel({
    required this.modifier,
    required this.label,
    required this.theme,
  });

  final int modifier;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (modifier < 0) {
      text = '$label: $modifier';
      color = Colors.green;
    } else if (modifier > 0) {
      text = '$label: +$modifier';
      color = theme.colorScheme.error;
    } else {
      text = '$label: 0';
      color = theme.colorScheme.onSurfaceVariant;
    }

    return Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color));
  }
}
