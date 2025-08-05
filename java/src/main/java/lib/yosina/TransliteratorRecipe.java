package lib.yosina;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import lib.yosina.transliterators.HiraKataCompositionTransliterator;
import lib.yosina.transliterators.HyphensTransliterator;
import lib.yosina.transliterators.HyphensTransliterator.Mapping;
import lib.yosina.transliterators.IvsSvsBaseTransliterator;
import lib.yosina.transliterators.IvsSvsBaseTransliterator.Charset;
import lib.yosina.transliterators.IvsSvsBaseTransliterator.Mode;
import lib.yosina.transliterators.Jisx0201AndAlikeTransliterator;
import lib.yosina.transliterators.ProlongedSoundMarksTransliterator;

/**
 * Configuration recipe for building transliterator chains. This class provides a declarative way to
 * configure complex transliterator chains using high-level options that are automatically converted
 * to the appropriate transliterator configurations.
 */
public class TransliteratorRecipe {
    /** Options for full-width conversion. */
    public static class ToFullwidthOptions {
        /** Disabled option - no full-width conversion will be performed. */
        public static final ToFullwidthOptions DISABLED = new ToFullwidthOptions(false, false);

        /** Enabled option - converts characters to full-width. */
        public static final ToFullwidthOptions ENABLED = new ToFullwidthOptions(true, false);

        /** Enabled option that also converts U+005C (backslash) to U+00A5 (yen sign). */
        public static final ToFullwidthOptions U005C_AS_YEN_SIGN =
                new ToFullwidthOptions(true, true);

        private final boolean enabled;
        private final boolean u005cAsYenSign;

        private ToFullwidthOptions(boolean enabled, boolean u005cAsYenSign) {
            this.enabled = enabled;
            this.u005cAsYenSign = u005cAsYenSign;
        }

        /**
         * Checks if full-width conversion is enabled.
         *
         * @return true if full-width conversion is enabled, false otherwise
         */
        public boolean isEnabled() {
            return enabled;
        }

        /**
         * Checks if U+005C (backslash) should be converted to U+00A5 (yen sign).
         *
         * @return true if backslash should be converted to yen sign, false otherwise
         */
        public boolean isU005cAsYenSign() {
            return u005cAsYenSign;
        }
    }

    /** Options for half-width conversion. */
    public static class ToHalfwidthOptions {
        /** Disabled option - no half-width conversion will be performed. */
        public static final ToHalfwidthOptions DISABLED = new ToHalfwidthOptions(false, false);

        /** Enabled option - converts characters to half-width. */
        public static final ToHalfwidthOptions ENABLED = new ToHalfwidthOptions(true, false);

        /** Enabled option that also converts kana characters to half-width (hankaku kana). */
        public static final ToHalfwidthOptions HANKAKU_KANA = new ToHalfwidthOptions(true, true);

        private final boolean enabled;
        private final boolean hankakuKana;

        private ToHalfwidthOptions(boolean enabled, boolean hankakuKana) {
            this.enabled = enabled;
            this.hankakuKana = hankakuKana;
        }

        /**
         * Checks if half-width conversion is enabled.
         *
         * @return true if half-width conversion is enabled, false otherwise
         */
        public boolean isEnabled() {
            return enabled;
        }

        /**
         * Checks if kana characters should be converted to half-width (hankaku kana).
         *
         * @return true if kana should be converted to half-width, false otherwise
         */
        public boolean isHankakuKana() {
            return hankakuKana;
        }
    }

    /** Options for IVS/SVS removal. */
    public static class RemoveIvsSvsOptions {
        /** Disabled option - IVS/SVS sequences will not be removed. */
        public static final RemoveIvsSvsOptions DISABLED = new RemoveIvsSvsOptions(false, false);

        /** Enabled option - removes IVS/SVS sequences while preserving base characters. */
        public static final RemoveIvsSvsOptions ENABLED = new RemoveIvsSvsOptions(true, false);

        /** Enabled option that drops all variation selectors completely. */
        public static final RemoveIvsSvsOptions DROP_ALL_SELECTORS =
                new RemoveIvsSvsOptions(true, true);

