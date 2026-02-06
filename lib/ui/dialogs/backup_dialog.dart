import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  /// User saved the backup.
  saved,
}

/// A dialog for creating and exporting database backups.
///
/// Uses the platform-native save dialog (SAF on Android, file saver on iOS)
/// to let the user choose where to save the backup file. Supports saving to
/// cloud storage providers (Google Drive, Dropbox, OneDrive) if installed.
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

    try {
      final value = await DatabaseHelper.instance.generateBackup();
      final bytes = Uint8List.fromList(utf8.encode(value));
      final fileName = '${_fileNameController.text}.txt';

      final savedPath = await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: bytes,
      );

      if (savedPath == null || !mounted) return;
      Navigator.of(
        context,
      ).pop(BackupResult(action: BackupAction.saved, savedPath: savedPath));
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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      content: Container(
        constraints: const BoxConstraints(maxWidth: maxDialogWidth),
        child: TextField(
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
      ),
      actions: <Widget>[
        TextButton(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.of(
            context,
          ).pop(const BackupResult(action: BackupAction.cancelled)),
        ),
        TextButton(onPressed: _handleSave, child: Text(l10n.save)),
      ],
    );
  }
}
