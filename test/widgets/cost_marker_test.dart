import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/cost_marker.dart';

void main() {
  group('costMarker', () {
    test('returns null when no markers are active', () {
      expect(costMarker({'§': false, '*': false}), isNull);
      expect(costMarker({}), isNull);
    });

    test('returns single symbol when only one is active', () {
      expect(costMarker({'§': true, '*': false}), '§');
      expect(costMarker({'§': false, '*': true}), '*');
    });

    test('joins multiple active symbols in insertion order', () {
      expect(costMarker({'§': true, '*': true}), '§*');
      expect(costMarker({'†': true, '*': true}), '†*');
      expect(costMarker({'‡': true, '*': true}), '‡*');
    });

    test('preserves declared order even when later markers are skipped', () {
      // Calculator UX: '*' (Building 44) is always the suffix, never appears
      // before the feature-specific marker. The Map's insertion order is the
      // contract.
      expect(costMarker({'§': true, 'X_FILTERED': false, '*': true}), '§*');
    });
  });
}
