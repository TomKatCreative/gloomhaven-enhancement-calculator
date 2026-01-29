import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

/// A warning dialog shown when selecting custom/community classes.
///
/// Informs users that custom classes are community-created content and may
/// be subject to change. Includes a link to the Discord server and a
/// "Don't show again" checkbox.
///
/// ## Example Usage
///
/// ```dart
/// final proceed = await CustomClassWarningDialog.show(context);
/// if (proceed == true) {
///   // User accepted the warning
/// }
/// ```
class CustomClassWarningDialog extends StatefulWidget {
  const CustomClassWarningDialog({super.key});

  /// Shows the custom class warning dialog.
  ///
  /// Returns:
  /// - `true` if the user chose to continue
  /// - `false` if the user chose to cancel
  /// - `null` if the dialog was dismissed
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (_) => const CustomClassWarningDialog(),
    );
  }

  @override
  State<CustomClassWarningDialog> createState() =>
      _CustomClassWarningDialogState();
}

class _CustomClassWarningDialogState extends State<CustomClassWarningDialog> {
  bool _hideMessage = SharedPrefs().hideCustomClassesWarningMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Center(
        child: Text('Custom Classes', style: theme.textTheme.headlineLarge),
      ),
      content: Container(
        constraints: const BoxConstraints(
          maxWidth: maxDialogWidth,
          minWidth: maxDialogWidth,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text:
                          "Please note that these classes are created by members of the 'Gloomhaven Custom Content Unity Guild' and are subject to change. Use at your own risk and report any incongruencies to the developer. More information can be found on the ",
                    ),
                    TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      text: 'Discord server',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Uri uri = Uri(
                            scheme: 'https',
                            host: 'discord.gg',
                            path:
                                'gloomhaven-custom-content-unity-guild-728375347732807825',
                          );
                          var urllaunchable = await canLaunchUrl(uri);
                          if (urllaunchable) {
                            await launchUrl(uri);
                          }
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Don't show again",
                    overflow: TextOverflow.visible,
                  ),
                  Checkbox(
                    value: _hideMessage,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SharedPrefs().hideCustomClassesWarningMessage = value;
                          _hideMessage = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text(
            'Continue',
            style: TextStyle(color: theme.contrastedPrimary),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
