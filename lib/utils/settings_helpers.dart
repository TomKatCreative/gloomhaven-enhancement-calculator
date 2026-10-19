import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a loading dialog with a progress indicator during restore operations.
void showLoaderDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.dialogMaxWidth(context),
              ),
              margin: const EdgeInsets.only(left: smallPadding),
              child: Text(AppLocalizations.of(context).restoring),
            ),
          ],
        ),
      );
    },
  );
}

/// Launches a URL in an external application.
Future<void> launchURL(Uri uri) async => await canLaunchUrl(uri)
    ? await launchUrl(uri, mode: LaunchMode.externalApplication)
    : await launchUrl(uri);

/// Opens a support email to the developer, prefilled with the app version
/// and device info. [details] (e.g. an error) is added below them.
Future<void> sendSupportEmail({String? details}) async {
  final deviceInfo = await getDeviceInfo();
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

  final emailBody =
      '''
App Version: $appVersion
Platform: ${Platform.isIOS ? 'iOS' : 'Android'}
  $deviceInfo
${details == null ? '' : '\n$details\n'}
--- Please describe your issue or provide your feedback below ---

''';

  await launchURL(
    Uri.parse(
      'mailto:tomkatcreative@gmail.com'
      '?subject=${Uri.encodeComponent('GHC Support & Feedback')}'
      '&body=${Uri.encodeComponent(emailBody)}',
    ),
  );
}

/// Gets device information for support emails.
///
/// Returns a formatted string with device model and OS version.
Future<String> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return 'Device: ${iosInfo.utsname.machine}\n'
        'OS Version: iOS ${iosInfo.systemVersion}';
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return 'Device: ${androidInfo.manufacturer} ${androidInfo.model}\n'
        'OS Version: Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
  }

  return 'Device: Unknown';
}
