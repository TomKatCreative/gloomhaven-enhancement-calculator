import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// Bottom sheet with a stepper for adjusting a resource count.
class ResourceStepperSheet extends StatefulWidget {
  const ResourceStepperSheet({
    super.key,
    required this.name,
    required this.assetKey,
    required this.iconColor,
    required this.initialCount,
    required this.onCountChanged,
  });

  final String name;
  final String assetKey;
  final Color iconColor;
  final int initialCount;
  final ValueChanged<int> onCountChanged;

  /// Shows the resource stepper sheet as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required String name,
    required String assetKey,
    required Color iconColor,
    required int initialCount,
    required ValueChanged<int> onCountChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ResourceStepperSheet(
        name: name,
        assetKey: assetKey,
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _controller = TextEditingController(text: '$_count');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateCount(int value) {
    setState(() => _count = value);
    _controller.text = '$_count';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    widget.onCountChanged(_count);
  }

  static const _maxCount = 999;

  void _increment() {
    if (_count >= _maxCount) return;
    _updateCount(_count + 1);
  }

  void _decrement() {
    if (_count <= 0) return;
    _updateCount(_count - 1);
  }

  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed != null && parsed >= 0) {
      _count = parsed.clamp(0, _maxCount);
      widget.onCountChanged(_count);
    } else if (text.isEmpty) {
      _count = 0;
      widget.onCountChanged(_count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
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
                    assetKey: widget.assetKey,
                    width: iconSizeXL,
                    color: widget.iconColor,
                  ),
                  const SizedBox(width: mediumPadding),
                  Text(widget.name, style: theme.textTheme.titleLarge),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: mediumPadding,
                    ),
                    child: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onTextChanged,
                        onTap: () => _controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controller.text.length,
                        ),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _count < _maxCount ? _increment : null,
                    icon: const Icon(Icons.add_rounded),
                    iconSize: iconSizeLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
