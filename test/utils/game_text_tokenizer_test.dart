import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_tokenizer.dart';
import 'package:gloomhaven_enhancement_calc/utils/game_text_tokens.dart';

void main() {
  group('ParsedWord.from', () {
    test('plain word — no punctuation, no overlay', () {
      final p = ParsedWord.from('MOVE');
      expect(p.assetKey, 'MOVE');
      expect(p.leadingPunct, isNull);
      expect(p.trailingPunct, isNull);
      expect(p.hasPlusOneOverlay, isFalse);
    });

    test('word with leading and trailing punctuation', () {
      // The parser strips one leading + one trailing punctuation char (per
      // the documented contract on ParsedWord.from). Real game text only
      // has one of each at a time.
      final p = ParsedWord.from('"MOVE,');
      expect(p.assetKey, 'MOVE');
      expect(p.leadingPunct, '"');
      expect(p.trailingPunct, ',');
      expect(p.hasPlusOneOverlay, isFalse);
    });

    test('compound icon "MOVE+1" sets the overlay flag', () {
      final p = ParsedWord.from('MOVE+1');
      expect(p.assetKey, 'MOVE');
      expect(p.hasPlusOneOverlay, isTrue);
    });

    test('standalone "+1" is preserved as the asset key (no overlay)', () {
      // Critical: stripping +1 here would yield "" and the attack-modifier
      // icon would fail to resolve. This is the documented edge case in
      // the parser.
      final p = ParsedWord.from('+1');
      expect(p.assetKey, '+1');
      expect(p.hasPlusOneOverlay, isFalse);
    });

    test('"+2" attack modifier is preserved unchanged', () {
      // +2 doesn't end in "+1" so the overlay stripper shouldn't touch it.
      final p = ParsedWord.from('+2');
      expect(p.assetKey, '+2');
      expect(p.hasPlusOneOverlay, isFalse);
    });

    test('compound icon with trailing comma — "ATTACK+1,"', () {
      final p = ParsedWord.from('ATTACK+1,');
      expect(p.assetKey, 'ATTACK');
      expect(p.trailingPunct, ',');
      expect(p.hasPlusOneOverlay, isTrue);
    });

    test('paren-wrapped icon — "(SHIELD)"', () {
      final p = ParsedWord.from('(SHIELD)');
      expect(p.assetKey, 'SHIELD');
      expect(p.leadingPunct, '(');
      expect(p.trailingPunct, ')');
      expect(p.hasPlusOneOverlay, isFalse);
    });
  });

  group('GameTextTokenizer.tokenize — formatted text', () {
    test('plain text becomes a single PlainTextToken (or word tokens)', () {
      final tokens = GameTextTokenizer.tokenize('hello world', false);
      // hello + space + world
      expect(tokens, hasLength(3));
      expect(tokens.every((t) => t is PlainTextToken), isTrue);
      expect((tokens[0] as PlainTextToken).text, 'hello');
      expect((tokens[1] as PlainTextToken).text, ' ');
      expect((tokens[2] as PlainTextToken).text, 'world');
    });

    test('**bold** wraps content in BoldToken', () {
      final tokens = GameTextTokenizer.tokenize('say **hi** now', false);
      expect(tokens.whereType<BoldToken>(), hasLength(1));
      expect(tokens.whereType<BoldToken>().first.text, 'hi');
    });

    test('*italic* wraps content in ItalicToken', () {
      final tokens = GameTextTokenizer.tokenize('say *hi* now', false);
      expect(tokens.whereType<ItalicToken>(), hasLength(1));
      expect(tokens.whereType<ItalicToken>().first.text, 'hi');
    });

    test('~~strikethrough~~ wraps content in StrikethroughToken', () {
      final tokens = GameTextTokenizer.tokenize('say ~~bye~~ now', false);
      expect(tokens.whereType<StrikethroughToken>(), hasLength(1));
      expect(tokens.whereType<StrikethroughToken>().first.text, 'bye');
    });

    test('bold and italic in the same string', () {
      final tokens = GameTextTokenizer.tokenize('**a** and *b*', false);
      expect(tokens.whereType<BoldToken>(), hasLength(1));
      expect(tokens.whereType<ItalicToken>(), hasLength(1));
    });
  });

  group('GameTextTokenizer.tokenize — text replacements', () {
    test('"plusone" is replaced with "+1"', () {
      final tokens = GameTextTokenizer.tokenize('gain plusone', false);
      // "gain" + " " + "+1"
      final plainTexts = tokens
          .whereType<PlainTextToken>()
          .map((t) => t.text)
          .toList();
      expect(plainTexts, contains('+1'));
    });

    test('"plustwo" is replaced with "+2"', () {
      final tokens = GameTextTokenizer.tokenize('plustwo bonus', false);
      final plainTexts = tokens
          .whereType<PlainTextToken>()
          .map((t) => t.text)
          .toList();
      expect(plainTexts, contains('+2'));
    });

    test('"pluszero" is replaced with "+0"', () {
      final tokens = GameTextTokenizer.tokenize('pluszero', false);
      final plainTexts = tokens
          .whereType<PlainTextToken>()
          .map((t) => t.text)
          .toList();
      expect(plainTexts, contains('+0'));
    });
  });

  group('GameTextTokenizer.tokenize — icon resolution', () {
    test('known asset key like "MOVE" produces an IconToken', () {
      final tokens = GameTextTokenizer.tokenize('use MOVE here', false);
      expect(tokens.whereType<IconToken>(), hasLength(1));
      final icon = tokens.whereType<IconToken>().first;
      expect(icon.element, 'MOVE');
      expect(icon.showPlusOneOverlay, isFalse);
    });

    test('"MOVE+1" produces an IconToken with overlay flag set', () {
      final tokens = GameTextTokenizer.tokenize('gain MOVE+1', false);
      final icon = tokens.whereType<IconToken>().first;
      expect(icon.element, 'MOVE');
      expect(icon.showPlusOneOverlay, isTrue);
    });

    test('unknown words pass through as PlainTextToken', () {
      final tokens = GameTextTokenizer.tokenize('flibbertigibbet', false);
      expect(tokens.whereType<IconToken>(), isEmpty);
      expect(tokens.whereType<PlainTextToken>(), isNotEmpty);
    });

    test('FIRE&ICE produces a StackedElementToken', () {
      final tokens = GameTextTokenizer.tokenize('use FIRE&ICE', false);
      expect(tokens.whereType<StackedElementToken>(), hasLength(1));
      final stacked = tokens.whereType<StackedElementToken>().first;
      expect(stacked.element1, 'FIRE');
      expect(stacked.element2, 'ICE');
    });
  });
}
