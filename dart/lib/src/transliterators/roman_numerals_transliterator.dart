// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// Replace roman numeral characters with their ASCII letter equivalents.
class RomanNumeralsTransliterator implements Transliterator {
  const RomanNumeralsTransliterator();
  static const _mappings = <String, List<String>>{
    '\u{2160}': ['I'],
    '\u{2170}': ['i'],
    '\u{2161}': ['I', 'I'],
    '\u{2171}': ['i', 'i'],
    '\u{2162}': ['I', 'I', 'I'],
    '\u{2172}': ['i', 'i', 'i'],
    '\u{2163}': ['I', 'V'],
    '\u{2173}': ['i', 'v'],
    '\u{2164}': ['V'],
    '\u{2174}': ['v'],
    '\u{2165}': ['V', 'I'],
    '\u{2175}': ['v', 'i'],
    '\u{2166}': ['V', 'I', 'I'],
    '\u{2176}': ['v', 'i', 'i'],
    '\u{2167}': ['V', 'I', 'I', 'I'],
    '\u{2177}': ['v', 'i', 'i', 'i'],
    '\u{2168}': ['I', 'X'],
    '\u{2178}': ['i', 'x'],
    '\u{2169}': ['X'],
    '\u{2179}': ['x'],
    '\u{216a}': ['X', 'I'],
    '\u{217a}': ['x', 'i'],
    '\u{216b}': ['X', 'I', 'I'],
    '\u{217b}': ['x', 'i', 'i'],
    '\u{216c}': ['L'],
    '\u{217c}': ['l'],
    '\u{216d}': ['C'],
    '\u{217d}': ['c'],
    '\u{216e}': ['D'],
    '\u{217e}': ['d'],
    '\u{216f}': ['M'],
    '\u{217f}': ['m'],
  };

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final replacement = _mappings[char.c];
      if (replacement != null) {
        for (final replacementChar in replacement) {
          yield Char(replacementChar, offset, char);
          offset += replacementChar.length;
        }
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }
}
