import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/settings/settings_section_header.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Debug settings section for testing purposes.
///
/// Only displayed when running in debug mode (kDebugMode).
/// Contains buttons to quickly create test characters for each class category.
class DebugSettingsSection extends StatelessWidget {
  const DebugSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final charactersModel = context.read<CharactersModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsSectionHeader(title: l10n.testing),
        ListTile(
          title: Text(l10n.createAll),
          onTap: () =>
              charactersModel.createCharactersTest(includeAllVariants: true),
        ),
        ListTile(
          title: Text(l10n.gloomhaven),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.gloomhaven,
          ),
        ),
        ListTile(
          title: Text('${l10n.gloomhaven} ${l10n.andVariants}'),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.gloomhaven,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.frosthaven),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.frosthaven,
          ),
        ),
        ListTile(
          title: Text('${l10n.frosthaven} ${l10n.andVariants}'),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.frosthaven,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.crimsonScales),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.crimsonScales,
          ),
        ),
        ListTile(
          title: Text('${l10n.crimsonScales} ${l10n.andVariants}'),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.crimsonScales,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.custom),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.custom,
          ),
        ),
        ListTile(
          title: Text('${l10n.custom} ${l10n.andVariants}'),
          onTap: () => charactersModel.createCharactersTest(
            classCategory: ClassCategory.custom,
            includeAllVariants: true,
          ),
        ),
      ],
    );
  }
}