        private final boolean enabled;
        private final boolean dropAllSelectors;

        private RemoveIvsSvsOptions(boolean enabled, boolean dropAllSelectors) {
            this.enabled = enabled;
            this.dropAllSelectors = dropAllSelectors;
        }

        /**
         * Checks if IVS/SVS removal is enabled.
         *
         * @return true if IVS/SVS removal is enabled, false otherwise
         */
        public boolean isEnabled() {
            return enabled;
        }

        /**
         * Checks if all variation selectors should be dropped completely.
         *
         * @return true if all selectors should be dropped, false otherwise
         */
        public boolean isDropAllSelectors() {
            return dropAllSelectors;
        }
    }

    /** Options for circled or squared characters replacement. */
    public static class ReplaceCircledOrSquaredCharactersOptions {
        /** Disabled option - circled or squared characters will not be replaced. */
        public static final ReplaceCircledOrSquaredCharactersOptions DISABLED =
                new ReplaceCircledOrSquaredCharactersOptions(false, false);

        /** Enabled option - replaces circled or squared characters including emojis. */
        public static final ReplaceCircledOrSquaredCharactersOptions ENABLED =
                new ReplaceCircledOrSquaredCharactersOptions(true, true);

        /** Enabled option that excludes emoji characters from replacement. */
        public static final ReplaceCircledOrSquaredCharactersOptions EXCLUDE_EMOJIS =
                new ReplaceCircledOrSquaredCharactersOptions(true, false);

        private final boolean enabled;
        private final boolean includeEmojis;

        private ReplaceCircledOrSquaredCharactersOptions(boolean enabled, boolean includeEmojis) {
            this.enabled = enabled;
            this.includeEmojis = includeEmojis;
        }

        /**
         * Checks if circled or squared character replacement is enabled.
         *
         * @return true if replacement is enabled, false otherwise
         */
        public boolean isEnabled() {
            return enabled;
        }

        /**
         * Checks if emoji characters should be included in replacement.
         *
         * @return true if emojis should be included, false otherwise
         */
        public boolean isIncludeEmojis() {
            return includeEmojis;
        }
    }

    /** Options for hyphens replacement. */
    public static class ReplaceHyphensOptions {
        /** Disabled option - hyphens will not be replaced. */
        public static final ReplaceHyphensOptions DISABLED = new ReplaceHyphensOptions(false, null);

        /** Enabled option with default precedence (JISX0208_90_WINDOWS, JISX0201). */
        public static final ReplaceHyphensOptions ENABLED =
                new ReplaceHyphensOptions(
                        true, List.of(Mapping.JISX0208_90_WINDOWS, Mapping.JISX0201));

        private final boolean enabled;
        private final List<Mapping> precedence;

        private ReplaceHyphensOptions(boolean enabled, List<Mapping> precedence) {
            this.enabled = enabled;
            this.precedence = precedence;
        }

        /**
         * Creates an enabled ReplaceHyphensOptions with custom precedence.
         *
         * @param precedence the list of mappings in order of precedence
         * @return a new ReplaceHyphensOptions instance with the specified precedence
         */
        public static ReplaceHyphensOptions withPrecedence(List<Mapping> precedence) {
            return new ReplaceHyphensOptions(true, precedence);
        }

        /**
         * Checks if hyphen replacement is enabled.
         *
         * @return true if hyphen replacement is enabled, false otherwise
         */
        public boolean isEnabled() {
            return enabled;
        }

        /**
         * Gets the precedence order for hyphen mappings.
         *
         * @return the list of mappings in order of precedence, or null if disabled
         */
        public List<Mapping> getPrecedence() {
            return precedence;
        }
    }

