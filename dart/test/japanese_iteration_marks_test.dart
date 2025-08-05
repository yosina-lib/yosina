import 'package:test/test.dart';
import 'package:yosina/src/transliterators/japanese_iteration_marks_transliterator.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('JapaneseIterationMarksTransliterator', () {
    String transliterate(String input) {
      final transliterator = JapaneseIterationMarksTransliterator();
      final chars = <Char>[];
      var offset = 0;
      for (final rune in input.runes) {
        final char = String.fromCharCode(rune);
        chars.add(Char(char, offset));
        offset += char.length;
      }
      final result = transliterator(chars).toList();
      return result.map((c) => c.c).join();
    }

    test('basic hiragana repetition', () {
      // Basic hiragana repetition
      expect(transliterate('さゝ'), equals('ささ'));

      // Multiple hiragana repetitions
      expect(transliterate('みゝこゝろ'), equals('みみこころ'));
    });

    test('hiragana voiced repetition', () {
      // Hiragana voiced repetition
      expect(transliterate('はゞ'), equals('はば'));

      // Multiple voiced repetitions
      expect(transliterate('たゞしゞま'), equals('ただしじま'));
    });

    test('basic katakana repetition', () {
      // Basic katakana repetition
      expect(transliterate('サヽ'), equals('ササ'));
    });

    test('katakana voiced repetition', () {
      // Katakana voiced repetition
      expect(transliterate('ハヾ'), equals('ハバ'));

      // Special case: ウ with voicing
      expect(transliterate('ウヾ'), equals('ウヴ'));
    });

    test('kanji repetition', () {
      // Basic kanji repetition
      expect(transliterate('人々'), equals('人人'));

      // Multiple kanji repetitions
      expect(transliterate('日々月々年々'), equals('日日月月年年'));

      // Kanji in compound words
      expect(transliterate('色々'), equals('色色'));
    });

    test('invalid combinations', () {
      // Hiragana mark after katakana
      expect(transliterate('カゝ'), equals('カゝ'));

      // Katakana mark after hiragana
      expect(transliterate('かヽ'), equals('かヽ'));

      // Kanji mark after hiragana
      expect(transliterate('か々'), equals('か々'));

      // Iteration mark at start
      expect(transliterate('ゝあ'), equals('ゝあ'));
    });

    test('consecutive iteration marks', () {
      // Consecutive iteration marks - only first should be expanded
      expect(transliterate('さゝゝ'), equals('ささゝ'));
    });

    test('non-repeatable characters', () {
      // Hiragana hatsuon can't repeat
      expect(transliterate('んゝ'), equals('んゝ'));

      // Hiragana sokuon can't repeat
      expect(transliterate('っゝ'), equals('っゝ'));

      // Katakana hatsuon can't repeat
      expect(transliterate('ンヽ'), equals('ンヽ'));

      // Katakana sokuon can't repeat
      expect(transliterate('ッヽ'), equals('ッヽ'));

      // Voiced character can't voice again
      expect(transliterate('がゞ'), equals('がゞ'));

      // Semi-voiced character can't voice
      expect(transliterate('ぱゞ'), equals('ぱゞ'));
    });

    test('mixed text', () {
      // Mixed hiragana, katakana, and kanji
      expect(transliterate('こゝろ、コヽロ、其々'), equals('こころ、ココロ、其其'));

      // Iteration marks in sentence
      expect(transliterate('日々の暮らしはさゝやか'), equals('日日の暮らしはささやか'));
    });

    test('halfwidth katakana', () {
      // Halfwidth katakana should not be supported
      expect(transliterate('ｻヽ'), equals('ｻヽ'));
    });

    test('voicing edge cases', () {
      // No voicing possible
      expect(transliterate('あゞ'), equals('あゞ'));

      // Voicing all consonants
      expect(transliterate('かゞたゞはゞさゞ'), equals('かがただはばさざ'));
    });

    test('complex scenarios', () {
      // Multiple types in sequence
      expect(transliterate('思々にこゝろサヾめく'), equals('思思にこころサザめく'));
    });

    test('empty string', () {
      expect(transliterate(''), equals(''));
    });

    test('no iteration marks', () {
      const input = 'これはテストです';
      expect(transliterate(input), equals(input));
    });

    test('iteration mark after space', () {
      expect(transliterate('さ ゝ'), equals('さ ゝ'));
    });

    test('iteration mark after punctuation', () {
      expect(transliterate('さ、ゝ'), equals('さ、ゝ'));
    });

    test('iteration mark after ASCII', () {
      expect(transliterate('Aゝ'), equals('Aゝ'));
    });

    test('CJK extension kanji', () {
      // CJK Extension A kanji
      expect(transliterate('㐀々'), equals('㐀㐀'));
    });

    test('multiple iteration marks in different contexts', () {
      // Test various combinations
      expect(transliterate('すゝむ、タヾカウ、山々'), equals('すすむ、タダカウ、山山'));
      expect(transliterate('はゝ、マヾ'), equals('はは、マヾ')); // マ doesn't have voicing
    });

    test('kanji iteration mark after katakana', () {
      // Kanji iteration mark should not work after katakana
      expect(transliterate('ア々'), equals('ア々'));
    });

    test('voicing variations', () {
      // Test all possible voicing combinations for hiragana
      expect(transliterate('かゞ'), equals('かが'));
      expect(transliterate('きゞ'), equals('きぎ'));
      expect(transliterate('くゞ'), equals('くぐ'));
      expect(transliterate('けゞ'), equals('けげ'));
      expect(transliterate('こゞ'), equals('こご'));
      expect(transliterate('さゞ'), equals('さざ'));
      expect(transliterate('しゞ'), equals('しじ'));
      expect(transliterate('すゞ'), equals('すず'));
      expect(transliterate('せゞ'), equals('せぜ'));
      expect(transliterate('そゞ'), equals('そぞ'));
      expect(transliterate('たゞ'), equals('ただ'));
      expect(transliterate('ちゞ'), equals('ちぢ'));
      expect(transliterate('つゞ'), equals('つづ'));
      expect(transliterate('てゞ'), equals('てで'));
      expect(transliterate('とゞ'), equals('とど'));
      expect(transliterate('はゞ'), equals('はば'));
      expect(transliterate('ひゞ'), equals('ひび'));
      expect(transliterate('ふゞ'), equals('ふぶ'));
      expect(transliterate('へゞ'), equals('へべ'));
      expect(transliterate('ほゞ'), equals('ほぼ'));
    });

    test('katakana voicing variations', () {
      // Test all possible voicing combinations for katakana
      expect(transliterate('カヾ'), equals('カガ'));
      expect(transliterate('キヾ'), equals('キギ'));
      expect(transliterate('クヾ'), equals('クグ'));
      expect(transliterate('ケヾ'), equals('ケゲ'));
      expect(transliterate('コヾ'), equals('コゴ'));
      expect(transliterate('サヾ'), equals('サザ'));
      expect(transliterate('シヾ'), equals('シジ'));
      expect(transliterate('スヾ'), equals('スズ'));
      expect(transliterate('セヾ'), equals('セゼ'));
      expect(transliterate('ソヾ'), equals('ソゾ'));
      expect(transliterate('タヾ'), equals('タダ'));
      expect(transliterate('チヾ'), equals('チヂ'));
      expect(transliterate('ツヾ'), equals('ツヅ'));
      expect(transliterate('テヾ'), equals('テデ'));
      expect(transliterate('トヾ'), equals('トド'));
      expect(transliterate('ハヾ'), equals('ハバ'));
      expect(transliterate('ヒヾ'), equals('ヒビ'));
      expect(transliterate('フヾ'), equals('フブ'));
      expect(transliterate('ヘヾ'), equals('ヘベ'));
      expect(transliterate('ホヾ'), equals('ホボ'));
      expect(transliterate('ウヾ'), equals('ウヴ'));
    });

    test('iteration mark combinations', () {
      // Different iteration marks in sequence
      expect(transliterate('さゝカヽ山々'), equals('ささカカ山山'));

      // Mixed with normal text
      expect(transliterate('これはさゝやかな日々です'), equals('これはささやかな日日です'));
    });

    test('special characters as iteration target', () {
      // Small characters can be repeated since they are valid hiragana/katakana
      expect(transliterate('ゃゝ'), equals('ゃゃ')); // Small ya can be repeated
      expect(transliterate('ャヽ'),
          equals('ャャ')); // Small katakana ya can be repeated

      // Prolonged sound mark
      expect(
          transliterate('ーヽ'),
          equals(
              'ーヽ')); // Prolonged sound mark can't be repeated (not katakana)
    });

    test('numbers and iteration marks', () {
      // Numbers followed by iteration marks
      expect(transliterate('1ゝ'), equals('1ゝ'));
      expect(transliterate('１ゝ'), equals('１ゝ'));
    });

    test('complex kanji ranges', () {
      // Test various CJK ranges
      // CJK Extension B
      expect(transliterate('𠀀々'), equals('𠀀𠀀')); // 𠀀𠀀

      // CJK Extension C
      expect(transliterate('𪀀々'), equals('𪀀𪀀')); // 𪀀𪀀
    });

    test('real world examples', () {
      // Common real-world usage
      expect(transliterate('人々'), equals('人人'));
      expect(transliterate('時々'), equals('時時'));
      expect(transliterate('様々'), equals('様様'));
      expect(transliterate('国々'), equals('国国'));
      expect(transliterate('所々'), equals('所所'));

      // In context
      expect(transliterate('様々な国々から'), equals('様様な国国から'));
      expect(transliterate('時々刻々'), equals('時時刻刻'));
    });

    test('edge cases with punctuation', () {
      // Various punctuation between characters and iteration marks
      expect(transliterate('さ。ゝ'), equals('さ。ゝ'));
      expect(transliterate('さ！ゝ'), equals('さ！ゝ'));
      expect(transliterate('さ？ゝ'), equals('さ？ゝ'));
      expect(transliterate('さ「ゝ'), equals('さ「ゝ'));
      expect(transliterate('さ」ゝ'), equals('さ」ゝ'));
    });

    test('mixed script boundaries', () {
      // Script boundaries - iteration marks should work within same script type
      expect(transliterate('漢字かゝ'),
          equals('漢字かか')); // Hiragana iteration mark works after hiragana
      expect(transliterate('ひらがなカヽ'),
          equals('ひらがなカカ')); // Katakana iteration mark works after katakana
      expect(transliterate('カタカナ人々'),
          equals('カタカナ人人')); // Kanji iteration mark works after kanji
    });
  });
}
