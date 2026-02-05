import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/utils/settings_helpers.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Result returned from the backup dialog.
class BackupResult {
  /// The type of backup action performed.
  final BackupAction action;

  /// The path where the backup was saved (only for [BackupAction.saved]).
  final String? savedPath;

  const BackupResult({required this.action, this.savedPath});
}

/// The type of backup action the user chose.
enum BackupAction {
  /// User cancelled the dialog.
  cancelled,

  /// User saved the backup to device storage (Android only).
  saved,

  /// User saved the backup to a custom location.
  custom,
}

/// A dialog for creating and exporting database backups.
///
/// On Android, offers "Save" (to Downloads or custom path) and "Choose location".
/// On iOS, offers "Choose location" to select where to save.
///
/// ## Example Usage
///
/// ```dart
/// final result = await BackupDialog.show(context: context);
///
/// if (result?.action == BackupAction.saved) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Saved to ${result.savedPath}')),
///   );
/// }
/// ```
class BackupDialog extends StatefulWidget {
  const BackupDialog({super.key});

  /// Shows the backup dialog and handles the backup process.
  ///
  /// Returns a [BackupResult] indicating what action was taken,
  /// or null if the dialog was dismissed.
  static Future<BackupResult?> show({required BuildContext context}) async {
    return showDialog<BackupResult?>(
      context: context,
      builder: (_) => const BackupDialog(),
    );
  }

  @override
  State<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  late final TextEditingController _fileNameController;
  String? _filenameError;

  @override
  void initState() {
    super.initState();
    final defaultName =
        'ghc_backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}';
    _fileNameController = TextEditingController(text: defaultName);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  bool _validateFilename() {
    if (_fileNameController.text.trim().isEmpty) {
      setState(() {
        _filenameError = 'Filename cannot be empty';
      });
      return false;
    }
    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateFilename()) return;

    if (!await getStoragePermission()) {
      return;
    }

    try {
      String value = await DatabaseHelper.instance.generateBackup();

      // Check if user has a custom backup path saved
      final customPath = SharedPrefs().customBackupPath;
      Directory? targetDir;

      if (customPath != null && await Directory(customPath).exists()) {
        targetDir = Directory(customPath);
      } else {
        // Use platform-independent path - getDownloadsDirectory() works on
        // Android, falls back to external storage if unavailable
        targetDir = await getDownloadsDirectory();
        targetDir ??= await getExternalStorageDirectory();
      }

      if (targetDir == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).backupError)),
          );
        return;
      }

      final downloadPath = targetDir.path;
      File backupFile = File('$downloadPath/${_fileNameController.text}.txt');
      await backupFile.writeAsString(value);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(BackupResult(action: BackupAction.saved, savedPath: downloadPath));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupError)),
        );
    }
  }

  Future<bool> _showFolderAccessExplanation() async {
    if (!Platform.isAndroid) return true;

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.folderAccessTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.folderAccessExplanation),
            const SizedBox(height: mediumPadding),
            Text(
              l10n.folderAccessTip,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.continue_),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleChooseLocation() async {
    if (!_validateFilename()) return;

    if (!await getStoragePermission()) {
      return;
    }

    // Show explanation dialog before SAF picker
    if (!await _showFolderAccessExplanation()) {
      return;
    }

    try {
      // Let user pick a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User cancelled the picker
        return;
      }

      // Save the backup to the selected location
      String value = await DatabaseHelper.instance.generateBackup();
      File backupFile = File(
        '$selectedDirectory/${_fileNameController.text}.txt',
      );
      await backupFile.writeAsString(value);

      // Save this path as the new default for future backups
      SharedPrefs().customBackupPath = selectedDirectory;

      if (!mounted) return;
      Navigator.of(context).pop(
        BackupResult(action: BackupAction.custom, savedPath: selectedDirectory),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupError)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Platform.isAndroid ? const Icon(Icons.warning_rounded) : null,
      content: Container(
        constraints: const BoxConstraints(maxWidth: maxDialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid) ...[
              Text(l10n.backupFileWarning),
              const SizedBox(height: smallPadding),
            ],
            TextField(
              decoration: InputDecoration(
                labelText: l10n.filename,
                errorText: _filenameError,
              ),
              controller: _fileNameController,
              onChanged: (_) {
                if (_filenameError != null) {
                  setState(() => _filenameError = null);
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(
                    '[\\#|\\<|\\>|\\+|\\\$|\\%|\\!|\\`|\\&|\\*|\\\'|\\||\\}|\\{|\\?|\\"|\\=|\\/|\\:|\\\\|\\ |\\@]',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.of(
            context,
          ).pop(const BackupResult(action: BackupAction.cancelled)),
        ),
        if (Platform.isAndroid)
          TextButton.icon(
            icon: Icon(MdiIcons.contentSave, color: theme.colorScheme.primary),
            label: Text(l10n.save),
            onPressed: _handleSave,
          ),
        TextButton.icon(
          icon: Icon(MdiIcons.folderOpen, color: theme.colorScheme.primary),
          label: const Text('Choose location...'),
          onPressed: _handleChooseLocation,
        ),
      ],
    );
  }
}
