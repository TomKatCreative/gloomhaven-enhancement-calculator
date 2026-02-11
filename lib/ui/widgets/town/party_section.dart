import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/stepper_buttons.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// Placeholder achievement labels for the party sheet.
const _achievementLabels = ['Achievement 1', 'Achievement 2', 'Achievement 3'];

/// Actions available in the party overflow menu.
enum PartyAction { rename, switchParty, deleteParty }

/// Displays party info: reputation tracker, shop price modifier,
/// scenario location, notes, and achievements.
class PartySection extends StatefulWidget {
  const PartySection({
    super.key,
    required this.party,
    required this.isEditMode,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.onMenuAction,
    required this.onIncrementReputation,
    required this.onDecrementReputation,
    required this.onReputationChanged,
    required this.onLocationChanged,
    required this.onNotesChanged,
    required this.onToggleAchievement,
    this.onNameChanged,
  });

  final Party party;
  final bool isEditMode;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<PartyAction> onMenuAction;
  final VoidCallback onIncrementReputation;
  final VoidCallback onDecrementReputation;
  final ValueChanged<int> onReputationChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onToggleAchievement;
  final ValueChanged<String>? onNameChanged;

  @override
  State<PartySection> createState() => _PartySectionState();
}

class _PartySectionState extends State<PartySection> {
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.party.location);
    _notesController = TextEditingController(text: widget.party.notes);
    _nameController = TextEditingController(text: widget.party.name);
  }

  @override
  void didUpdateWidget(covariant PartySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.party.id != widget.party.id) {
      _locationController.text = widget.party.location;
      _notesController.text = widget.party.notes;
      _nameController.text = widget.party.name;
      _isEditingName = false;
    }
    // Exit name editing when leaving edit mode
    if (!widget.isEditMode && oldWidget.isEditMode) {
      _commitNameEdit();
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _commitNameEdit() {
    if (!_isEditingName) return;
    final trimmed = _nameController.text.trim();
    if (trimmed.isNotEmpty && trimmed != widget.party.name) {
      widget.onNameChanged?.call(trimmed);
    } else {
      _nameController.text = widget.party.name;
    }
    setState(() => _isEditingName = false);
  }

  List<Widget> _buildReputationSlider(ThemeData theme) {
    final slider = SfSlider(
      min: minReputation.toDouble(),
      max: maxReputation.toDouble(),
      value: widget.party.reputation.toDouble(),
      stepSize: widget.isEditMode ? 1 : null,
      showTicks: true,
      showLabels: true,
      interval: 10,
      activeColor: theme.colorScheme.primary,
      onChanged: widget.isEditMode
          ? (dynamic value) =>
                widget.onReputationChanged((value as double).round())
          : (_) {},
    );

    if (!widget.isEditMode) {
      return [
        const SizedBox(height: smallPadding),
        IgnorePointer(child: slider),
      ];
    }

    return [
      const SizedBox(height: smallPadding),
      slider,
      const SizedBox(height: mediumPadding),
      StepperButtons(
        onDecrement: widget.party.reputation > minReputation
            ? widget.onDecrementReputation
            : null,
        onIncrement: widget.party.reputation < maxReputation
            ? widget.onIncrementReputation
            : null,
      ),
    ];
  }

  void _handleMenuAction(PartyAction action) {
    if (action == PartyAction.rename) {
      setState(() => _isEditingName = true);
    } else {
      widget.onMenuAction(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CollapsibleSectionCard(
      title: _isEditingName ? '' : widget.party.name,
      titleWidget: _isEditingName
          ? TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.contrastedPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _commitNameEdit,
                ),
                suffixIconConstraints: const BoxConstraints(),
              ),
              onSubmitted: (_) => _commitNameEdit(),
            )
          : null,
      icon: Icons.groups,
      initiallyExpanded: widget.initiallyExpanded,
      onExpansionChanged: widget.onExpansionChanged,
      trailing: widget.isEditMode
          ? PopupMenuButton<PartyAction>(
              iconColor: theme.colorScheme.onSurfaceVariant,
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: PartyAction.rename,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.renameParty),
                      const SizedBox(width: largePadding),
                      Icon(
                        Icons.edit_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: PartyAction.switchParty,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.switchAction),
                      const SizedBox(width: largePadding),
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: PartyAction.deleteParty,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.delete),
                      const SizedBox(width: largePadding),
                      Icon(
                        Icons.delete_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
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
              // Reputation slider and stepper
              ..._buildReputationSlider(theme),
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
        ),
      ],
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
