import '../char.dart';
import '../transliterator.dart';
import 'hira_kata_table.dart';

/// Combines decomposed hiragana and katakana characters into composed equivalents.
///
/// This transliterator handles composition of characters like か + ゛-> が, combining
/// base characters with diacritical marks (dakuten and handakuten) into their
/// precomposed forms.
class HiraKataCompositionTransliterator implements Transliterator {
  /// Creates a transliterator that composes hiragana and katakana characters.
  ///
  /// The [composeNonCombiningMarks] parameter determines whether to compose
  /// non-combining voiced marks (゛ U+309B) and semi-voiced marks (゜ U+309C)
  /// in addition to their combining counterparts (゛ U+3099 and ゜ U+309A).
  /// Defaults to false.
  HiraKataCompositionTransliterator({
    this.composeNonCombiningMarks = false,
  }) {
    _table = _buildTable();
  }

  /// Whether to compose non-combining marks (゛ U+309B and ゜U+309C)
  /// in addition to combining marks (゛U+3099 and ゜U+309A)
  final bool composeNonCombiningMarks;

  late final Map<String, Map<String, String>> _table;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    Char? pendingChar;

    for (final char in inputChars) {
      if (pendingChar != null) {
        // Check if current char is a combining mark
        final markTable = _table[char.c];
        if (markTable != null) {
          final composed = markTable[pendingChar.c];
          if (composed != null) {
            yield Char(composed, offset, pendingChar);
            offset += composed.length;
            pendingChar = null;
            continue;
          }
        }
        // No composition, yield pending char
        yield pendingChar.withOffset(offset);
        offset += pendingChar.c.length;
      }
      pendingChar = char;
    }

    // Handle any remaining character
    if (pendingChar != null) {
      yield pendingChar.withOffset(offset);
      offset += pendingChar.c.length;
    }
  }

  Map<String, Map<String, String>> _buildTable() {
    // Generate tables from shared HiraKataTable
    final voicedTable = HiraKataTable.generateVoicedCharacters();
    final semiVoicedTable = HiraKataTable.generateSemiVoicedCharacters();

    final table = <String, Map<String, String>>{
      '\u{3099}': voicedTable, // combining voiced mark
      '\u{309a}': semiVoicedTable, // combining semi-voiced mark
    };

    // Add non-combining marks if enabled
    if (composeNonCombiningMarks) {
      table['\u{309b}'] = voicedTable; // non-combining voiced mark
      table['\u{309c}'] = semiVoicedTable; // non-combining semi-voiced mark
    }

    return table;
  }
}
