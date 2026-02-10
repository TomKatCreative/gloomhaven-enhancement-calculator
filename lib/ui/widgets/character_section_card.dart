import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// Reusable card wrapper for character screen sections.
///
/// Provides a consistent card appearance with:
/// - Title row (icon + text) using [contrastedPrimary]
/// - [surfaceContainerLow] background with [outlineVariant] border
/// - [borderRadiusMedium] corners
/// - Optional [constraints] (default maxWidth: 400)
class CharacterSectionCard extends StatelessWidget {
  const CharacterSectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.child,
    this.constraints = const BoxConstraints(maxWidth: 400),
    this.sectionKey,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final BoxConstraints constraints;
  final GlobalKey? sectionKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.contrastedPrimary;

    return Container(
      key: sectionKey,
      constraints: constraints,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              largePadding,
              mediumPadding,
              mediumPadding,
              smallPadding,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: iconSizeSmall, color: primaryColor),
                  const SizedBox(width: smallPadding),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
                if (trailing case final trailing?) trailing,
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(
              largePadding,
              0,
              largePadding,
              largePadding,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Card variant with an [ExpansionTile] for collapsible sections.
class CollapsibleSectionCard extends StatefulWidget {
  const CollapsibleSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.children,
    this.constraints = const BoxConstraints(maxWidth: 400),
    this.sectionKey,
  });

  final String title;
  final IconData? icon;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final BoxConstraints constraints;
  final GlobalKey? sectionKey;

  @override
  State<CollapsibleSectionCard> createState() => _CollapsibleSectionCardState();
}

class _CollapsibleSectionCardState extends State<CollapsibleSectionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.contrastedPrimary;

    return Container(
      key: widget.sectionKey,
      constraints: widget.constraints,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: _isExpanded ? primaryColor : theme.colorScheme.primary,
          onExpansionChanged: (value) {
            widget.onExpansionChanged(value);
            setState(() => _isExpanded = value);
          },
          initiallyExpanded: _isExpanded,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: iconSizeSmall, color: primaryColor),
                const SizedBox(width: smallPadding),
              ],
              Flexible(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          children: widget.children,
        ),
      ),
    );
  }
}
