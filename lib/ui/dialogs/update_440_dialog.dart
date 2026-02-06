import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

class Update440Dialog extends StatefulWidget {
  const Update440Dialog({super.key});

  @override
  State<Update440Dialog> createState() => _Update440DialogState();
}

class _Update440DialogState extends State<Update440Dialog> {
  @override
  void initState() {
    super.initState();
    // Mark the dialog as shown so it won't appear again
    SharedPrefs().showUpdate440Dialog = false;
  }

  @override
  Widget build(BuildContext context) {
    final showBuyMeACoffee =
        kDebugMode || (Platform.isAndroid && SharedPrefs().isUSRegion);

    return AlertDialog(
      title: Text(
        'Version 4.4.0',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The backup system now includes all app data. Creating a new backup now is strongly recommended. Note that backups created before version 4.2.0 can no longer be restored.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Many UI, quality of life, and performance improvements.',
            ),
            const SizedBox(height: 12),
            Text(
              showBuyMeACoffee
                  ? "If you enjoy using this app, please consider supporting it through the 'Buy Me a Coffee' link in the Settings screen or by leaving a review!"
                  : 'If you enjoy using this app, please consider leaving a review!',
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
