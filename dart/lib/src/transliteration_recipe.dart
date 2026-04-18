import 'transliterator.dart';
import 'transliterators/charset.dart';

/// Recipe-level mode for historical hiragana/katakana conversion.
///
/// Unlike the transliterator-level [ConversionMode], this enum does not include
/// a "skip" value. Use `null` to indicate that the conversion should not be applied.
enum HistoricalHirakatasRecipeMode {
  /// Convert to the simple modern equivalent (e.g., ゐ -> い).
  /// Voiced katakana characters are left unchanged.
  simple,

  /// Decompose into multiple modern characters (e.g., ゐ -> うぃ).
  /// Voiced katakana characters are also decomposed.
  decompose,
}

// MARK: - Option Classes

/// Options for full-width conversion.
/// Options for converting characters to their fullwidth equivalents.
///
/// Controls which character types should be converted to fullwidth forms.
/// Fullwidth characters are typically used in East Asian typography.
class ToFullwidthOptions {
  /// Creates fullwidth conversion options with explicit settings.
  const ToFullwidthOptions({
    required this.enabled,
    required this.u005cAsYenSign,
  });

  /// Creates disabled fullwidth conversion options.
  const ToFullwidthOptions.disabled()
      : enabled = false,
        u005cAsYenSign = false;

  /// Creates enabled fullwidth conversion options with default settings.
  const ToFullwidthOptions.enabled()
      : enabled = true,
        u005cAsYenSign = false;

  /// Creates enabled fullwidth conversion options that treat backslash as yen sign.
  const ToFullwidthOptions.u005cAsYenSign()
      : enabled = true,
        u005cAsYenSign = true;

  /// Whether fullwidth conversion is enabled.
  final bool enabled;

  /// Whether to treat backslash (U+005C) as yen sign.
  final bool u005cAsYenSign;

  /// Whether fullwidth conversion is enabled.
  bool get isEnabled => enabled;

  /// Whether backslash should be treated as yen sign.
  bool get isU005cAsYenSign => u005cAsYenSign;

  /// Creates options from a boolean enabled state.
  static ToFullwidthOptions fromBool(bool enabled) {
    return enabled
        ? const ToFullwidthOptions.enabled()
        : const ToFullwidthOptions.disabled();
  }
}

/// Options for half-width conversion.
/// Options for converting characters to their halfwidth equivalents.
///
/// Controls which character types should be converted to halfwidth forms.
/// Halfwidth characters are single-byte width characters commonly used in ASCII.
class ToHalfwidthOptions {
  const ToHalfwidthOptions({
    required this.enabled,
    required this.hankakuKana,
  });

  const ToHalfwidthOptions.disabled()
      : enabled = false,
        hankakuKana = false;

  const ToHalfwidthOptions.enabled()
      : enabled = true,
        hankakuKana = false;

  const ToHalfwidthOptions.hankakuKana()
      : enabled = true,
        hankakuKana = true;

  /// Whether halfwidth conversion is enabled.
  final bool enabled;

  /// Whether to convert to hankaku (halfwidth) kana.
  final bool hankakuKana;

  bool get isEnabled => enabled;
  bool get isHankakuKana => hankakuKana;

  static ToHalfwidthOptions fromBool(bool enabled) {
    return enabled
        ? const ToHalfwidthOptions.enabled()
        : const ToHalfwidthOptions.disabled();
  }
}

/// Options for IVS/SVS removal.
/// Options for removing Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS).
///
/// Controls which types of variation sequences should be removed from the text.
/// These sequences are used to specify glyph variants in Unicode.
class RemoveIvsSvsOptions {
  const RemoveIvsSvsOptions({
    required this.enabled,
    required this.dropAllSelectors,
  });

  const RemoveIvsSvsOptions.disabled()
      : enabled = false,
        dropAllSelectors = false;

  const RemoveIvsSvsOptions.enabled()
      : enabled = true,
        dropAllSelectors = false;

  const RemoveIvsSvsOptions.dropAllSelectors()
      : enabled = true,
        dropAllSelectors = true;

  /// Whether IVS/SVS removal is enabled.
  final bool enabled;

  /// Whether to drop all variation selectors.
  final bool dropAllSelectors;

  bool get isEnabled => enabled;
  bool get isDropAllSelectors => dropAllSelectors;

  static RemoveIvsSvsOptions fromBool(bool enabled) {
    return enabled
        ? const RemoveIvsSvsOptions.enabled()
        : const RemoveIvsSvsOptions.disabled();
  }
}

