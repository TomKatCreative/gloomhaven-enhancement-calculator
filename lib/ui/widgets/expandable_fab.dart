import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// A controlled expandable floating action button that fans out child actions
/// in a 90° arc (right-to-up) when [isOpen] is true.
///
/// Based on the Flutter cookbook pattern:
/// https://docs.flutter.dev/cookbook/effects/expandable-fab
@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.openIcon,
    required this.closeIcon,
    this.distance = 56.0,
    required this.children,
  });

  /// Whether the FAB is currently expanded (driven externally by edit mode).
  final bool isOpen;

  /// Called when the user taps the FAB to toggle open/closed.
  final ValueChanged<bool> onToggle;

  /// Icon shown when the FAB is closed (tap to open).
  final Widget openIcon;

  /// Icon shown when the FAB is open (tap to close).
  final Widget closeIcon;

  /// Maximum distance the action buttons fan out.
  final double distance;

  /// The action buttons that appear when expanded.
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.isOpen ? 1.0 : 0.0,
      duration: animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void didUpdateWidget(ExpandableFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: colorScheme.primaryContainer,
          elevation: 4,
          child: InkWell(
            onTap: () => widget.onToggle(false),
            child: Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: IconTheme(
                data: IconThemeData(color: colorScheme.onPrimaryContainer),
                child: widget.closeIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (
      var i = 0, angleInDegrees = 0.0;
      i < count;
      i++, angleInDegrees += step
    ) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: widget.isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          widget.isOpen ? 0.7 : 1.0,
          widget.isOpen ? 0.7 : 1.0,
          1.0,
        ),
        duration: animationDuration,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: widget.isOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: animationDuration,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: () => widget.onToggle(true),
            child: widget.openIcon,
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 8.0 + offset.dx,
          bottom: 8.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: IgnorePointer(ignoring: progress.isDismissed, child: child!),
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

/// A circular action button used as an expanding action.
@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
    this.iconColor,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: color ?? theme.colorScheme.secondary,
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(smallPadding),
          child: IconTheme(
            data: IconThemeData(
              color: iconColor ?? theme.colorScheme.onSecondary,
            ),
            child: icon,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
