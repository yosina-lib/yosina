import '../char.dart';
import '../transliterator.dart';

/// Options for JIS X 0201 transliterator.
/// Resolved options with all defaults applied.
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
class JisX0201AndAlikeTransliterator implements Transliterator {
  JisX0201AndAlikeTransliterator({
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
    final grTable = <String, String>{
      '\u{3002}': '\u{ff61}', // 。 to ｡
      '\u{300c}': '\u{ff62}', // 「 to ｢
      '\u{300d}': '\u{ff63}', // 」 to ｣
      '\u{3001}': '\u{ff64}', // 、 to ､
      '\u{30fb}': '\u{ff65}', // ・ to ･
      '\u{30f2}': '\u{ff66}', // ヲ to ｦ
      '\u{30a1}': '\u{ff67}', // ァ to ｧ
      '\u{30a3}': '\u{ff68}', // ィ to ｨ
      '\u{30a5}': '\u{ff69}', // ゥ to ｩ
      '\u{30a7}': '\u{ff6a}', // ェ to ｪ
      '\u{30a9}': '\u{ff6b}', // ォ to ｫ
      '\u{30e3}': '\u{ff6c}', // ャ to ｬ
      '\u{30e5}': '\u{ff6d}', // ュ to ｭ
      '\u{30e7}': '\u{ff6e}', // ョ to ｮ
      '\u{30c3}': '\u{ff6f}', // ッ to ｯ
      '\u{30fc}': '\u{ff70}', // ー to ｰ
      '\u{30a2}': '\u{ff71}', // ア to ｱ
      '\u{30a4}': '\u{ff72}', // イ to ｲ
      '\u{30a6}': '\u{ff73}', // ウ to ｳ
      '\u{30a8}': '\u{ff74}', // エ to ｴ
      '\u{30aa}': '\u{ff75}', // オ to ｵ
      '\u{30ab}': '\u{ff76}', // カ to ｶ
      '\u{30ad}': '\u{ff77}', // キ to ｷ
      '\u{30af}': '\u{ff78}', // ク to ｸ
      '\u{30b1}': '\u{ff79}', // ケ to ｹ
      '\u{30b3}': '\u{ff7a}', // コ to ｺ
      '\u{30b5}': '\u{ff7b}', // サ to ｻ
      '\u{30b7}': '\u{ff7c}', // シ to ｼ
      '\u{30b9}': '\u{ff7d}', // ス to ｽ
      '\u{30bb}': '\u{ff7e}', // セ to ｾ
      '\u{30bd}': '\u{ff7f}', // ソ to ｿ
      '\u{30bf}': '\u{ff80}', // タ to ﾀ
      '\u{30c1}': '\u{ff81}', // チ to ﾁ
      '\u{30c4}': '\u{ff82}', // ツ to ﾂ
      '\u{30c6}': '\u{ff83}', // テ to ﾃ
      '\u{30c8}': '\u{ff84}', // ト to ﾄ
      '\u{30ca}': '\u{ff85}', // ナ to ﾅ
      '\u{30cb}': '\u{ff86}', // ニ to ﾆ
      '\u{30cc}': '\u{ff87}', // ヌ to ﾇ
      '\u{30cd}': '\u{ff88}', // ネ to ﾈ
      '\u{30ce}': '\u{ff89}', // ノ to ﾉ
      '\u{30cf}': '\u{ff8a}', // ハ to ﾊ
      '\u{30d2}': '\u{ff8b}', // ヒ to ﾋ
      '\u{30d5}': '\u{ff8c}', // フ to ﾌ
      '\u{30d8}': '\u{ff8d}', // ヘ to ﾍ
      '\u{30db}': '\u{ff8e}', // ホ to ﾎ
      '\u{30de}': '\u{ff8f}', // マ to ﾏ
      '\u{30df}': '\u{ff90}', // ミ to ﾐ
      '\u{30e0}': '\u{ff91}', // ム to ﾑ
      '\u{30e1}': '\u{ff92}', // メ to ﾒ
      '\u{30e2}': '\u{ff93}', // モ to ﾓ
      '\u{30e4}': '\u{ff94}', // ヤ to ﾔ
      '\u{30e6}': '\u{ff95}', // ユ to ﾕ
      '\u{30e8}': '\u{ff96}', // ヨ to ﾖ
      '\u{30e9}': '\u{ff97}', // ラ to ﾗ
      '\u{30ea}': '\u{ff98}', // リ to ﾘ
      '\u{30eb}': '\u{ff99}', // ル to ﾙ
      '\u{30ec}': '\u{ff9a}', // レ to ﾚ
      '\u{30ed}': '\u{ff9b}', // ロ to ﾛ
      '\u{30ef}': '\u{ff9c}', // ワ to ﾜ
      '\u{30f3}': '\u{ff9d}', // ン to ﾝ
      '\u{309b}': '\u{ff9e}', // ゛ to ﾞ
      '\u{309c}': '\u{ff9f}', // ゜to ﾟ
    };

    // Handle unsafe specials
    if (_resolvedOptions.convertUnsafeSpecials) {
      grTable['\u{30a0}'] = '\u{003d}'; // ゠ to =
    }

    return grTable;
  }

  Map<String, String> _buildDecompositionTable() {
    return <String, String>{
      // Voiced katakana
      '\u{30ac}': '\u{ff76}\u{ff9e}', // ガ to ｶﾞ
      '\u{30ae}': '\u{ff77}\u{ff9e}', // ギ to ｷﾞ
      '\u{30b0}': '\u{ff78}\u{ff9e}', // グ to ｸﾞ
      '\u{30b2}': '\u{ff79}\u{ff9e}', // ゲ to ｹﾞ
      '\u{30b4}': '\u{ff7a}\u{ff9e}', // ゴ to ｺﾞ
      '\u{30b6}': '\u{ff7b}\u{ff9e}', // ザ to ｻﾞ
      '\u{30b8}': '\u{ff7c}\u{ff9e}', // ジ to ｼﾞ
      '\u{30ba}': '\u{ff7d}\u{ff9e}', // ズ to ｽﾞ
      '\u{30bc}': '\u{ff7e}\u{ff9e}', // ゼ to ｾﾞ
      '\u{30be}': '\u{ff7f}\u{ff9e}', // ゾ to ｿﾞ
      '\u{30c0}': '\u{ff80}\u{ff9e}', // ダ to ﾀﾞ
      '\u{30c2}': '\u{ff81}\u{ff9e}', // ヂ to ﾁﾞ
      '\u{30c5}': '\u{ff82}\u{ff9e}', // ヅ to ﾂﾞ
      '\u{30c7}': '\u{ff83}\u{ff9e}', // デ to ﾃﾞ
      '\u{30c9}': '\u{ff84}\u{ff9e}', // ド to ﾄﾞ
      '\u{30d0}': '\u{ff8a}\u{ff9e}', // バ to ﾊﾞ
      '\u{30d3}': '\u{ff8b}\u{ff9e}', // ビ to ﾋﾞ
      '\u{30d6}': '\u{ff8c}\u{ff9e}', // ブ to ﾌﾞ
      '\u{30d9}': '\u{ff8d}\u{ff9e}', // ベ to ﾍﾞ
      '\u{30dc}': '\u{ff8e}\u{ff9e}', // ボ to ﾎﾞ
      '\u{30f4}': '\u{ff73}\u{ff9e}', // ヴ to ｳﾞ
      '\u{30f7}': '\u{ff9c}\u{ff9e}', // ヷ to ﾜﾞ
      '\u{30fa}': '\u{ff66}\u{ff9e}', // ヺ to ｦﾞ

      // Semi-voiced katakana
      '\u{30d1}': '\u{ff8a}\u{ff9f}', // パ to ﾊﾟ
      '\u{30d4}': '\u{ff8b}\u{ff9f}', // ピ to ﾋﾟ
      '\u{30d7}': '\u{ff8c}\u{ff9f}', // プ to ﾌﾟ
      '\u{30da}': '\u{ff8d}\u{ff9f}', // ペ to ﾍﾟ
      '\u{30dd}': '\u{ff8e}\u{ff9f}', // ポ to ﾎﾟ
    };
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
    final reverseGRTable = <String, String>{
      '\u{ff61}': '\u{3002}', // ｡ to 。
      '\u{ff62}': '\u{300c}', // ｢ to 「
      '\u{ff63}': '\u{300d}', // ｣ to 」
      '\u{ff64}': '\u{3001}', // ､ to 、
      '\u{ff65}': '\u{30fb}', // ･ to ・
      '\u{ff66}': '\u{30f2}', // ｦ to ヲ
      '\u{ff67}': '\u{30a1}', // ｧ to ァ
      '\u{ff68}': '\u{30a3}', // ｨ to ィ
      '\u{ff69}': '\u{30a5}', // ｩ to ゥ
      '\u{ff6a}': '\u{30a7}', // ｪ to ェ
      '\u{ff6b}': '\u{30a9}', // ｫ to ォ
      '\u{ff6c}': '\u{30e3}', // ｬ to ャ
      '\u{ff6d}': '\u{30e5}', // ｭ to ュ
      '\u{ff6e}': '\u{30e7}', // ｮ to ョ
      '\u{ff6f}': '\u{30c3}', // ｯ to ッ
      '\u{ff70}': '\u{30fc}', // ｰ to ー
      '\u{ff71}': '\u{30a2}', // ｱ to ア
      '\u{ff72}': '\u{30a4}', // ｲ to イ
      '\u{ff73}': '\u{30a6}', // ｳ to ウ
      '\u{ff74}': '\u{30a8}', // ｴ to エ
      '\u{ff75}': '\u{30aa}', // ｵ to オ
      '\u{ff76}': '\u{30ab}', // ｶ to カ
      '\u{ff77}': '\u{30ad}', // ｷ to キ
      '\u{ff78}': '\u{30af}', // ｸ to ク
      '\u{ff79}': '\u{30b1}', // ｹ to ケ
      '\u{ff7a}': '\u{30b3}', // ｺ to コ
      '\u{ff7b}': '\u{30b5}', // ｻ to サ
      '\u{ff7c}': '\u{30b7}', // ｼ to シ
      '\u{ff7d}': '\u{30b9}', // ｽ to ス
      '\u{ff7e}': '\u{30bb}', // ｾ to セ
      '\u{ff7f}': '\u{30bd}', // ｿ to ソ
      '\u{ff80}': '\u{30bf}', // ﾀ to タ
      '\u{ff81}': '\u{30c1}', // ﾁ to チ
      '\u{ff82}': '\u{30c4}', // ﾂ to ツ
      '\u{ff83}': '\u{30c6}', // ﾃ to テ
      '\u{ff84}': '\u{30c8}', // ﾄ to ト
      '\u{ff85}': '\u{30ca}', // ﾅ to ナ
      '\u{ff86}': '\u{30cb}', // ﾆ to ニ
      '\u{ff87}': '\u{30cc}', // ﾇ to ヌ
      '\u{ff88}': '\u{30cd}', // ﾈ to ネ
      '\u{ff89}': '\u{30ce}', // ﾉ to ノ
      '\u{ff8a}': '\u{30cf}', // ﾊ to ハ
      '\u{ff8b}': '\u{30d2}', // ﾋ to ヒ
      '\u{ff8c}': '\u{30d5}', // ﾌ to フ
      '\u{ff8d}': '\u{30d8}', // ﾍ to ヘ
      '\u{ff8e}': '\u{30db}', // ﾎ to ホ
      '\u{ff8f}': '\u{30de}', // ﾏ to マ
      '\u{ff90}': '\u{30df}', // ﾐ to ミ
      '\u{ff91}': '\u{30e0}', // ﾑ to ム
      '\u{ff92}': '\u{30e1}', // ﾒ to メ
      '\u{ff93}': '\u{30e2}', // ﾓ to モ
      '\u{ff94}': '\u{30e4}', // ﾔ to ヤ
      '\u{ff95}': '\u{30e6}', // ﾕ to ユ
      '\u{ff96}': '\u{30e8}', // ﾖ to ヨ
      '\u{ff97}': '\u{30e9}', // ﾗ to ラ
      '\u{ff98}': '\u{30ea}', // ﾘ to リ
      '\u{ff99}': '\u{30eb}', // ﾙ to ル
      '\u{ff9a}': '\u{30ec}', // ﾚ to レ
      '\u{ff9b}': '\u{30ed}', // ﾛ to ロ
      '\u{ff9c}': '\u{30ef}', // ﾜ to ワ
      '\u{ff9d}': '\u{30f3}', // ﾝ to ン
      '\u{ff9e}': '\u{309b}', // ﾞ to ゛
      '\u{ff9f}': '\u{309c}', // ﾟ to ゜
    };

    // Handle unsafe specials
    if (_resolvedOptions.convertUnsafeSpecials) {
      reverseGRTable['\u{003d}'] = '\u{30a0}'; // = to ゠
    }
    return reverseGRTable;
  }

  Map<String, String> _buildCompositionTable() {
    // Build composition table for combining halfwidth katakana with voice marks
    return <String, String>{
      // Voiced katakana (base + voiced mark)
      '\u{ff76}\u{ff9e}': '\u{30ac}', // ｶﾞ to ガ
      '\u{ff77}\u{ff9e}': '\u{30ae}', // ｷﾞ to ギ
      '\u{ff78}\u{ff9e}': '\u{30b0}', // ｸﾞ to グ
      '\u{ff79}\u{ff9e}': '\u{30b2}', // ｹﾞ to ゲ
      '\u{ff7a}\u{ff9e}': '\u{30b4}', // ｺﾞ to ゴ
      '\u{ff7b}\u{ff9e}': '\u{30b6}', // ｻﾞ to ザ
      '\u{ff7c}\u{ff9e}': '\u{30b8}', // ｼﾞ to ジ
      '\u{ff7d}\u{ff9e}': '\u{30ba}', // ｽﾞ to ズ
      '\u{ff7e}\u{ff9e}': '\u{30bc}', // ｾﾞ to ゼ
      '\u{ff7f}\u{ff9e}': '\u{30be}', // ｿﾞ to ゾ
      '\u{ff80}\u{ff9e}': '\u{30c0}', // ﾀﾞ to ダ
      '\u{ff81}\u{ff9e}': '\u{30c2}', // ﾁﾞ to ヂ
      '\u{ff82}\u{ff9e}': '\u{30c5}', // ﾂﾞ to ヅ
      '\u{ff83}\u{ff9e}': '\u{30c7}', // ﾃﾞ to デ
      '\u{ff84}\u{ff9e}': '\u{30c9}', // ﾄﾞ to ド
      '\u{ff8a}\u{ff9e}': '\u{30d0}', // ﾊﾞ to バ
      '\u{ff8b}\u{ff9e}': '\u{30d3}', // ﾋﾞ to ビ
      '\u{ff8c}\u{ff9e}': '\u{30d6}', // ﾌﾞ to ブ
      '\u{ff8d}\u{ff9e}': '\u{30d9}', // ﾍﾞ to ベ
      '\u{ff8e}\u{ff9e}': '\u{30dc}', // ﾎﾞ to ボ
      '\u{ff73}\u{ff9e}': '\u{30f4}', // ｳﾞ to ヴ
      '\u{ff9c}\u{ff9e}': '\u{30f7}', // ﾜﾞ to ヷ
      '\u{ff66}\u{ff9e}': '\u{30fa}', // ｦﾞ to ヺ

      // Semi-voiced katakana (base + semi-voiced mark)
      '\u{ff8a}\u{ff9f}': '\u{30d1}', // ﾊﾟ to パ
      '\u{ff8b}\u{ff9f}': '\u{30d4}', // ﾋﾟ to ピ
      '\u{ff8c}\u{ff9f}': '\u{30d7}', // ﾌﾟ to プ
      '\u{ff8d}\u{ff9f}': '\u{30da}', // ﾍﾟ to ペ
      '\u{ff8e}\u{ff9f}': '\u{30dd}', // ﾎﾟ to ポ
    };
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    if (_fullwidthToHalfwidth) {
      yield* _toHalfwidth(inputChars);
    } else {
      yield* _toFullwidth(inputChars);
    }
  }

  Iterable<Char> _toHalfwidth(Iterable<Char> inputChars) sync* {
    var offset = 0;
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
      if (_resolvedOptions.convertHiraganas && _resolvedOptions.convertGR) {
        final codepoint = char.c.isNotEmpty ? char.c.codeUnitAt(0) : 0;
        if (codepoint >= 0x3041 && codepoint <= 0x3094) {
          // Convert hiragana to katakana first, then to halfwidth
          final katakanaCodepoint = codepoint + 0x60;
          final katakanaChar = String.fromCharCode(katakanaCodepoint);

          // Check if this katakana has a halfwidth equivalent
          final halfwidth = _grTable[katakanaChar];
          if (halfwidth != null) {
            yield Char(halfwidth, offset, char);
            offset += halfwidth.length;
            continue;
          }

          // Check if it decomposes
          final decomposed = _decompositionTable[katakanaChar];
          if (decomposed != null) {
            for (final rune in decomposed.runes) {
              final decomposedChar = String.fromCharCode(rune);
              yield Char(decomposedChar, offset, char);
              offset += decomposedChar.length;
            }
            continue;
          }
        }
      }

      // No conversion, yield as-is
      yield char.withOffset(offset);
      offset += char.c.length;
    }
  }

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
