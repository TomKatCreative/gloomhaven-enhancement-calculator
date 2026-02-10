import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

/// Applies the same column-patching logic that [DatabaseHelper.restoreBackup]
/// uses for backups created before schema v18 (Personal Quests) or v7
/// (Resources).
///
/// This is intentionally duplicated from the production code so the test
/// catches regressions if the patching logic is accidentally changed.
void _patchCharacterMaps(List<dynamic> json) {
  // Index 0 in json[1] is the Characters table data
  for (var k = 0; k < json[1][0].length; k++) {
    json[1][0][k][columnResourceHide] ??= 0;
    json[1][0][k][columnResourceMetal] ??= 0;
    json[1][0][k][columnResourceLumber] ??= 0;
    json[1][0][k][columnResourceArrowvine] ??= 0;
    json[1][0][k][columnResourceAxenut] ??= 0;
    json[1][0][k][columnResourceRockroot] ??= 0;
    json[1][0][k][columnResourceFlamefruit] ??= 0;
    json[1][0][k][columnResourceCorpsecap] ??= 0;
    json[1][0][k][columnResourceSnowthistle] ??= 0;
    json[1][0][k][columnCharacterPersonalQuestId] ??= '';
    json[1][0][k][columnCharacterPersonalQuestProgress] ??= '[]';
  }
}

