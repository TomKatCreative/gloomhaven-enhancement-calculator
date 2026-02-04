import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/settings_section_header.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Settings section for display preferences.
///
/// Contains:
/// - Dark mode toggle
/// - Font preference toggle (Inter vs custom fonts)
/// - Show retired characters toggle
class DisplaySettingsSection extends StatelessWidget {
  const DisplaySettingsSection({super.key, required this.onSettingsChanged});

  /// Callback triggered when any setting in this section changes.
  final VoidCallback onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final charactersModel = context.read<CharactersModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsSectionHeader(title: AppLocalizations.of(context).display),
        Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              outline: Colors.transparent,
            ),
          ),
          child: SwitchListTile(
            secondary: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            title: Text(AppLocalizations.of(context).brightness),
            subtitle: Text(
              theme.brightness == Brightness.dark
                  ? AppLocalizations.of(context).dark
                  : AppLocalizations.of(context).light,
            ),
            activeThumbImage: const AssetImage('images/elements/elem_dark.png'),
            activeThumbColor: const Color(0xff1f272e),
            inactiveThumbColor: const Color(0xffeda50b),
            inactiveTrackColor: const Color(0xffeda50b).withValues(alpha: 0.75),
            activeTrackColor: const Color(0xff1f272e),
            inactiveThumbImage: const AssetImage(
              'images/elements/elem_light.png',
            ),
            value: themeProvider.useDarkMode,
            onChanged: (val) {
              context.read<ThemeProvider>().updateDarkMode(val);
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.font_download_rounded),
          title: Text(AppLocalizations.of(context).useInterFont),
          subtitle: Text(AppLocalizations.of(context).useInterFontDescription),
          value: themeProvider.useDefaultFonts,
          onChanged: (val) {
            context.read<ThemeProvider>().updateDefaultFonts(val);
          },
        ),
        SwitchListTile(
          secondary: Icon(
            charactersModel.showRetired
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
          ),
          title: Text(AppLocalizations.of(context).showRetiredCharacters),
          subtitle: Text(
            AppLocalizations.of(context).showRetiredCharactersDescription,
          ),
          value: charactersModel.showRetired,
          onChanged: (val) {
            context.read<CharactersModel>().toggleShowRetired();
            onSettingsChanged();
          },
        ),
      ],
    );
  }
}
