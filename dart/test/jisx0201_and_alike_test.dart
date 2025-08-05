import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('JisX0201AndAlikeTransliterator', () {
    group('Fullwidth to Halfwidth conversion', () {
      test('converts fullwidth ASCII to halfwidth with convertGL=true', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
        );

        final testCases = [
          ('！', '!'), ('＂', '"'), ('＃', '#'), ('＄', '\$'), ('％', '%'),
          ('＆', '&'), ('＇', "'"), ('（', '('), ('）', ')'), ('＊', '*'),
          ('＋', '+'), ('，', ','), ('－', '-'), ('．', '.'), ('／', '/'),
          ('０', '0'), ('１', '1'), ('２', '2'), ('３', '3'), ('４', '4'),
          ('５', '5'), ('６', '6'), ('７', '7'), ('８', '8'), ('９', '9'),
          ('：', ':'), ('；', ';'), ('＜', '<'), ('＝', '='), ('＞', '>'),
          ('？', '?'), ('＠', '@'),
          ('Ａ', 'A'), ('Ｂ', 'B'), ('Ｃ', 'C'), ('Ｚ', 'Z'),
          ('ａ', 'a'), ('ｂ', 'b'), ('ｃ', 'c'), ('ｚ', 'z'),
          ('［', '['), ('］', ']'), ('＾', '^'), ('＿', '_'),
          ('｀', '`'), ('｛', '{'), ('｜', '|'), ('｝', '}'),
          ('　', ' '), // Ideographic space to space
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.length, equals(1));
          expect(result[0].c, equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('converts fullwidth katakana to halfwidth with convertGR=true', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGR: true,
        );

        final testCases = [
          ('ア', 'ｱ'),
          ('イ', 'ｲ'),
          ('ウ', 'ｳ'),
          ('エ', 'ｴ'),
          ('オ', 'ｵ'),
          ('カ', 'ｶ'),
          ('キ', 'ｷ'),
          ('ク', 'ｸ'),
          ('ケ', 'ｹ'),
          ('コ', 'ｺ'),
          ('サ', 'ｻ'),
          ('シ', 'ｼ'),
          ('ス', 'ｽ'),
          ('セ', 'ｾ'),
          ('ソ', 'ｿ'),
          ('タ', 'ﾀ'),
          ('チ', 'ﾁ'),
          ('ツ', 'ﾂ'),
          ('テ', 'ﾃ'),
          ('ト', 'ﾄ'),
          ('ナ', 'ﾅ'),
          ('ニ', 'ﾆ'),
          ('ヌ', 'ﾇ'),
          ('ネ', 'ﾈ'),
          ('ノ', 'ﾉ'),
          ('ハ', 'ﾊ'),
          ('ヒ', 'ﾋ'),
          ('フ', 'ﾌ'),
          ('ヘ', 'ﾍ'),
          ('ホ', 'ﾎ'),
          ('マ', 'ﾏ'),
          ('ミ', 'ﾐ'),
          ('ム', 'ﾑ'),
          ('メ', 'ﾒ'),
          ('モ', 'ﾓ'),
          ('ヤ', 'ﾔ'),
          ('ユ', 'ﾕ'),
          ('ヨ', 'ﾖ'),
          ('ラ', 'ﾗ'),
          ('リ', 'ﾘ'),
          ('ル', 'ﾙ'),
          ('レ', 'ﾚ'),
          ('ロ', 'ﾛ'),
          ('ワ', 'ﾜ'),
          ('ヲ', 'ｦ'),
          ('ン', 'ﾝ'),
          ('ァ', 'ｧ'),
          ('ィ', 'ｨ'),
          ('ゥ', 'ｩ'),
          ('ェ', 'ｪ'),
          ('ォ', 'ｫ'),
          ('ッ', 'ｯ'),
          ('ャ', 'ｬ'),
          ('ュ', 'ｭ'),
          ('ョ', 'ｮ'),
          ('ー', 'ｰ'),
          ('・', '･'),
          ('「', '｢'),
          ('」', '｣'),
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.length, equals(1));
          expect(result[0].c, equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('decomposes voiced katakana to base + voice mark', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGR: true,
        );

        final testCases = [
          ('ガ', 'ｶﾞ'),
          ('ギ', 'ｷﾞ'),
          ('グ', 'ｸﾞ'),
          ('ゲ', 'ｹﾞ'),
          ('ゴ', 'ｺﾞ'),
          ('ザ', 'ｻﾞ'),
          ('ジ', 'ｼﾞ'),
          ('ズ', 'ｽﾞ'),
          ('ゼ', 'ｾﾞ'),
          ('ゾ', 'ｿﾞ'),
          ('ダ', 'ﾀﾞ'),
          ('ヂ', 'ﾁﾞ'),
          ('ヅ', 'ﾂﾞ'),
          ('デ', 'ﾃﾞ'),
          ('ド', 'ﾄﾞ'),
          ('バ', 'ﾊﾞ'),
          ('ビ', 'ﾋﾞ'),
          ('ブ', 'ﾌﾞ'),
          ('ベ', 'ﾍﾞ'),
          ('ボ', 'ﾎﾞ'),
          ('ヴ', 'ｳﾞ'),
          ('パ', 'ﾊﾟ'),
          ('ピ', 'ﾋﾟ'),
          ('プ', 'ﾌﾟ'),
          ('ペ', 'ﾍﾟ'),
          ('ポ', 'ﾎﾟ'),
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.map((c) => c.c).join(), equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('respects convertGL=false option', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: false,
          convertGR: true,
        );

        // ASCII should not convert
        final ascii = [Char('Ａ', 0), Char('１', 1), Char('！', 2)];
        final asciiResult = transliterator(ascii).toList();
        expect(asciiResult[0].c, equals('Ａ'));
        expect(asciiResult[1].c, equals('１'));
        expect(asciiResult[2].c, equals('！'));

        // Katakana should still convert
        final katakana = [Char('ア', 0)];
        final katakanaResult = transliterator(katakana).toList();
        expect(katakanaResult[0].c, equals('ｱ'));
      });

      test('respects convertGR=false option', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          convertGR: false,
        );

        // Katakana should not convert
        final katakana = [Char('ア', 0), Char('カ', 1)];
        final katakanaResult = transliterator(katakana).toList();
        expect(katakanaResult[0].c, equals('ア'));
        expect(katakanaResult[1].c, equals('カ'));

        // ASCII should still convert
        final ascii = [Char('Ａ', 0)];
        final asciiResult = transliterator(ascii).toList();
        expect(asciiResult[0].c, equals('A'));
      });

      test('converts hiragana to halfwidth katakana when convertHiraganas=true',
          () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertHiraganas: true,
          convertGR: true,
        );

        final testCases = [
          ('あ', 'ｱ'),
          ('い', 'ｲ'),
          ('う', 'ｳ'),
          ('え', 'ｴ'),
          ('お', 'ｵ'),
          ('か', 'ｶ'),
          ('き', 'ｷ'),
          ('く', 'ｸ'),
          ('け', 'ｹ'),
          ('こ', 'ｺ'),
          ('が', 'ｶﾞ'),
          ('ぎ', 'ｷﾞ'),
          ('ぐ', 'ｸﾞ'),
          ('げ', 'ｹﾞ'),
          ('ご', 'ｺﾞ'),
          ('ぱ', 'ﾊﾟ'),
          ('ぴ', 'ﾋﾟ'),
          ('ぷ', 'ﾌﾟ'),
          ('ぺ', 'ﾍﾟ'),
          ('ぽ', 'ﾎﾟ'),
          ('ん', 'ﾝ'),
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.map((c) => c.c).join(), equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('preserves hiragana when convertHiraganas=false', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertHiraganas: false,
          convertGR: true,
        );

        final hiragana = 'あいうえお';
        final result =
            transliterator(hiragana.split('').map((c) => Char(c, 0))).toList();
        expect(result.map((c) => c.c).join(), equals(hiragana));
      });

      test('converts unsafe specials when enabled', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertUnsafeSpecials: true,
        );

        final input = [Char('゠', 0)]; // U+30A0
        final result = transliterator(input).toList();
        expect(result[0].c, equals('='));
      });

      test('preserves unsafe specials when disabled', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertUnsafeSpecials: false,
        );

        final input = [Char('゠', 0)]; // U+30A0
        final result = transliterator(input).toList();
        expect(result[0].c, equals('゠'));
      });

      test('handles backslash conversion with u005cAsBackslash', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          u005cAsBackslash: true,
        );

        final input = [Char('＼', 0)]; // Fullwidth backslash
        final result = transliterator(input).toList();
        expect(result[0].c, equals('\\'));
      });

      test('handles complex mixed content', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          convertGR: true,
        );

        final input = 'Ｈｅｌｌｏ　世界！　カタカナ　１２３';
        final expected = 'Hello 世界! ｶﾀｶﾅ 123';

        final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
        final result = transliterator(chars).toList();
        expect(result.map((c) => c.c).join(), equals(expected));
      });
    });

    group('Halfwidth to Fullwidth conversion', () {
      test('converts halfwidth ASCII to fullwidth with convertGL=true', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGL: true,
        );

        final testCases = [
          ('!', '！'), ('"', '＂'), ('#', '＃'), ('\$', '＄'), ('%', '％'),
          ('&', '＆'), ("'", '＇'), ('(', '（'), (')', '）'), ('*', '＊'),
          ('+', '＋'), (',', '，'), ('-', '－'), ('.', '．'), ('/', '／'),
          ('0', '０'), ('1', '１'), ('2', '２'), ('3', '３'), ('9', '９'),
          ('A', 'Ａ'), ('B', 'Ｂ'), ('Z', 'Ｚ'),
          ('a', 'ａ'), ('b', 'ｂ'), ('z', 'ｚ'),
          ('[', '［'), (']', '］'), ('^', '＾'), ('_', '＿'),
          ('`', '｀'), ('{', '｛'), ('|', '｜'), ('}', '｝'),
          (' ', '　'), // Space to ideographic space
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.length, equals(1));
          expect(result[0].c, equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('converts halfwidth katakana to fullwidth with convertGR=true', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGR: true,
        );

        final testCases = [
          ('ｱ', 'ア'),
          ('ｲ', 'イ'),
          ('ｳ', 'ウ'),
          ('ｴ', 'エ'),
          ('ｵ', 'オ'),
          ('ｶ', 'カ'),
          ('ｷ', 'キ'),
          ('ｸ', 'ク'),
          ('ｹ', 'ケ'),
          ('ｺ', 'コ'),
          ('ｻ', 'サ'),
          ('ｼ', 'シ'),
          ('ｽ', 'ス'),
          ('ｾ', 'セ'),
          ('ｿ', 'ソ'),
          ('ﾀ', 'タ'),
          ('ﾁ', 'チ'),
          ('ﾂ', 'ツ'),
          ('ﾃ', 'テ'),
          ('ﾄ', 'ト'),
          ('ﾅ', 'ナ'),
          ('ﾆ', 'ニ'),
          ('ﾇ', 'ヌ'),
          ('ﾈ', 'ネ'),
          ('ﾉ', 'ノ'),
          ('ﾊ', 'ハ'),
          ('ﾋ', 'ヒ'),
          ('ﾌ', 'フ'),
          ('ﾍ', 'ヘ'),
          ('ﾎ', 'ホ'),
          ('ﾏ', 'マ'),
          ('ﾐ', 'ミ'),
          ('ﾑ', 'ム'),
          ('ﾒ', 'メ'),
          ('ﾓ', 'モ'),
          ('ﾔ', 'ヤ'),
          ('ﾕ', 'ユ'),
          ('ﾖ', 'ヨ'),
          ('ﾗ', 'ラ'),
          ('ﾘ', 'リ'),
          ('ﾙ', 'ル'),
          ('ﾚ', 'レ'),
          ('ﾛ', 'ロ'),
          ('ﾜ', 'ワ'),
          ('ｦ', 'ヲ'),
          ('ﾝ', 'ン'),
          ('ｧ', 'ァ'),
          ('ｨ', 'ィ'),
          ('ｩ', 'ゥ'),
          ('ｪ', 'ェ'),
          ('ｫ', 'ォ'),
          ('ｯ', 'ッ'),
          ('ｬ', 'ャ'),
          ('ｭ', 'ュ'),
          ('ｮ', 'ョ'),
          ('ｰ', 'ー'),
        ];

        for (final (input, expected) in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result.length, equals(1));
          expect(result[0].c, equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('combines voiced marks when combineVoicedSoundMarks=true', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGR: true,
          combineVoicedSoundMarks: true,
        );

        final testCases = [
          ('ｶﾞ', 'ガ'),
          ('ｷﾞ', 'ギ'),
          ('ｸﾞ', 'グ'),
          ('ｹﾞ', 'ゲ'),
          ('ｺﾞ', 'ゴ'),
          ('ｻﾞ', 'ザ'),
          ('ｼﾞ', 'ジ'),
          ('ｽﾞ', 'ズ'),
          ('ｾﾞ', 'ゼ'),
          ('ｿﾞ', 'ゾ'),
          ('ﾀﾞ', 'ダ'),
          ('ﾁﾞ', 'ヂ'),
          ('ﾂﾞ', 'ヅ'),
          ('ﾃﾞ', 'デ'),
          ('ﾄﾞ', 'ド'),
          ('ﾊﾞ', 'バ'),
          ('ﾋﾞ', 'ビ'),
          ('ﾌﾞ', 'ブ'),
          ('ﾍﾞ', 'ベ'),
          ('ﾎﾞ', 'ボ'),
          ('ｳﾞ', 'ヴ'),
          ('ﾊﾟ', 'パ'),
          ('ﾋﾟ', 'ピ'),
          ('ﾌﾟ', 'プ'),
          ('ﾍﾟ', 'ペ'),
          ('ﾎﾟ', 'ポ'),
        ];

        for (final (input, expected) in testCases) {
          final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
          final result = transliterator(chars).toList();
          expect(result.map((c) => c.c).join(), equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('preserves separate voice marks when combineVoicedSoundMarks=false',
          () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGR: true,
          combineVoicedSoundMarks: false,
        );

        final testCases = [
          ('ｶﾞ', 'カ゛'),
          ('ｷﾞ', 'キ゛'),
          ('ｸﾞ', 'ク゛'),
          ('ﾊﾟ', 'ハ゜'),
          ('ﾋﾟ', 'ヒ゜'),
          ('ﾌﾟ', 'フ゜'),
        ];

        for (final (input, expected) in testCases) {
          final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
          final result = transliterator(chars).toList();
          expect(result.map((c) => c.c).join(), equals(expected),
              reason: 'Failed for input: $input');
        }
      });

      test('handles yen sign conversion with u00a5AsYenSign', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGL: true,
          u00a5AsYenSign: true,
        );

        final input = [Char('¥', 0)]; // Half-width yen
        final result = transliterator(input).toList();
        expect(result[0].c, equals('￥'));
      });

      // NOTE: The Dart implementation currently converts \ to ＼ by default,
      // which differs from other language implementations that convert to ￥.
      // This is a known difference that may need to be addressed in the future.

      test('handles backslash conversion with u005cAsBackslash', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGL: true,
          u005cAsBackslash: true,
        );

        final input = [Char('\\', 0)];
        final result = transliterator(input).toList();
        expect(result[0].c, equals('＼'));
      });

      test('handles tilde conversions', () {
        // Wave dash
        var transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGL: true,
          u007eAsWaveDash: true,
        );
        var input = [Char('~', 0)];
        var result = transliterator(input).toList();
        expect(result[0].c, equals('\u301c')); // Wave dash

        // When converting back
        transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          u007eAsWaveDash: true,
        );
        input = [Char('\u301c', 0)]; // Wave dash
        result = transliterator(input).toList();
        expect(result[0].c, equals('~'));
      });
    });

    group('Edge cases and special scenarios', () {
      test('handles empty input', () {
        final transliterator = JisX0201AndAlikeTransliterator();
        final result = transliterator([]).toList();
        expect(result, isEmpty);
      });

      test('preserves non-convertible characters', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          convertGR: true,
        );

        final testCases = [
          '漢', // Kanji
          '🎌', // Emoji
          '€', // Euro sign
          'ひ', // Hiragana (when convertHiraganas=false)
        ];

        for (final input in testCases) {
          final result = transliterator([Char(input, 0)]).toList();
          expect(result[0].c, equals(input),
              reason: 'Failed to preserve: $input');
        }
      });

      test('maintains character offsets', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGR: true,
        );

        final input = [
          Char('あ', 0),
          Char('ガ', 5),
          Char('イ', 10),
        ];

        final result = transliterator(input).toList();

        // First character preserved (hiragana)
        expect(result[0].offset, equals(0));

        // Voiced katakana splits but maintains original source character offset
        expect(result[1].offset, equals(1)); // ｶ (offset counter increments)
        expect(result[2].offset, equals(2)); // ﾞ

        // Last character
        expect(result[3].offset, equals(3)); // ｲ
      });

      test('handles mixed complex string', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          convertGR: true,
          convertHiraganas: true,
        );

        final input =
            '字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー゠';
        final expected =
            '字!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ=';

        final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
        final result = transliterator(chars).toList();
        expect(result.map((c) => c.c).join(), equals(expected));
      });

      test('all options default test', () {
        // Test with default options (should be fullwidthToHalfwidth=true)
        final transliterator = JisX0201AndAlikeTransliterator();

        final input = [Char('Ａ', 0), Char('ア', 1)];
        final result = transliterator(input).toList();

        // Should convert both by default
        expect(result[0].c, equals('A'));
        expect(result[1].c, equals('ｱ'));
      });
    });

    group('Comprehensive test cases from other languages', () {
      test('matches JavaScript test case 1', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: false,
          convertGR: false,
        );

        final input =
            '字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー゠';
        final expected = input; // No conversion

        final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
        final result = transliterator(chars).toList();
        expect(result.map((c) => c.c).join(), equals(expected));
      });

      test('matches Python fullwidth to halfwidth with GL and GR', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: true,
          convertGL: true,
          convertGR: true,
        );

        final input =
            '字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー゠';
        final expected =
            '字!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ=';

        final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
        final result = transliterator(chars).toList();
        expect(result.map((c) => c.c).join(), equals(expected));
      });

      test('matches Ruby halfwidth to fullwidth with voice mark combining', () {
        final transliterator = JisX0201AndAlikeTransliterator(
          fullwidthToHalfwidth: false,
          convertGL: true,
          convertGR: true,
          combineVoicedSoundMarks: true,
        );

        final input =
            '!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ';
        final expected =
            '！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝\uff5eァィゥェォャュョッアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー';

        final chars = input.split('').indexed.map((e) => Char(e.$2, e.$1));
        final result = transliterator(chars).toList();
        expect(result.map((c) => c.c).join(), equals(expected));
      });
    });
  });
}
