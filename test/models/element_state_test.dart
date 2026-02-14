import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/element_state.dart';

void main() {
  group('ElementState', () {
    test('has exactly 3 values', () {
      expect(ElementState.values.length, 3);
    });

    group('nextState()', () {
      test('gone → strong', () {
        expect(ElementState.gone.nextState(), ElementState.strong);
      });

      test('strong → waning', () {
        expect(ElementState.strong.nextState(), ElementState.waning);
      });

      test('waning → gone', () {
        expect(ElementState.waning.nextState(), ElementState.gone);
      });

      test('full cycle returns to original state', () {
        final state = ElementState.gone;
        expect(state.nextState().nextState().nextState(), state);
      });
    });

    group('fromIndex()', () {
      test('0 → gone', () {
        expect(ElementState.fromIndex(0), ElementState.gone);
      });

      test('1 → strong', () {
        expect(ElementState.fromIndex(1), ElementState.strong);
      });

      test('2 → waning', () {
        expect(ElementState.fromIndex(2), ElementState.waning);
      });

      test('negative index returns gone', () {
        expect(ElementState.fromIndex(-1), ElementState.gone);
      });

      test('out of range index returns gone', () {
        expect(ElementState.fromIndex(3), ElementState.gone);
      });

      test('large invalid index returns gone', () {
        expect(ElementState.fromIndex(999), ElementState.gone);
      });
    });
  });
}
