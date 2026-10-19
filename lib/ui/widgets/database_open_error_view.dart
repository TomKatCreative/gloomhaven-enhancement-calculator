import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/data/database_too_new_exception.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/utils/settings_helpers.dart';
import 'package:share_plus/share_plus.dart';

/// Shown in place of the Characters page when the database can't be opened.
///
/// The file is never deleted on a failed open, so this gives the user a way
/// out: export the raw database and contact the developer. A database from a
/// newer app version ([DatabaseTooNewException]) gets an "update the app"
/// message instead of a generic error.
class DatabaseOpenErrorView extends StatelessWidget {
  const DatabaseOpenErrorView({
    super.key,
    required this.error,
    this.databasePath = DatabaseHelper.databasePath,
  });

  final Object error;

  /// Where the database file lives. Overridable for tests.
  final Future<String> Function() databasePath;

  /// [context] must be the button's own, so the iPad share popover can
  /// anchor to it.
  Future<void> _export(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppLocalizations.of(context).exportDatabaseError;
    try {
      final path = await databasePath();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], sharePositionOrigin: origin),
      );
    } catch (e) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tooNew = error is DatabaseTooNewException;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              tooNew ? Icons.system_update : Icons.error_outline,
              size: iconSizeXL,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: largePadding),
            Text(
              tooNew ? l10n.databaseTooNewTitle : l10n.databaseOpenErrorTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: smallPadding),
            Text(
              tooNew
                  ? l10n.databaseTooNewMessage
                  : l10n.databaseOpenErrorMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: extraLargePadding),
            Builder(
              builder: (buttonContext) => FilledButton.icon(
                onPressed: () => _export(buttonContext),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.exportDatabase),
              ),
            ),
            const SizedBox(height: smallPadding),
            OutlinedButton.icon(
              onPressed: () => sendSupportEmail(details: 'Error: $error'),
              icon: const Icon(Icons.email),
              label: Text(l10n.contactDeveloper),
            ),
            if (!tooNew) ...[
              const SizedBox(height: largePadding),
              ExpansionTile(
                title: Text(l10n.errorDetails),
                children: [SelectableText(error.toString())],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
