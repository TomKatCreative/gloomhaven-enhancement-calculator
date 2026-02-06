import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/utils/settings_helpers.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';

/// Handles the database restore flow including confirmation, file picking,
/// and the actual restore operation.
///
/// This is not a traditional dialog widget but a utility class that manages
/// the entire restore workflow.
///
/// ## Example Usage
///
/// ```dart
/// await RestoreDialog.show(context: context);
/// // If successful, the characters model will be reloaded
/// ```
class RestoreDialog {
  RestoreDialog._();

  /// Shows the restore confirmation dialog and handles the restore process.
  ///
  /// The flow is:
  /// 1. Show warning dialog asking for confirmation
  /// 2. Request storage permission (iOS only)
  /// 3. Open file picker to select backup file
  /// 4. Show loading dialog while restoring
  /// 5. Restore the database and reload characters
  /// 6. Show error dialog if restore fails
  static Future<void> show({required BuildContext context}) async {
    final confirmed = await _showConfirmationDialog(context);
    if (confirmed != true) return;
    if (!context.mounted) return;

    await _handleFilePicker(context);
  }

  static Future<bool?> _showConfirmationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            constraints: const BoxConstraints(maxWidth: maxDialogWidth),
            child: Text(l10n.restoreWarning),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(l10n.continue_),
              onPressed: () async {
                if (!await getStoragePermission()) {
                  return;
                }
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _handleFilePicker(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['json', 'txt'],
    );

    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;

    File file = File(path);
    String contents = file.readAsStringSync();

    if (!context.mounted) return;
    await _performRestore(context, contents);
  }

  static Future<void> _performRestore(
    BuildContext context,
    String contents,
  ) async {
    showLoaderDialog(context);

    try {
      await DatabaseHelper.instance.restoreBackup(contents);
      SharedPrefs().initialPage = 0;
      if (!context.mounted) return;

      // Refresh theme from restored SharedPrefs
      final prefs = SharedPrefs();
      context.read<ThemeProvider>().updateThemeConfig(
        ThemeConfig(
          seedColor: Color(prefs.primaryClassColor),
          useDarkMode: prefs.darkTheme,
          useDefaultFonts: prefs.useDefaultFonts,
        ),
      );

      // Refresh calculator model from restored SharedPrefs
      context.read<EnhancementCalculatorModel>().reloadFromPrefs();

      // Sync showRetired with restored value
      final charactersModel = context.read<CharactersModel>();
      if (charactersModel.showRetired != prefs.showRetiredCharacters) {
        charactersModel.showRetired = prefs.showRetiredCharacters;
      }

      await charactersModel.loadCharacters();
      if (!context.mounted) return;
      context.read<CharactersModel>().jumpToPage(0);
    } catch (e) {
      if (!context.mounted) return;
      await _showErrorDialog(context, e);
    }

    if (!context.mounted) return;
    // Pop the loader dialog
    Navigator.of(context).pop();
    // Pop the settings screen (restore successful)
    Navigator.of(context).pop();
  }

  static Future<void> _showErrorDialog(
    BuildContext context,
    Object error,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.errorDuringRestore,
            style: theme.textTheme.headlineLarge,
          ),
          actions: [
            TextButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: error.toString())),
              icon: const Icon(Icons.copy),
              label: Text(l10n.copy),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
          content: Container(
            constraints: const BoxConstraints(maxWidth: maxDialogWidth),
            child: SingleChildScrollView(
              child: Text(l10n.restoreErrorMessage(error.toString())),
            ),
          ),
        );
      },
    );
  }
}