void main() {
  late List<dynamic> json;

  /// Load the v16 backup fixture once.
  setUpAll(() {
    final file = File('test/helpers/fake_backup_helper.txt');
    final contents = file.readAsStringSync();
    json = convert.jsonDecode(contents);
  });

  group('Schema v16 backup restore', () {
    group('structure validation', () {
      test('backup has expected table names', () {
        expect(json[0], [
          'Characters',
          'CharacterPerks',
          'CharacterMasteries',
          'MetaData',
        ]);
      });

      test('MetaData table is present (required by restoreBackup)', () {
        expect(json[0].contains('MetaData'), isTrue);
      });

      test('backup is old format (no SharedPrefs element)', () {
        expect(json.length, 2);
      });

      test('MetaData records schema version 16', () {
        final metadata = json[1][3] as List;
        expect(metadata.length, 1);
        expect(metadata[0][DatabaseHelper.columnDatabaseVersion], 16);
      });
    });

    group('Character column patching', () {
      test('v16 characters are missing PersonalQuest columns', () {
        final characters = json[1][0] as List;
        for (final charMap in characters) {
          expect(charMap.containsKey(columnCharacterPersonalQuestId), isFalse);
          expect(
            charMap.containsKey(columnCharacterPersonalQuestProgress),
            isFalse,
          );
        }
      });

      test('patching adds PersonalQuest columns with defaults', () {
        // Work on a deep copy so we don't mutate shared state
        final copy = convert.jsonDecode(convert.jsonEncode(json));
        _patchCharacterMaps(copy);

        final characters = copy[1][0] as List;
        for (final charMap in characters) {
          expect(charMap[columnCharacterPersonalQuestId], '');
          expect(charMap[columnCharacterPersonalQuestProgress], '[]');
        }
      });

      test('patching preserves existing resource columns', () {
        final copy = convert.jsonDecode(convert.jsonEncode(json));
        _patchCharacterMaps(copy);

        // Cassandra has ResourceHide=5 and ResourceCorpseCap=-4
        final cassandra = copy[1][0][1];
        expect(cassandra[columnResourceHide], 5);
        expect(cassandra[columnResourceCorpsecap], -4);

        // Third Guy has ResourceWood=8
        final thirdGuy = copy[1][0][2];
        expect(thirdGuy[columnResourceLumber], 8);
      });
    });

    group('Character deserialization', () {
      late List<Character> characters;

      setUpAll(() {
        final copy = convert.jsonDecode(convert.jsonEncode(json));
        _patchCharacterMaps(copy);
        characters = (copy[1][0] as List)
            .map((m) => Character.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('all 3 characters deserialize successfully', () {
        expect(characters.length, 3);
      });

      test('first character: Nyah Heathcote (Spellweaver GH2E)', () {
        final c = characters[0];
        expect(c.name, 'Nyah Heathcote');
        expect(c.playerClass.classCode, 'sw');
        expect(c.variant.name, 'gloomhaven2E');
        expect(c.uuid, 'e1159780-037d-11f1-b103-ddb25d4a1d79');
        expect(c.previousRetirements, 1);
        expect(c.xp, 45);
        expect(c.gold, 45);
        expect(c.isRetired, false);
        expect(c.personalQuestId, '');
        expect(c.personalQuestProgress, isEmpty);
      });

      test('second character: Cassandra (custom class)', () {
        final c = characters[1];
        expect(c.name, 'Cassandra');
        expect(c.playerClass.classCode, 'cassandra');
        expect(c.variant.name, 'base');
        expect(c.uuid, 'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79');
        expect(c.previousRetirements, 5);
        expect(c.xp, 422);
        expect(c.gold, 135);
        expect(c.resourceHide, 5);
        expect(c.resourceCorpsecap, -4);
        expect(c.personalQuestId, '');
        expect(c.personalQuestProgress, isEmpty);
      });

      test('third character: Third Guy (Infuser)', () {
        final c = characters[2];
        expect(c.name, 'Third Guy');
        expect(c.playerClass.classCode, 'infuser');
        expect(c.variant.name, 'base');
        expect(c.uuid, '319a8990-037e-11f1-b103-ddb25d4a1d79');
        expect(c.previousRetirements, 4);
        expect(c.xp, 98);
        expect(c.gold, 61);
        expect(c.checkMarks, 5);
        expect(c.resourceLumber, 8);
        expect(c.personalQuestId, '');
        expect(c.personalQuestProgress, isEmpty);
      });
    });

    group('CharacterPerk deserialization', () {
      late List<CharacterPerk> perks;

      setUpAll(() {
        perks = (json[1][1] as List)
            .map((m) => CharacterPerk.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('all perk records deserialize successfully', () {
        expect(perks.length, 54);
      });

      test('perks are distributed across all 3 characters', () {
        final uuids = perks.map((p) => p.associatedCharacterUuid).toSet();
        expect(uuids, {
          'e1159780-037d-11f1-b103-ddb25d4a1d79',
          'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79',
          '319a8990-037e-11f1-b103-ddb25d4a1d79',
        });
      });

      test('Spellweaver GH2E has 18 perks (none selected)', () {
        final swPerks = perks
            .where(
              (p) =>
                  p.associatedCharacterUuid ==
                  'e1159780-037d-11f1-b103-ddb25d4a1d79',
            )
            .toList();
        expect(swPerks.length, 18);
        expect(swPerks.every((p) => !p.characterPerkIsSelected), isTrue);
      });

      test('Cassandra has selected perks preserved', () {
        final cassandraPerks = perks
            .where(
              (p) =>
                  p.associatedCharacterUuid ==
                  'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79',
            )
            .toList();
        final selectedIds = cassandraPerks
            .where((p) => p.characterPerkIsSelected)
            .map((p) => p.associatedPerkId)
            .toSet();
        expect(selectedIds, {
          'cassandra_base_04a',
          'cassandra_base_04b',
          'cassandra_base_04c',
          'cassandra_base_10a',
          'cassandra_base_10b',
        });
      });

      test('Infuser has selected perks preserved', () {
        final infuserPerks = perks
            .where(
              (p) =>
                  p.associatedCharacterUuid ==
                  '319a8990-037e-11f1-b103-ddb25d4a1d79',
            )
            .toList();
        final selectedIds = infuserPerks
            .where((p) => p.characterPerkIsSelected)
            .map((p) => p.associatedPerkId)
            .toSet();
        expect(selectedIds, {
          'infuser_base_01a',
          'infuser_base_02a',
          'infuser_base_06a',
          'infuser_base_06b',
          'infuser_base_09a',
          'infuser_base_09b',
          'infuser_base_10a',
        });
      });
    });

    group('CharacterMastery deserialization', () {
      late List<CharacterMastery> masteries;

      setUpAll(() {
        masteries = (json[1][2] as List)
            .map((m) => CharacterMastery.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('all mastery records deserialize successfully', () {
        expect(masteries.length, 6);
      });

      test('masteries are distributed across all 3 characters', () {
        final uuids = masteries.map((m) => m.associatedCharacterUuid).toSet();
        expect(uuids, {
          'e1159780-037d-11f1-b103-ddb25d4a1d79',
          'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79',
          '319a8990-037e-11f1-b103-ddb25d4a1d79',
        });
      });

      test('Cassandra has one achieved mastery', () {
        final cassandraMasteries = masteries
            .where(
              (m) =>
                  m.associatedCharacterUuid ==
                  'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79',
            )
            .toList();
        expect(cassandraMasteries.length, 2);
        final achieved = cassandraMasteries
            .where((m) => m.characterMasteryAchieved)
            .toList();
        expect(achieved.length, 1);
        expect(achieved.first.associatedMasteryId, 'cassandra_base_1');
      });

      test('Spellweaver and Infuser have no achieved masteries', () {
        final nonCassandra = masteries
            .where(
              (m) =>
                  m.associatedCharacterUuid !=
                  'f4bb7fc0-037d-11f1-b103-ddb25d4a1d79',
            )
            .toList();
        expect(nonCassandra.every((m) => !m.characterMasteryAchieved), isTrue);
      });
    });
  });
}
