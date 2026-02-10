import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// A bordered container with an [ExpansionTile] that applies an animated
/// backdrop blur when expanded. Used to frost the large class icon SVG
/// that sits behind character screen sections.
class BlurredExpansionContainer extends StatefulWidget {
  const BlurredExpansionContainer({
    super.key,
    required this.title,
    required this.children,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    this.constraints,
  });

  final Widget title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final BoxConstraints? constraints;

  @override
  State<BlurredExpansionContainer> createState() =>
      _BlurredExpansionContainerState();
}

class _BlurredExpansionContainerState extends State<BlurredExpansionContainer> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _isExpanded ? expansionBlurSigma : 0),
        duration: animationDuration,
        builder: (context, sigma, child) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: child!,
        ),
        child: Container(
          constraints: widget.constraints,
          decoration: BoxDecoration(
            border: Border.all(
              width: dividerThickness,
              color: theme.colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: _isExpanded
                  ? theme.extension<AppThemeExtension>()!.contrastedPrimary
                  : theme.colorScheme.primary,
              onExpansionChanged: (value) {
                widget.onExpansionChanged(value);
                setState(() => _isExpanded = value);
              },
              initiallyExpanded: _isExpanded,
              title: widget.title,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
