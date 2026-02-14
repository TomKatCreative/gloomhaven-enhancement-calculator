import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// Reusable card wrapper for screen sections.
///
/// Provides a consistent card appearance with:
/// - Title row (icon + text) using [contrastedPrimary]
/// - [surfaceContainerLow] background with [outlineVariant] border
/// - [borderRadiusMedium] corners
/// - Optional [constraints] (default: [ResponsiveLayout.contentMaxWidth])
/// - Customizable [contentPadding] for the child content area
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.titleWidget,
    this.icon,
    this.svgAssetKey,
    this.trailing,
    required this.child,
    this.constraints,
    this.contentPadding = const EdgeInsets.fromLTRB(
      largePadding,
      0,
      largePadding,
      largePadding,
    ),
    this.sectionKey,
  });

  final String title;

  /// Optional widget that replaces the default [Text] title.
  final Widget? titleWidget;
  final IconData? icon;

  /// SVG asset key to display before the title (alternative to [icon]).
  final String? svgAssetKey;
  final Widget? trailing;
  final Widget child;

  /// Optional constraints. Defaults to [ResponsiveLayout.contentMaxWidth].
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry contentPadding;
  final GlobalKey? sectionKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.contrastedPrimary;
    final effectiveConstraints =
        constraints ??
        BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context));

    return Container(
      key: sectionKey,
      constraints: effectiveConstraints,
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
                ] else if (svgAssetKey != null) ...[
                  ThemedSvg(
                    assetKey: svgAssetKey!,
                    width: iconSizeSmall,
                    color: primaryColor,
                  ),
                  const SizedBox(width: smallPadding),
                ],
                Expanded(
                  child:
                      titleWidget ??
                      Text(
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
    this.titleWidget,
    this.icon,
    this.svgAssetKey,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.children,
    this.constraints,
    this.sectionKey,
    this.trailing,
  });

  final String title;

  /// Optional widget that replaces the default [Text] title.
  final Widget? titleWidget;
  final IconData? icon;

  /// SVG asset key to display before the title (alternative to [icon]).
  final String? svgAssetKey;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;

  /// Optional constraints. Defaults to [ResponsiveLayout.contentMaxWidth].
  final BoxConstraints? constraints;
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
    final effectiveConstraints =
        widget.constraints ??
        BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context));

    return Container(
      key: widget.sectionKey,
      constraints: effectiveConstraints,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (value) {
            widget.onExpansionChanged(value);
            setState(() => _isExpanded = value);
          },
          initiallyExpanded: _isExpanded,
          iconColor: primaryColor,
          trailing: widget.trailing != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.trailing!,
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: animationDuration,
                      child: Icon(
                        Icons.expand_more,
                        color: _isExpanded ? primaryColor : null,
                      ),
                    ),
                  ],
                )
              : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: iconSizeSmall, color: primaryColor),
                const SizedBox(width: smallPadding),
              ] else if (widget.svgAssetKey != null) ...[
                ThemedSvg(
                  assetKey: widget.svgAssetKey!,
                  width: iconSizeSmall,
                  color: primaryColor,
                ),
                const SizedBox(width: smallPadding),
              ],
              Flexible(
                child:
                    widget.titleWidget ??
                    Text(
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
