import '../char.dart';
import '../transliterator.dart';
import 'hira_kata_table.dart';

/// Options for JIS X 0201 transliterator.
///
/// Internal class that holds the resolved configuration options with all
/// defaults applied based on the conversion direction.
class _ResolvedOptions {
  _ResolvedOptions({
    required this.combineVoicedSoundMarks,
    required this.convertHiraganas,
    required this.convertGL,
    required this.convertGR,
    required this.convertUnsafeSpecials,
    required this.u005cAsYenSign,
    required this.u005cAsBackslash,
    required this.u007eAsFullwidthTilde,
    required this.u007eAsWaveDash,
    required this.u007eAsOverline,
    required this.u007eAsFullwidthMacron,
    required this.u00a5AsYenSign,
  });

  final bool combineVoicedSoundMarks;
  final bool convertHiraganas;
  final bool convertGL;
  final bool convertGR;
  final bool convertUnsafeSpecials;
  final bool u005cAsYenSign;
  final bool u005cAsBackslash;
  final bool u007eAsFullwidthTilde;
  final bool u007eAsWaveDash;
  final bool u007eAsOverline;
  final bool u007eAsFullwidthMacron;
  final bool u00a5AsYenSign;
}

/// JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion.
///
/// This transliterator handles conversion between:
/// - Half-width group:
///   - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E.
///   - Half-width katakanas: U+FF61 - U+FF9F.
/// - Full-width group:
///   - Full-width alphabets, numerics, and symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5.
///   - Wave dash: U+301C.
///   - Hiraganas: U+3041 - U+3094.
///   - Katakanas: U+30A1 - U+30F7 and U+30FA.
///   - Hiragana/katakana voicing marks: U+309B, U+309C, and U+30FC.
///   - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
class Jisx0201AndAlikeTransliterator implements Transliterator {
  /// Creates a JIS X 0201 transliterator with specified options.
  ///
  /// [fullwidthToHalfwidth] determines the conversion direction:
  /// - true: Convert fullwidth to halfwidth (default)
  /// - false: Convert halfwidth to fullwidth
  ///
  /// [combineVoicedSoundMarks] combines halfwidth katakana with voice marks
  /// into precomposed forms (only applies to halfwidth to fullwidth).
  ///
  /// [convertHiraganas] enables hiragana to halfwidth katakana conversion.
  ///
  /// [convertGL] enables conversion of GL characters (ASCII range).
  ///
  /// [convertGR] enables conversion of GR characters (katakana range).
  ///
  /// [convertUnsafeSpecials] enables conversion of characters that might
  /// cause issues in some contexts (defaults based on direction).
  ///
  /// Various options control the mapping of ambiguous characters:
  /// - [u005cAsYenSign]/[u005cAsBackslash]: How to handle backslash
  /// - [u007eAsFullwidthTilde]/[u007eAsWaveDash]/[u007eAsOverline]/[u007eAsFullwidthMacron]: How to handle tilde
  /// - [u00a5AsYenSign]: How to handle yen sign
  Jisx0201AndAlikeTransliterator({
    bool fullwidthToHalfwidth = true,
    bool combineVoicedSoundMarks = true,
    bool convertHiraganas = false,
    bool convertGL = true,
    bool convertGR = true,
    bool? convertUnsafeSpecials,
    bool? u005cAsYenSign,
    bool? u005cAsBackslash,
    bool? u007eAsFullwidthTilde,
    bool? u007eAsWaveDash,
    bool? u007eAsOverline,
    bool? u007eAsFullwidthMacron,
    bool? u00a5AsYenSign,
  }) : _fullwidthToHalfwidth = fullwidthToHalfwidth {
    if (fullwidthToHalfwidth) {
      // Forward direction defaults
      _resolvedOptions = _ResolvedOptions(
        combineVoicedSoundMarks: combineVoicedSoundMarks,
        convertHiraganas: convertHiraganas,
        convertGL: convertGL,
        convertGR: convertGR,
        convertUnsafeSpecials: convertUnsafeSpecials ?? true,
        u005cAsYenSign: u005cAsYenSign ?? (u00a5AsYenSign == null),
        u005cAsBackslash: u005cAsBackslash ?? false,
        u007eAsFullwidthTilde: u007eAsFullwidthTilde ?? true,
        u007eAsWaveDash: u007eAsWaveDash ?? true,
        u007eAsOverline: u007eAsOverline ?? false,
        u007eAsFullwidthMacron: u007eAsFullwidthMacron ?? false,
        u00a5AsYenSign: u00a5AsYenSign ?? false,
      );

      if (_resolvedOptions.u005cAsYenSign && _resolvedOptions.u00a5AsYenSign) {
        throw ArgumentError(
            'u005cAsYenSign and u00a5AsYenSign are mutually exclusive');
      }
    } else {
      // Reverse direction defaults
      _resolvedOptions = _ResolvedOptions(
        combineVoicedSoundMarks: combineVoicedSoundMarks,
        convertHiraganas: convertHiraganas,
        convertGL: convertGL,
        convertGR: convertGR,
        convertUnsafeSpecials: convertUnsafeSpecials ?? false,
        u005cAsYenSign: u005cAsYenSign ?? (u005cAsBackslash == null),
        u005cAsBackslash: u005cAsBackslash ?? false,
        u007eAsFullwidthTilde: u007eAsFullwidthTilde ??
            (u007eAsWaveDash == null &&
                u007eAsOverline == null &&
                u007eAsFullwidthMacron == null),
        u007eAsWaveDash: u007eAsWaveDash ?? false,
        u007eAsOverline: u007eAsOverline ?? false,
        u007eAsFullwidthMacron: u007eAsFullwidthMacron ?? false,
        u00a5AsYenSign: u00a5AsYenSign ?? true,
      );

      if (_resolvedOptions.u005cAsYenSign &&
          _resolvedOptions.u005cAsBackslash) {
        throw ArgumentError(
            'u005cAsYenSign and u005cAsBackslash are mutually exclusive');
      }
      if (_resolvedOptions.u007eAsFullwidthTilde &&
              (_resolvedOptions.u007eAsWaveDash ||
                  _resolvedOptions.u007eAsOverline ||
                  _resolvedOptions.u007eAsFullwidthMacron) ||
          _resolvedOptions.u007eAsWaveDash &&
              (_resolvedOptions.u007eAsOverline ||
                  _resolvedOptions.u007eAsFullwidthMacron) ||
          _resolvedOptions.u007eAsOverline &&
              _resolvedOptions.u007eAsFullwidthMacron) {
        throw ArgumentError(
            'u007eAsFullwidthTilde, u007eAsWaveDash, u007eAsOverline, and '
            'u007eAsFullwidthMacron are mutually exclusive');
      }
    }
  }

