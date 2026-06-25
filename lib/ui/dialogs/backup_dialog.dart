import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Result returned from the backup dialog.
class BackupResult {
  /// The type of backup action performed.
  final BackupAction action;

  const BackupResult({required this.action});
}

/// The type of backup action the user chose.
enum BackupAction {
  /// User cancelled the dialog.
  cancelled,

  /// User exported the backup via the share sheet.
  shared,
}

/// A dialog for creating and exporting database backups.
///
/// Exports the backup through the platform share sheet (share_plus), which on
/// iOS includes "Save to Files" and on Android offers save/share targets. This
/// relies only on the document/share APIs — no media-picker SDK — so the app
/// requires no camera/photo/location privacy permissions.
///
/// ## Example Usage
///
/// ```dart
/// await BackupDialog.show(context: context);
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
  bool _isSharing = false;

  bool get _isBusy => _isSharing;

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
    final value = await DatabaseHelper.instance.backupService.generateBackup();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$_fileName');
    await file.writeAsString(value);
    return file.path;
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
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
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
      ],
    );
  }
}
