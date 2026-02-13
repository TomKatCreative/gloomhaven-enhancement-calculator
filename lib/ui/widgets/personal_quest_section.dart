/// Collapsible section displaying a character's Personal Quest and progress.
///
/// Shows the quest title, unlock reward, and requirement progress. In edit
/// mode, allows changing the quest and adjusting progress via +/- buttons.
///
/// ## View Mode
/// - Quest title with unlock class icon in header
/// - Requirements list with progress text (e.g., "12/20")
///
/// ## Edit Mode
/// - Tappable quest title to change PQ
/// - +/- buttons for each requirement's progress
/// - TextFormField selector when no quest assigned
///
/// ## Retirement Prompt
/// When the last requirement is completed, a dialog prompts the player
/// to retire (per official Gloomhaven rules).
library;

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/personal_quest_selector_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class PersonalQuestSection extends StatelessWidget {
  const PersonalQuestSection({
    required this.character,
    this.embedded = false,
    super.key,
  });
  final Character character;

  /// When true, renders just the quest content without a card wrapper.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CharactersModel>();
    final quest = character.personalQuest;

    // No quest assigned: show select button (hidden for retired characters)
    if (quest == null) {
      if (character.isRetired) return const SizedBox.shrink();
      if (embedded) {
        return Padding(
          padding: const EdgeInsets.only(bottom: largePadding),
          child: Center(
            child: _SelectQuestButton(character: character, model: model),
          ),
        );
      }
      return Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: _SelectQuestButton(character: character, model: model),
      );
    }

    // Embedded mode: just the content, no card wrapper
    if (embedded) {
      return _QuestContent(character: character, quest: quest, model: model);
    }

    // Quest assigned: show collapsible card
    return CollapsibleSectionCard(
      icon: Icons.map_rounded,
      initiallyExpanded: SharedPrefs().personalQuestExpanded,
      onExpansionChanged: (value) =>
          SharedPrefs().personalQuestExpanded = value,
      title: AppLocalizations.of(context).personalQuest,
      children: [
        _QuestContent(character: character, quest: quest, model: model),
      ],
    );
  }
}

class _SelectQuestButton extends StatelessWidget {
  const _SelectQuestButton({required this.character, required this.model});
  final Character character;
  final CharactersModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(
      context,
    ).extension<AppThemeExtension>()!.contrastedPrimary;
    return OutlinedButton.icon(
      onPressed: () => _selectQuest(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
      ),
      icon: const Icon(Icons.add_rounded, size: iconSizeSmall),
      label: Text(l10n.selectAPersonalQuest),
    );
  }

  Future<void> _selectQuest(BuildContext context) async {
    final quest = await showPersonalQuestSelectorDialog(
      context: context,
      edition: GameEdition.gloomhaven,
    );
    if (quest != null && context.mounted) {
      await model.updatePersonalQuest(character, quest.id);
    }
  }
}

class _QuestContent extends StatelessWidget {
  const _QuestContent({
    required this.character,
    required this.quest,
    required this.model,
  });
  final Character character;
  final PersonalQuest quest;
  final CharactersModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = model.isEditMode && !character.isRetired;

