// GENERATED CODE - DO NOT MODIFY BY HAND

import 'transliterator_registry.dart';
import 'transliterators/combined_transliterator.dart';
import 'transliterators/ideographic_annotations_transliterator.dart';
import 'transliterators/kanji_old_new_transliterator.dart';
import 'transliterators/mathematical_alphanumerics_transliterator.dart';
import 'transliterators/radicals_transliterator.dart';
import 'transliterators/spaces_transliterator.dart';

/// Register all generated transliterators with the given registry.
void registerGeneratedTransliterators(TransliteratorRegistry registry) {
  registry
    ..register('spaces', (options) => SpacesTransliterator())
    ..register('radicals', (options) => RadicalsTransliterator())
    ..register('mathematicalAlphanumerics',
        (options) => MathematicalAlphanumericsTransliterator())
    ..register('ideographicAnnotations',
        (options) => IdeographicAnnotationsTransliterator())
    ..register('kanjiOldNew', (options) => KanjiOldNewTransliterator())
    ..register('combined', (options) => CombinedTransliterator());
}