    // Recipe fields with default values
    private boolean kanjiOldNew = false;
    private boolean replaceSuspiciousHyphensToProlongedSoundMarks = false;
    private boolean replaceCombinedCharacters = false;
    private ReplaceCircledOrSquaredCharactersOptions replaceCircledOrSquaredCharacters =
            ReplaceCircledOrSquaredCharactersOptions.DISABLED;
    private boolean replaceIdeographicAnnotations = false;
    private boolean replaceRadicals = false;
    private boolean replaceSpaces = false;
    private ReplaceHyphensOptions replaceHyphens = ReplaceHyphensOptions.DISABLED;
    private boolean replaceMathematicalAlphanumerics = false;
    private boolean combineDecomposedHiraganasAndKatakanas = false;
    private ToFullwidthOptions toFullwidth = ToFullwidthOptions.DISABLED;
    private ToHalfwidthOptions toHalfwidth = ToHalfwidthOptions.DISABLED;
    private RemoveIvsSvsOptions removeIvsSvs = RemoveIvsSvsOptions.DISABLED;
    private Charset charset = Charset.UNIJIS_2004;

    // Builder methods
    /**
     * Enables or disables old-to-new kanji character conversion.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "舊字體の變換"
     * // Output: "旧字体の変換"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withKanjiOldNew(true);
     * }</pre>
     *
     * @param kanjiOldNew true to enable old-to-new kanji conversion, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withKanjiOldNew(boolean kanjiOldNew) {
        this.kanjiOldNew = kanjiOldNew;
        return this;
    }

    /**
     * Enables or disables replacement of suspicious hyphens with prolonged sound marks.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "スーパ-" (with hyphen-minus)
     * // Output: "スーパー" (becomes prolonged sound mark)
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceSuspiciousHyphensToProlongedSoundMarks(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceSuspiciousHyphensToProlongedSoundMarks(boolean replace) {
        this.replaceSuspiciousHyphensToProlongedSoundMarks = replace;
        return this;
    }

    /**
     * Enables or disables replacement of combined characters.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "㍻" (single character for Heisei era)
     * // Output: "平成"
     * // Input:  "㈱"
     * // Output: "(株)"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceCombinedCharacters(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceCombinedCharacters(boolean replace) {
        this.replaceCombinedCharacters = replace;
        return this;
    }

    /**
     * Sets the circled or squared character replacement options.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "①②③"
     * // Output: "(1)(2)(3)"
     * // Input:  "㊙㊗"
     * // Output: "(秘)(祝)"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceCircledOrSquaredCharacters(
     *         ReplaceCircledOrSquaredCharactersOptions.ENABLED);
     * }</pre>
     *
     * @param options the replacement options
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceCircledOrSquaredCharacters(
            ReplaceCircledOrSquaredCharactersOptions options) {
        this.replaceCircledOrSquaredCharacters = options;
        return this;
    }

    /**
     * Enables or disables replacement of ideographic annotations.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "㆖㆘" (ideographic annotations)
     * // Output: "上下"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceIdeographicAnnotations(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceIdeographicAnnotations(boolean replace) {
        this.replaceIdeographicAnnotations = replace;
        return this;
    }

    /**
     * Enables or disables replacement of CJK radicals.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "⾔⾨⾷" (Kangxi radicals)
     * // Output: "言門食" (CJK ideographs)
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceRadicals(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceRadicals(boolean replace) {
        this.replaceRadicals = replace;
        return this;
    }

    /**
     * Enables or disables replacement of various space characters.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "A　B" (ideographic space U+3000)
     * // Output: "A B" (half-width space)
     * // Input:  "A B" (non-breaking space U+00A0)
     * // Output: "A B" (regular space)
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceSpaces(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceSpaces(boolean replace) {
        this.replaceSpaces = replace;
        return this;
    }

    /**
     * Sets the hyphen replacement options.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "2019—2020" (em dash)
     * // Output: "2019-2020" (hyphen-minus)
     * // Input:  "A–B" (en dash)
     * // Output: "A-B"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceHyphens(ReplaceHyphensOptions.ENABLED);
     * }</pre>
     *
     * @param options the hyphen replacement options
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceHyphens(ReplaceHyphensOptions options) {
        this.replaceHyphens = options;
        return this;
    }

    /**
     * Enables or disables replacement of mathematical alphanumeric symbols.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "𝐀𝐁𝐂" (mathematical bold)
     * // Output: "ABC"
     * // Input:  "𝟏𝟐𝟑" (mathematical bold digits)
     * // Output: "123"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withReplaceMathematicalAlphanumerics(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withReplaceMathematicalAlphanumerics(boolean replace) {
        this.replaceMathematicalAlphanumerics = replace;
        return this;
    }

    /**
     * Enables or disables combination of decomposed hiragana and katakana characters.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "が" (か + ゙)
     * // Output: "が" (single character)
     * // Input:  "ペ" (ヘ + ゚)
     * // Output: "ペ" (single character)
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withCombineDecomposedHiraganasAndKatakanas(true);
     * }</pre>
     *
     * @param combine true to enable combination, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withCombineDecomposedHiraganasAndKatakanas(boolean combine) {
        this.combineDecomposedHiraganasAndKatakanas = combine;
        return this;
    }

    /**
     * Sets the full-width conversion options.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "ABC123"
     * // Output: "ＡＢＣ１２３"
     * // Input:  "ｶﾀｶﾅ"
     * // Output: "カタカナ"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withToFullwidth(ToFullwidthOptions.ENABLED);
     * }</pre>
     *
     * @param options the full-width conversion options
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withToFullwidth(ToFullwidthOptions options) {
        this.toFullwidth = options;
        return this;
    }

    /**
     * Sets the half-width conversion options.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "ＡＢＣ１２３"
     * // Output: "ABC123"
     * // Input:  "カタカナ" (with hankaku-kana)
     * // Output: "ｶﾀｶﾅ"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withToHalfwidth(ToHalfwidthOptions.HANKAKU_KANA);
     * }</pre>
     *
     * @param options the half-width conversion options
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withToHalfwidth(ToHalfwidthOptions options) {
        this.toHalfwidth = options;
        return this;
    }

    /**
     * Sets the IVS/SVS removal options.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "葛󠄀" (葛 + IVS U+E0100)
     * // Output: "葛" (without selector)
     * // Input:  "辻󠄀" (辻 + IVS)
     * // Output: "辻"
     * TransliteratorRecipe recipe = new TransliteratorRecipe()
     *     .withRemoveIvsSvs(RemoveIvsSvsOptions.ENABLED);
     * }</pre>
     *
     * @param options the IVS/SVS removal options
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withRemoveIvsSvs(RemoveIvsSvsOptions options) {
        this.removeIvsSvs = options;
        return this;
    }

    /**
     * Sets the charset to use for character mappings.
     *
     * @param charset the charset to use
     * @return this recipe instance for method chaining
     */
    public TransliteratorRecipe withCharset(Charset charset) {
        this.charset = charset;
        return this;
    }