  final bool _fullwidthToHalfwidth;
  late final _ResolvedOptions _resolvedOptions;

  // Cached mappings - initialized lazily
  Map<String, String>? __glTable;
  Map<String, String>? __grTable;
  Map<String, String>? __decompositionTable;
  // Reverse mappings for halfwidth to fullwidth conversion
  Map<String, String>? __reverseGLTable;
  Map<String, String>? __reverseGRTable;
  // Composition table for combining halfwidth katakana with voice marks
  Map<String, String>? __compositionTable;

  // Lazy getters for mapping tables
  Map<String, String> get _glTable {
    __glTable ??= _buildGLTable();
    return __glTable!;
  }

  Map<String, String> get _grTable {
    __grTable ??= _buildGRTable();
    return __grTable!;
  }

  Map<String, String> get _decompositionTable {
    __decompositionTable ??= _buildDecompositionTable();
    return __decompositionTable!;
  }

  Map<String, String> get _reverseGLTable {
    __reverseGLTable ??= _buildReverseGLTable();
    return __reverseGLTable!;
  }

  Map<String, String> get _reverseGRTable {
    __reverseGRTable ??= _buildReverseGRTable();
    return __reverseGRTable!;
  }

  Map<String, String> get _compositionTable {
    __compositionTable ??= _buildCompositionTable();
    return __compositionTable!;
  }