/// Options for hyphens replacement.
/// Options for replacing various hyphen-like characters.
///
/// Controls which types of hyphens and dashes should be replaced with a standard hyphen.
/// This helps normalize different dash characters used across various input methods.
class ReplaceHyphensOptions {
  const ReplaceHyphensOptions({
    required this.enabled,
    this.precedence,
  });

  const ReplaceHyphensOptions.disabled()
      : enabled = false,
        precedence = null;

  const ReplaceHyphensOptions.enabled()
      : enabled = true,
        precedence = const ['jisx0208_90_windows', 'jisx0201'];

  /// Whether hyphen replacement is enabled.
  final bool enabled;

  /// The precedence order for hyphen replacement.
  final List<String>? precedence;

  bool get isEnabled => enabled;

  static ReplaceHyphensOptions withPrecedence(List<String> precedence) {
    return ReplaceHyphensOptions(enabled: true, precedence: precedence);
  }

  static ReplaceHyphensOptions fromBool(bool enabled) {
    return enabled
        ? const ReplaceHyphensOptions.enabled()
        : const ReplaceHyphensOptions.disabled();
  }
}

/// Options for circled or squared characters replacement.
/// Options for replacing circled or squared characters with their normal equivalents.
///
/// Controls which types of enclosed characters should be replaced.
/// These include characters enclosed in circles or squares, commonly used in East Asian typography.
class ReplaceCircledOrSquaredCharactersOptions {
  const ReplaceCircledOrSquaredCharactersOptions({
    required this.enabled,
    required this.includeEmojis,
  });

  const ReplaceCircledOrSquaredCharactersOptions.disabled()
      : enabled = false,
        includeEmojis = false;

  const ReplaceCircledOrSquaredCharactersOptions.enabled()
      : enabled = true,
        includeEmojis = true;

  const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis()
      : enabled = true,
        includeEmojis = false;

  /// Whether replacement is enabled.
  final bool enabled;

  /// Whether to include emoji characters in the replacement.
  final bool includeEmojis;

  bool get isEnabled => enabled;

  static ReplaceCircledOrSquaredCharactersOptions fromBool(bool enabled) {
    return enabled
        ? const ReplaceCircledOrSquaredCharactersOptions.enabled()
        : const ReplaceCircledOrSquaredCharactersOptions.disabled();
  }
}

/// Options for replacing suspicious hyphens with prolonged sound marks.
///
/// Controls the behavior of suspicious hyphen replacement. In conservative mode,
/// only prolonged marks following alphanumeric characters are replaced. In aggressive
/// mode, prolonged marks between non-kana characters are also replaced.
class ReplaceSuspiciousHyphensOptions {
  const ReplaceSuspiciousHyphensOptions._({
    required this.enabled,
    required this.replaceProlongedMarksBetweenNonKanas,
  });

  /// Disabled option - suspicious hyphens will not be replaced.
  static const disabled = ReplaceSuspiciousHyphensOptions._(
      enabled: false, replaceProlongedMarksBetweenNonKanas: false);

  /// Conservative mode - replaces hyphens following kana and alphanumeric characters.
  static const conservative = ReplaceSuspiciousHyphensOptions._(
      enabled: true, replaceProlongedMarksBetweenNonKanas: false);

  /// Aggressive mode - also replaces prolonged marks between non-kana characters.
  static const aggressive = ReplaceSuspiciousHyphensOptions._(
      enabled: true, replaceProlongedMarksBetweenNonKanas: true);

  /// Whether suspicious hyphens replacement is enabled.
  final bool enabled;

  /// Whether to also replace prolonged marks between non-kana characters.
  final bool replaceProlongedMarksBetweenNonKanas;

  /// Whether replacement is enabled.
  bool get isEnabled => enabled;

  /// Whether aggressive mode is enabled (replaces prolonged marks between non-kana characters).
  bool get isAggressive => replaceProlongedMarksBetweenNonKanas;

  /// Creates options from a boolean enabled state.
  static ReplaceSuspiciousHyphensOptions fromBool(bool enabled) {
    return enabled ? conservative : disabled;
  }
}

// MARK: - TransliteratorConfig

// MARK: - TransliterationRecipe

