// Advanced usage examples for Yosina Dart library.
// This example demonstrates various real-world use cases and techniques.

import 'package:yosina/yosina.dart';

void main() {
  print('=== Advanced Yosina Dart Usage Examples ===\n');

  // 1. Web scraping text normalization
  {
    print('1. Web Scraping Text Normalization');
    print('   (Typical use case: cleaning scraped Japanese web content)');

    final webScrapingRecipe = TransliterationRecipe(
      kanjiOldNew: true,
      replaceSpaces: true,
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
      replaceIdeographicAnnotations: true,
      replaceRadicals: true,
      combineDecomposedHiraganasAndKatakanas: true,
    );

    final normalizer = Transliterator.withRecipe(webScrapingRecipe);

    // Simulate messy web content
    final messyContent = [
      ('これは　テスト です。', 'Mixed spaces from different sources'),
      ('コンピューター-プログラム', 'Suspicious hyphens in katakana'),
      ('古い漢字：廣島、檜、國', 'Old-style kanji forms'),
      ('部首：⺅⻌⽊', 'CJK radicals instead of regular kanji'),
    ];

    for (final (text, description) in messyContent) {
      final cleaned = Chars.charsToString(normalizer(Chars.fromString(text)));
      print('  $description:');
      print('    Before: \'$text\'');
      print('    After:  \'$cleaned\'');
      print('');
    }
  }

  // 2. Document standardization
  {
    print('2. Document Standardization');
    print('   (Use case: preparing documents for consistent formatting)');

    final documentRecipe = TransliterationRecipe(
      toFullwidth: ToFullwidthOptions.enabled(),
      replaceSpaces: true,
      kanjiOldNew: true,
      combineDecomposedHiraganasAndKatakanas: true,
    );

    final documentStandardizer = Transliterator.withRecipe(documentRecipe);

    final documentSamples = [
      ('Hello World 123', 'ASCII text to full-width'),
      ('カ゛', 'Decomposed katakana with combining mark'),
      ('檜原村', 'Old kanji in place names'),
    ];

    for (final (text, description) in documentSamples) {
      final standardized =
          Chars.charsToString(documentStandardizer(Chars.fromString(text)));
      print('  $description:');
      print('    Input:  \'$text\'');
      print('    Output: \'$standardized\'');
      print('');
    }
  }

  // 3. Search index preparation
  {
    print('3. Search Index Preparation');
    print('   (Use case: normalizing text for search engines)');

    final searchRecipe = TransliterationRecipe(
      kanjiOldNew: true,
      replaceSpaces: true,
      toHalfwidth: ToHalfwidthOptions.enabled(),
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
    );

    final searchNormalizer = Transliterator.withRecipe(searchRecipe);

    final searchSamples = [
      ('東京スカイツリー', 'Famous landmark name'),
      ('プログラミング言語', 'Technical terms'),
      ('コンピューター-サイエンス', 'Academic field with suspicious hyphen'),
    ];

    for (final (text, description) in searchSamples) {
      final normalized =
          Chars.charsToString(searchNormalizer(Chars.fromString(text)));
      print('  $description:');
      print('    Original:   \'$text\'');
      print('    Normalized: \'$normalized\'');
      print('');
    }
  }

  // 4. Custom pipeline example
  {
    print('4. Custom Processing Pipeline');
    print('   (Use case: step-by-step text transformation)');

    // Create multiple transliterators for pipeline processing
    final steps = [
      ('Spaces', ['spaces']),
      (
        'Old Kanji',
        [
          {
            'name': 'ivsSvsBase',
            'options': {
              'mode': 'ivs-svs',
              'charset': Charset.unijis2004,
            },
          },
          {'name': 'kanjiOldNew'},
          {
            'name': 'ivsSvsBase',
            'options': {
              'mode': 'base',
              'charset': Charset.unijis2004,
            },
          },
        ]
      ),
      (
        'Width',
        [
          {
            'name': 'jisX0201AndAlike',
            'options': {
              'u005cAsYenSign': false,
            },
          },
        ]
      ),
      ('ProlongedSoundMarks', ['prolongedSoundMarks']),
    ];

    final transliterators = <(String, Transliterator)>[];
    for (final (name, config) in steps) {
      final t = config is List<String>
          ? Transliterator.withList(config)
          : Transliterator.withMap(config as List<Map<String, dynamic>>);
      transliterators.add((name, t));
    }

    const pipelineText = 'hello　world ﾃｽﾄ 檜-システム';
    var currentText = pipelineText;

    print('  Starting text: \'$currentText\'');

    for (final (stepName, transliterator) in transliterators) {
      final previousText = currentText;
      currentText =
          Chars.charsToString(transliterator(Chars.fromString(currentText)));
      if (previousText != currentText) {
        print('  After $stepName: \'$currentText\'');
      }
    }

    print('  Final result: \'$currentText\'');
  }

  // 5. Unicode normalization showcase
  {
    print('\n5. Unicode Normalization Showcase');
    print('   (Demonstrating various Unicode edge cases)');

    final unicodeRecipe = TransliterationRecipe(
      replaceSpaces: true,
      replaceMathematicalAlphanumerics: true,
      replaceRadicals: true,
    );

    final unicodeNormalizer = Transliterator.withRecipe(unicodeRecipe);

    final unicodeSamples = [
      ('\u{2003}\u{2002}\u{2000}', 'Various em/en spaces'),
      ('\u{3000}\u{00A0}\u{202F}', 'Ideographic and narrow spaces'),
      ('⺅⻌⽊', 'CJK radicals'),
      ('\u{1D400}\u{1D401}\u{1D402}', 'Mathematical bold letters'),
    ];

    print('\n   Processing text samples with character codes:\n');
    for (final (text, description) in unicodeSamples) {
      print('   $description:');
      print('     Original: \'$text\'');

      // Show character codes for clarity
      final codes = text.codeUnits
          .map((c) => 'U+${c.toRadixString(16).toUpperCase().padLeft(4, '0')}');
      print('     Codes:    ${codes.join(' ')}');

      final transliterated =
          Chars.charsToString(unicodeNormalizer(Chars.fromString(text)));
      print('     Result:   \'$transliterated\'\n');
    }
  }

  // 6. Performance considerations
  {
    print('6. Performance Considerations');
    print('   (Reusing transliterators for better performance)');

    final perfRecipe = TransliterationRecipe(
      kanjiOldNew: true,
      replaceSpaces: true,
    );

    final perfTransliterator = Transliterator.withRecipe(perfRecipe);

    // Simulate processing multiple texts
    final texts = [
      'これはテストです',
      '檜原村は美しい',
      'hello　world',
      'プログラミング',
    ];

    print('  Processing ${texts.length} texts with the same transliterator:');
    for (var i = 0; i < texts.length; i++) {
      final text = texts[i];
      final result =
          Chars.charsToString(perfTransliterator(Chars.fromString(text)));
      print('    ${i + 1}: \'$text\' → \'$result\'');
    }
  }

  print('\n=== Advanced Examples Complete ===');
}
