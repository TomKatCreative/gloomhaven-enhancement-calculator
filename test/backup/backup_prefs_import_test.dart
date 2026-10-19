import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';
import '../migration/harness/ffi.dart';
import '../migration/harness/harness.dart';
import 'backup_harness.dart';

/// Every real backup that carries settings restores them exactly, including
/// values written by older app versions.
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  setUp(setupSharedPreferences);
  tearDown(closeApp);

  // Legacy enhancement selection is stored as an index into the enhancement
  // list. Every prefs-carrying backup is from 4.5.0+, whose list order is
  // `git show v4.5.0:lib/data/enhancement_data.dart`: 5 = Retaliate,
  // 6 = Pierce. Pinned here independently of the current list.
  const legacyEnhancementNames = {5: 'Retaliate', 6: 'Pierce'};

  for (final fixture in backupFixtures.where((f) => f.hasPrefs)) {
    group(fixture.name, () {
      final exported = fixture.decode()[2] as Map<String, dynamic>;

      Future<SharedPreferences> restored() async {
        await freshAppDatabase();
        await restore(fixture.read());
        return SharedPreferences.getInstance();
      }

      test(
        'restores every setting, calculator value and enhancer level',
        () async {
          final prefs = await restored();
          for (final category in ['settings', 'calculator', 'enhancerLevels']) {
            final values = Map<String, dynamic>.from(exported[category] as Map);
            values.remove('customClasses'); // Retired setting; ignored.
            values.remove('enhancementKey'); // Checked below.
            for (final MapEntry(:key, :value) in values.entries) {
              expect(prefs.get(key), value, reason: '$category.$key');
            }
          }
        },
      );

      test('ignores the retired customClasses setting', () async {
        final prefs = await restored();
        expect(prefs.get('customClasses'), isNull);
      });

      // Every real backup lists all locked classes, so re-locking classes a
      // backup omits is covered by shared_prefs_backup_test.dart instead.
      test('restores every class unlock', () async {
        final lockedClasses = PlayerClasses.playerClasses.where(
          (p) => p.locked,
        );
        // Unlock everything first so a class the backup stores as locked
        // only ends up locked if the import actually writes it.
        for (final pc in lockedClasses) {
          SharedPrefs().setPlayerClassIsUnlocked(pc.classCode, true);
        }
        await restored();
        final unlocks = Map<String, dynamic>.from(
          exported['classUnlocks'] as Map,
        );
        for (final pc in lockedClasses) {
          expect(
            SharedPrefs().getPlayerClassIsUnlocked(pc.classCode),
            unlocks[pc.classCode] ?? false,
            reason: pc.classCode,
          );
        }
      });

      final legacyIndex =
          (exported['calculator'] as Map)['enhancementType'] as int?;
      if (legacyIndex != null) {
        test('turns legacy enhancement index $legacyIndex into '
            '${legacyEnhancementNames[legacyIndex]}', () async {
          await restored();
          final model = EnhancementCalculatorModel()..reloadFromPrefs();
          expect(model.enhancement?.name, legacyEnhancementNames[legacyIndex]);
          expect(
            SharedPrefs().enhancementKey,
            EnhancementData.enhancements
                .firstWhere(
                  (e) => e.name == legacyEnhancementNames[legacyIndex],
                )
                .key,
          );
        });
      }
    });
  }
}
