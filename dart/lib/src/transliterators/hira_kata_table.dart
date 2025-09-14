/// Shared hiragana-katakana mapping table.
///
/// This class provides static data and utility methods for converting between
/// hiragana, katakana, and halfwidth katakana characters. It serves as a
/// central repository for character mappings used by various transliterators.
class HiraKataTable {
  // Private constructor to prevent instantiation
  HiraKataTable._();

  /// Main mapping table for hiragana and katakana characters.
  ///
  /// Each entry contains:
  /// - Hiragana forms: (base, voiced with dakuten, semi-voiced with handakuten)
  /// - Katakana forms: (base, voiced with dakuten, semi-voiced with handakuten)
  /// - Halfwidth katakana form (if available)
  ///
  /// Empty strings indicate that a particular form doesn't exist.
  static const hiraganaKatakanaTable = [
    // Vowels
    (('あ', '', ''), ('ア', '', ''), 'ｱ'),
    (('い', '', ''), ('イ', '', ''), 'ｲ'),
    (('う', 'ゔ', ''), ('ウ', 'ヴ', ''), 'ｳ'),
    (('え', '', ''), ('エ', '', ''), 'ｴ'),
    (('お', '', ''), ('オ', '', ''), 'ｵ'),
    // K-row
    (('か', 'が', ''), ('カ', 'ガ', ''), 'ｶ'),
    (('き', 'ぎ', ''), ('キ', 'ギ', ''), 'ｷ'),
    (('く', 'ぐ', ''), ('ク', 'グ', ''), 'ｸ'),
    (('け', 'げ', ''), ('ケ', 'ゲ', ''), 'ｹ'),
    (('こ', 'ご', ''), ('コ', 'ゴ', ''), 'ｺ'),
    // S-row
    (('さ', 'ざ', ''), ('サ', 'ザ', ''), 'ｻ'),
    (('し', 'じ', ''), ('シ', 'ジ', ''), 'ｼ'),
    (('す', 'ず', ''), ('ス', 'ズ', ''), 'ｽ'),
    (('せ', 'ぜ', ''), ('セ', 'ゼ', ''), 'ｾ'),
    (('そ', 'ぞ', ''), ('ソ', 'ゾ', ''), 'ｿ'),
    // T-row
    (('た', 'だ', ''), ('タ', 'ダ', ''), 'ﾀ'),
    (('ち', 'ぢ', ''), ('チ', 'ヂ', ''), 'ﾁ'),
    (('つ', 'づ', ''), ('ツ', 'ヅ', ''), 'ﾂ'),
    (('て', 'で', ''), ('テ', 'デ', ''), 'ﾃ'),
    (('と', 'ど', ''), ('ト', 'ド', ''), 'ﾄ'),
    // N-row
    (('な', '', ''), ('ナ', '', ''), 'ﾅ'),
    (('に', '', ''), ('ニ', '', ''), 'ﾆ'),
    (('ぬ', '', ''), ('ヌ', '', ''), 'ﾇ'),
    (('ね', '', ''), ('ネ', '', ''), 'ﾈ'),
    (('の', '', ''), ('ノ', '', ''), 'ﾉ'),
    // H-row
    (('は', 'ば', 'ぱ'), ('ハ', 'バ', 'パ'), 'ﾊ'),
    (('ひ', 'び', 'ぴ'), ('ヒ', 'ビ', 'ピ'), 'ﾋ'),
    (('ふ', 'ぶ', 'ぷ'), ('フ', 'ブ', 'プ'), 'ﾌ'),
    (('へ', 'べ', 'ぺ'), ('ヘ', 'ベ', 'ペ'), 'ﾍ'),
    (('ほ', 'ぼ', 'ぽ'), ('ホ', 'ボ', 'ポ'), 'ﾎ'),
    // M-row
    (('ま', '', ''), ('マ', '', ''), 'ﾏ'),
    (('み', '', ''), ('ミ', '', ''), 'ﾐ'),
    (('む', '', ''), ('ム', '', ''), 'ﾑ'),
    (('め', '', ''), ('メ', '', ''), 'ﾒ'),
    (('も', '', ''), ('モ', '', ''), 'ﾓ'),
    // Y-row
    (('や', '', ''), ('ヤ', '', ''), 'ﾔ'),
    (('ゆ', '', ''), ('ユ', '', ''), 'ﾕ'),
    (('よ', '', ''), ('ヨ', '', ''), 'ﾖ'),
    // R-row
    (('ら', '', ''), ('ラ', '', ''), 'ﾗ'),
    (('り', '', ''), ('リ', '', ''), 'ﾘ'),
    (('る', '', ''), ('ル', '', ''), 'ﾙ'),
    (('れ', '', ''), ('レ', '', ''), 'ﾚ'),
    (('ろ', '', ''), ('ロ', '', ''), 'ﾛ'),
    // W-row
    (('わ', '', ''), ('ワ', 'ヷ', ''), 'ﾜ'),
    (('ゐ', '', ''), ('ヰ', 'ヸ', ''), ''),
    (('ゑ', '', ''), ('ヱ', 'ヹ', ''), ''),
    (('を', '', ''), ('ヲ', 'ヺ', ''), 'ｦ'),
    (('ん', '', ''), ('ン', '', ''), 'ﾝ'),
  ];