/// Represents a recipe for creating transliterators.
///
/// This class encapsulates a set of text transformation options that can be
/// applied to Japanese text. It builds a configured pipeline of transliterators
/// based on the specified options.
///
/// The recipe supports various transformations including:
/// - Character width conversions (fullwidth/halfwidth)
/// - Script conversions (hiragana/katakana)
/// - Character normalization (hyphens, spaces, etc.)
/// - Variant sequence handling (IVS/SVS)
class TransliterationRecipe {
  TransliterationRecipe({
    this.kanjiOldNew = false,
    this.hiraKata,
    this.replaceJapaneseIterationMarks = false,
    this.replaceSuspiciousHyphensToProlongedSoundMarks =
        ReplaceSuspiciousHyphensOptions.disabled,
    this.replaceCombinedCharacters = false,
    this.replaceCircledOrSquaredCharacters =
        const ReplaceCircledOrSquaredCharactersOptions.disabled(),
    this.replaceIdeographicAnnotations = false,
    this.replaceRadicals = false,
    this.replaceSpaces = false,
    this.replaceHyphens = const ReplaceHyphensOptions.disabled(),
    this.replaceMathematicalAlphanumerics = false,
    this.replaceRomanNumerals = false,
    this.replaceArchaicHirakatas = false,
    this.replaceSmallHirakatas = false,
    this.convertHistoricalHirakatas,
    this.combineDecomposedHiraganasAndKatakanas = false,
    this.toFullwidth = const ToFullwidthOptions.disabled(),
    this.toHalfwidth = const ToHalfwidthOptions.disabled(),
    this.removeIvsSvs = const RemoveIvsSvsOptions.disabled(),
    this.charset = Charset.unijis2004,
  }) {
    // Check for mutually exclusive options
    final errors = <String>[];
    if (toFullwidth.isEnabled && toHalfwidth.isEnabled) {
      errors.add('toFullwidth and toHalfwidth are mutually exclusive');
    }

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('; '));
    }
  }

  /// Whether to convert old kanji forms to new forms.
  final bool kanjiOldNew;

  /// The hiragana/katakana conversion mode ('hira' or 'kata').
  final String? hiraKata;

  /// Whether to replace Japanese iteration marks.
  final bool replaceJapaneseIterationMarks;

  /// Options for replacing suspicious hyphens with prolonged sound marks.
  final ReplaceSuspiciousHyphensOptions
      replaceSuspiciousHyphensToProlongedSoundMarks;

  /// Whether to replace combined characters.
  final bool replaceCombinedCharacters;

  /// Options for replacing circled or squared characters.
  final ReplaceCircledOrSquaredCharactersOptions
      replaceCircledOrSquaredCharacters;

  /// Whether to replace ideographic annotations.
  final bool replaceIdeographicAnnotations;

  /// Whether to replace Kangxi radicals.
  final bool replaceRadicals;

  /// Whether to replace various space characters.
  final bool replaceSpaces;

  /// Options for replacing hyphens.
  final ReplaceHyphensOptions replaceHyphens;

  /// Whether to replace mathematical alphanumeric symbols.
  final bool replaceMathematicalAlphanumerics;

  /// Whether to replace roman numeral characters.
  final bool replaceRomanNumerals;

  /// Whether to replace archaic kana (hentaigana) with modern equivalents.
  final bool replaceArchaicHirakatas;

  /// Whether to replace small hiragana/katakana with ordinary-sized equivalents.
  final bool replaceSmallHirakatas;

  /// Conversion mode for historical hiragana/katakana characters (ゐ, ゑ, ヰ, ヱ, ヷ, ヸ, ヹ, ヺ).
  ///
  /// - [HistoricalHirakatasRecipeMode.simple]: Convert hiragana/katakana to single-character modern equivalents;
  ///   voiced characters are left unchanged.
  /// - [HistoricalHirakatasRecipeMode.decompose]: Convert all historical kana to multi-character decomposed forms.
  /// - `null`: Leave unchanged (default).
  final HistoricalHirakatasRecipeMode? convertHistoricalHirakatas;

  /// Whether to combine decomposed hiragana and katakana characters.
  final bool combineDecomposedHiraganasAndKatakanas;

  /// Options for converting to fullwidth characters.
  final ToFullwidthOptions toFullwidth;

  /// Options for converting to halfwidth characters.
  final ToHalfwidthOptions toHalfwidth;

  /// Options for removing IVS/SVS sequences.
  final RemoveIvsSvsOptions removeIvsSvs;

  /// The character set to use for conversions.
  final Charset charset;

  /// Builds a list of transliterator configurations from this recipe.
  ///
  /// The transliterators are ordered to ensure proper text transformation.
  /// The order is important as some transformations depend on others.
  List<TransliteratorConfig> buildTransliteratorConfigs() {
    final builder = _TransliteratorConfigListBuilder();

    // Apply transformations in the specified order
    _applyKanjiOldNew(builder, kanjiOldNew, removeIvsSvs, charset);
    _applyReplaceSuspiciousHyphensToProlongedSoundMarks(
        builder, replaceSuspiciousHyphensToProlongedSoundMarks);
    _applyReplaceCircledOrSquaredCharacters(
        builder, replaceCircledOrSquaredCharacters);
    _applyReplaceCombinedCharacters(builder, replaceCombinedCharacters);
    _applyReplaceIdeographicAnnotations(builder, replaceIdeographicAnnotations);
    _applyReplaceRadicals(builder, replaceRadicals);
    _applyReplaceSpaces(builder, replaceSpaces);
    _applyReplaceHyphens(builder, replaceHyphens);
    _applyReplaceMathematicalAlphanumerics(
        builder, replaceMathematicalAlphanumerics);
    _applyReplaceRomanNumerals(builder, replaceRomanNumerals);
    _applyReplaceArchaicHirakatas(builder, replaceArchaicHirakatas);
    _applyReplaceSmallHirakatas(builder, replaceSmallHirakatas);
    _applyHistoricalHirakatas(builder, convertHistoricalHirakatas);
    _applyCombineDecomposedHiraganasAndKatakanas(
        builder, combineDecomposedHiraganasAndKatakanas);
    _applyToFullwidth(builder, toFullwidth);
    _applyHiraKata(builder, hiraKata);
    _applyReplaceJapaneseIterationMarks(builder, replaceJapaneseIterationMarks);
    _applyToHalfwidth(builder, toHalfwidth);
    _applyRemoveIvsSvs(builder, removeIvsSvs, charset);

    return builder.build();
  }

  // Private helper methods for applying transformations

  static void _removeIvsSvsHelper(_TransliteratorConfigListBuilder ctx,
      bool dropAllSelectors, Charset charset) {
    // First insert IVS-or-SVS mode at head
    ctx
      ..insertHead(
        TransliteratorConfig('ivsSvsBase', {
          'mode': 'ivs-or-svs',
          'charset': charset,
        }),
        forceReplace: true,
      )
      ..insertTail(
        TransliteratorConfig('ivsSvsBase', {
          'mode': 'base',
          'dropSelectorsAltogether': dropAllSelectors,
          'charset': charset,
        }),
        forceReplace: true,
      );
  }

  static void _applyKanjiOldNew(_TransliteratorConfigListBuilder ctx,
      bool kanjiOldNew, RemoveIvsSvsOptions removeIvsSvs, Charset charset) {
    if (kanjiOldNew) {
      if (!removeIvsSvs.isEnabled) {
        _removeIvsSvsHelper(ctx, false, charset);
      }
      ctx.insertMiddle(
        const TransliteratorConfig('kanjiOldNew'),
        forceReplace: false,
      );
    }
  }

  static void _applyHiraKata(
      _TransliteratorConfigListBuilder ctx, String? hiraKata) {
    if (hiraKata != null) {
      ctx.insertTail(
        TransliteratorConfig('hiraKata', {'mode': hiraKata}),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceJapaneseIterationMarks(
      _TransliteratorConfigListBuilder ctx,
      bool replaceJapaneseIterationMarks) {
    if (replaceJapaneseIterationMarks) {
      // Insert HiraKataComposition at head to ensure composed forms
      ctx
        ..insertHead(
          const TransliteratorConfig('hiraKataComposition', {
            'composeNonCombiningMarks': true,
          }),
          forceReplace: false,
        )
        // Then insert the japanese-iteration-marks in the middle
        ..insertMiddle(
          const TransliteratorConfig('japaneseIterationMarks'),
          forceReplace: false,
        );
    }
  }

  static void _applyReplaceSuspiciousHyphensToProlongedSoundMarks(
      _TransliteratorConfigListBuilder ctx,
      ReplaceSuspiciousHyphensOptions options) {
    if (options.isEnabled) {
      ctx.insertMiddle(
        TransliteratorConfig('prolongedSoundMarks', {
          'replaceProlongedMarksFollowingAlnums': true,
          'replaceProlongedMarksBetweenNonKanas': options.isAggressive,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceIdeographicAnnotations(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('ideographicAnnotations'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceRadicals(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('radicals'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceSpaces(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('spaces'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceHyphens(
      _TransliteratorConfigListBuilder ctx, ReplaceHyphensOptions options) {
    if (options.isEnabled) {
      final Map<String, dynamic> configOptions =
          options.precedence != null ? {'precedence': options.precedence} : {};
      ctx.insertMiddle(
        TransliteratorConfig('hyphens', configOptions),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceMathematicalAlphanumerics(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('mathematicalAlphanumerics'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceRomanNumerals(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('romanNumerals'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceArchaicHirakatas(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('archaicHirakatas'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceSmallHirakatas(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('smallHirakatas'),
        forceReplace: false,
      );
    }
  }

  static void _applyHistoricalHirakatas(_TransliteratorConfigListBuilder ctx,
      HistoricalHirakatasRecipeMode? convertHistoricalHirakatas) {
    if (convertHistoricalHirakatas != null) {
      final voicedMode =
          convertHistoricalHirakatas == HistoricalHirakatasRecipeMode.decompose
              ? 'decompose'
              : 'skip';
      ctx.insertMiddle(
        TransliteratorConfig('historicalHirakatas', {
          'hiraganas': convertHistoricalHirakatas.name,
          'katakanas': convertHistoricalHirakatas.name,
          'voicedKatakanas': voicedMode,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyCombineDecomposedHiraganasAndKatakanas(
      _TransliteratorConfigListBuilder ctx, bool combine) {
    if (combine) {
      ctx.insertHead(
        const TransliteratorConfig('hiraKataComposition', {
          'decomposeFirst': true,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyToFullwidth(
      _TransliteratorConfigListBuilder ctx, ToFullwidthOptions options) {
    if (options.isEnabled) {
      ctx.insertTail(
        TransliteratorConfig('jisx0201AndAlike', {
          'fullwidthToHalfwidth': false,
          'u005cAsYenSign': options.isU005cAsYenSign,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyToHalfwidth(
      _TransliteratorConfigListBuilder ctx, ToHalfwidthOptions options) {
    if (options.isEnabled) {
      ctx.insertTail(
        TransliteratorConfig('jisx0201AndAlike', {
          'fullwidthToHalfwidth': true,
          'convertGL': true,
          'convertGR': options.isHankakuKana,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyRemoveIvsSvs(_TransliteratorConfigListBuilder ctx,
      RemoveIvsSvsOptions options, Charset charset) {
    if (options.isEnabled) {
      _removeIvsSvsHelper(ctx, options.isDropAllSelectors, charset);
    }
  }

  static void _applyReplaceCombinedCharacters(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('combined'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceCircledOrSquaredCharacters(
      _TransliteratorConfigListBuilder ctx,
      ReplaceCircledOrSquaredCharactersOptions options) {
    if (options.isEnabled) {
      ctx.insertMiddle(
        TransliteratorConfig('circledOrSquared', {
          'includeEmojis': options.includeEmojis,
        }),
        forceReplace: false,
      );
    }
  }
}

// MARK: - Internal Builder

/// Internal builder for creating lists of transliterator configurations.
///
/// This builder maintains separate head and tail lists to allow insertion
/// at different positions in the final configuration list.
class _TransliteratorConfigListBuilder {
  final List<TransliteratorConfig> _head = [];
  final List<TransliteratorConfig> _tail = [];

  /// Inserts a configuration at the head of the list.
  ///
  /// If [forceReplace] is true and a config with the same name exists,
  /// it will be replaced. Otherwise, duplicates are ignored.
  void insertHead(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_head, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _head[existingIndex] = config;
      }
    } else {
      _head.insert(0, config);
    }
  }

  /// Inserts a configuration in the middle position.
  ///
  /// Middle configs are inserted at the beginning of the tail list.
  /// If [forceReplace] is true and a config with the same name exists,
  /// it will be replaced.
  void insertMiddle(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_tail, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _tail[existingIndex] = config;
      }
    } else {
      _tail.insert(0, config); // Insert at beginning of tail (middle position)
    }
  }

  /// Inserts a configuration at the tail of the list.
  ///
  /// If [forceReplace] is true and a config with the same name exists,
  /// it will be replaced. Otherwise, duplicates are ignored.
  void insertTail(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_tail, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _tail[existingIndex] = config;
      }
    } else {
      _tail.add(config);
    }
  }

  int _findConfigIndex(List<TransliteratorConfig> configs, String name) {
    for (var i = 0; i < configs.length; i++) {
      if (configs[i].name == name) {
        return i;
      }
    }
    return -1;
  }

  /// Builds the final list by concatenating head and tail lists.
  List<TransliteratorConfig> build() {
    return [..._head, ..._tail];
  }
}
