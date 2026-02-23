import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_parser.dart';
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';

/// Callback that returns the left-side widgets (checkboxes + divider/spacer).
/// Receives the measured content height for CheckRowDivider sizing.
typedef LeadingBuilder = List<Widget> Function(double contentHeight);

class CheckableRow extends StatefulWidget {
  final String details;
  final LeadingBuilder leadingBuilder;

  const CheckableRow({
    super.key,
    required this.details,
    required this.leadingBuilder,
  });

  @override
  State<CheckableRow> createState() => _CheckableRowState();
}

class _CheckableRowState extends State<CheckableRow> {
  double _height = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        children: <Widget>[
          ...widget.leadingBuilder(_height),
          SizeProviderWidget(
            onChildSize: (Size? size) {
              if (size != null && context.mounted) {
                setState(() {
                  _height = size.height * 0.9;
                });
              }
            },
            child: Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: GameTextParser.parse(
                    context,
                    widget.details,
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
