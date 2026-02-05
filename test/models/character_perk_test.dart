import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

void main() {
  group('CharacterPerk Model', () {
    test('constructor sets all fields', () {
      final perk = CharacterPerk('char-uuid', 'perk-id-1', true);

      expect(perk.associatedCharacterUuid, equals('char-uuid'));
      expect(perk.associatedPerkId, equals('perk-id-1'));
      expect(perk.characterPerkIsSelected, isTrue);
    });

    test('constructor defaults isSelected to false when passed false', () {
      final perk = CharacterPerk('char-uuid', 'perk-id-1', false);

      expect(perk.characterPerkIsSelected, isFalse);
    });

    group('fromMap', () {
      test('parses isSelected=1 as true', () {
        final map = {
          columnAssociatedCharacterUuid: 'char-uuid',
          columnAssociatedPerkId: 'perk-id-1',
          columnCharacterPerkIsSelected: 1,
        };

        final perk = CharacterPerk.fromMap(map);

        expect(perk.associatedCharacterUuid, equals('char-uuid'));
        expect(perk.associatedPerkId, equals('perk-id-1'));
        expect(perk.characterPerkIsSelected, isTrue);
      });

      test('parses isSelected=0 as false', () {
        final map = {
          columnAssociatedCharacterUuid: 'char-uuid',
          columnAssociatedPerkId: 'perk-id-2',
          columnCharacterPerkIsSelected: 0,
        };

        final perk = CharacterPerk.fromMap(map);

        expect(perk.characterPerkIsSelected, isFalse);
      });
    });

    group('toMap', () {
      test('serializes isSelected=true correctly', () {
        final perk = CharacterPerk('char-uuid', 'perk-id-1', true);

        final map = perk.toMap();

        expect(map[columnAssociatedCharacterUuid], equals('char-uuid'));
        expect(map[columnAssociatedPerkId], equals('perk-id-1'));
        expect(map[columnCharacterPerkIsSelected], equals(1));
      });

      test('serializes isSelected=false correctly', () {
        final perk = CharacterPerk('char-uuid', 'perk-id-1', false);

        final map = perk.toMap();

        expect(map[columnCharacterPerkIsSelected], equals(0));
      });
    });

    test('toMap/fromMap round-trip preserves all data', () {
      final original = CharacterPerk('char-uuid', 'perk-id-1', true);

      final map = original.toMap();
      final restored = CharacterPerk.fromMap(map);

      expect(
        restored.associatedCharacterUuid,
        equals(original.associatedCharacterUuid),
      );
      expect(restored.associatedPerkId, equals(original.associatedPerkId));
      expect(
        restored.characterPerkIsSelected,
        equals(original.characterPerkIsSelected),
      );
    });
  });
}