  Map<String, String> _buildGLTable() {
    // Basic fullwidth to halfwidth mappings
    final glTable = <String, String>{
      '\u{3000}': '\u{0020}', // Ideographic space to space
      '\u{ff01}': '\u{0021}', // ！ to !
      '\u{ff02}': '\u{0022}', // ＂ to "
      '\u{ff03}': '\u{0023}', // ＃ to #
      '\u{ff04}': '\u{0024}', // ＄ to $
      '\u{ff05}': '\u{0025}', // ％ to %
      '\u{ff06}': '\u{0026}', // ＆ to &
      '\u{ff07}': '\u{0027}', // ＇ to '
      '\u{ff08}': '\u{0028}', // （ to (
      '\u{ff09}': '\u{0029}', // ） to )
      '\u{ff0a}': '\u{002a}', // ＊ to *
      '\u{ff0b}': '\u{002b}', // ＋ to +
      '\u{ff0c}': '\u{002c}', // ， to ,
      '\u{ff0d}': '\u{002d}', // － to -
      '\u{ff0e}': '\u{002e}', // ． to .
      '\u{ff0f}': '\u{002f}', // ／ to /
      '\u{ff1a}': '\u{003a}', // ： to :
      '\u{ff1b}': '\u{003b}', // ； to ;
      '\u{ff1c}': '\u{003c}', // ＜ to <
      '\u{ff1d}': '\u{003d}', // ＝ to =
      '\u{ff1e}': '\u{003e}', // ＞ to >
      '\u{ff1f}': '\u{003f}', // ？ to ?
      '\u{ff20}': '\u{0040}', // ＠ to @
      '\u{ff3b}': '\u{005b}', // ［ to [
      '\u{ff3c}': '\u{005c}', // ＼ to \
      '\u{ff3d}': '\u{005d}', // ］ to ]
      '\u{ff3e}': '\u{005e}', // ＾ to ^
      '\u{ff3f}': '\u{005f}', // ＿ to _
      '\u{ff40}': '\u{0060}', // ｀ to `
      '\u{ff5b}': '\u{007b}', // ｛ to {
      '\u{ff5c}': '\u{007c}', // ｜ to |
      '\u{ff5d}': '\u{007d}', // ｝ to }
    };

    // Add digits
    for (var i = 0; i <= 9; i++) {
      glTable[String.fromCharCode(0xff10 + i)] = String.fromCharCode(0x30 + i);
    }

    // Add uppercase and lowercase letters
    for (var i = 0; i < 26; i++) {
      glTable[String.fromCharCode(0xff21 + i)] = String.fromCharCode(0x41 + i);
      glTable[String.fromCharCode(0xff41 + i)] = String.fromCharCode(0x61 + i);
    }

    // Handle tilde conversions
    if (_resolvedOptions.u007eAsWaveDash) {
      glTable['\u{301c}'] = '\u{007e}'; // 〜 to ~
    }
    if (_resolvedOptions.u007eAsOverline) {
      glTable['\u{203e}'] = '\u{007e}'; // ‾ to ~
    }
    if (_resolvedOptions.u007eAsFullwidthMacron) {
      glTable['\u{ffe3}'] = '\u{007e}'; // ￣ to ~
    }
    if (_resolvedOptions.u007eAsFullwidthTilde) {
      glTable['\u{ff5e}'] = '\u{007e}'; // ～ to ~
    }

    // Handle yen sign
    if (_resolvedOptions.u00a5AsYenSign) {
      glTable['\u{ffe5}'] = '\u{00a5}'; // ￥ to ¥
    } else if (_resolvedOptions.u005cAsYenSign) {
      glTable['\u{ffe5}'] = '\u{005c}'; // ￥ to \
    }
    return glTable;
  }

  Map<String, String> _buildGRTable() {
    // Get the base GR table from the shared HiraKataTable
    final grTable = HiraKataTable.generateGRTable();

    // Handle unsafe specials
    if (_resolvedOptions.convertUnsafeSpecials) {
      grTable['\u{30a0}'] = '\u{003d}'; // ゠ to =
    }

    return grTable;
  }

  Map<String, String> _buildDecompositionTable() {
    // Get the voiced letters table from the shared HiraKataTable
    final voicedLettersTable = HiraKataTable.generateVoicedLettersTable();

    // Handle combining marks
    voicedLettersTable['\u{3099}'] = '\u{ff9e}'; // combining dakuten
    voicedLettersTable['\u{309a}'] = '\u{ff9f}'; // combining handakuten

    return voicedLettersTable;
  }

