import '../char.dart';
import '../transliterator.dart';

/// Japanese iteration marks transliterator.
///
/// This transliterator handles the replacement of Japanese iteration marks with the appropriate
/// repeated characters:
/// - ゝ (hiragana repetition): Repeats previous hiragana if valid
/// - ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
/// - ヽ (katakana repetition): Repeats previous katakana if valid
/// - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
/// - 々 (kanji repetition): Repeats previous kanji
///
/// Invalid combinations remain unchanged. Characters that can't be repeated include:
/// - Voiced/semi-voiced characters
/// - Hatsuon (ん/ン)
/// - Sokuon (っ/ッ)
///
/// Halfwidth katakana with iteration marks are NOT supported.
/// Consecutive iteration marks: only the first one is expanded.

/// Character type classification for iteration mark handling.
enum _CharType {
  other,
  hiragana,
  hiraganaVoiced,
  katakana,
  katakanaVoiced,
  kanji,
}

/// Helper class to store character information for iteration mark processing.
class _CharInfo {
  _CharInfo(this.charStr, this.type);
  final String charStr;
  final _CharType type;
}

class JapaneseIterationMarksTransliterator implements Transliterator {
  /// Creates a Japanese iteration marks transliterator.
  ///
  /// This transliterator replaces iteration marks with the appropriate
  /// repeated characters based on context.
  JapaneseIterationMarksTransliterator();
  // Iteration mark characters
  static const int _hiraganaIterationMark = 0x309D; // ゝ
  static const int _hiraganaVoicedIterationMark = 0x309E; // ゞ
  static const int _katakanaIterationMark = 0x30FD; // ヽ
  static const int _katakanaVoicedIterationMark = 0x30FE; // ヾ
  static const int _kanjiIterationMark = 0x3005; // 々

  // Vertical iteration mark characters
  static const int _verticalHiraganaIterationMark = 0x3031; // 〱
  static const int _verticalHiraganaVoicedIterationMark = 0x3032; // 〲
  static const int _verticalKatakanaIterationMark = 0x3033; // 〳
  static const int _verticalKatakanaVoicedIterationMark = 0x3034; // 〴

  // Special characters that cannot be repeated
  static const Set<int> _hatsuonChars = {
    0x3093, // ん
    0x30F3, // ン
    0xFF9D, // ﾝ (halfwidth)
  };

  static const Set<int> _sokuonChars = {
    0x3063, // っ
    0x30C3, // ッ
    0xFF6F, // ｯ (halfwidth)
  };

  // Semi-voiced characters
  static const Set<String> _semiVoicedChars = {
    // Hiragana semi-voiced
    'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ',
    // Katakana semi-voiced
    'パ', 'ピ', 'プ', 'ペ', 'ポ',
  };

  // Voicing mappings for hiragana
  static const Map<String, String> _hiraganaVoicing = {
    'か': 'が',
    'き': 'ぎ',
    'く': 'ぐ',
    'け': 'げ',
    'こ': 'ご',
    'さ': 'ざ',
    'し': 'じ',
    'す': 'ず',
    'せ': 'ぜ',
    'そ': 'ぞ',
    'た': 'だ',
    'ち': 'ぢ',
    'つ': 'づ',
    'て': 'で',
    'と': 'ど',
    'は': 'ば',
    'ひ': 'び',
    'ふ': 'ぶ',
    'へ': 'べ',
    'ほ': 'ぼ',
  };

  // Voicing mappings for katakana
  static const Map<String, String> _katakanaVoicing = {
    'カ': 'ガ',
    'キ': 'ギ',
    'ク': 'グ',
    'ケ': 'ゲ',
    'コ': 'ゴ',
    'サ': 'ザ',
    'シ': 'ジ',
    'ス': 'ズ',
    'セ': 'ゼ',
    'ソ': 'ゾ',
    'タ': 'ダ',
    'チ': 'ヂ',
    'ツ': 'ヅ',
    'テ': 'デ',
    'ト': 'ド',
    'ハ': 'バ',
    'ヒ': 'ビ',
    'フ': 'ブ',
    'ヘ': 'ベ',
    'ホ': 'ボ',
    'ウ': 'ヴ',
  };

