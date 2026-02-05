import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

void main() {
  group('CharacterMastery Model', () {
    test('constructor sets all fields', () {
      final mastery = CharacterMastery('char-uuid', 'mastery-id-1', true);

      expect(mastery.associatedCharacterUuid, equals('char-uuid'));
      expect(mastery.associatedMasteryId, equals('mastery-id-1'));
      expect(mastery.characterMasteryAchieved, isTrue);
    });

    test('constructor defaults achieved to false when passed false', () {
      final mastery = CharacterMastery('char-uuid', 'mastery-id-1', false);

      expect(mastery.characterMasteryAchieved, isFalse);
    });

    group('fromMap', () {
      test('parses achieved=1 as true', () {
        final map = {
          columnAssociatedCharacterUuid: 'char-uuid',
          columnAssociatedMasteryId: 'mastery-id-1',
          columnCharacterMasteryAchieved: 1,
        };

        final mastery = CharacterMastery.fromMap(map);

        expect(mastery.associatedCharacterUuid, equals('char-uuid'));
        expect(mastery.associatedMasteryId, equals('mastery-id-1'));
        expect(mastery.characterMasteryAchieved, isTrue);
      });

      test('parses achieved=0 as false', () {
        final map = {
          columnAssociatedCharacterUuid: 'char-uuid',
          columnAssociatedMasteryId: 'mastery-id-2',
          columnCharacterMasteryAchieved: 0,
        };

        final mastery = CharacterMastery.fromMap(map);

        expect(mastery.characterMasteryAchieved, isFalse);
      });
    });

    group('toMap', () {
      test('serializes achieved=true correctly', () {
        final mastery = CharacterMastery('char-uuid', 'mastery-id-1', true);

        final map = mastery.toMap();

        expect(map[columnAssociatedCharacterUuid], equals('char-uuid'));
        expect(map[columnAssociatedMasteryId], equals('mastery-id-1'));
        expect(map[columnCharacterMasteryAchieved], equals(1));
      });

      test('serializes achieved=false correctly', () {
        final mastery = CharacterMastery('char-uuid', 'mastery-id-1', false);

        final map = mastery.toMap();

        expect(map[columnCharacterMasteryAchieved], equals(0));
      });
    });

    test('toMap/fromMap round-trip preserves all data', () {
      final original = CharacterMastery('char-uuid', 'mastery-id-1', true);

      final map = original.toMap();
      final restored = CharacterMastery.fromMap(map);

      expect(
        restored.associatedCharacterUuid,
        equals(original.associatedCharacterUuid),
      );
      expect(
        restored.associatedMasteryId,
        equals(original.associatedMasteryId),
      );
      expect(
        restored.characterMasteryAchieved,
        equals(original.characterMasteryAchieved),
      );
    });
  });
}