  Map<String, String> _buildReverseGLTable() {
    // Basic halfwidth to fullwidth mappings
    final reverseGLTable = <String, String>{
      '\u{0020}': '\u{3000}', // space to Ideographic space
      '\u{0021}': '\u{ff01}', // ! to ！
      '\u{0022}': '\u{ff02}', // " to ＂
      '\u{0023}': '\u{ff03}', // # to ＃
      '\u{0024}': '\u{ff04}', // $ to ＄
      '\u{0025}': '\u{ff05}', // % to ％
      '\u{0026}': '\u{ff06}', // & to ＆
      '\u{0027}': '\u{ff07}', // ' to ＇
      '\u{0028}': '\u{ff08}', // ( to （
      '\u{0029}': '\u{ff09}', // ) to ）
      '\u{002a}': '\u{ff0a}', // * to ＊
      '\u{002b}': '\u{ff0b}', // + to ＋
      '\u{002c}': '\u{ff0c}', // , to ，
      '\u{002d}': '\u{ff0d}', // - to －
      '\u{002e}': '\u{ff0e}', // . to ．
      '\u{002f}': '\u{ff0f}', // / to ／
      '\u{003a}': '\u{ff1a}', // : to ：
      '\u{003b}': '\u{ff1b}', // ; to ；
      '\u{003c}': '\u{ff1c}', // < to ＜
      '\u{003d}': '\u{ff1d}', // = to ＝
      '\u{003e}': '\u{ff1e}', // > to ＞
      '\u{003f}': '\u{ff1f}', // ? to ？
      '\u{0040}': '\u{ff20}', // @ to ＠
      '\u{005b}': '\u{ff3b}', // [ to ［
      '\u{005d}': '\u{ff3d}', // ] to ］
      '\u{005e}': '\u{ff3e}', // ^ to ＾
      '\u{005f}': '\u{ff3f}', // _ to ＿
      '\u{0060}': '\u{ff40}', // ` to ｀
      '\u{007b}': '\u{ff5b}', // { to ｛
      '\u{007c}': '\u{ff5c}', // | to ｜
      '\u{007d}': '\u{ff5d}', // } to ｝
    };

    // Add digits
    for (var i = 0; i <= 9; i++) {
      reverseGLTable[String.fromCharCode(0x30 + i)] =
          String.fromCharCode(0xff10 + i);
    }

    // Add uppercase and lowercase letters
    for (var i = 0; i < 26; i++) {
      reverseGLTable[String.fromCharCode(0x41 + i)] =
          String.fromCharCode(0xff21 + i);
      reverseGLTable[String.fromCharCode(0x61 + i)] =
          String.fromCharCode(0xff41 + i);
    }

    // Handle backslash/yen sign based on options
    if (_resolvedOptions.u005cAsBackslash) {
      reverseGLTable['\u{005c}'] = '\u{ff3c}'; // \ to ＼
    } else if (_resolvedOptions.u005cAsYenSign) {
      reverseGLTable['\u{005c}'] = '\u{ffe5}'; // \ to ￥
    }

    // Handle tilde conversions
    if (_resolvedOptions.u007eAsFullwidthTilde) {
      reverseGLTable['\u{007e}'] = '\u{ff5e}'; // ~ to ～
    } else if (_resolvedOptions.u007eAsWaveDash) {
      reverseGLTable['\u{007e}'] = '\u{301c}'; // ~ to 〜
    } else if (_resolvedOptions.u007eAsOverline) {
      reverseGLTable['\u{007e}'] = '\u{203e}'; // ~ to ‾
    } else if (_resolvedOptions.u007eAsFullwidthMacron) {
      reverseGLTable['\u{007e}'] = '\u{ffe3}'; // ~ to ￣
    }

    // Handle yen sign
    if (_resolvedOptions.u00a5AsYenSign) {
      reverseGLTable['\u{00a5}'] = '\u{ffe5}'; // ¥ to ￥
    }

    return reverseGLTable;
  }

  Map<String, String> _buildReverseGRTable() {
    // Get the GR table and reverse it
    final grTable = HiraKataTable.generateGRTable();
    final reverseGRTable = <String, String>{};
    for (final entry in grTable.entries) {
      reverseGRTable[entry.value] = entry.key;
    }

    // Handle unsafe specials
    if (_resolvedOptions.convertUnsafeSpecials) {
      reverseGRTable['\u{003d}'] = '\u{30a0}'; // = to ゠
    }
    return reverseGRTable;
  }

