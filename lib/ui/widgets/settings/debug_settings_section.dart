import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
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
              _createTestCharacters(charactersModel, includeAllVariants: true),
        ),
        ListTile(
          title: Text(l10n.gloomhaven),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.gloomhaven,
          ),
        ),
        ListTile(
          title: Text('${l10n.gloomhaven} ${l10n.andVariants}'),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.gloomhaven,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.frosthaven),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.frosthaven,
          ),
        ),
        ListTile(
          title: Text('${l10n.frosthaven} ${l10n.andVariants}'),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.frosthaven,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.crimsonScales),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.crimsonScales,
          ),
        ),
        ListTile(
          title: Text('${l10n.crimsonScales} ${l10n.andVariants}'),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.crimsonScales,
            includeAllVariants: true,
          ),
        ),
        ListTile(
          title: Text(l10n.custom),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.custom,
          ),
        ),
        ListTile(
          title: Text('${l10n.custom} ${l10n.andVariants}'),
          onTap: () => _createTestCharacters(
            charactersModel,
            classCategory: ClassCategory.custom,
            includeAllVariants: true,
          ),
        ),
      ],
    );
  }

  /// Creates test characters with random attributes for debugging.
  static Future<void> _createTestCharacters(
    CharactersModel charactersModel, {
    ClassCategory? classCategory,
    bool includeAllVariants = false,
  }) async {
    final random = Random();

    final playerClassesToCreate = classCategory == null
        ? PlayerClasses.playerClasses
        : PlayerClasses.playerClasses.where(
            (element) => element.category == classCategory,
          );

    for (PlayerClass playerClass in playerClassesToCreate) {
      if (includeAllVariants) {
        final availableVariants = _getAvailableVariants(playerClass);

        for (Variant variant in availableVariants) {
          final variantName = _getVariantDisplayName(playerClass.name, variant);

          await charactersModel.createCharacter(
            variantName,
            playerClass,
            initialLevel: random.nextInt(9) + 1,
            previousRetirements: random.nextInt(4),
            edition: GameEdition.values[random.nextInt(3)],
            prosperityLevel: random.nextInt(5),
            variant: variant,
          );
        }
      } else {
        await charactersModel.createCharacter(
          playerClass.name,
          playerClass,
          initialLevel: random.nextInt(9) + 1,
          previousRetirements: random.nextInt(4),
          edition: GameEdition.values[random.nextInt(3)],
          prosperityLevel: random.nextInt(5),
        );
      }
    }
  }

  static List<Variant> _getAvailableVariants(PlayerClass playerClass) {
    final perksForClass = PerksRepository.perksMap[playerClass.classCode];
    if (perksForClass == null || perksForClass.isEmpty) {
      return [Variant.base];
    }
    return perksForClass.map((perks) => perks.variant).toSet().toList();
  }

  static String _getVariantDisplayName(String className, Variant variant) {
    switch (variant) {
      case Variant.base:
        return className;
      case Variant.frosthavenCrossover:
        return '$className (FH)';
      case Variant.gloomhaven2E:
        return '$className (GH2E)';
      default:
        return '$className (${variant.name})';
    }
  }
}
