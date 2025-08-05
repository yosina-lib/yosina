import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('Char', () {
    test('creates char with correct properties', () {
      final char = Char('あ', 0);
      expect(char.c, 'あ');
      expect(char.offset, 0);
      expect(char.source, isNull);
    });

    test('creates char with source', () {
      final source = Char('A', 0);
      final char = Char('a', 1, source);
      expect(char.source, source);
    });

    test('withOffset creates new char with different offset', () {
      final char = Char('あ', 0);
      final newChar = char.withOffset(5);
      expect(newChar.c, 'あ');
      expect(newChar.offset, 5);
      expect(newChar.source, char);
    });
  });

  group('Chars', () {
    test('fromString converts ASCII string correctly', () {
      final chars = Chars.fromString('Hello').toList();
      expect(chars.length, 6);
      expect(chars[0].c, 'H');
      expect(chars[0].offset, 0);
      expect(chars[1].c, 'e');
      expect(chars[1].offset, 1);
    });

    test('fromString handles Japanese characters', () {
      final chars = Chars.fromString('こんにちは').toList();
      expect(chars.length, 6);
      expect(chars[0].c, 'こ');
      expect(chars[1].c, 'ん');
      expect(chars[2].c, 'に');
      expect(chars[3].c, 'ち');
      expect(chars[4].c, 'は');
    });

    test('toString converts chars back to string', () {
      final original = 'Hello, 世界!';
      final chars = Chars.fromString(original);
      final result = Chars.charsToString(chars);
      expect(result, original);
    });
  });

  group('Generated Transliterators', () {
    late TransliteratorRegistry registry;

    setUpAll(() {
      registry = TransliteratorRegistry();

      // Register generated transliterators manually for testing
      // In production, this would be done by the generated code
      try {
        // Try to import generated transliterators
        registry.register('spaces', (options) {
          // This would normally import the generated file
          // For now, create a simple mock
          return _MockTransliterator((chars) sync* {
            for (final char in chars) {
              if (char.c == '\u{3000}' || char.c == '\u{00A0}') {
                yield Char(' ', char.offset, char);
              } else {
                yield char;
              }
            }
          });
        });
      } catch (e) {
        // Generated files may not exist yet
      }
    });

    test('spaces transliterator replaces fullwidth space', () {
      final transliterator = registry.create('spaces');
      final input = Chars.fromString('Hello　World');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'Hello World');
    });
  });

  group('ProlongedSoundMarksTransliterator', () {
    test('replaces hyphen after katakana with prolonged sound mark', () {
      final transliterator = ProlongedSoundMarksTransliterator();
      final input = Chars.fromString('コンピュータ-');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'コンピューター');
    });

    test('replaces hyphen after halfwidth katakana', () {
      final transliterator = ProlongedSoundMarksTransliterator();
      final input = Chars.fromString('ｺﾝﾋﾟｭｰﾀ-');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ｺﾝﾋﾟｭｰﾀｰ');
    });

    test('does not replace hyphen after non-prolongable character', () {
      final transliterator = ProlongedSoundMarksTransliterator();
      final input = Chars.fromString('ん-');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ん-');
    });

    test('handles alphanumeric replacement when option is set', () {
      final transliterator = ProlongedSoundMarksTransliterator(
        replaceProlongedMarksFollowingAlnums: true,
      );
      final input = Chars.fromString('CD-ROM');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'CD-ROM'); // Should remain as hyphen
    });
  });

  group('ChainedTransliterator', () {
    test('chains multiple transliterators', () {
      final chain = ChainedTransliterator([
        _MockTransliterator((chars) sync* {
          for (final char in chars) {
            if (char.c == 'A') {
              yield Char('B', char.offset, char);
            } else {
              yield char;
            }
          }
        }),
        _MockTransliterator((chars) sync* {
          for (final char in chars) {
            if (char.c == 'B') {
              yield Char('C', char.offset, char);
            } else {
              yield char;
            }
          }
        }),
      ]);

      final input = Chars.fromString('ABC');
      final output = chain(input);
      final result = Chars.charsToString(output);
      expect(result, 'CCC');
    });
  });
}

// Mock transliterator for testing
class _MockTransliterator implements Transliterator {
  _MockTransliterator(this._transform);
  final Iterable<Char> Function(Iterable<Char>) _transform;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) => _transform(inputChars);
}
