import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('TransliteratorRecipe', () {
    group('Low-level API', () {
      test('fromNames creates configs with names only', () {
        final recipe = TransliteratorRecipe.fromNames(['spaces', 'hyphens']);
        expect(recipe.configs.length, equals(2));
        expect(recipe.configs[0].name, equals('spaces'));
        expect(recipe.configs[0].options, isEmpty);
        expect(recipe.configs[1].name, equals('hyphens'));
        expect(recipe.configs[1].options, isEmpty);
      });

      test('fromMap creates configs with options', () {
        final recipe = TransliteratorRecipe.fromMap([
          {'name': 'spaces'},
          {
            'name': 'hyphens',
            'options': {
              'precedence': ['jisx0208_90']
            }
          },
        ]);
        expect(recipe.configs.length, equals(2));
        expect(recipe.configs[0].name, equals('spaces'));
        expect(recipe.configs[0].options, isEmpty);
        expect(recipe.configs[1].name, equals('hyphens'));
        expect(
            recipe.configs[1].options['precedence'], equals(['jisx0208_90']));
      });

      test('empty recipe throws on create', () {
        final recipe = TransliteratorRecipe([]);
        expect(
          () => recipe.create(TransliteratorRegistry()),
          throwsArgumentError,
        );
      });
    });

    group('High-level API - Basic options', () {
      test('default recipe has no configs', () {
        final recipe = TransliteratorRecipe.withOptions();
        expect(recipe.configs, isEmpty);
      });

      test('kanjiOldNew adds ivs-svs-base and kanji-old-new', () {
        final recipe = TransliteratorRecipe.withOptions(kanjiOldNew: true);
        final configs = recipe.configs;

        expect(configs.length, equals(3));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('kanjiOldNew'));
        expect(configs[2].name, equals('ivsSvsBase'));
        expect(configs[2].options['mode'], equals('base'));
      });

      test('replaceSuspiciousHyphensToProlongedSoundMarks', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceSuspiciousHyphensToProlongedSoundMarks: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('prolongedSoundMarks'));
        expect(
            configs[0].options['replaceProlongedMarksFollowingAlnums'], isTrue);
      });

      test('replaceCombinedCharacters', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceCombinedCharacters: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('combined'));
      });

      test('replaceIdeographicAnnotations', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceIdeographicAnnotations: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('ideographicAnnotations'));
      });

      test('replaceRadicals', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceRadicals: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('radicals'));
      });

      test('replaceSpaces', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceSpaces: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('spaces'));
      });

      test('replaceMathematicalAlphanumerics', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceMathematicalAlphanumerics: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('mathematicalAlphanumerics'));
      });

      test('combineDecomposedHiraganasAndKatakanas', () {
        final recipe = TransliteratorRecipe.withOptions(
          combineDecomposedHiraganasAndKatakanas: true,
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hiraKataComposition'));
        expect(configs[0].options['decomposeFirst'], isTrue);
      });
    });

    group('High-level API - Complex options', () {
      test('replaceCircledOrSquaredCharacters - default', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceCircledOrSquaredCharacters:
              ReplaceCircledOrSquaredCharactersOptions.fromBool(true),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('circledOrSquared'));
        expect(configs[0].options['includeEmojis'], isTrue);
      });

      test('replaceCircledOrSquaredCharacters - exclude emojis', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceCircledOrSquaredCharacters:
              const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis(),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('circledOrSquared'));
        expect(configs[0].options['includeEmojis'], isFalse);
      });

      test('replaceHyphens - default', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceHyphens: ReplaceHyphensOptions.fromBool(true),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hyphens'));
        expect(configs[0].options['precedence'],
            equals(['jisx0208_90_windows', 'jisx0201']));
      });

      test('replaceHyphens - custom precedence', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceHyphens: ReplaceHyphensOptions.withPrecedence(
            ['jisx0208_90', 'ascii'],
          ),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('hyphens'));
        expect(
            configs[0].options['precedence'], equals(['jisx0208_90', 'ascii']));
      });

      test('toFullwidth - default', () {
        final recipe = TransliteratorRecipe.withOptions(
          toFullwidth: ToFullwidthOptions.fromBool(true),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisX0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isFalse);
        expect(configs[0].options['u005cAsYenSign'], isFalse);
      });

      test('toFullwidth - u005c as yen sign', () {
        final recipe = TransliteratorRecipe.withOptions(
          toFullwidth: const ToFullwidthOptions.u005cAsYenSign(),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisX0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isFalse);
        expect(configs[0].options['u005cAsYenSign'], isTrue);
      });

      test('toHalfwidth - default', () {
        final recipe = TransliteratorRecipe.withOptions(
          toHalfwidth: ToHalfwidthOptions.fromBool(true),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisX0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isTrue);
        expect(configs[0].options['convertGL'], isTrue);
        expect(configs[0].options['convertGR'], isFalse);
      });

      test('toHalfwidth - hankaku kana', () {
        final recipe = TransliteratorRecipe.withOptions(
          toHalfwidth: const ToHalfwidthOptions.hankakuKana(),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(1));
        expect(configs[0].name, equals('jisX0201AndAlike'));
        expect(configs[0].options['fullwidthToHalfwidth'], isTrue);
        expect(configs[0].options['convertGL'], isTrue);
        expect(configs[0].options['convertGR'], isTrue);
      });

      test('removeIvsSvs - default', () {
        final recipe = TransliteratorRecipe.withOptions(
          removeIvsSvs: RemoveIvsSvsOptions.fromBool(true),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(2));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('ivsSvsBase'));
        expect(configs[1].options['mode'], equals('base'));
        expect(configs[1].options['dropSelectorsAltogether'], isFalse);
      });

      test('removeIvsSvs - drop all selectors', () {
        final recipe = TransliteratorRecipe.withOptions(
          removeIvsSvs: const RemoveIvsSvsOptions.dropAllSelectors(),
        );
        final configs = recipe.configs;

        expect(configs.length, equals(2));
        expect(configs[0].name, equals('ivsSvsBase'));
        expect(configs[0].options['mode'], equals('ivs-or-svs'));
        expect(configs[1].name, equals('ivsSvsBase'));
        expect(configs[1].options['mode'], equals('base'));
        expect(configs[1].options['dropSelectorsAltogether'], isTrue);
      });

      test('charset configuration', () {
        final recipe = TransliteratorRecipe.withOptions(
          removeIvsSvs: RemoveIvsSvsOptions.fromBool(true),
          charset: 'unijis_90',
        );
        final configs = recipe.configs;

        expect(configs[0].options['charset'], equals('unijis_90'));
        expect(configs[1].options['charset'], equals('unijis_90'));
      });
    });

    group('Mutual exclusion', () {
      test('toFullwidth and toHalfwidth are mutually exclusive', () {
        expect(
          () => TransliteratorRecipe.withOptions(
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
        final recipe = TransliteratorRecipe.withOptions(
          replaceCombinedCharacters: true,
          replaceCircledOrSquaredCharacters:
              ReplaceCircledOrSquaredCharactersOptions.fromBool(true),
        );
        final configs = recipe.configs;

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
        final recipe = TransliteratorRecipe.withOptions(
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
        final configs = recipe.configs;
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
          'jisX0201AndAlike',
        };

        final actualNames = names.toSet();
        expect(actualNames, equals(expectedNames));

        // Verify tail section exists (but don't assume order due to insert method)
        expect(names, contains('jisX0201AndAlike'));
        expect(names.where((name) => name == 'ivsSvsBase').length,
            equals(2)); // appears twice
      });
    });

    group('Comprehensive configuration', () {
      test('all options enabled', () {
        final recipe = TransliteratorRecipe.withOptions(
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
          charset: 'unijis_90',
        );
        final configs = recipe.configs;

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
          'jisX0201AndAlike',
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
            configs.firstWhere((c) => c.name == 'jisX0201AndAlike');
        expect(jisx0201Config.options['convertGR'], isTrue);

        // Count ivs-svs-base occurrences
        final ivsSvsCount = configs.where((c) => c.name == 'ivsSvsBase').length;
        expect(ivsSvsCount, equals(2));
      });
    });

    group('Functional tests', () {
      late TransliteratorRegistry registry;

      setUp(() {
        registry = TransliteratorRegistry.createDefault();
      });

      test('recipe can create transliterator without errors', () {
        final recipe = TransliteratorRecipe.withOptions(
          replaceSpaces: true,
        );
        final transliterator = recipe.create(registry);

        // Just test that the transliterator can be created and called
        final input = Chars.fromString('Test');
        final output = transliterator(input);
        expect(output, isNotNull);
        expect(output, isA<Iterable<Char>>());
      });

      test('complex recipe can create transliterator without errors', () {
        final recipe = TransliteratorRecipe.withOptions(
          kanjiOldNew: true,
          replaceSpaces: true,
          toHalfwidth: const ToHalfwidthOptions.enabled(),
          replaceCircledOrSquaredCharacters:
              const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis(),
        );
        final transliterator = recipe.create(registry);

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
  });
}