  // Unvoicing mappings for hiragana (voiced -> unvoiced)
  static const Map<String, String> _hiraganaUnvoicing = {
    'が': 'か',
    'ぎ': 'き',
    'ぐ': 'く',
    'げ': 'け',
    'ご': 'こ',
    'ざ': 'さ',
    'じ': 'し',
    'ず': 'す',
    'ぜ': 'せ',
    'ぞ': 'そ',
    'だ': 'た',
    'ぢ': 'ち',
    'づ': 'つ',
    'で': 'て',
    'ど': 'と',
    'ば': 'は',
    'び': 'ひ',
    'ぶ': 'ふ',
    'べ': 'へ',
    'ぼ': 'ほ',
  };

  // Unvoicing mappings for katakana (voiced -> unvoiced)
  static const Map<String, String> _katakanaUnvoicing = {
    'ガ': 'カ',
    'ギ': 'キ',
    'グ': 'ク',
    'ゲ': 'ケ',
    'ゴ': 'コ',
    'ザ': 'サ',
    'ジ': 'シ',
    'ズ': 'ス',
    'ゼ': 'セ',
    'ゾ': 'ソ',
    'ダ': 'タ',
    'ヂ': 'チ',
    'ヅ': 'ツ',
    'デ': 'テ',
    'ド': 'ト',
    'バ': 'ハ',
    'ビ': 'ヒ',
    'ブ': 'フ',
    'ベ': 'ヘ',
    'ボ': 'ホ',
    'ヴ': 'ウ',
  };

  /// Checks if the given codepoint is any type of iteration mark.
  bool _isIterationMark(int codepoint) {
    return codepoint == _hiraganaIterationMark ||
        codepoint == _hiraganaVoicedIterationMark ||
        codepoint == _katakanaIterationMark ||
        codepoint == _katakanaVoicedIterationMark ||
        codepoint == _kanjiIterationMark ||
        codepoint == _verticalHiraganaIterationMark ||
        codepoint == _verticalHiraganaVoicedIterationMark ||
        codepoint == _verticalKatakanaIterationMark ||
        codepoint == _verticalKatakanaVoicedIterationMark;
  }

