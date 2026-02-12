import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/resource.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// Bottom sheet with a stepper for adjusting a resource count.
class ResourceStepperSheet extends StatefulWidget {
  const ResourceStepperSheet({
    super.key,
    required this.resource,
    required this.iconColor,
    required this.initialCount,
    required this.onCountChanged,
  });

  final Resource resource;
  final Color iconColor;
  final int initialCount;
  final ValueChanged<int> onCountChanged;

  /// Shows the resource stepper sheet as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Resource resource,
    required Color iconColor,
    required int initialCount,
    required ValueChanged<int> onCountChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => ResourceStepperSheet(
        resource: resource,
        iconColor: iconColor,
        initialCount: initialCount,
        onCountChanged: onCountChanged,
      ),
    );
  }

  @override
  State<ResourceStepperSheet> createState() => _ResourceStepperSheetState();
}

class _ResourceStepperSheetState extends State<ResourceStepperSheet> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _increment() {
    setState(() => _count++);
    widget.onCountChanged(_count);
  }

  void _decrement() {
    if (_count <= 0) return;
    setState(() => _count--);
    widget.onCountChanged(_count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemedSvg(
                  assetKey: widget.resource.icon,
                  width: iconSizeXL,
                  color: widget.iconColor,
                ),
                const SizedBox(width: mediumPadding),
                Text(widget.resource.name, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(height: dividerThickness),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: extraLargePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _count > 0 ? _decrement : null,
                  icon: const Icon(Icons.remove_rounded),
                  iconSize: iconSizeLarge,
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '$_count',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _increment,
                  icon: const Icon(Icons.add_rounded),
                  iconSize: iconSizeLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