  /// Mapping table for small kana characters (sutegana).
  ///
  /// Each entry contains:
  /// - Small hiragana form
  /// - Small katakana form
  /// - Halfwidth katakana form (if available)
  ///
  /// These are used for representing palatalized sounds and other special cases.
  static const hiraganaKatakanaSmallTable = [
    ('ぁ', 'ァ', 'ｧ'),
    ('ぃ', 'ィ', 'ｨ'),
    ('ぅ', 'ゥ', 'ｩ'),
    ('ぇ', 'ェ', 'ｪ'),
    ('ぉ', 'ォ', 'ｫ'),
    ('っ', 'ッ', 'ｯ'),
    ('ゃ', 'ャ', 'ｬ'),
    ('ゅ', 'ュ', 'ｭ'),
    ('ょ', 'ョ', 'ｮ'),
    ('ゎ', 'ヮ', ''),
    ('ゕ', 'ヵ', ''),
    ('ゖ', 'ヶ', ''),
  ];

  /// Generates a map of base characters to their voiced equivalents.
  ///
  /// This includes:
  /// - Hiragana characters that can take dakuten (゛)
  /// - Katakana characters that can take dakuten (゛)
  /// - Iteration marks that have voiced forms
  ///
  /// Used by [HiraKataCompositionTransliterator] to compose characters.
  static Map<String, String> generateVoicedCharacters() {
    final result = <String, String>{};

    for (final entry in hiraganaKatakanaTable) {
      final hiragana = entry.$1;
      final katakana = entry.$2;

      // Add hiragana voiced mappings
      if (hiragana.$1.isNotEmpty && hiragana.$2.isNotEmpty) {
        result[hiragana.$1] = hiragana.$2;
      }

      // Add katakana voiced mappings
      if (katakana.$1.isNotEmpty && katakana.$2.isNotEmpty) {
        result[katakana.$1] = katakana.$2;
      }
    }

    // Add iteration marks
    result['\u{309d}'] = '\u{309e}'; // ゝ -> ゞ
    result['\u{30fd}'] = '\u{30fe}'; // ヽ -> ヾ
    result['\u{3031}'] = '\u{3032}'; // 〱 -> 〲 (vertical hiragana)
    result['\u{3033}'] = '\u{3034}'; // 〳 -> 〴 (vertical katakana)

    return result;
  }

  /// Generates a map of base characters to their semi-voiced equivalents.
  ///
  /// This includes characters from the H-row (は行) that can take
  /// handakuten (゜) to form P-sounds.
  ///
  /// Used by [HiraKataCompositionTransliterator] to compose characters.
  static Map<String, String> generateSemiVoicedCharacters() {
    final result = <String, String>{};

    for (final entry in hiraganaKatakanaTable) {
      final hiragana = entry.$1;
      final katakana = entry.$2;

      // Add hiragana semi-voiced mappings
      if (hiragana.$1.isNotEmpty && hiragana.$3.isNotEmpty) {
        result[hiragana.$1] = hiragana.$3;
      }

      // Add katakana semi-voiced mappings
      if (katakana.$1.isNotEmpty && katakana.$3.isNotEmpty) {
        result[katakana.$1] = katakana.$3;
      }
    }

    return result;
  }

