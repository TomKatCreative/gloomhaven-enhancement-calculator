/// Bottom sheet displaying supplemental details for a personal quest requirement.
///
/// Shown when a [PersonalQuestRequirement] has a non-null [details] field.
/// The requirement's [description] is rendered as a header (parsed through
/// [GameTextParser] for inline icons), followed by the full details text.
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';

class RequirementDetailsSheet extends StatelessWidget {
  const RequirementDetailsSheet({super.key, required this.requirement});

  final PersonalQuestRequirement requirement;

  /// Shows the requirement details as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required PersonalQuestRequirement requirement,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RequirementDetailsSheet(requirement: requirement),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.titleMedium,
                children: GameTextParser.parse(
                  context,
                  requirement.description,
                  isDark,
                ),
              ),
            ),
          ),
          const Divider(height: dividerThickness),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(largePadding),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: GameTextParser.parse(
                    context,
                    requirement.details!,
                    isDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