  /// Determines the character type for iteration mark processing.
  ///
  /// Returns the appropriate [_CharType] based on the character's script
  /// and voicing status. Characters that cannot be repeated (hatsuon,
  /// sokuon, semi-voiced) return [_CharType.other].
  _CharType _getCharType(String charStr) {
    if (charStr.isEmpty) {
      return _CharType.other;
    }

    final runes = charStr.runes;
    if (runes.isEmpty) {
      return _CharType.other;
    }

    final codepoint = runes.first;

    // Check if it's hatsuon or sokuon
    if (_hatsuonChars.contains(codepoint) || _sokuonChars.contains(codepoint)) {
      return _CharType.other;
    }

    // Check if it's semi-voiced
    if (_semiVoicedChars.contains(charStr)) {
      return _CharType.other;
    }

    // Check if it's a voiced character before determining script type
    final isVoiced = _hiraganaVoicing.values.contains(charStr) ||
        _katakanaVoicing.values.contains(charStr);

    // Hiragana (excluding special marks)
    if (codepoint >= 0x3041 && codepoint <= 0x3096) {
      return isVoiced ? _CharType.hiraganaVoiced : _CharType.hiragana;
    }

    // Katakana (excluding halfwidth and special marks)
    if (codepoint >= 0x30A1 && codepoint <= 0x30FA) {
      return isVoiced ? _CharType.katakanaVoiced : _CharType.katakana;
    }

    // Kanji - CJK Unified Ideographs (common ranges)
    if ((codepoint >= 0x4E00 && codepoint <= 0x9FFF) ||
        (codepoint >= 0x3400 && codepoint <= 0x4DBF) ||
        (codepoint >= 0x20000 && codepoint <= 0x2A6DF) ||
        (codepoint >= 0x2A700 && codepoint <= 0x2B73F) ||
        (codepoint >= 0x2B740 && codepoint <= 0x2B81F) ||
        (codepoint >= 0x2B820 && codepoint <= 0x2CEAF) ||
        (codepoint >= 0x2CEB0 && codepoint <= 0x2EBEF) ||
        (codepoint >= 0x30000 && codepoint <= 0x3134F)) {
      return _CharType.kanji;
    }

    return _CharType.other;
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    _CharInfo? prevCharInfo;
    bool prevWasIterationMark = false;

    for (final char in inputChars) {
      final currentChar = char.c;
      final runes = currentChar.runes;
      final codepoint = runes.isNotEmpty ? runes.first : -1;

      if (codepoint >= 0 && _isIterationMark(codepoint)) {
        // Check if previous character was also an iteration mark
        if (prevWasIterationMark) {
          // Don't replace consecutive iteration marks
          yield char.withOffset(offset);
          offset += currentChar.length;
          prevWasIterationMark = true;
          continue;
        }

        // Try to replace the iteration mark
        String? replacement;
        if (prevCharInfo != null) {
          switch (codepoint) {
            case _hiraganaIterationMark:
            case _verticalHiraganaIterationMark:
              // Repeat previous hiragana if valid
              if (prevCharInfo.type == _CharType.hiragana) {
                replacement = prevCharInfo.charStr;
              } else if (prevCharInfo.type == _CharType.hiraganaVoiced) {
                // Voiced character followed by unvoiced iteration mark
                replacement = _hiraganaUnvoicing[prevCharInfo.charStr];
              }
              break;

            case _hiraganaVoicedIterationMark:
            case _verticalHiraganaVoicedIterationMark:
              // Repeat previous hiragana with voicing if possible
              if (prevCharInfo.type == _CharType.hiragana) {
                replacement = _hiraganaVoicing[prevCharInfo.charStr];
              } else if (prevCharInfo.type == _CharType.hiraganaVoiced) {
                // Voiced character followed by voiced iteration mark
                replacement = prevCharInfo.charStr;
              }
              break;

            case _katakanaIterationMark:
            case _verticalKatakanaIterationMark:
              // Repeat previous katakana if valid
              if (prevCharInfo.type == _CharType.katakana) {
                replacement = prevCharInfo.charStr;
              } else if (prevCharInfo.type == _CharType.katakanaVoiced) {
                // Voiced character followed by unvoiced iteration mark
                replacement = _katakanaUnvoicing[prevCharInfo.charStr];
              }
              break;

            case _katakanaVoicedIterationMark:
            case _verticalKatakanaVoicedIterationMark:
              // Repeat previous katakana with voicing if possible
              if (prevCharInfo.type == _CharType.katakana) {
                replacement = _katakanaVoicing[prevCharInfo.charStr];
              } else if (prevCharInfo.type == _CharType.katakanaVoiced) {
                // Voiced character followed by voiced iteration mark
                replacement = prevCharInfo.charStr;
              }
              break;

            case _kanjiIterationMark:
              // Repeat previous kanji
              if (prevCharInfo.type == _CharType.kanji) {
                replacement = prevCharInfo.charStr;
              }
              break;
          }
        }

        if (replacement != null) {
          // Replace the iteration mark
          yield Char(replacement, offset, char);
          offset += replacement.length;
          prevWasIterationMark = true;
          // Keep the original prevCharInfo - don't update it
        } else {
          // Couldn't replace the iteration mark
          yield char.withOffset(offset);
          offset += currentChar.length;
          prevWasIterationMark = true;
        }
      } else {
        // Not an iteration mark
        yield char.withOffset(offset);
        offset += currentChar.length;

        // Update previous character info
        final charType = _getCharType(currentChar);
        if (charType != _CharType.other) {
          prevCharInfo = _CharInfo(currentChar, charType);
        } else {
          prevCharInfo = null;
        }

        prevWasIterationMark = false;
      }
    }
  }
}