    return Padding(
      padding: const EdgeInsets.only(
        left: largePadding,
        right: mediumPadding,
        bottom: largePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest title row
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.titleMedium,
                    children: [
                      TextSpan(text: '${quest.number}: ${quest.title}'),
                      if (quest.unlockClassCode != null) ...[
                        const TextSpan(text: ' · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(
                            width: iconSizeMedium,
                            height: iconSizeMedium,
                            child: ClassIconSvg(
                              playerClass: PlayerClasses.playerClasses
                                  .firstWhere(
                                    (c) => c.classCode == quest.unlockClassCode,
                                  ),
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ] else if (quest.unlockEnvelope != null) ...[
                        const TextSpan(text: ' · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.mail_outline,
                            size: iconSizeMedium,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isEditMode)
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _changeQuest(context),
                ),
            ],
          ),
          const SizedBox(height: mediumPadding),
          // Requirements list
          ...List.generate(quest.requirements.length, (index) {
            final req = quest.requirements[index];
            final progress = index < character.personalQuestProgress.length
                ? character.personalQuestProgress[index]
                : 0;
            return _RequirementRow(
              requirement: req,
              progress: progress,
              index: index,
              character: character,
              model: model,
              isEditMode: isEditMode,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _changeQuest(BuildContext context) async {
    // Show warning dialog
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: AppLocalizations.of(context).changePersonalQuest,
      content: Text(AppLocalizations.of(context).changePersonalQuestBody),
      confirmLabel: AppLocalizations.of(context).change,
      cancelLabel: AppLocalizations.of(context).cancel,
    );
    if (confirmed != true || !context.mounted) return;

    final newQuest = await showPersonalQuestSelectorDialog(
      context: context,
      edition: GameEdition.gloomhaven,
    );
    if (newQuest != null && context.mounted) {
      await model.updatePersonalQuest(character, newQuest.id);
    }
  }
}

class _RequirementRow extends StatefulWidget {
  const _RequirementRow({
    required this.requirement,
    required this.progress,
    required this.index,
    required this.character,
    required this.model,
    required this.isEditMode,
  });

  final PersonalQuestRequirement requirement;
  final int progress;
  final int index;
  final Character character;
  final CharactersModel model;
  final bool isEditMode;

  @override
  State<_RequirementRow> createState() => _RequirementRowState();
}

@visibleForTesting
bool isRetirementSnackBarVisible = false;

class _RequirementRowState extends State<_RequirementRow> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.progress > 0 ? widget.progress.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_RequirementRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _textController.text = widget.progress > 0
          ? widget.progress.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = widget.progress >= widget.requirement.target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: iconSizeSmall,
            color: isComplete
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: smallPadding),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isComplete ? theme.disabledColor : null,
                  ),
                  children: Utils.generateCheckRowDetails(
                    context,
                    widget.requirement.description,
                    theme.brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: smallPadding),
          if (widget.isEditMode) ...[
            if (widget.requirement.target > 20)
              _buildTextField(theme)
            else ...[
              IconButton(
                iconSize: iconSizeSmall,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(tinyPadding),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: widget.progress > 0
                    ? () => _updateProgress(context, widget.progress - 1)
                    : null,
              ),
              IntrinsicWidth(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Invisible placeholder reserves width for widest value,
                    // which is 14
                    Opacity(
                      opacity: 0,
                      child: Text('20', style: theme.textTheme.bodySmall),
                    ),
                    Text(
                      '${widget.progress}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '/${widget.requirement.target}',
                style: theme.textTheme.bodySmall,
              ),
              IconButton(
                iconSize: iconSizeSmall,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(tinyPadding),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: widget.progress < widget.requirement.target
                    ? () => _updateProgress(context, widget.progress + 1)
                    : null,
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(right: mediumPadding),
              child: Text(
                AppLocalizations.of(
                  context,
                ).progressOf(widget.progress, widget.requirement.target),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isComplete
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    final isComplete = widget.progress >= widget.requirement.target;
    final secondaryColor = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 55,
          child: TextField(
            controller: _textController,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isComplete ? theme.colorScheme.primary : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(
                mediumPadding,
                smallPadding,
                0,
                smallPadding,
              ),
              hintText: '0',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value) ?? 0;
              _updateProgress(context, parsed);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: tinyPadding),
          child: Text(
            '/',
            style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
          ),
        ),
        Text(
          '${widget.requirement.target}',
          style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
        ),
      ],
    );
  }

  Future<void> _updateProgress(BuildContext context, int newValue) async {
    final justCompleted = await widget.model.updatePersonalQuestProgress(
      widget.character,
      widget.index,
      newValue,
    );
    if (justCompleted && context.mounted) {
      _showRetirementSnackBar(context);
    }
  }

  void _showRetirementSnackBar(BuildContext context) {
    if (isRetirementSnackBarVisible) return;
    isRetirementSnackBarVisible = true;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    _showConfetti(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(l10n.personalQuestComplete),
            action: SnackBarAction(
              label: l10n.retire,
              textColor: ColorUtils.ensureContrast(
                theme.colorScheme.primary,
                theme.colorScheme.inverseSurface,
              ),
              onPressed: () => _showRetirementDialog(context),
            ),
          ),
        )
        .closed
        .then((_) => isRetirementSnackBarVisible = false);
  }

  void _showConfetti(BuildContext context) {
    final overlay = Overlay.of(context);
    final controller = ConfettiController(duration: const Duration(seconds: 1));
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Align(
        alignment: Alignment.bottomCenter,
        child: ConfettiWidget(
          confettiController: controller,
          blastDirection: -pi / 2,
          emissionFrequency: 0.8,
          maxBlastForce: 60,
          minBlastForce: 30,
          blastDirectionality: BlastDirectionality.explosive,
        ),
      ),
    );
    overlay.insert(entry);
    controller.play();
    // Remove overlay after particles settle
    Future.delayed(const Duration(seconds: 6), () {
      entry.remove();
      controller.dispose();
    });
  }

  Future<void> _showRetirementDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.personalQuestComplete,
      content: Text(l10n.personalQuestCompleteBody(widget.character.name)),
      confirmLabel: l10n.retire,
      cancelLabel: l10n.notYet,
    );
    if (confirmed == true && context.mounted) {
      await widget.model.retireCurrentCharacter();
      if (context.mounted) {
        context.read<AppModel>().updateTheme();
      }
    }
  }
}
