import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// Reusable card wrapper for screen sections.
///
/// Provides a consistent card appearance with:
/// - Title row (icon + text) using [contrastedPrimary]
/// - [surfaceContainerLow] background with [outlineVariant] border
/// - [borderRadiusMedium] corners
/// - Optional [constraints] (default maxWidth: [maxWidth])
/// - Customizable [contentPadding] for the child content area
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.child,
    this.constraints = const BoxConstraints(maxWidth: maxWidth),
    this.contentPadding = const EdgeInsets.fromLTRB(
      largePadding,
      0,
      largePadding,
      largePadding,
    ),
    this.sectionKey,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry contentPadding;
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
                ?trailing,
              ],
            ),
          ),
          // Content
          Padding(padding: contentPadding, child: child),
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
    this.constraints = const BoxConstraints(maxWidth: maxWidth),
    this.sectionKey,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final BoxConstraints constraints;
  final GlobalKey? sectionKey;
  final Widget? trailing;

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
              if (widget.trailing != null) ...[
                const SizedBox(width: smallPadding),
                widget.trailing!,
              ],
            ],
          ),
          children: widget.children,
        ),
      ),
    );
  }
}