    // Getters
    /**
     * Checks if old-to-new kanji conversion is enabled.
     *
     * @return true if old-to-new kanji conversion is enabled, false otherwise
     */
    public boolean isKanjiOldNew() {
        return kanjiOldNew;
    }

    /**
     * Checks if replacement of suspicious hyphens to prolonged sound marks is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceSuspiciousHyphensToProlongedSoundMarks() {
        return replaceSuspiciousHyphensToProlongedSoundMarks;
    }

    /**
     * Checks if replacement of combined characters is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceCombinedCharacters() {
        return replaceCombinedCharacters;
    }

    /**
     * Gets the current circled or squared character replacement options.
     *
     * @return the replacement options
     */
    public ReplaceCircledOrSquaredCharactersOptions getReplaceCircledOrSquaredCharacters() {
        return replaceCircledOrSquaredCharacters;
    }

    /**
     * Checks if replacement of ideographic annotations is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceIdeographicAnnotations() {
        return replaceIdeographicAnnotations;
    }

    /**
     * Checks if replacement of CJK radicals is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceRadicals() {
        return replaceRadicals;
    }

    /**
     * Checks if replacement of various space characters is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceSpaces() {
        return replaceSpaces;
    }

    /**
     * Gets the current hyphen replacement options.
     *
     * @return the hyphen replacement options
     */
    public ReplaceHyphensOptions getReplaceHyphens() {
        return replaceHyphens;
    }

