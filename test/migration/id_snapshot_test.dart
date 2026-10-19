import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';

/// Character perk/mastery rows store these IDs; once shipped, an ID must keep
/// meaning the same perk forever. IDs are append-only: removing or
/// renumbering one fails even under --update-goldens. Added IDs and text
/// edits fail until the golden is regenerated and the diff reviewed.
void main() {
  test('perk IDs are append-only', () {
    _expectSnapshot('test/fixtures/ids/perk_ids.json', {
      for (final MapEntry(key: classCode, value: groups)
          in PerksRepository.perksMap.entries)
        classCode: {
          for (final group in groups)
            group.variant.name: {
              for (final perk in PerksRepository.getPerksForCharacter(
                classCode,
                group.variant,
              ))
                perk.perkId: perk.perkDetails,
            },
        },
    });
  });

  test('mastery IDs are append-only', () {
    _expectSnapshot('test/fixtures/ids/mastery_ids.json', {
      for (final MapEntry(key: classCode, value: groups)
          in MasteriesRepository.masteriesMap.entries)
        classCode: {
          for (final group in groups)
            group.variant.name: {
              for (final mastery
                  in MasteriesRepository.getMasteriesForCharacter(
                    classCode,
                    group.variant,
                  ))
                mastery.id: mastery.masteryDetails,
            },
        },
    });
  });
}

void _expectSnapshot(
  String path,
  Map<String, Map<String, Map<String, String>>> live,
) {
  final file = File(path);
  if (file.existsSync()) {
    final golden = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final removed = <String>[];
    for (final MapEntry(key: classCode, value: variants) in golden.entries) {
      for (final MapEntry(key: variant, value: ids)
          in (variants as Map<String, dynamic>).entries) {
        for (final id in (ids as Map<String, dynamic>).keys) {
          if (live[classCode]?[variant]?.containsKey(id) != true) {
            removed.add('$classCode/$variant/$id');
          }
        }
      }
    }
    expect(
      removed,
      isEmpty,
      reason:
          'Shipped IDs disappeared. Existing characters store these IDs; '
          'renumbering hides or swaps their selections. Add new IDs instead.',
    );
  }
  if (autoUpdateGoldenFiles || !file.existsSync()) {
    file.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(live)}\n',
    );
  }
  expect(
    live,
    jsonDecode(file.readAsStringSync()),
    reason: 'IDs or texts changed; review and run --update-goldens',
  );
}
