import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

/// Name text field with random name generator and retirement counter.
class NameField extends StatefulWidget {
  final TextEditingController nameController;
  final int previousRetirements;
  final ValueChanged<int> onRetirementChanged;

  const NameField({
    super.key,
    required this.nameController,
    required this.previousRetirements,
    required this.onRetirementChanged,
  });

  @override
  NameFieldState createState() => NameFieldState();
}

class NameFieldState extends State<NameField> {
  late final faker.Faker _faker;
  late String _placeholderName;
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _faker = faker.Faker();
    _placeholderName = _generateRandomName();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _generateRandomName() {
    return '${_faker.person.firstName()} ${_faker.person.lastName()}';
  }

  /// Returns the effective name — typed text or the current placeholder.
  String get effectiveName => widget.nameController.text.isEmpty
      ? _placeholderName
      : widget.nameController.text;

  /// Requests focus on the name text field.
  void requestFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(_nameFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            textCapitalization: TextCapitalization.words,
            autocorrect: false,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: l10n.name,
              hintText: _placeholderName,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(),
            ),
            controller: widget.nameController,
          ),
        ),
        const SizedBox(width: smallPadding),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.dice),
          tooltip: 'Generate random name',
          onPressed: () {
            widget.nameController.clear();
            FocusScope.of(context).requestFocus(_nameFocusNode);
            setState(() {
              _placeholderName = _generateRandomName();
            });
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: widget.previousRetirements > 0
                      ? () => widget.onRetirementChanged(
                          widget.previousRetirements - 1,
                        )
                      : null,
                ),
                IntrinsicWidth(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Opacity(opacity: 0, child: Text('66')),
                      Text(
                        '${widget.previousRetirements}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: widget.previousRetirements < 99
                      ? () => widget.onRetirementChanged(
                          widget.previousRetirements + 1,
                        )
                      : null,
                ),
              ],
            ),
            Text(
              l10n.retirements,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