    /**
     * Checks if replacement of mathematical alphanumeric symbols is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceMathematicalAlphanumerics() {
        return replaceMathematicalAlphanumerics;
    }

    /**
     * Checks if combination of decomposed hiragana and katakana characters is enabled.
     *
     * @return true if combination is enabled, false otherwise
     */
    public boolean isCombineDecomposedHiraganasAndKatakanas() {
        return combineDecomposedHiraganasAndKatakanas;
    }

    /**
     * Gets the current full-width conversion options.
     *
     * @return the full-width conversion options
     */
    public ToFullwidthOptions getToFullwidth() {
        return toFullwidth;
    }

    /**
     * Gets the current half-width conversion options.
     *
     * @return the half-width conversion options
     */
    public ToHalfwidthOptions getToHalfwidth() {
        return toHalfwidth;
    }

    /**
     * Gets the current IVS/SVS removal options.
     *
     * @return the IVS/SVS removal options
     */
    public RemoveIvsSvsOptions getRemoveIvsSvs() {
        return removeIvsSvs;
    }

    /**
     * Gets the current charset setting.
     *
     * @return the charset to use for character mappings
     */
    public Charset getCharset() {
        return charset;
    }

    /**
     * Build transliterator configurations from this recipe.
     *
     * @return A list of TransliteratorConfig objects that can be passed to
     *     Yosina.makeTransliterator
     * @throws IllegalArgumentException if the recipe contains mutually exclusive options
     */
    public List<Yosina.TransliteratorConfig> buildTransliteratorConfigs() {
        // Check for mutually exclusive options
        List<String> errors = new ArrayList<>();
        if (toFullwidth.isEnabled() && toHalfwidth.isEnabled()) {
            errors.add("toFullwidth and toHalfwidth are mutually exclusive");
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("; ", errors));
        }

        TransliteratorConfigListBuilder ctx = new TransliteratorConfigListBuilder();

        // Apply transformations in the specified order
        ctx = applyKanjiOldNew(ctx);
        ctx = applyReplaceSuspiciousHyphensToProlongedSoundMarks(ctx);
        ctx = applyReplaceCircledOrSquaredCharacters(ctx);
        ctx = applyReplaceCombinedCharacters(ctx);
        ctx = applyReplaceIdeographicAnnotations(ctx);
        ctx = applyReplaceRadicals(ctx);
        ctx = applyReplaceSpaces(ctx);
        ctx = applyReplaceHyphens(ctx);
        ctx = applyReplaceMathematicalAlphanumerics(ctx);
        ctx = applyCombineDecomposedHiraganasAndKatakanas(ctx);
        ctx = applyToFullwidth(ctx);
        ctx = applyToHalfwidth(ctx);
        ctx = applyRemoveIvsSvs(ctx);

