import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';

void main() {
  group('PerksRepository ID stability', () {
    test('all perk numbers are unique within each class+variant group', () {
      for (final entry in PerksRepository.perksMap.entries) {
        final classCode = entry.key;
        for (final perksGroup in entry.value) {
          final numbers = perksGroup.perks.map((p) => p.number).toList();
          final unique = numbers.toSet();
          expect(
            unique.length,
            numbers.length,
            reason:
                '$classCode/${perksGroup.variant.name} has duplicate perk numbers: '
                '${numbers.where((n) => numbers.where((m) => m == n).length > 1).toSet()}',
          );
        }
      }
    });

    test('all generated perk IDs are unique within each class+variant', () {
      for (final entry in PerksRepository.perksMap.entries) {
        final classCode = entry.key;
        for (final perksGroup in entry.value) {
          final perks = PerksRepository.getPerksForCharacter(
            classCode,
            perksGroup.variant,
          );
          final ids = perks.map((p) => p.perkId).toList();
          final unique = ids.toSet();
          expect(
            unique.length,
            ids.length,
            reason:
                '$classCode/${perksGroup.variant.name} has duplicate perk IDs',
          );
        }
      }
    });

    test('perk IDs follow expected format', () {
      final idPattern = RegExp(r'^[a-z]+_[a-zA-Z0-9]+_\d{2}[a-z]$');
      for (final entry in PerksRepository.perksMap.entries) {
        final classCode = entry.key;
        for (final perksGroup in entry.value) {
          final perks = PerksRepository.getPerksForCharacter(
            classCode,
            perksGroup.variant,
          );
          for (final perk in perks) {
            expect(
              idPattern.hasMatch(perk.perkId),
              isTrue,
              reason:
                  '$classCode/${perksGroup.variant.name}: '
                  'perk ID "${perk.perkId}" does not match expected format '
                  '{classCode}_{variant}_{NN}{letter}',
            );
          }
        }
      }
    });

    test('every class has at least one variant with perks', () {
      for (final entry in PerksRepository.perksMap.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: '${entry.key} has no perk groups',
        );
        for (final perksGroup in entry.value) {
          expect(
            perksGroup.perks,
            isNotEmpty,
            reason:
                '${entry.key}/${perksGroup.variant.name} has empty perk list',
          );
        }
      }
    });
  });

  group('MasteriesRepository ID stability', () {
    test('all mastery numbers are unique within each class+variant group', () {
      for (final entry in MasteriesRepository.masteriesMap.entries) {
        final classCode = entry.key;
        for (final masteriesGroup in entry.value) {
          final numbers = masteriesGroup.masteries
              .map((m) => m.number)
              .toList();
          final unique = numbers.toSet();
          expect(
            unique.length,
            numbers.length,
            reason:
                '$classCode/${masteriesGroup.variant.name} has duplicate mastery numbers: '
                '${numbers.where((n) => numbers.where((m) => m == n).length > 1).toSet()}',
          );
        }
      }
    });

    test('all generated mastery IDs are unique within each class+variant', () {
      for (final entry in MasteriesRepository.masteriesMap.entries) {
        final classCode = entry.key;
        for (final masteriesGroup in entry.value) {
          final masteries = MasteriesRepository.getMasteriesForCharacter(
            classCode,
            masteriesGroup.variant,
          );
          final ids = masteries.map((m) => m.id).toList();
          final unique = ids.toSet();
          expect(
            unique.length,
            ids.length,
            reason:
                '$classCode/${masteriesGroup.variant.name} has duplicate mastery IDs',
          );
        }
      }
    });

    test('mastery IDs follow expected format', () {
      final idPattern = RegExp(r'^[a-z]+_[a-zA-Z0-9]+_\d+$');
      for (final entry in MasteriesRepository.masteriesMap.entries) {
        final classCode = entry.key;
        for (final masteriesGroup in entry.value) {
          final masteries = MasteriesRepository.getMasteriesForCharacter(
            classCode,
            masteriesGroup.variant,
          );
          for (final mastery in masteries) {
            expect(
              idPattern.hasMatch(mastery.id),
              isTrue,
              reason:
                  '$classCode/${masteriesGroup.variant.name}: '
                  'mastery ID "${mastery.id}" does not match expected format '
                  '{classCode}_{variant}_{number}',
            );
          }
        }
      }
    });

    test('every class has at least one variant with masteries', () {
      for (final entry in MasteriesRepository.masteriesMap.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: '${entry.key} has no mastery groups',
        );
        for (final masteriesGroup in entry.value) {
          expect(
            masteriesGroup.masteries,
            isNotEmpty,
            reason:
                '${entry.key}/${masteriesGroup.variant.name} has empty mastery list',
          );
        }
      }
    });
  });

  group('Cross-repository consistency', () {
    test('every class in perksMap also exists in masteriesMap', () {
      for (final classCode in MasteriesRepository.masteriesMap.keys) {
        expect(
          PerksRepository.perksMap.containsKey(classCode),
          isTrue,
          reason: '$classCode exists in masteriesMap but not in perksMap',
        );
      }
    });

    test('mastery variants have matching perk variants for all classes', () {
      for (final entry in MasteriesRepository.masteriesMap.entries) {
        final classCode = entry.key;
        final masteryVariants = entry.value.map((m) => m.variant).toSet();
        final perkGroups = PerksRepository.perksMap[classCode];
        expect(
          perkGroups,
          isNotNull,
          reason: '$classCode has masteries but no perks',
        );
        final perkVariants = perkGroups!.map((p) => p.variant).toSet();
        for (final variant in masteryVariants) {
          expect(
            perkVariants.contains(variant),
            isTrue,
            reason:
                '$classCode has masteries for ${variant.name} but no perks for that variant',
          );
        }
      }
    });
  });
}
