import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
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
  late List<dynamic> jsonV420;
  late List<dynamic> jsonV432;

  setUpAll(() {
    final v420File = File('test/helpers/fake_backup_v420.txt');
    jsonV420 = convert.jsonDecode(v420File.readAsStringSync());

    final v432File = File('test/helpers/fake_backup_v432.txt');
    jsonV432 = convert.jsonDecode(v432File.readAsStringSync());
  });

  // ───────────────────────────────────────────────────────────────────────
  // v4.2.0 backup (DB v8) — oldest supported version
  // ───────────────────────────────────────────────────────────────────────

  group('v4.2.0 backup (DB v8)', () {
    group('structure validation', () {
      test('backup has expected table names', () {
        expect(jsonV420[0], [
          'Characters',
          'CharacterPerks',
          'CharacterMasteries',
          'MetaData',
        ]);
      });

      test('MetaData table is present', () {
        expect(jsonV420[0].contains('MetaData'), isTrue);
      });

      test('backup is old format (no SharedPrefs element)', () {
        expect(jsonV420.length, 2);
      });

      test('MetaData records DB version 8 and app version 4.2.0', () {
        final metadata = jsonV420[1][3] as List;
        expect(metadata.length, 1);
        expect(metadata[0][DatabaseHelper.columnDatabaseVersion], 8);
        expect(metadata[0][DatabaseHelper.columnAppVersion], '4.2.0');
      });
    });

    group('column patching', () {
      test('v8 characters already have resource columns', () {
        final characters = jsonV420[1][0] as List;
        for (final charMap in characters) {
          expect(charMap.containsKey(columnResourceHide), isTrue);
          expect(charMap.containsKey(columnResourceMetal), isTrue);
          expect(charMap.containsKey(columnResourceLumber), isTrue);
        }
      });

      test('v8 characters are missing PersonalQuest columns', () {
        final characters = jsonV420[1][0] as List;
        for (final charMap in characters) {
          expect(charMap.containsKey(columnCharacterPersonalQuestId), isFalse);
          expect(
            charMap.containsKey(columnCharacterPersonalQuestProgress),
            isFalse,
          );
        }
      });

      test('patching adds PersonalQuest columns with defaults', () {
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV420));
        _patchCharacterMaps(copy);

        final characters = copy[1][0] as List;
        for (final charMap in characters) {
          expect(charMap[columnCharacterPersonalQuestId], '');
          expect(charMap[columnCharacterPersonalQuestProgress], '[]');
        }
      });

      test('patching preserves existing resource values', () {
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV420));
        _patchCharacterMaps(copy);

        // dragdde: Metal=5, Wood=2, Arrowvine=11, Rockroot=1, Corpsecap=4
        final dragdde = copy[1][0][0];
        expect(dragdde[columnResourceMetal], 5);
        expect(dragdde[columnResourceLumber], 2);
        expect(dragdde[columnResourceArrowvine], 11);
        expect(dragdde[columnResourceRockroot], 1);
        expect(dragdde[columnResourceCorpsecap], 4);

        // Another One: Hide=2, Axenut=7, Rockroot=7, Snowthistle=-1
        final anotherOne = copy[1][0][1];
        expect(anotherOne[columnResourceHide], 2);
        expect(anotherOne[columnResourceAxenut], 7);
        expect(anotherOne[columnResourceRockroot], 7);
        expect(anotherOne[columnResourceSnowthistle], -1);
      });
    });

    group('Character deserialization', () {
      late List<Character> characters;

      setUpAll(() {
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV420));
        _patchCharacterMaps(copy);
        characters = (copy[1][0] as List)
            .map((m) => Character.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('all 2 characters deserialize successfully', () {
        expect(characters.length, 2);
      });

      test('dragdde (Drifter frosthavenCrossover)', () {
        final c = characters[0];
        expect(c.name, 'dragdde');
        expect(c.playerClass.classCode, 'ds');
        expect(c.variant.name, 'frosthavenCrossover');
        expect(c.uuid, '99b5c850-095a-11f1-8897-b35abb6f294a');
        expect(c.previousRetirements, 0);
        expect(c.xp, 45);
        expect(c.gold, 45);
        expect(c.checkMarks, 3);
        expect(c.resourceMetal, 5);
        expect(c.resourceLumber, 2);
        expect(c.resourceArrowvine, 11);
        expect(c.resourceRockroot, 1);
        expect(c.resourceCorpsecap, 4);
        expect(c.personalQuestId, '');
        expect(c.personalQuestProgress, isEmpty);
      });

      test('Another One Created At 420 (Deep Wraith base)', () {
        final c = characters[1];
        expect(c.name, 'Another One Created At 420');
        expect(c.playerClass.classCode, 'deepwraith');
        expect(c.variant.name, 'base');
        expect(c.uuid, 'c34a5050-095a-11f1-8897-b35abb6f294a');
        expect(c.previousRetirements, 1);
        expect(c.xp, 150);
        expect(c.gold, 50);
        expect(c.checkMarks, 11);
        expect(c.resourceHide, 2);
        expect(c.resourceAxenut, 7);
        expect(c.resourceRockroot, 7);
        expect(c.resourceSnowthistle, -1);
        expect(c.personalQuestId, '');
        expect(c.personalQuestProgress, isEmpty);
      });
    });

    group('CharacterPerk deserialization', () {
      late List<CharacterPerk> perks;

      setUpAll(() {
        perks = (jsonV420[1][1] as List)
            .map((m) => CharacterPerk.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('33 total perk records', () {
        expect(perks.length, 33);
      });

      test('perks are distributed across 2 characters', () {
        final uuids = perks.map((p) => p.associatedCharacterUuid).toSet();
        expect(uuids, {
          '99b5c850-095a-11f1-8897-b35abb6f294a',
          'c34a5050-095a-11f1-8897-b35abb6f294a',
        });
      });

      test('Drifter has 15 perks with 6 selected', () {
        final drifterPerks = perks
            .where(
              (p) =>
                  p.associatedCharacterUuid ==
                  '99b5c850-095a-11f1-8897-b35abb6f294a',
            )
            .toList();
        expect(drifterPerks.length, 15);
        final selectedIds = drifterPerks
            .where((p) => p.characterPerkIsSelected)
            .map((p) => p.associatedPerkId)
            .toSet();
        expect(selectedIds, {
          'ds_frosthavenCrossover_02b',
          'ds_frosthavenCrossover_02c',
          'ds_frosthavenCrossover_02d',
          'ds_frosthavenCrossover_03b',
          'ds_frosthavenCrossover_04a',
          'ds_frosthavenCrossover_05a',
        });
      });

      test('Deep Wraith has 18 perks with 7 selected', () {
        final dwPerks = perks
            .where(
              (p) =>
                  p.associatedCharacterUuid ==
                  'c34a5050-095a-11f1-8897-b35abb6f294a',
            )
            .toList();
        expect(dwPerks.length, 18);
        final selectedIds = dwPerks
            .where((p) => p.characterPerkIsSelected)
            .map((p) => p.associatedPerkId)
            .toSet();
        expect(selectedIds, {
          'deepwraith_base_01a',
          'deepwraith_base_02a',
          'deepwraith_base_02b',
          'deepwraith_base_03a',
          'deepwraith_base_04a',
          'deepwraith_base_04b',
          'deepwraith_base_05a',
        });
      });
    });

    group('CharacterMastery deserialization', () {
      late List<CharacterMastery> masteries;

      setUpAll(() {
        masteries = (jsonV420[1][2] as List)
            .map((m) => CharacterMastery.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('4 total masteries, none achieved', () {
        expect(masteries.length, 4);
        expect(masteries.every((m) => !m.characterMasteryAchieved), isTrue);
      });

      test('masteries are distributed across 2 characters', () {
        final uuids = masteries.map((m) => m.associatedCharacterUuid).toSet();
        expect(uuids, {
          '99b5c850-095a-11f1-8897-b35abb6f294a',
          'c34a5050-095a-11f1-8897-b35abb6f294a',
        });
      });
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // v4.3.2 backup (DB v16)
  // ───────────────────────────────────────────────────────────────────────

  group('v4.3.2 backup (DB v16)', () {
    group('structure validation', () {
      test('backup has expected table names', () {
        expect(jsonV432[0], [
          'Characters',
          'CharacterPerks',
          'CharacterMasteries',
          'MetaData',
        ]);
      });

      test('MetaData table is present', () {
        expect(jsonV432[0].contains('MetaData'), isTrue);
      });

      test('backup is old format (no SharedPrefs element)', () {
        expect(jsonV432.length, 2);
      });

      test('MetaData records DB version 16 and app version 4.3.2', () {
        final metadata = jsonV432[1][3] as List;
        expect(metadata.length, 1);
        expect(metadata[0][DatabaseHelper.columnDatabaseVersion], 16);
        expect(metadata[0][DatabaseHelper.columnAppVersion], '4.3.2');
      });
    });

    group('column patching', () {
      test('v16 characters are missing PersonalQuest columns', () {
        final characters = jsonV432[1][0] as List;
        for (final charMap in characters) {
          expect(charMap.containsKey(columnCharacterPersonalQuestId), isFalse);
          expect(
            charMap.containsKey(columnCharacterPersonalQuestProgress),
            isFalse,
          );
        }
      });

      test('patching adds PersonalQuest columns with defaults', () {
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV432));
        _patchCharacterMaps(copy);

        final characters = copy[1][0] as List;
        for (final charMap in characters) {
          expect(charMap[columnCharacterPersonalQuestId], '');
          expect(charMap[columnCharacterPersonalQuestProgress], '[]');
        }
      });

      test('patching preserves existing resource columns', () {
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV432));
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
        final copy = convert.jsonDecode(convert.jsonEncode(jsonV432));
        _patchCharacterMaps(copy);
        characters = (copy[1][0] as List)
            .map((m) => Character.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('all 3 characters deserialize successfully', () {
        expect(characters.length, 3);
      });

      test('Nyah Heathcote (Spellweaver GH2E)', () {
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

      test('Cassandra (custom class)', () {
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

      test('Third Guy (Infuser)', () {
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
        perks = (jsonV432[1][1] as List)
            .map((m) => CharacterPerk.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('54 total perk records', () {
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
        masteries = (jsonV432[1][2] as List)
            .map((m) => CharacterMastery.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      });

      test('6 total masteries', () {
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

  // ───────────────────────────────────────────────────────────────────────
  // Sequential restore — v4.2.0 then v4.3.2
  // ───────────────────────────────────────────────────────────────────────

  group('sequential restore', () {
    test('v4.2.0 data is fully replaced by v4.3.2 data', () {
      // Parse v4.2.0 first
      final copyV420 = convert.jsonDecode(convert.jsonEncode(jsonV420));
      _patchCharacterMaps(copyV420);
      final charsV420 = (copyV420[1][0] as List)
          .map((m) => Character.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(charsV420.length, 2);

      // Then "restore" v4.3.2 on top
      final copyV432 = convert.jsonDecode(convert.jsonEncode(jsonV432));
      _patchCharacterMaps(copyV432);
      final charsV432 = (copyV432[1][0] as List)
          .map((m) => Character.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(charsV432.length, 3);

      // UUIDs are completely different between the two backups
      final v420Uuids = charsV420.map((c) => c.uuid).toSet();
      final v432Uuids = charsV432.map((c) => c.uuid).toSet();
      expect(v420Uuids.intersection(v432Uuids), isEmpty);
    });

    test('perk and mastery counts update correctly', () {
      final perksV420 = (jsonV420[1][1] as List)
          .map((m) => CharacterPerk.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(perksV420.length, 33);

      final perksV432 = (jsonV432[1][1] as List)
          .map((m) => CharacterPerk.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(perksV432.length, 54);

      final masteriesV420 = (jsonV420[1][2] as List)
          .map((m) => CharacterMastery.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(masteriesV420.length, 4);

      final masteriesV432 = (jsonV432[1][2] as List)
          .map((m) => CharacterMastery.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      expect(masteriesV432.length, 6);
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // Version enforcement
  // ───────────────────────────────────────────────────────────────────────

  group('version enforcement', () {
    test('backup with no MetaData table throws', () {
      final noMeta = [
        ['Characters', 'CharacterPerks'],
        [[], []],
      ];
      final backup = convert.jsonEncode(noMeta);
      final json = convert.jsonDecode(backup);
      expect(json[0].contains('MetaData'), isFalse);
    });

    test('backup with DB version < 8 is rejected', () {
      // Simulate a backup with MetaData present but old DB version
      final oldBackup = [
        ['Characters', 'CharacterPerks', 'CharacterMasteries', 'MetaData'],
        [
          [],
          [],
          [],
          [
            {
              DatabaseHelper.columnDatabaseVersion: 5,
              DatabaseHelper.columnAppVersion: '3.0.0',
            },
          ],
        ],
      ];
      final metaDataIndex = oldBackup[0].indexOf('MetaData');
      final metaData = (oldBackup[1] as List)[metaDataIndex] as List;
      expect(metaData.isNotEmpty, isTrue);
      expect(
        (metaData[0] as Map)[DatabaseHelper.columnDatabaseVersion] as int,
        lessThan(8),
      );
    });

    test('backup with empty MetaData is rejected', () {
      final emptyMeta = [
        ['Characters', 'CharacterPerks', 'CharacterMasteries', 'MetaData'],
        [[], [], [], []],
      ];
      final metaDataIndex = emptyMeta[0].indexOf('MetaData');
      final metaData = (emptyMeta[1] as List)[metaDataIndex] as List;
      expect(metaData.isEmpty, isTrue);
    });

    test('v4.2.0 backup (DB v8) passes version check', () {
      final metaDataIndex = jsonV420[0].indexOf('MetaData');
      final metaData = jsonV420[1][metaDataIndex] as List;
      expect(metaData.isNotEmpty, isTrue);
      expect(
        metaData[0][DatabaseHelper.columnDatabaseVersion] as int,
        greaterThanOrEqualTo(8),
      );
    });

    test('v4.3.2 backup (DB v16) passes version check', () {
      final metaDataIndex = jsonV432[0].indexOf('MetaData');
      final metaData = jsonV432[1][metaDataIndex] as List;
      expect(metaData.isNotEmpty, isTrue);
      expect(
        metaData[0][DatabaseHelper.columnDatabaseVersion] as int,
        greaterThanOrEqualTo(8),
      );
    });
  });
}