        return ctx.build();
    }

    private TransliteratorConfigListBuilder removeIvsSvsHelper(
            TransliteratorConfigListBuilder ctx, boolean dropAllSelectors) {
        // First insert IVS-or-SVS mode at head
        ctx =
                ctx.insertHead(
                        new Yosina.TransliteratorConfig(
                                "ivs-svs-base",
                                Optional.of(
                                        new IvsSvsBaseTransliterator.Options()
                                                .withMode(Mode.IVS_OR_SVS)
                                                .withCharset(charset))),
                        true);
        ctx =
                ctx.insertTail(
                        new Yosina.TransliteratorConfig(
                                "ivs-svs-base",
                                Optional.of(
                                        new IvsSvsBaseTransliterator.Options()
                                                .withMode(Mode.BASE)
                                                .withDropSelectorAltogether(dropAllSelectors)
                                                .withCharset(charset))),
                        true);

        return ctx;
    }

    private TransliteratorConfigListBuilder applyKanjiOldNew(TransliteratorConfigListBuilder ctx) {
        if (kanjiOldNew) {
            ctx = removeIvsSvsHelper(ctx, false);
            ctx = ctx.insertMiddle(new Yosina.TransliteratorConfig("kanji-old-new"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceSuspiciousHyphensToProlongedSoundMarks(
            TransliteratorConfigListBuilder ctx) {
        if (replaceSuspiciousHyphensToProlongedSoundMarks) {
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig(
                                    "prolonged-sound-marks",
                                    Optional.of(
                                            new ProlongedSoundMarksTransliterator.Options()
                                                    .withReplaceProlongedMarksFollowingAlnums(
                                                            true))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceIdeographicAnnotations(
            TransliteratorConfigListBuilder ctx) {
        if (replaceIdeographicAnnotations) {
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig("ideographic-annotations"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceRadicals(
            TransliteratorConfigListBuilder ctx) {
        if (replaceRadicals) {
            ctx = ctx.insertMiddle(new Yosina.TransliteratorConfig("radicals"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceSpaces(
            TransliteratorConfigListBuilder ctx) {
        if (replaceSpaces) {
            ctx = ctx.insertMiddle(new Yosina.TransliteratorConfig("spaces"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceHyphens(
            TransliteratorConfigListBuilder ctx) {
        if (replaceHyphens.isEnabled()) {
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig(
                                    "hyphens",
                                    Optional.of(
                                            new HyphensTransliterator.Options(
                                                    replaceHyphens.getPrecedence()))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceMathematicalAlphanumerics(
            TransliteratorConfigListBuilder ctx) {
        if (replaceMathematicalAlphanumerics) {
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig("mathematical-alphanumerics"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyCombineDecomposedHiraganasAndKatakanas(
            TransliteratorConfigListBuilder ctx) {
        if (combineDecomposedHiraganasAndKatakanas) {
            ctx =
                    ctx.insertHead(
                            new Yosina.TransliteratorConfig(
                                    "hira-kata-composition",
                                    Optional.of(
                                            new HiraKataCompositionTransliterator.Options(true))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyToFullwidth(TransliteratorConfigListBuilder ctx) {
        if (toFullwidth.isEnabled()) {
            ctx =
                    ctx.insertTail(
                            new Yosina.TransliteratorConfig(
                                    "jisx0201-and-alike",
                                    Optional.of(
                                            new Jisx0201AndAlikeTransliterator.Options()
                                                    .withFullwidthToHalfwidth(false)
                                                    .withU005cAsYenSign(
                                                            toFullwidth.isU005cAsYenSign()))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyToHalfwidth(TransliteratorConfigListBuilder ctx) {
        if (toHalfwidth.isEnabled()) {
            ctx =
                    ctx.insertTail(
                            new Yosina.TransliteratorConfig(
                                    "jisx0201-and-alike",
                                    Optional.of(
                                            new Jisx0201AndAlikeTransliterator.Options()
                                                    .withFullwidthToHalfwidth(true)
                                                    .withConvertGL(true)
                                                    .withConvertGR(toHalfwidth.isHankakuKana()))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyRemoveIvsSvs(TransliteratorConfigListBuilder ctx) {
        if (removeIvsSvs.isEnabled()) {
            ctx = removeIvsSvsHelper(ctx, removeIvsSvs.isDropAllSelectors());
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceCombinedCharacters(
            TransliteratorConfigListBuilder ctx) {
        if (replaceCombinedCharacters) {
            ctx = ctx.insertMiddle(new Yosina.TransliteratorConfig("combined"), false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceCircledOrSquaredCharacters(
            TransliteratorConfigListBuilder ctx) {
        if (replaceCircledOrSquaredCharacters.isEnabled()) {
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig(
                                    "circled-or-squared",
                                    Optional.of(
                                            new lib.yosina.transliterators.CircledOrSquared
                                                            .Options()
                                                    .withIncludeEmojis(
                                                            replaceCircledOrSquaredCharacters
                                                                    .isIncludeEmojis()))),
                            false);
        }
        return ctx;
    }
}
