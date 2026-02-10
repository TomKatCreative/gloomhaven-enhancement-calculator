import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/changelog_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/backup_settings_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/debug_settings_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/display_settings_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/gameplay_settings_section.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/settings_helpers.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  final EnhancementCalculatorModel enhancementCalculatorModel;

  const SettingsScreen({super.key, required this.enhancementCalculatorModel});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid,
      child: Scaffold(
        appBar: GHCAppBar(
          title: AppLocalizations.of(context).settings,
          scrollController: scrollController,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              controller: scrollController,
              children: <Widget>[
                GameplaySettingsSection(onSettingsChanged: _onSettingsChanged),
                DisplaySettingsSection(onSettingsChanged: _onSettingsChanged),
                const BackupSettingsSection(),
                const DebugSettingsSection(),
                // Extra padding to scroll content above bottom sheet
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
        bottomSheet: _buildBottomSheet(context),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return FutureBuilder(
      future: _packageInfoFuture,
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return _SettingsBottomSheet(packageInfo: snapshot.data!);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Bottom sheet with support links, social media, and version info.
class _SettingsBottomSheet extends StatelessWidget {
  final PackageInfo packageInfo;

  const _SettingsBottomSheet({required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            theme.navigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: smallPadding),
          Text(l10n.supportAndFeedback, textAlign: TextAlign.center),
          _buildSocialLinks(context),
          if (kDebugMode || (Platform.isAndroid && SharedPrefs().isUSRegion))
            _buildBuyMeCoffeeButton(),
          _buildVersionInfo(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.discord),
          onPressed: () {
            launchURL(
              Uri(scheme: 'https', host: 'discord.gg', path: 'UwuGf4hdnA'),
            );
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram),
          onPressed: () async {
            await launchURL(
              Uri(
                scheme: 'https',
                host: 'instagram.com',
                path: 'tomkatcreative',
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.email),
          onPressed: () => _sendSupportEmail(context),
        ),
      ],
    );
  }

  Future<void> _sendSupportEmail(BuildContext context) async {
    final deviceInfo = await getDeviceInfo();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    final emailBody =
        '''
App Version: $appVersion
Platform: ${Platform.isIOS ? 'iOS' : 'Android'}
  $deviceInfo

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

  Widget _buildBuyMeCoffeeButton() {
    return IconButton(
      icon: const ThemedSvg(assetKey: 'BMC_BUTTON', height: iconSizeXL),
      tooltip: 'Buy Me a Coffee',
      onPressed: () {
        launchURL(
          Uri(
            scheme: 'https',
            host: 'buymeacoffee.com',
            path: '/tomkatcreative',
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final metaStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final linkStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.contrastedPrimary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: smallPadding, right: smallPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('v${packageInfo.version} ', style: metaStyle),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangelogScreen(),
                ),
              );
            },
            child: Text(l10n.changelog, style: linkStyle),
          ),
          Text(' • ', style: metaStyle),
          GestureDetector(
            onTap: () {
              launchURL(
                Uri.parse('https://creativecommons.org/licenses/by-nc-sa/4.0/'),
              );
            },
            child: Text(l10n.license, style: linkStyle),
          ),
        ],
      ),
    );
  }
}
