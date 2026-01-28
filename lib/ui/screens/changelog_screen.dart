import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Column(
                children: [
                  Text(AppLocalizations.of(context).changelog),
                  if (snapshot.hasData)
                    Text(
                      kDebugMode
                          ? 'v${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                          : 'v${snapshot.data!.version}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              );
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _VersionSection(
              version: '4.3.3',
              date: '2026-01-27',
              changes: [
                'UI overhaul of Enhancement Calculator.',
                'Added cost breakdown details.',
              ],
            ),
            const SizedBox(height: 24),
            const _VersionSection(
              version: '4.3.2',
              date: '2026-01-18',
              changes: ['Added Alchemancer class.'],
            ),
            const SizedBox(height: 24),
            _VersionSection(
              version: '4.3.1',
              date: '2026-01-17',
              changes: [
                'Added Gloomhaven 2nd Edition mode to the Enhancement Calculator.',
                'Move "Scenario 114 Reward" and "Building 44" toggles to Enhancement Calculator page.',
                'Added device information to email feedback pre-populated body text.',
              ],
            ),
            const SizedBox(height: 24),
            _VersionSection(
              version: '4.3.0',
              date: '2026-01-11',
              changes: [
                'Added all Gloomhaven 2nd Edition unlockable classes.',
                'Added Mercenary Pack classes.',
                '⚠️ Some icons still unavailable for some GH2E and Mercenary Pack classes. Will update when they become available.',
                'Added "Hail\'s Discount" option to Enhancement Calculator.',
                if (Platform.isAndroid)
                  '(US based Android users only) Added "Buy me a Coffee" link to the Settings screen for donations (no added perks or features - just a way to show support)',
              ],
            ),
            const SizedBox(height: 24),
            const _VersionSection(
              version: '4.2.2',
              date: '2025-10-16',
              changes: [
                'Added all Gloomhaven 2nd Edition starter classes (locked classes coming soon).',
              ],
            ),
            const SizedBox(height: 24),
            const _VersionSection(
              version: '4.2.1',
              date: '2025-10-06',
              changes: [
                'Added Vimthreader, DOME, CORE, and Skitterclaw custom classes from CCUG.',
              ],
            ),
            const SizedBox(height: 24),
            const _VersionSection(
              version: '4.2.0',
              date: '2025-06-19',
              changes: [
                'Added all Frosthaven variants of Gloomhaven and JotL classes (Crimson Scales coming soon).',
                'Corrected an error present in the "Astral" class perk list.',
                '⚠️ Breaking database migration: backups created before version 4.2.0 can no longer be restored.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionSection extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;

  const _VersionSection({
    required this.version,
    required this.date,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'v$version',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...changes.map(
          (change) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(change)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
