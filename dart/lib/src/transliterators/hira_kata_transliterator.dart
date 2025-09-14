import '../char.dart';
import '../transliterator.dart';
import 'hira_kata_table.dart';

/// Converts between Hiragana and Katakana scripts.
///
/// This transliterator can convert hiragana characters to their katakana equivalents
/// or vice versa, based on the mode specified in the constructor.
class HiraKataTransliterator implements Transliterator {
  /// Creates a hiragana/katakana transliterator.
  ///
  /// [mode] specifies the conversion direction:
  /// - 'hira-to-kata': Convert hiragana to katakana (default)
  /// - 'kata-to-hira': Convert katakana to hiragana
  /// - 'hira': Alias for 'kata-to-hira'
  /// - 'kata': Alias for 'hira-to-kata'
  HiraKataTransliterator({
    this.mode = 'hira-to-kata',
  }) {
    _mappingTable = _buildMappingTable();
  }

  /// The conversion mode determining the direction of transliteration.
  ///
  /// Valid values:
  /// - 'hira-to-kata': Convert hiragana characters to katakana
  /// - 'kata-to-hira': Convert katakana characters to hiragana
  /// - 'hira': Shorthand for 'kata-to-hira'
  /// - 'kata': Shorthand for 'hira-to-kata'
  final String mode;

  /// Static cache for mapping tables to avoid rebuilding them for each instance.
  ///
  /// Since the character mappings are constant and depend only on the mode,
  /// we cache them to improve performance when creating multiple transliterators.
  static final Map<String, Map<String, String>> _mappingCache = {};

  late final Map<String, String> _mappingTable;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;

    for (final char in inputChars) {
      final originalChar = char.c;

      // Check if the character needs to be converted
      final mapped = _mappingTable[originalChar];
      if (mapped != null) {
        yield Char(mapped, offset, char);
      } else {
        yield char.withOffset(offset);
      }

      offset += originalChar.length;
    }
  }

  /// Builds the character mapping table based on the current mode.
  ///
  /// Returns a map where keys are source characters and values are
  /// their corresponding characters in the target script.
  Map<String, String> _buildMappingTable() {
    // Check cache first
    final cached = _mappingCache[mode];
    if (cached != null) {
      return cached;
    }

    final mapping = <String, String>{};

    // Main table mappings
    for (final entry in HiraKataTable.hiraganaKatakanaTable) {
      final hiragana = entry.$1;
      final katakana = entry.$2;

      if (mode == 'hira-to-kata') {
        // Base character
        if (hiragana.$1.isNotEmpty) {
          mapping[hiragana.$1] = katakana.$1;
        }
        // Voiced character
        if (hiragana.$2.isNotEmpty && katakana.$2.isNotEmpty) {
          mapping[hiragana.$2] = katakana.$2;
        }
        // Semi-voiced character
        if (hiragana.$3.isNotEmpty && katakana.$3.isNotEmpty) {
          mapping[hiragana.$3] = katakana.$3;
        }
      } else {
        // kata-to-hira mode
        // Base character
        if (katakana.$1.isNotEmpty && hiragana.$1.isNotEmpty) {
          mapping[katakana.$1] = hiragana.$1;
        }
        // Voiced character
        if (katakana.$2.isNotEmpty && hiragana.$2.isNotEmpty) {
          mapping[katakana.$2] = hiragana.$2;
        }
        // Semi-voiced character
        if (katakana.$3.isNotEmpty && hiragana.$3.isNotEmpty) {
          mapping[katakana.$3] = hiragana.$3;
        }
      }
    }

    // Small character mappings
    for (final entry in HiraKataTable.hiraganaKatakanaSmallTable) {
      final hiragana = entry.$1;
      final katakana = entry.$2;

      if (mode == 'hira-to-kata') {
        mapping[hiragana] = katakana;
      } else {
        mapping[katakana] = hiragana;
      }
    }

    // Cache the result
    _mappingCache[mode] = mapping;

    return mapping;
  }
}
