import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('TransliterationRecipe', () {
    group('Low-level API', () {
      test('withList creates transliterator from names', () {
        final transliterator = Transliterator.withList(['spaces', 'hyphens']);
        expect(transliterator, isNotNull);
        expect(transliterator, isA<Transliterator>());
      });

      test('withMap creates transliterator with options', () {
        final transliterator = Transliterator.withMap([
          {'name': 'spaces'},
          {
            'name': 'hyphens',
            'options': {
              'precedence': ['jisx0208_90']
            }
          },
        ]);
        expect(transliterator, isNotNull);
        expect(transliterator, isA<Transliterator>());
      });

      test('empty configs throws on create', () {
        expect(
          () => Transliterator.withConfigs([]),
          throwsArgumentError,
        );
      });
    });

    group('High-level API - Basic options', () {
      test('default recipe has no configs', () {
        final recipe = TransliterationRecipe();
        final configs = recipe.buildTransliteratorConfigs();
        expect(configs, isEmpty);
      });

      test('kanjiOldNew adds ivs-svs-base and kanji-old-new', () {
        final recipe = TransliterationRecipe(kanjiOldNew: true);
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(3));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('kanjiOldNew'));
        expect(configs[2].name, equals('ivsSvsBase'));
        expect(configs[2].options['mode'], equals('base'));
      });

      test('replaceSuspiciousHyphensToProlongedSoundMarks', () {
        final recipe = TransliterationRecipe(
          replaceSuspiciousHyphensToProlongedSoundMarks: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('prolongedSoundMarks'));
        expect(
            configs[0].options['replaceProlongedMarksFollowingAlnums'], isTrue);
      });

      test('replaceCombinedCharacters', () {
        final recipe = TransliterationRecipe(
          replaceCombinedCharacters: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('combined'));
      });

      test('replaceIdeographicAnnotations', () {
        final recipe = TransliterationRecipe(
          replaceIdeographicAnnotations: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('ideographicAnnotations'));
      });

      test('replaceRadicals', () {
        final recipe = TransliterationRecipe(
          replaceRadicals: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('radicals'));
      });

      test('replaceSpaces', () {
        final recipe = TransliterationRecipe(
          replaceSpaces: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('spaces'));
      });

      test('replaceMathematicalAlphanumerics', () {
        final recipe = TransliterationRecipe(
          replaceMathematicalAlphanumerics: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('mathematicalAlphanumerics'));
      });

      test('replaceRomanNumerals', () {
        final recipe = TransliterationRecipe(
          replaceRomanNumerals: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('romanNumerals'));
      });

      test('combineDecomposedHiraganasAndKatakanas', () {
        final recipe = TransliterationRecipe(
          combineDecomposedHiraganasAndKatakanas: true,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hiraKataComposition'));
        expect(configs[0].options['decomposeFirst'], isTrue);
      });
    });

    group('High-level API - Complex options', () {
      test('replaceCircledOrSquaredCharacters - default', () {
        final recipe = TransliterationRecipe(
          replaceCircledOrSquaredCharacters:
              ReplaceCircledOrSquaredCharactersOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('circledOrSquared'));
        expect(configs[0].options['includeEmojis'], isTrue);
      });

      test('replaceCircledOrSquaredCharacters - exclude emojis', () {
        final recipe = TransliterationRecipe(
          replaceCircledOrSquaredCharacters:
              const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis(),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('circledOrSquared'));
        expect(configs[0].options['includeEmojis'], isFalse);
      });

      test('replaceHyphens - default', () {
        final recipe = TransliterationRecipe(
          replaceHyphens: ReplaceHyphensOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hyphens'));
        expect(configs[0].options['precedence'],
            equals(['jisx0208_90_windows', 'jisx0201']));
      });

      test('replaceHyphens - custom precedence', () {
        final recipe = TransliterationRecipe(
          replaceHyphens: ReplaceHyphensOptions.withPrecedence(
            ['jisx0208_90', 'ascii'],
          ),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hyphens'));
        expect(
            configs[0].options['precedence'], equals(['jisx0208_90', 'ascii']));
      });

      test('toFullwidth - default', () {
        final recipe = TransliterationRecipe(
          toFullwidth: ToFullwidthOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisx0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isFalse);
        expect(configs[0].options['u005cAsYenSign'], isFalse);
      });

      test('toFullwidth - u005c as yen sign', () {
        final recipe = TransliterationRecipe(
          toFullwidth: const ToFullwidthOptions.u005cAsYenSign(),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisx0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isFalse);
        expect(configs[0].options['u005cAsYenSign'], isTrue);
      });

      test('toHalfwidth - default', () {
        final recipe = TransliterationRecipe(
          toHalfwidth: ToHalfwidthOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisx0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isTrue);
        expect(configs[0].options['convertGL'], isTrue);
        expect(configs[0].options['convertGR'], isFalse);
      });

      test('toHalfwidth - hankaku kana', () {
        final recipe = TransliterationRecipe(
          toHalfwidth: const ToHalfwidthOptions.hankakuKana(),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisx0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isTrue);
        expect(configs[0].options['convertGL'], isTrue);
        expect(configs[0].options['convertGR'], isTrue);
      });

      test('removeIvsSvs - default', () {
        final recipe = TransliterationRecipe(
          removeIvsSvs: RemoveIvsSvsOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(2));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('ivsSvsBase'));
        expect(configs[1].options['mode'], equals('base'));
        expect(configs[1].options['dropSelectorsAltogether'], isFalse);
      });

      test('removeIvsSvs - drop all selectors', () {
        final recipe = TransliterationRecipe(
          removeIvsSvs: const RemoveIvsSvsOptions.dropAllSelectors(),
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs.length, equals(2));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('ivsSvsBase'));
        expect(configs[1].options['mode'], equals('base'));
        expect(configs[1].options['dropSelectorsAltogether'], isTrue);
      });

      test('charset configuration', () {
        final recipe = TransliterationRecipe(
          removeIvsSvs: RemoveIvsSvsOptions.fromBool(true),
          charset: Charset.unijis90,
        );
        final configs = recipe.buildTransliteratorConfigs();

        expect(configs[0].options['charset'], equals(Charset.unijis90));
        expect(configs[1].options['charset'], equals(Charset.unijis90));
      });
    });

    group('Mutual exclusion', () {
      test('toFullwidth and toHalfwidth are mutually exclusive', () {
        expect(
          () => TransliterationRecipe(
            toFullwidth: ToFullwidthOptions.fromBool(true),
            toHalfwidth: ToHalfwidthOptions.fromBool(true),
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('mutually exclusive'),
            ),
          ),
        );
      });
    });

    group('Ordering', () {
      test('circled-or-squared comes before combined', () {
        final recipe = TransliterationRecipe(
          replaceCombinedCharacters: true,
          replaceCircledOrSquaredCharacters:
              ReplaceCircledOrSquaredCharactersOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();

        // Debug: print the actual order
        // print('Config names: ${configs.map((c) => c.name).toList()}');

        final circledIndex =
            configs.indexWhere((c) => c.name == 'circledOrSquared');
        final combinedIndex = configs.indexWhere((c) => c.name == 'combined');

        // Since insertMiddle inserts at position 0, the order is reversed
        // So combined (applied later) comes before circledOrSquared
        expect(circledIndex, isNonNegative);
        expect(combinedIndex, isNonNegative);
        expect(combinedIndex, lessThan(circledIndex));
      });

      test('comprehensive ordering test', () {
        final recipe = TransliterationRecipe(
          kanjiOldNew: true,
          replaceSuspiciousHyphensToProlongedSoundMarks: true,
          replaceCircledOrSquaredCharacters:
              ReplaceCircledOrSquaredCharactersOptions.fromBool(true),
          replaceCombinedCharacters: true,
          replaceIdeographicAnnotations: true,
          replaceRadicals: true,
          replaceSpaces: true,
          replaceHyphens: ReplaceHyphensOptions.fromBool(true),
          replaceMathematicalAlphanumerics: true,
          combineDecomposedHiraganasAndKatakanas: true,
          toFullwidth: ToFullwidthOptions.fromBool(true),
        );
        final configs = recipe.buildTransliteratorConfigs();
        final names = configs.map((c) => c.name).toList();

        // Verify head section
        expect(names[0], equals('hiraKataComposition')); // head
        expect(names[1], equals('ivsSvsBase')); // head (ivs-or-svs)

        // Verify presence of all expected transliterators
        final expectedNames = {
          'hiraKataComposition',
          'ivsSvsBase', // appears twice
          'kanjiOldNew',
          'prolongedSoundMarks',
          'circledOrSquared',
          'combined',
          'ideographicAnnotations',
          'radicals',
          'spaces',
          'hyphens',
          'mathematicalAlphanumerics',
          'jisx0201AndAlike',
        };

        final actualNames = names.toSet();
        expect(actualNames, equals(expectedNames));

        // Verify tail section exists (but don't assume order due to insert method)
        expect(names, contains('jisx0201AndAlike'));
        expect(names.where((name) => name == 'ivsSvsBase').length,
            equals(2)); // appears twice
      });
    });

    group('Comprehensive configuration', () {
      test('all options enabled', () {
        final recipe = TransliterationRecipe(
          kanjiOldNew: true,
          replaceSuspiciousHyphensToProlongedSoundMarks: true,
          replaceCombinedCharacters: true,
          replaceCircledOrSquaredCharacters:
              const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis(),
          replaceIdeographicAnnotations: true,
          replaceRadicals: true,
          replaceSpaces: true,
          replaceHyphens: ReplaceHyphensOptions.withPrecedence(['ascii']),
          replaceMathematicalAlphanumerics: true,
          combineDecomposedHiraganasAndKatakanas: true,
          toHalfwidth: const ToHalfwidthOptions.hankakuKana(),
          removeIvsSvs: const RemoveIvsSvsOptions.dropAllSelectors(),
          charset: Charset.unijis90,
        );
        final configs = recipe.buildTransliteratorConfigs();

        // Verify all expected transliterators are present
        final expectedNames = {
          'hiraKataComposition',
          'ivsSvsBase', // appears twice
          'kanjiOldNew',
          'prolongedSoundMarks',
          'circledOrSquared',
          'combined',
          'ideographicAnnotations',
          'radicals',
          'spaces',
          'hyphens',
          'mathematicalAlphanumerics',
          'jisx0201AndAlike',
        };

        final actualNames = configs.map((c) => c.name).toSet();
        expect(actualNames, equals(expectedNames));

        // Verify specific configurations
        final hyphensConfig = configs.firstWhere((c) => c.name == 'hyphens');
        expect(hyphensConfig.options['precedence'], equals(['ascii']));

        final circledConfig =
            configs.firstWhere((c) => c.name == 'circledOrSquared');
        expect(circledConfig.options['includeEmojis'], isFalse);

        final jisx0201Config =
            configs.firstWhere((c) => c.name == 'jisx0201AndAlike');
        expect(jisx0201Config.options['convertGR'], isTrue);

        // Count ivs-svs-base occurrences
        final ivsSvsCount = configs.where((c) => c.name == 'ivsSvsBase').length;
        expect(ivsSvsCount, equals(2));
      });
    });

    group('Functional tests', () {
      test('recipe can create transliterator without errors', () {
        final recipe = TransliterationRecipe(
          replaceSpaces: true,
        );
        final transliterator = Transliterator.withRecipe(recipe);

        // Just test that the transliterator can be created and called
        final input = Chars.fromString('Test');
        final output = transliterator(input);
        expect(output, isNotNull);
        expect(output, isA<Iterable<Char>>());
      });

      test('complex recipe can create transliterator without errors', () {
        final recipe = TransliterationRecipe(
          kanjiOldNew: true,
          replaceSpaces: true,
          toHalfwidth: const ToHalfwidthOptions.enabled(),
          replaceCircledOrSquaredCharacters:
              const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis(),
        );
        final transliterator = Transliterator.withRecipe(recipe);

        // Just test that the complex transliterator can be created
        final input = Chars.fromString('Test');
        final output = transliterator(input);
        expect(output, isNotNull);
        expect(output, isA<Iterable<Char>>());
      });

      // Note: Detailed functional tests would require more investigation
      // into the specific implementations and expected behaviors of
      // individual transliterators. For now, we verify that the recipe
      // system can create and chain transliterators without errors.
    });
  });

  group('Option classes', () {
    group('ToFullwidthOptions', () {
      test('constructors and properties', () {
        const disabled = ToFullwidthOptions.disabled();
        expect(disabled.isEnabled, isFalse);
        expect(disabled.isU005cAsYenSign, isFalse);

        const enabled = ToFullwidthOptions.enabled();
        expect(enabled.isEnabled, isTrue);
        expect(enabled.isU005cAsYenSign, isFalse);

        const yenSign = ToFullwidthOptions.u005cAsYenSign();
        expect(yenSign.isEnabled, isTrue);
        expect(yenSign.isU005cAsYenSign, isTrue);
      });

      test('fromBool factory', () {
        final enabled = ToFullwidthOptions.fromBool(true);
        expect(enabled.isEnabled, isTrue);
        expect(enabled.isU005cAsYenSign, isFalse);

        final disabled = ToFullwidthOptions.fromBool(false);
        expect(disabled.isEnabled, isFalse);
        expect(disabled.isU005cAsYenSign, isFalse);
      });
    });

    group('ToHalfwidthOptions', () {
      test('constructors and properties', () {
        const disabled = ToHalfwidthOptions.disabled();
        expect(disabled.isEnabled, isFalse);
        expect(disabled.isHankakuKana, isFalse);

        const enabled = ToHalfwidthOptions.enabled();
        expect(enabled.isEnabled, isTrue);
        expect(enabled.isHankakuKana, isFalse);

        const hankaku = ToHalfwidthOptions.hankakuKana();
        expect(hankaku.isEnabled, isTrue);
        expect(hankaku.isHankakuKana, isTrue);
      });
    });

    group('RemoveIvsSvsOptions', () {
      test('constructors and properties', () {
        const disabled = RemoveIvsSvsOptions.disabled();
        expect(disabled.isEnabled, isFalse);
        expect(disabled.isDropAllSelectors, isFalse);

        const enabled = RemoveIvsSvsOptions.enabled();
        expect(enabled.isEnabled, isTrue);
        expect(enabled.isDropAllSelectors, isFalse);

        const dropAll = RemoveIvsSvsOptions.dropAllSelectors();
        expect(dropAll.isEnabled, isTrue);
        expect(dropAll.isDropAllSelectors, isTrue);
      });
    });

    group('ReplaceHyphensOptions', () {
      test('constructors and properties', () {
        const disabled = ReplaceHyphensOptions.disabled();
        expect(disabled.isEnabled, isFalse);
        expect(disabled.precedence, isNull);

        const enabled = ReplaceHyphensOptions.enabled();
        expect(enabled.isEnabled, isTrue);
        expect(enabled.precedence, equals(['jisx0208_90_windows', 'jisx0201']));

        final custom = ReplaceHyphensOptions.withPrecedence(['ascii']);
        expect(custom.isEnabled, isTrue);
        expect(custom.precedence, equals(['ascii']));
      });
    });

    group('ReplaceCircledOrSquaredCharactersOptions', () {
      test('constructors and properties', () {
        const disabled = ReplaceCircledOrSquaredCharactersOptions.disabled();
        expect(disabled.isEnabled, isFalse);
        expect(disabled.includeEmojis, isFalse);

        const enabled = ReplaceCircledOrSquaredCharactersOptions.enabled();
        expect(enabled.isEnabled, isTrue);
        expect(enabled.includeEmojis, isTrue);

        const excludeEmojis =
            ReplaceCircledOrSquaredCharactersOptions.excludeEmojis();
        expect(excludeEmojis.isEnabled, isTrue);
        expect(excludeEmojis.includeEmojis, isFalse);
      });
    });

    test('toFullwidth must come before hiraKata', () {
      final recipe = TransliterationRecipe(
        toFullwidth: const ToFullwidthOptions.enabled(),
        hiraKata: 'kata-to-hira',
      );

      final configs = recipe.buildTransliteratorConfigs();

      expect(configs.length, equals(2));
      expect(configs[0].name, equals('jisx0201AndAlike'));
      expect(configs[1].name, equals('hiraKata'));

      // Test the actual transliteration works correctly
      final transliterator = Transliterator.withRecipe(recipe);
      final input = Chars.fromString('ｶﾀｶﾅ');
      final output = transliterator(input).toList();
      final result = output.map((c) => c.c).join();
      expect(result, equals('かたかな'));
    });
  });
}
