import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

class AddSubtractDialog extends StatefulWidget {
  const AddSubtractDialog(this.currentValue, this.hintText, {super.key});

  final int currentValue;
  final String hintText;

  @override
  State<AddSubtractDialog> createState() => _AddSubtractDialogState();
}

class _AddSubtractDialogState extends State<AddSubtractDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _hasInput = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleOperation(bool isAddition) {
    final inputValue = int.parse(_controller.text);
    final newValue = isAddition
        ? widget.currentValue + inputValue
        : widget.currentValue - inputValue;

    // Ensure value doesn't go below 0
    Navigator.pop(context, newValue.clamp(0, double.infinity).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Adjust ${widget.hintText}')),
      content: Container(
        constraints: const BoxConstraints(maxWidth: maxDialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a value to add or subtract from your current ${widget.hintText.toLowerCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: mediumPadding * 2),
            Row(
              children: [
                // Subtract button
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: _hasInput
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    iconSize: 32,
                    onPressed: _hasInput ? () => _handleOperation(false) : null,
                    tooltip: 'Subtract',
                  ),
                ),
                // Input field
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        _hasInput = value.isNotEmpty;
                      });
                    },
                    enableInteractiveSelection: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: titleFontSize),
                  ),
                ),
                // Add button
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: _hasInput
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    iconSize: 32,
                    onPressed: _hasInput ? () => _handleOperation(true) : null,
                    tooltip: 'Add',
                  ),
                ),
              ],
            ),
            const SizedBox(height: mediumPadding),
            Text(
              'Current: ${widget.currentValue}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
