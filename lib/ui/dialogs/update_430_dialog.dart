import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

class Update430Dialog extends StatelessWidget {
  const Update430Dialog({super.key});

  @override
  Widget build(BuildContext context) {
    SharedPrefs().showUpdate430Dialog = false;
    return AlertDialog(
      title: Text(
        'New in version 4.3.0',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (SharedPrefs().showUpdate420Dialog)
              Text(
                '• ⚠️ A necessary database migration means you cannot restore backups created before version 4.2.0. Please create a new backup now to replace any existing ones.',
              ),
            Text(
              '• Added all remaining Gloomhaven Second Edition and Mercenary Pack classes.',
            ),
            if (SharedPrefs().isUSRegion)
              Text('• Added a "Buy me a Coffee" link in the Settings screen.'),
            Text(
              '• Changelog and license link added to the bottom of the Settings screen.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}
