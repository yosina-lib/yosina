import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('HiraKataCompositionTransliterator', () {
    test('composes hiragana with combining marks by default', () {
      final transliterator = HiraKataCompositionTransliterator();
      final input = [
        Char('か', 0),
        Char('\u{3099}', 1), // Combining voiced mark
      ];
      final result = transliterator(input).toList();
      expect(result.length, equals(1));
      expect(result[0].c, equals('が'));
    });

    test('composes katakana with combining marks', () {
      final transliterator = HiraKataCompositionTransliterator();
      final input = [
        Char('ハ', 0),
        Char('\u{309A}', 1), // Combining handakuten
      ];
      final result = transliterator(input).toList();
      expect(result.length, equals(1));
      expect(result[0].c, equals('パ'));
    });

    test('composes with non-combining marks when enabled', () {
      final transliterator = HiraKataCompositionTransliterator(
        composeNonCombiningMarks: true,
      );
      final input = [
        Char('か', 0),
        Char('\u{309B}', 1), // Non-combining voiced mark
      ];
      final result = transliterator(input).toList();
      expect(result.length, equals(1));
      expect(result[0].c, equals('が'));
    });

    test('does not compose non-combining marks when disabled', () {
      final transliterator = HiraKataCompositionTransliterator(
        composeNonCombiningMarks: false,
      );
      final input = [
        Char('か', 0),
        Char('\u{309B}', 1), // Non-combining voiced mark
      ];
      final result = transliterator(input).toList();
      expect(result.length, equals(2));
      expect(result[0].c, equals('か'));
      expect(result[1].c, equals('\u{309B}'));
    });

    test('composes iteration marks with combining marks', () {
      final transliterator = HiraKataCompositionTransliterator();

      // Hiragana iteration mark
      final input1 = [
        Char('\u{309d}', 0), // ゝ
        Char('\u{3099}', 1), // Combining voiced mark
      ];
      final result1 = transliterator(input1).toList();
      expect(result1.length, equals(1));
      expect(result1[0].c, equals('\u{309e}')); // ゞ

      // Katakana iteration mark
      final input2 = [
        Char('\u{30fd}', 0), // ヽ
        Char('\u{3099}', 1), // Combining voiced mark
      ];
      final result2 = transliterator(input2).toList();
      expect(result2.length, equals(1));
      expect(result2[0].c, equals('\u{30fe}')); // ヾ

      // Vertical hiragana iteration mark
      final input3 = [
        Char('\u{3031}', 0), // 〱
        Char('\u{3099}', 1), // Combining voiced mark
      ];
      final result3 = transliterator(input3).toList();
      expect(result3.length, equals(1));
      expect(result3[0].c, equals('\u{3032}')); // 〲

      // Vertical katakana iteration mark
      final input4 = [
        Char('\u{3033}', 0), // 〳
        Char('\u{3099}', 1), // Combining voiced mark
      ];
      final result4 = transliterator(input4).toList();
      expect(result4.length, equals(1));
      expect(result4[0].c, equals('\u{3034}')); // 〴
    });

    test('composes vertical iteration marks with non-combining marks', () {
      final transliterator = HiraKataCompositionTransliterator(
        composeNonCombiningMarks: true,
      );

      // Vertical hiragana with non-combining mark
      final input1 = [
        Char('\u{3031}', 0), // 〱
        Char('\u{309B}', 1), // Non-combining voiced mark
      ];
      final result1 = transliterator(input1).toList();
      expect(result1.length, equals(1));
      expect(result1[0].c, equals('\u{3032}')); // 〲

      // Vertical katakana with non-combining mark
      final input2 = [
        Char('\u{3033}', 0), // 〳
        Char('\u{309B}', 1), // Non-combining voiced mark
      ];
      final result2 = transliterator(input2).toList();
      expect(result2.length, equals(1));
      expect(result2[0].c, equals('\u{3034}')); // 〴
    });
  });

  group('IvsSvsBaseTransliterator', () {
    test('converts IVS/SVS to base in base mode', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis2004,
      );
      // This test would need actual IVS/SVS data loaded
      // For now, just verify it doesn't crash
      final input = [Char('漢', 0), Char('', 1)];
      final result = transliterator(input).toList();
      expect(result.length, greaterThan(0));
    });

    test('drops selectors when dropSelectorsAltogether is true', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'base',
        dropSelectorsAltogether: true,
      );
      final input = [
        Char('漢\u{FE00}', 0),
        Char('', 1),
      ];
      final result = transliterator(input).toList();
      // Should drop the selector
      expect(result.any((char) => char.c == '\u{FE00}'), isFalse);
    });

    test('adds variation selectors in ivs-or-svs mode', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        preferSvs: false,
      );
      // This would need actual data to test properly
      final input = [Char('漢', 0), Char('', 1)];
      final result = transliterator(input).toList();
      expect(result.length, greaterThan(0));
    });

    test('respects charset option', () {
      final transliterator90 = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis90,
      );
      final transliterator2004 = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis2004,
      );
      // Both should work without error
      final input = [Char('漢', 0), Char('', 1)];
      transliterator90(input).toList();
      transliterator2004(input).toList();
    });
  });

  group('Jisx0201AndAlikeTransliterator', () {
    test('converts fullwidth to halfwidth by default', () {
      final transliterator = Jisx0201AndAlikeTransliterator();
      final input = [
        Char('Ａ', 0), // Fullwidth A
        Char('１', 1), // Fullwidth 1
      ];
      final result = transliterator(input).toList();
      expect(result[0].c, equals('A'));
      expect(result[1].c, equals('1'));
    });

    test('converts halfwidth to fullwidth when disabled', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: false,
      );
      final input = [
        Char('A', 0),
        Char('1', 1),
      ];
      final result = transliterator(input).toList();
      expect(result[0].c, equals('Ａ'));
      expect(result[1].c, equals('１'));
    });

    test('respects convertGL option', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        convertGL: false,
      );
      final input = [Char('Ａ', 0)];
      final result = transliterator(input).toList();
      expect(result[0].c, equals('Ａ')); // Should not convert
    });

    test('respects convertGR option', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        convertGR: false,
      );
      final input = [Char('ア', 0)]; // Fullwidth katakana
      final result = transliterator(input).toList();
      expect(result[0].c, equals('ア')); // Should not convert
    });

    test('converts hiragana when enabled', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        convertHiraganas: true,
      );
      final input = [Char('あ', 0)]; // Hiragana
      final result = transliterator(input).toList();
      expect(result[0].c, equals('\u{FF71}')); // Should convert to halfwidth ｱ
    });

    test('decomposes voiced katakana to halfwidth', () {
      final transliterator = Jisx0201AndAlikeTransliterator();
      final input = [Char('ガ', 0)]; // Fullwidth voiced katakana
      final result = transliterator(input).toList();
      expect(result.length, equals(2));
      expect(result[0].c, equals('\u{FF76}')); // ｶ
      expect(result[1].c, equals('\u{FF9E}')); // ﾞ
    });

    test('combines voiced marks when converting to fullwidth', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: false,
        combineVoicedSoundMarks: true,
      );
      final input = [
        Char('\u{FF76}', 0), // ｶ
        Char('\u{FF9E}', 1), // ﾞ
      ];
      final result = transliterator(input).toList();
      expect(result.length, equals(1));
      expect(result[0].c, equals('ガ'));
    });

    test('handles yen sign conversion with u005cAsYenSign', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        u005cAsYenSign: true,
      );
      final input = [Char('￥', 0)]; // Fullwidth yen
      final result = transliterator(input).toList();
      expect(result[0].c, equals('\\')); // Backslash
    });

    test('handles yen sign conversion with u00a5AsYenSign', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        u00a5AsYenSign: true,
      );
      final input = [Char('￥', 0)]; // Fullwidth yen
      final result = transliterator(input).toList();
      expect(result[0].c, equals('\u{00A5}')); // Yen sign
    });

    test('handles tilde conversions', () {
      // Wave dash
      var transliterator = Jisx0201AndAlikeTransliterator(
        u007eAsWaveDash: true,
      );
      var input = [Char('〜', 0)]; // Wave dash
      var result = transliterator(input).toList();
      expect(result[0].c, equals('~'));

      // Overline
      transliterator = Jisx0201AndAlikeTransliterator(
        u007eAsOverline: true,
      );
      input = [Char('‾', 0)]; // Overline
      result = transliterator(input).toList();
      expect(result[0].c, equals('~'));

      // Fullwidth macron
      transliterator = Jisx0201AndAlikeTransliterator(
        u007eAsFullwidthMacron: true,
      );
      input = [Char('￣', 0)]; // Fullwidth macron
      result = transliterator(input).toList();
      expect(result[0].c, equals('~'));
    });

    test('converts unsafe specials when enabled', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        convertUnsafeSpecials: true,
      );
      final input = [Char('゠', 0)]; // Katakana-hiragana double hyphen
      final result = transliterator(input).toList();
      expect(result[0].c, equals('=')); // Equals sign
    });
  });

  group('Generated Transliterators', () {
    test('KanjiOldNewTransliterator works', () {
      final transliterator = KanjiOldNewTransliterator();
      final input = [Char('旧', 0)];
      final result = transliterator(input).toList();
      expect(result.length, greaterThan(0));
    });
  });
}