  Map<String, String> _buildCompositionTable() {
    // Build composition table for combining halfwidth katakana with voice marks
    // This is the reverse of the voiced letters table
    final voicedLettersTable = HiraKataTable.generateVoicedLettersTable();
    final compositionTable = <String, String>{};

    for (final entry in voicedLettersTable.entries) {
      // The voiced letters table has fullwidth as key and halfwidth+mark as value
      // We need halfwidth+mark as key and fullwidth as value
      compositionTable[entry.value] = entry.key;
    }

    return compositionTable;
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    if (_fullwidthToHalfwidth) {
      yield* _toHalfwidth(inputChars);
    } else {
      yield* _toFullwidth(inputChars);
    }
  }

  /// Converts fullwidth characters to halfwidth.
  Iterable<Char> _toHalfwidth(Iterable<Char> inputChars) sync* {
    var offset = 0;
    // Build hiragana table if needed
    Map<String, String>? hiraganaTable;
    if (_resolvedOptions.convertHiraganas && _resolvedOptions.convertGR) {
      hiraganaTable = HiraKataTable.generateHiraganaTable();
    }

    for (final char in inputChars) {
      // Try GL table first
      if (_resolvedOptions.convertGL) {
        final replacement = _glTable[char.c];
        if (replacement != null) {
          yield Char(replacement, offset, char);
          offset += replacement.length;
          continue;
        }
      }

      // Try GR table
      if (_resolvedOptions.convertGR) {
        final replacement = _grTable[char.c];
        if (replacement != null) {
          yield Char(replacement, offset, char);
          offset += replacement.length;
          continue;
        }

        // Try decomposition table
        final decomposed = _decompositionTable[char.c];
        if (decomposed != null) {
          // Yield each character in the decomposition
          for (final rune in decomposed.runes) {
            final decomposedChar = String.fromCharCode(rune);
            yield Char(decomposedChar, offset, char);
            offset += decomposedChar.length;
          }
          continue;
        }
      }

      // Handle hiragana conversion if enabled
      if (hiraganaTable != null) {
        final replacement = hiraganaTable[char.c];
        if (replacement != null) {
          // Yield each character in the decomposition
          for (final rune in replacement.runes) {
            final decomposedChar = String.fromCharCode(rune);
            yield Char(decomposedChar, offset, char);
            offset += decomposedChar.length;
          }
          continue;
        }
      }

      // No conversion, yield as-is
      yield char.withOffset(offset);
      offset += char.c.length;
    }
  }

  /// Converts halfwidth characters to fullwidth.
  Iterable<Char> _toFullwidth(Iterable<Char> inputChars) sync* {
    var offset = 0;
    final iterator = inputChars.iterator;
    Char? pending;

    while (pending != null || iterator.moveNext()) {
      final char = pending ?? iterator.current;
      pending = null;

      var matched = false;

      // Check for halfwidth katakana that might combine with voiced marks
      if (_resolvedOptions.convertGR &&
          _resolvedOptions.combineVoicedSoundMarks) {
        // Check if next character could complete a combination
        if (iterator.moveNext()) {
          final nextChar = iterator.current;
          if (nextChar.c == '\u{ff9e}' || nextChar.c == '\u{ff9f}') {
            // Try to find a combined form using the composition table
            final combined = char.c + nextChar.c;
            final composedChar = _compositionTable[combined];
            if (composedChar != null) {
              yield Char(composedChar, offset, char);
              offset += composedChar.length;
              matched = true;
            } else {
              // No combination found, save next char for next iteration
              pending = nextChar;
            }
          } else {
            // Next char is not a voice mark, save it for next iteration
            pending = nextChar;
          }
        }
      }

      if (!matched) {
        // Try reverse GL mapping using the dedicated reverse table
        if (_resolvedOptions.convertGL) {
          final replacement = _reverseGLTable[char.c];
          if (replacement != null) {
            yield Char(replacement, offset, char);
            offset += replacement.length;
            matched = true;
          }
        }

        // Try reverse GR mapping using the dedicated reverse table
        if (!matched && _resolvedOptions.convertGR) {
          final replacement = _reverseGRTable[char.c];
          if (replacement != null) {
            yield Char(replacement, offset, char);
            offset += replacement.length;
            matched = true;
          }
        }

        if (!matched) {
          yield char.withOffset(offset);
          offset += char.c.length;
        }
      }
    }
  }
}
