import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Requests storage permission on iOS. Android returns true immediately.
///
/// Returns true if permission is granted, false otherwise.
Future<bool> getStoragePermission() async {
  if (Platform.isAndroid) {
    return true;
  }
  PermissionStatus permissionStatus = await Permission.storage.request();
  if (permissionStatus.isGranted) {
    return true;
  } else if (permissionStatus.isPermanentlyDenied) {
    await openAppSettings();
  } else if (permissionStatus.isDenied) {
    return false;
  }
  return false;
}

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
              constraints: const BoxConstraints(maxWidth: maxDialogWidth),
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
