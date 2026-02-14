import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

class Update450Dialog extends StatefulWidget {
  const Update450Dialog({super.key});

  @override
  State<Update450Dialog> createState() => _Update450DialogState();
}

class _Update450DialogState extends State<Update450Dialog> {
  @override
  void initState() {
    super.initState();
    // Mark the dialog as shown so it won't appear again
    SharedPrefs().showUpdate450Dialog = false;
  }

  @override
  Widget build(BuildContext context) {
    final showBuyMeACoffee =
        kDebugMode || (Platform.isAndroid && SharedPrefs().isUSRegion);

    return AlertDialog(
      title: Text(
        'Version 4.5.0',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• You can now assign Gloomhaven personal quests to new and existing characters. Currently only Gloomhaven, but Frosthaven, Gloomhaven 2nd Edition, and Crimson Scales coming soon!',
            ),
            const SizedBox(height: 12),
            const Text(
              '• As of v4.4.0, the backup system includes all app data. Note that backups created before version 4.2.0 can no longer be restored.',
            ),
            const SizedBox(height: 12),
            const Text('• UI overhaul of the whole app.'),
            const SizedBox(height: 12),
            Text(
              showBuyMeACoffee
                  ? "• If you enjoy using this app, please consider supporting its development through the 'Buy Me a Coffee' link in the Settings screen, or by leaving a review! ✨"
                  : '• If you enjoy using this app, please consider leaving a review! ✨',
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
