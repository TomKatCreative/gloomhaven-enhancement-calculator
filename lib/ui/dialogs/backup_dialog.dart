import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Result returned from the backup dialog.
class BackupResult {
  /// The type of backup action performed.
  final BackupAction action;

  /// The user-entered filename (only for [BackupAction.saved]).
  final String? savedFilename;

  const BackupResult({required this.action, this.savedFilename});
}

/// The type of backup action the user chose.
enum BackupAction {
  /// User cancelled the dialog.
  cancelled,

  /// User saved the backup to device storage.
  saved,

  /// User shared the backup via the share sheet.
  shared,
}

/// A dialog for creating and exporting database backups.
///
/// Offers two export options:
/// - **Save**: Opens the platform-native save picker (SAF on Android, file
///   saver on iOS) to let the user choose where to save. Supports cloud
///   storage providers if installed.
/// - **Share**: Opens the platform share sheet to send the file via email,
///   cloud storage, messaging, etc.
///
/// ## Example Usage
///
/// ```dart
/// final result = await BackupDialog.show(context: context);
///
/// if (result?.action == BackupAction.saved) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Saved ${result.savedFilename}')),
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
  bool _isSaving = false;
  bool _isSharing = false;

  bool get _isBusy => _isSaving || _isSharing;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: 'ghc_backup');
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  bool _validateFilename() {
    if (_fileNameController.text.trim().isEmpty) {
      setState(() {
        _filenameError = 'Cannot be empty';
      });
      return false;
    }
    return true;
  }

  String get _fileName => '${_fileNameController.text}.json';

  Future<String> _generateBackupFile() async {
    final value = await DatabaseHelper.instance.generateBackup();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$_fileName');
    await file.writeAsString(value);
    return file.path;
  }

  Future<void> _handleSave() async {
    if (!_validateFilename()) return;

    setState(() => _isSaving = true);
    try {
      final value = await DatabaseHelper.instance.generateBackup();
      final bytes = Uint8List.fromList(utf8.encode(value));

      final savedPath = await FilePicker.platform.saveFile(
        fileName: _fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (savedPath == null || !mounted) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }
      Navigator.of(
        context,
      ).pop(BackupResult(action: BackupAction.saved, savedFilename: _fileName));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupError)),
        );
    }
  }

  Future<void> _handleShare() async {
    if (!_validateFilename()) return;

    setState(() => _isSharing = true);
    try {
      final filePath = await _generateBackupFile();

      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(const BackupResult(action: BackupAction.shared));

      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSharing = false);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupIncludes,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: largePadding),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.filename,
                errorText: _filenameError,
                suffixText: '.json',
              ),
              textAlign: TextAlign.end,
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
          onPressed: _isBusy
              ? null
              : () => Navigator.of(
                  context,
                ).pop(const BackupResult(action: BackupAction.cancelled)),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _isBusy ? null : _handleShare,
          child: _isSharing
              ? const SizedBox.square(
                  dimension: iconSizeSmall,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.share),
        ),
        TextButton(
          onPressed: _isBusy ? null : _handleSave,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: iconSizeSmall,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
