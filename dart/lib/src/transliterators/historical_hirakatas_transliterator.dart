import '../char.dart';
import '../transliterator.dart';

/// Conversion mode for historical hiragana/katakana characters.
enum ConversionMode {
  /// Convert to the simple modern equivalent (e.g., ゐ -> い).
  simple,

  /// Decompose into multiple modern characters (e.g., ゐ -> うぃ).
  decompose,

  /// Skip conversion, leaving the character unchanged.
  skip,
}

/// Conversion mode for voiced historical katakana characters.
enum VoicedConversionMode {
  /// Decompose into modern equivalents (e.g., ヷ -> ヴァ).
  decompose,

  /// Skip conversion, leaving the character unchanged.
  skip,
}

/// Converts historical hiragana/katakana characters to their modern equivalents.
///
/// This transliterator handles three categories of historical kana:
/// - Historical hiragana: ゐ (U+3090), ゑ (U+3091)
/// - Historical katakana: ヰ (U+30F0), ヱ (U+30F1)
/// - Voiced historical katakana: ヷ (U+30F7), ヸ (U+30F8), ヹ (U+30F9), ヺ (U+30FA)
class HistoricalHirakatasTransliterator implements Transliterator {
  /// Creates a historical hirakatas transliterator.
  ///
  /// [hiraganas] controls how historical hiragana characters
  /// are converted (default: [ConversionMode.simple]).
  ///
  /// [katakanas] controls how historical katakana characters
  /// are converted (default: [ConversionMode.simple]).
  ///
  /// [voicedKatakanas] controls how voiced historical katakana
  /// characters are converted (default: [VoicedConversionMode.skip]).
  HistoricalHirakatasTransliterator({
    this.hiraganas = ConversionMode.simple,
    this.katakanas = ConversionMode.simple,
    this.voicedKatakanas = VoicedConversionMode.skip,
  });

  /// The conversion mode for historical hiragana characters.
  final ConversionMode hiraganas;

  /// The conversion mode for historical katakana characters.
  final ConversionMode katakanas;

  /// The conversion mode for voiced historical katakana characters.
  final VoicedConversionMode voicedKatakanas;

  /// Historical hiragana mappings: source -> {simple, decompose}.
  static const _historicalHiraganaMappings = <String, (String, String)>{
    '\u{3090}': ('\u{3044}', '\u{3046}\u{3043}'), // ゐ → い / うぃ
    '\u{3091}': ('\u{3048}', '\u{3046}\u{3047}'), // ゑ → え / うぇ
  };

  /// Historical katakana mappings: source -> {simple, decompose}.
  static const _historicalKatakanaMappings = <String, (String, String)>{
    '\u{30F0}': ('\u{30A4}', '\u{30A6}\u{30A3}'), // ヰ → イ / ウィ
    '\u{30F1}': ('\u{30A8}', '\u{30A6}\u{30A7}'), // ヱ → エ / ウェ
  };

  /// Voiced historical katakana mappings: source -> small vowel suffix.
  static const _voicedHistoricalKanaMappings = <String, String>{
    '\u{30F7}': '\u{30A1}', // ヷ → ァ
    '\u{30F8}': '\u{30A3}', // ヸ → ィ
    '\u{30F9}': '\u{30A7}', // ヹ → ェ
    '\u{30FA}': '\u{30A9}', // ヺ → ォ
  };

  /// Decomposed voiced historical kana mappings (for decomposed input).
  /// Keyed by base kana, value is the small vowel suffix.
  static const _voicedHistoricalKanaDecomposedMappings = <String, String>{
    '\u{30EF}': '\u{30A1}', // ヷ → ァ
    '\u{30F0}': '\u{30A3}', // ヸ → ィ
    '\u{30F1}': '\u{30A7}', // ヹ → ェ
    '\u{30F2}': '\u{30A9}', // ヺ → ォ
  };

  /// Combining dakuten (voiced sound mark).
  static const _combiningDakuten = '\u{3099}';
  static const _vu = '\u{30F4}';
  static const _u = '\u{30A6}';

  /// Emits a single char through the normal processing pipeline.
  Iterable<Char> _emitChar(Char char, int offset) sync* {
    // Historical hiragana
    final hiraMapping = _historicalHiraganaMappings[char.c];
    if (hiraMapping != null && hiraganas != ConversionMode.skip) {
      final replacement =
          hiraganas == ConversionMode.simple ? hiraMapping.$1 : hiraMapping.$2;
      yield Char(replacement, offset, char);
      return;
    }

    // Historical katakana
    final kataMapping = _historicalKatakanaMappings[char.c];
    if (kataMapping != null && katakanas != ConversionMode.skip) {
      final replacement =
          katakanas == ConversionMode.simple ? kataMapping.$1 : kataMapping.$2;
      yield Char(replacement, offset, char);
      return;
    }

    // Voiced historical katakana (composed form)
    if (voicedKatakanas == VoicedConversionMode.decompose) {
      final decomposed = _voicedHistoricalKanaMappings[char.c];
      if (decomposed != null) {
        yield Char(_vu, offset, char);
        yield Char(decomposed, offset + _vu.length, char);
        return;
      }
    }

    yield char.withOffset(offset);
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    Char? pending;
    for (final char in inputChars) {
      if (pending == null) {
        pending = char;
        continue;
      }
      if (char.c == _combiningDakuten) {
        // Check if pending char could be a decomposed voiced base
        final decomposed = _voicedHistoricalKanaDecomposedMappings[pending.c];
        if (voicedKatakanas == VoicedConversionMode.skip ||
            decomposed == null) {
          yield pending.withOffset(offset);
          offset += pending.c.length;
          pending = char;
          continue;
        }
        yield Char(_u, offset, pending);
        offset += _u.length;
        yield char.withOffset(offset);
        offset += char.c.length;
        yield Char(decomposed, offset, pending);
        offset += decomposed.length;
        pending = null;
        continue;
      }
      // Current char is not dakuten, flush pending through normal processing
      for (final emitted in _emitChar(pending, offset)) {
        yield emitted;
        offset = emitted.offset + emitted.c.length;
      }
      pending = char;
    }

    // Flush remaining pending
    if (pending != null) {
      for (final emitted in _emitChar(pending, offset)) {
        yield emitted;
        offset = emitted.offset + emitted.c.length;
      }
    }
  }
}
