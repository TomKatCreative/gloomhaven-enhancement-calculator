/// A single requirement row for a personal quest.
///
/// Displays the requirement description and progress controls. In edit mode,
/// renders one of three interaction variants based on the requirement's target:
/// - **Binary** (target = 1): Checkbox
/// - **Low target** (2–20): +/- buttons with progress counter
/// - **High target** (>20): Text field with target denominator
///
/// In view mode, shows a read-only checkbox or progress text.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/requirement_details_sheet.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class RequirementRow extends StatefulWidget {
  const RequirementRow({
    required this.requirement,
    required this.progress,
    required this.index,
    required this.character,
    required this.model,
    required this.isEditMode,
    this.isLocked = false,
    this.onQuestCompleted,
    super.key,
  });

  final PersonalQuestRequirement requirement;
  final int progress;
  final int index;
  final Character character;
  final CharactersModel model;
  final bool isEditMode;
  final bool isLocked;

  /// Called when updating progress causes the entire quest to be completed.
  final VoidCallback? onQuestCompleted;

  @override
  State<RequirementRow> createState() => _RequirementRowState();
}

class _RequirementRowState extends State<RequirementRow> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.progress > 0 ? widget.progress.toString() : '',
    );
  }

  @override
  void didUpdateWidget(RequirementRow oldWidget) {
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
    final isDimmed = isComplete || widget.isLocked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.requirement.details != null)
            GestureDetector(
              onTap: () => RequirementDetailsSheet.show(
                context: context,
                requirement: widget.requirement,
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: smallPadding),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: iconSizeSmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: isDimmed ? theme.disabledColor.a : 1.0,
                child: RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: GameTextParser.parse(
                      context,
                      widget.requirement.description,
                      theme.brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: smallPadding),
          if (widget.isEditMode) ...[
            if (widget.requirement.target == 1)
              Checkbox(
                value: widget.progress >= 1,
                activeColor: theme
                    .extension<AppThemeExtension>()!
                    .contrastedPrimary,
                onChanged: widget.isLocked
                    ? null
                    : (value) =>
                          _updateProgress(context, value == true ? 1 : 0),
              )
            else if (widget.requirement.target > 30)
              _buildTextField(theme)
            else ...[
              IconButton(
                iconSize: iconSizeSmall,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(tinyPadding),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: widget.isLocked
                    ? null
                    : widget.progress > 0
                    ? () => _updateProgress(context, widget.progress - 1)
                    : null,
              ),
              IntrinsicWidth(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible placeholder reserves width for widest value
                    Opacity(
                      opacity: 0,
                      child: Text('20/20', style: theme.textTheme.bodySmall),
                    ),
                    Text(
                      '${widget.progress}/${widget.requirement.target}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isComplete
                            ? theme
                                  .extension<AppThemeExtension>()!
                                  .contrastedPrimary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: iconSizeSmall,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(tinyPadding),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: widget.isLocked
                    ? null
                    : widget.progress < widget.requirement.target
                    ? () => _updateProgress(context, widget.progress + 1)
                    : null,
              ),
            ],
          ] else if (widget.requirement.target == 1)
            Checkbox(
              value: widget.progress >= 1,
              activeColor: theme
                  .extension<AppThemeExtension>()!
                  .contrastedPrimary,
              onChanged: null,
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: mediumPadding),
              child: Text(
                AppLocalizations.of(
                  context,
                ).progressOf(widget.progress, widget.requirement.target),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isComplete
                      ? theme.extension<AppThemeExtension>()!.contrastedPrimary
                      : widget.isLocked
                      ? theme.disabledColor
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
            enabled: !widget.isLocked,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isComplete
                  ? theme.extension<AppThemeExtension>()!.contrastedPrimary
                  : null,
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
      widget.onQuestCompleted?.call();
    }
  }
}
