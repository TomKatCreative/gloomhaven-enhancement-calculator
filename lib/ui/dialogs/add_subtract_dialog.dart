import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

class AddSubtractDialog extends StatefulWidget {
  const AddSubtractDialog(this.currentValue, this.labelText, {super.key});

  final int currentValue;
  final String labelText;

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
    final inputValue = int.tryParse(_controller.text);
    if (inputValue == null) return; // Guard against invalid input

    final newValue = isAddition
        ? widget.currentValue + inputValue
        : widget.currentValue - inputValue;

    // Ensure value doesn't go below 0
    Navigator.pop(context, newValue.clamp(0, double.infinity).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Adjust ${widget.labelText}')),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a value to add or subtract from your current ${widget.labelText.toLowerCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: largePadding),
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
                    iconSize: iconSizeXL,
                    onPressed: _hasInput ? () => _handleOperation(false) : null,
                    tooltip: AppLocalizations.of(context).subtract,
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
                    decoration: InputDecoration(labelText: widget.labelText),
                    style: Theme.of(context).textTheme.headlineMedium,
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
                    iconSize: iconSizeXL,
                    onPressed: _hasInput ? () => _handleOperation(true) : null,
                    tooltip: AppLocalizations.of(context).add,
                  ),
                ),
              ],
            ),
            const SizedBox(height: smallPadding),
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
