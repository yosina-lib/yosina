import 'char.dart';
import 'transliterator.dart';

/// A transliterator that chains multiple transliterators together.
class ChainedTransliterator implements Transliterator {
  const ChainedTransliterator(this.transliterators);
  final List<Transliterator> transliterators;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) {
    var result = inputChars;
    for (final transliterator in transliterators) {
      result = transliterator(result);
    }
    return result;
  }
}