  /// Generates the GR (Graphics Right) table for JIS X 0201 conversion.
  ///
  /// Maps fullwidth katakana characters to their halfwidth equivalents,
  /// including punctuation marks and special symbols.
  ///
  /// The GR designation refers to the right half of the JIS X 0201
  /// character set (0xA1-0xDF), which contains halfwidth katakana.
  static Map<String, String> generateGRTable() {
    final result = <String, String>{
      '\u{3002}': '\u{ff61}', // 。 -> ｡
      '\u{300c}': '\u{ff62}', // 「 -> ｢
      '\u{300d}': '\u{ff63}', // 」 -> ｣
      '\u{3001}': '\u{ff64}', // 、 -> ､
      '\u{30fb}': '\u{ff65}', // ・ -> ･
      '\u{30fc}': '\u{ff70}', // ー -> ｰ
      '\u{309b}': '\u{ff9e}', // ゛ -> ﾞ
      '\u{309c}': '\u{ff9f}', // ゜-> ﾟ
    };

    // Add katakana mappings from main table
    for (final entry in hiraganaKatakanaTable) {
      final katakana = entry.$2;
      final halfwidth = entry.$3;

      if (halfwidth.isNotEmpty) {
        result[katakana.$1] = halfwidth;
      }
    }

    // Add small kana mappings
    for (final entry in hiraganaKatakanaSmallTable) {
      final katakana = entry.$2;
      final halfwidth = entry.$3;
      if (halfwidth.isNotEmpty) {
        result[katakana] = halfwidth;
      }
    }

    return result;
  }

  /// Generates a table mapping voiced/semi-voiced katakana to halfwidth sequences.
  ///
  /// Since halfwidth katakana doesn't have precomposed voiced forms,
  /// they are represented as base character + combining mark sequences.
  /// For example: ガ -> ｶﾞ (halfwidth カ + halfwidth dakuten)
  static Map<String, String> generateVoicedLettersTable() {
    final result = <String, String>{};

    for (final entry in hiraganaKatakanaTable) {
      final katakana = entry.$2;
      final halfwidth = entry.$3;
      if (halfwidth.isNotEmpty) {
        if (katakana.$2.isNotEmpty) {
          result[katakana.$2] = '$halfwidth\u{ff9e}';
        }
        if (katakana.$3.isNotEmpty) {
          result[katakana.$3] = '$halfwidth\u{ff9f}';
        }
      }
    }

    return result;
  }

  /// Generates a table mapping hiragana characters to halfwidth katakana.
  ///
  /// This is used when converting hiragana directly to halfwidth forms,
  /// effectively performing both script conversion (hiragana to katakana)
  /// and width conversion (fullwidth to halfwidth) in one step.
  static Map<String, String> generateHiraganaTable() {
    final result = <String, String>{};

    // Add main table hiragana mappings
    for (final entry in hiraganaKatakanaTable) {
      final hiragana = entry.$1;
      final halfwidth = entry.$3;
      if (halfwidth.isNotEmpty) {
        result[hiragana.$1] = halfwidth;
        if (hiragana.$2.isNotEmpty) {
          result[hiragana.$2] = '$halfwidth\u{ff9e}';
        }
        if (hiragana.$3.isNotEmpty) {
          result[hiragana.$3] = '$halfwidth\u{ff9f}';
        }
      }
    }

    // Add small kana mappings
    for (final entry in hiraganaKatakanaSmallTable) {
      final hiragana = entry.$1;
      final halfwidth = entry.$3;
      if (halfwidth.isNotEmpty) {
        result[hiragana] = halfwidth;
      }
    }

    return result;
  }
}
