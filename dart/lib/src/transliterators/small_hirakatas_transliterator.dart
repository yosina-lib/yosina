// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// Replaces small hiragana/katakana with their ordinary-sized equivalents.
///
/// This transliterator applies character-by-character replacements based on
/// a predefined mapping table.
class SmallHirakatasTransliterator implements Transliterator {
  /// Creates a new instance of [SmallHirakatasTransliterator].
  ///
  /// [options] are currently unused but reserved for future extensions.
  const SmallHirakatasTransliterator([Map<String, dynamic> options = const {}]);

  static const _mappings = <String, String>{
    '\u{3041}': '\u{3042}',
    '\u{3043}': '\u{3044}',
    '\u{3045}': '\u{3046}',
    '\u{3047}': '\u{3048}',
    '\u{3049}': '\u{304a}',
    '\u{3063}': '\u{3064}',
    '\u{3083}': '\u{3084}',
    '\u{3085}': '\u{3086}',
    '\u{3087}': '\u{3088}',
    '\u{308e}': '\u{308f}',
    '\u{3095}': '\u{304b}',
    '\u{3096}': '\u{3051}',
    '\u{30a1}': '\u{30a2}',
    '\u{30a3}': '\u{30a4}',
    '\u{30a5}': '\u{30a6}',
    '\u{30a7}': '\u{30a8}',
    '\u{30a9}': '\u{30aa}',
    '\u{30c3}': '\u{30c4}',
    '\u{30e3}': '\u{30e4}',
    '\u{30e5}': '\u{30e6}',
    '\u{30e7}': '\u{30e8}',
    '\u{30ee}': '\u{30ef}',
    '\u{30f5}': '\u{30ab}',
    '\u{30f6}': '\u{30b1}',
    '\u{31f0}': '\u{30af}',
    '\u{31f1}': '\u{30b7}',
    '\u{31f2}': '\u{30b9}',
    '\u{31f3}': '\u{30c8}',
    '\u{31f4}': '\u{30cc}',
    '\u{31f5}': '\u{30cf}',
    '\u{31f6}': '\u{30d2}',
    '\u{31f7}': '\u{30d5}',
    '\u{31f8}': '\u{30d8}',
    '\u{31f9}': '\u{30db}',
    '\u{31fa}': '\u{30e0}',
    '\u{31fb}': '\u{30e9}',
    '\u{31fc}': '\u{30ea}',
    '\u{31fd}': '\u{30eb}',
    '\u{31fe}': '\u{30ec}',
    '\u{31ff}': '\u{30ed}',
    '\u{ff67}': '\u{ff71}',
    '\u{ff68}': '\u{ff72}',
    '\u{ff69}': '\u{ff73}',
    '\u{ff6a}': '\u{ff74}',
    '\u{ff6b}': '\u{ff75}',
    '\u{ff6c}': '\u{ff94}',
    '\u{ff6d}': '\u{ff95}',
    '\u{ff6e}': '\u{ff96}',
    '\u{ff6f}': '\u{ff82}',
    '\u{1b132}': '\u{3053}',
    '\u{1b150}': '\u{3090}',
    '\u{1b151}': '\u{3091}',
    '\u{1b152}': '\u{3092}',
    '\u{1b155}': '\u{30b3}',
    '\u{1b164}': '\u{30f0}',
    '\u{1b165}': '\u{30f1}',
    '\u{1b166}': '\u{30f2}',
    '\u{1b167}': '\u{30f3}',
  };

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final replacement = _mappings[char.c];
      if (replacement != null) {
        yield Char(replacement, offset, char);
        offset += replacement.length;
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }
}
