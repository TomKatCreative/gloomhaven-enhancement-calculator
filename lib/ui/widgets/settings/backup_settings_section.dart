import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/backup_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/restore_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/settings_section_header.dart';
import 'package:path/path.dart' as p;

/// Settings section for backup and restore functionality.
///
/// Contains:
/// - Backup button (exports database to file)
/// - Restore button (imports database from file)
class BackupSettingsSection extends StatelessWidget {
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsSectionHeader(title: l10n.backupAndRestore),
        ListTile(
          leading: const Icon(Icons.download_rounded),
          title: Text(l10n.backup),
          subtitle: Text(l10n.backupDescription),
          onTap: () => _handleBackup(context, l10n),
        ),
        ListTile(
          leading: const Icon(Icons.upload_rounded),
          title: Text(l10n.restore),
          subtitle: Text(l10n.restoreDescription),
          onTap: () => RestoreDialog.show(context: context),
        ),
      ],
    );
  }

  Future<void> _handleBackup(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await BackupDialog.show(context: context);

    if (result == null) return;

    if (result.action == BackupAction.saved && result.savedPath != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.saved(
                p.basename(result.savedPath!),
                p.dirname(result.savedPath!),
              ),
            ),
          ),
        );
    }
  }
}
