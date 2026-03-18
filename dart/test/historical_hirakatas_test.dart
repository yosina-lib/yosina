import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('HistoricalHirakatasTransliterator', () {
    group('simple hiragana (default)', () {
      test('basic conversion', () {
        final transliterator = HistoricalHirakatasTransliterator();

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑ'))),
          'いえ',
        );
      });

      test('passthrough', () {
        final transliterator = HistoricalHirakatasTransliterator();

        expect(
          Chars.charsToString(transliterator(Chars.fromString('あいう'))),
          'あいう',
        );
      });

      test('mixed input', () {
        final transliterator = HistoricalHirakatasTransliterator();

        expect(
          Chars.charsToString(transliterator(Chars.fromString('あゐいゑう'))),
          'あいいえう',
        );
      });
    });

    group('decompose hiragana', () {
      test('decomposes historical hiragana', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.decompose,
          katakanas: ConversionMode.skip,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑ'))),
          'うぃうぇ',
        );
      });
    });

    group('skip hiragana', () {
      test('leaves historical hiragana unchanged', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑ'))),
          'ゐゑ',
        );
      });
    });

    group('simple katakana (default)', () {
      test('basic conversion', () {
        final transliterator = HistoricalHirakatasTransliterator();

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヰヱ'))),
          'イエ',
        );
      });
    });

    group('decompose katakana', () {
      test('decomposes historical katakana', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.decompose,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヰヱ'))),
          'ウィウェ',
        );
      });
    });

    group('voiced katakana decompose', () {
      test('decomposes voiced historical katakana', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
          voicedKatakanas: VoicedConversionMode.decompose,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヷヸヹヺ'))),
          'ヴァヴィヴェヴォ',
        );
      });
    });

    group('voiced katakana skip (default)', () {
      test('leaves voiced historical katakana unchanged', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヷヸヹヺ'))),
          'ヷヸヹヺ',
        );
      });
    });

    group('all decompose', () {
      test('decomposes all historical kana', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.decompose,
          katakanas: ConversionMode.decompose,
          voicedKatakanas: VoicedConversionMode.decompose,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑヰヱヷヸヹヺ'))),
          'うぃうぇウィウェヴァヴィヴェヴォ',
        );
      });
    });

    group('all skip', () {
      test('leaves all historical kana unchanged', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
          voicedKatakanas: VoicedConversionMode.skip,
        );

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑヰヱヷヸヹヺ'))),
          'ゐゑヰヱヷヸヹヺ',
        );
      });
    });

    group('decomposed voiced katakana input', () {
      test('decomposed input with decompose mode converts like composed', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
          voicedKatakanas: VoicedConversionMode.decompose,
        );

        expect(
          Chars.charsToString(
              transliterator(Chars.fromString('ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099'))),
          'ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ',
        );
      });

      test('decomposed input with skip mode passes through unchanged', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
          voicedKatakanas: VoicedConversionMode.skip,
        );

        expect(
          Chars.charsToString(
              transliterator(Chars.fromString('ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099'))),
          'ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099',
        );
      });

      test('decomposed voiced must not split base from combining mark', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.simple,
          voicedKatakanas: VoicedConversionMode.skip,
        );

        // ヰ+゙ should be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヰ\u3099'))),
          'ヰ\u3099',
        );
      });

      test('decomposed voiced with decompose mode', () {
        final transliterator = HistoricalHirakatasTransliterator(
          hiraganas: ConversionMode.skip,
          katakanas: ConversionMode.skip,
          voicedKatakanas: VoicedConversionMode.decompose,
        );

        // ヰ+゙ = ヸ, should produce ウ+゙+ィ (decomposed)
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヰ\u3099'))),
          'ウ\u3099ィ',
        );
      });
    });

    group('empty input', () {
      test('handles empty input', () {
        final transliterator = HistoricalHirakatasTransliterator();

        expect(
          Chars.charsToString(transliterator(Chars.fromString(''))),
          '',
        );
      });
    });
  });
}
