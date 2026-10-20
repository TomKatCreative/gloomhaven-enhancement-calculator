import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';

void main() {
  group('getAssetConfig', () {
    test('strips punctuation before lookup', () {
      expect(getAssetConfig('ATTACK,'), same(assets['ATTACK']));
      expect(getAssetConfig('(MOVE).'), same(assets['MOVE']));
      expect(getAssetConfig('"ATTACK":'), same(assets['ATTACK']));
      expect(getAssetConfig("'MOVE'"), same(assets['MOVE']));
    });

    test('maps any xp value to the XP icon', () {
      expect(getAssetConfig('xp8').path, 'ui/xp.svg');
      expect(getAssetConfig('xp10,').path, 'ui/xp.svg');
    });

    test('accepts lowercase keys such as class codes', () {
      expect(getAssetConfig(ClassCodes.brute), same(assets[ClassCodes.brute]));
      expect(getAssetConfig('hex'), same(assets['hex']));
      expect(getAssetConfig('plus_one'), same(assets['plus_one']));
    });

    test('throws for an unknown key', () {
      expect(
        () => getAssetConfig('NOT_AN_ASSET'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('tryGetAssetConfig', () {
    test('strips punctuation before lookup', () {
      expect(tryGetAssetConfig('ATTACK,'), same(assets['ATTACK']));
    });

    test('skips all-lowercase words so class codes do not match prose', () {
      expect(assets[ClassCodes.brute], isNotNull);
      expect(tryGetAssetConfig(ClassCodes.brute), isNull);
      expect(tryGetAssetConfig('hex'), isNull);
    });

    test('still matches numeric tokens and xp values', () {
      expect(tryGetAssetConfig('+1'), same(assets['+1']));
      expect(tryGetAssetConfig('2x'), same(assets['2x']));
      expect(tryGetAssetConfig('xp8')?.path, 'ui/xp.svg');
    });

    test('returns null for an unknown key', () {
      expect(tryGetAssetConfig('NOT_AN_ASSET'), isNull);
    });
  });
}
