import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations_en.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations_pt.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/resource.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';

import '../helpers/test_data.dart';

void main() {
  group('Resource', () {
    test('displayOrder lists every resource exactly once', () {
      expect(Resource.displayOrder, unorderedEquals(Resource.values));
      expect(Resource.displayOrder.toSet().length, Resource.values.length);
    });

    test('displayOrder keeps the sheet order', () {
      expect(Resource.displayOrder.map((r) => r.assetKey), [
        'LUMBER',
        'METAL',
        'HIDE',
        'ARROWVINE',
        'AXENUT',
        'CORPSECAP',
        'FLAMEFRUIT',
        'ROCKROOT',
        'SNOWTHISTLE',
      ]);
    });

    test('columns are the persisted Characters column names', () {
      expect(Resource.values.map((r) => r.column), [
        'ResourceHide',
        'ResourceMetal',
        'ResourceWood',
        'ResourceArrowVine',
        'ResourceAxeNut',
        'ResourceRockRoot',
        'ResourceFlameFruit',
        'ResourceCorpseCap',
        'ResourceSnowThistle',
      ]);
    });

    test('every asset key has an icon', () {
      for (final resource in Resource.values) {
        expect(getAssetConfig(resource.assetKey), isNotNull);
      }
    });

    test('every resource has a label in each locale', () {
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsPt()]) {
        for (final resource in Resource.values) {
          expect(resource.label(l10n), isNotEmpty);
        }
      }
      expect(Resource.lumber.label(AppLocalizationsEn()), 'Lumber');
      expect(Resource.lumber.label(AppLocalizationsPt()), 'Madeira');
    });
  });

  group('Character resources', () {
    test('toMap writes one column per resource', () {
      final character = TestData.createCharacter();
      character.resources[Resource.snowthistle] = 4;

      final map = character.toMap();

      for (final resource in Resource.values) {
        expect(map.containsKey(resource.column), isTrue);
      }
      expect(map[columnResourceSnowthistle], 4);
      expect(map[columnResourceHide], 0);
    });

    test('fromMap defaults missing resource columns to 0', () {
      final map = TestData.createCharacter().toMap()
        ..remove(columnResourceLumber);

      final character = Character.fromMap(map);

      expect(character.resources[Resource.lumber], 0);
      expect(character.resources.length, Resource.values.length);
    });

    test('constructor fills unspecified resources with 0', () {
      final character = Character(
        uuid: 'r',
        name: 'R',
        playerClass: TestData.createCharacter().playerClass,
        resources: {Resource.metal: 2},
      );

      expect(character.resources[Resource.metal], 2);
      expect(character.resources[Resource.hide], 0);
      expect(character.resources.length, Resource.values.length);
    });
  });
}
