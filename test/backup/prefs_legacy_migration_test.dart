import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../migration/harness/ffi.dart';
import '../migration/harness/harness.dart';
import 'backup_harness.dart';

/// Settings written by older app versions that are re-interpreted on read.
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    await SharedPrefs().init();
    return SharedPreferences.getInstance();
  }

  group('gloomhavenMode (≤ v4.3.0) → gameEdition', () {
    for (final (legacy, edition) in [
      (true, GameEdition.gloomhaven),
      (false, GameEdition.frosthaven),
    ]) {
      test('gloomhavenMode=$legacy becomes ${edition.name}', () async {
        final prefs = await prefsWith({'gloomhavenMode': legacy});
        expect(SharedPrefs().gameEdition, edition);
        expect(prefs.getInt('gameEdition'), edition.index);
        expect(prefs.containsKey('gloomhavenMode'), isFalse);
      });
    }

    test('an existing gameEdition wins over gloomhavenMode', () async {
      await prefsWith({
        'gameEdition': GameEdition.gloomhaven2e.index,
        'gloomhavenMode': true,
      });
      expect(SharedPrefs().gameEdition, GameEdition.gloomhaven2e);
    });
  });

  test('a missing clearOldPrefs flag means "wipe prefs on launch"', () async {
    // main.dart clears every pref when this is true: it runs once on fresh
    // installs and on 2020-era installs that predate the flag.
    await prefsWith({});
    expect(SharedPrefs().clearSharedPrefs, isTrue);
    SharedPrefs().clearSharedPrefs = false;
    expect(SharedPrefs().clearSharedPrefs, isFalse);
  });

  test('a saved character index past the restored characters clamps to the '
      'last one', () async {
    await prefsWith({'currentCharacterIndex': 17});
    await freshAppDatabase();
    await restore(backupFixtures.first.read());
    final model = await loadCharactersModel();
    expect(model.currentCharacter, model.characters.last);
    expect(SharedPrefs().currentCharacterIndex, model.characters.length - 1);
    await closeApp();
  });
}
