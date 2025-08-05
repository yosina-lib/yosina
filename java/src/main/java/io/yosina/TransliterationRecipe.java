package io.yosina;

import io.yosina.transliterators.HiraKataCompositionTransliterator;
import io.yosina.transliterators.HyphensTransliterator;
import io.yosina.transliterators.HyphensTransliterator.Mapping;
import io.yosina.transliterators.IvsSvsBaseTransliterator;
import io.yosina.transliterators.IvsSvsBaseTransliterator.Charset;
import io.yosina.transliterators.IvsSvsBaseTransliterator.Mode;
import io.yosina.transliterators.Jisx0201AndAlikeTransliterator;
import io.yosina.transliterators.ProlongedSoundMarksTransliterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Configuration recipe for building transliterator chains. This class provides a declarative way to
 * configure complex transliterator chains using high-level options that are automatically converted
 * to the appropriate transliterator configurations.
 */
public class TransliterationRecipe {
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
    private String hiraKata = null;
    private boolean replaceJapaneseIterationMarks = false;
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withKanjiOldNew(true);
     * }</pre>
     *
     * @param kanjiOldNew true to enable old-to-new kanji conversion, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withKanjiOldNew(boolean kanjiOldNew) {
        this.kanjiOldNew = kanjiOldNew;
        return this;
    }

    /**
     * Sets the hiragana-katakana conversion mode.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "ひらがな" (with "hira-to-kata")
     * // Output: "ヒラガナ"
     * // Input:  "カタカナ" (with "kata-to-hira")
     * // Output: "かたかな"
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withHiraKata("hira-to-kata");
     * }</pre>
     *
     * @param hiraKata "hira-to-kata" or "kata-to-hira", or null to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withHiraKata(String hiraKata) {
        this.hiraKata = hiraKata;
        return this;
    }

    /**
     * Enables or disables Japanese iteration marks replacement.
     *
     * <p>Example usage:
     *
     * <pre>{@code
     * // Input:  "時々"
     * // Output: "時時"
     * // Input:  "いすゞ"
     * // Output: "いすず"
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceJapaneseIterationMarks(true);
     * }</pre>
     *
     * @param replaceJapaneseIterationMarks true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceJapaneseIterationMarks(
            boolean replaceJapaneseIterationMarks) {
        this.replaceJapaneseIterationMarks = replaceJapaneseIterationMarks;
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceSuspiciousHyphensToProlongedSoundMarks(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceSuspiciousHyphensToProlongedSoundMarks(
            boolean replace) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceCombinedCharacters(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceCombinedCharacters(boolean replace) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceCircledOrSquaredCharacters(
     *         ReplaceCircledOrSquaredCharactersOptions.ENABLED);
     * }</pre>
     *
     * @param options the replacement options
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceCircledOrSquaredCharacters(
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceIdeographicAnnotations(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceIdeographicAnnotations(boolean replace) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceRadicals(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceRadicals(boolean replace) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceSpaces(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceSpaces(boolean replace) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceHyphens(ReplaceHyphensOptions.ENABLED);
     * }</pre>
     *
     * @param options the hyphen replacement options
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceHyphens(ReplaceHyphensOptions options) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withReplaceMathematicalAlphanumerics(true);
     * }</pre>
     *
     * @param replace true to enable replacement, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withReplaceMathematicalAlphanumerics(boolean replace) {
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
     * // Input:  "ヘ゜" (ヘ + ゜)
     * // Output: "ペ" (single character)
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withCombineDecomposedHiraganasAndKatakanas(true);
     * }</pre>
     *
     * @param combine true to enable combination, false to disable
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withCombineDecomposedHiraganasAndKatakanas(boolean combine) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withToFullwidth(ToFullwidthOptions.ENABLED);
     * }</pre>
     *
     * @param options the full-width conversion options
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withToFullwidth(ToFullwidthOptions options) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withToHalfwidth(ToHalfwidthOptions.HANKAKU_KANA);
     * }</pre>
     *
     * @param options the half-width conversion options
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withToHalfwidth(ToHalfwidthOptions options) {
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
     * TransliterationRecipe recipe = new TransliterationRecipe()
     *     .withRemoveIvsSvs(RemoveIvsSvsOptions.ENABLED);
     * }</pre>
     *
     * @param options the IVS/SVS removal options
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withRemoveIvsSvs(RemoveIvsSvsOptions options) {
        this.removeIvsSvs = options;
        return this;
    }

    /**
     * Sets the charset to use for character mappings.
     *
     * @param charset the charset to use
     * @return this recipe instance for method chaining
     */
    public TransliterationRecipe withCharset(Charset charset) {
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
     * Gets the hiragana-katakana conversion mode.
     *
     * @return "hira-to-kata", "kata-to-hira", or null if disabled
     */
    public String getHiraKata() {
        return hiraKata;
    }

    /**
     * Checks if Japanese iteration marks replacement is enabled.
     *
     * @return true if replacement is enabled, false otherwise
     */
    public boolean isReplaceJapaneseIterationMarks() {
        return replaceJapaneseIterationMarks;
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
        ctx = applyHiraKata(ctx);
        ctx = applyReplaceJapaneseIterationMarks(ctx);
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

    private TransliteratorConfigListBuilder applyHiraKata(TransliteratorConfigListBuilder ctx) {
        if (hiraKata != null) {
            io.yosina.transliterators.HiraKataTransliterator.Options.Mode mode =
                    "hira-to-kata".equals(hiraKata)
                            ? io.yosina.transliterators.HiraKataTransliterator.Options.Mode
                                    .HIRA_TO_KATA
                            : io.yosina.transliterators.HiraKataTransliterator.Options.Mode
                                    .KATA_TO_HIRA;
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig(
                                    "hira-kata",
                                    Optional.of(
                                            new io.yosina.transliterators.HiraKataTransliterator
                                                    .Options(mode))),
                            false);
        }
        return ctx;
    }

    private TransliteratorConfigListBuilder applyReplaceJapaneseIterationMarks(
            TransliteratorConfigListBuilder ctx) {
        if (replaceJapaneseIterationMarks) {
            // Insert HiraKataComposition at head to ensure composed forms
            ctx =
                    ctx.insertHead(
                            new Yosina.TransliteratorConfig(
                                    "hira-kata-composition",
                                    Optional.of(
                                            new HiraKataCompositionTransliterator.Options(true))),
                            false);
            // Then insert the japanese-iteration-marks in the middle
            ctx =
                    ctx.insertMiddle(
                            new Yosina.TransliteratorConfig("japanese-iteration-marks"), false);
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
                                            new io.yosina.transliterators.CircledOrSquared.Options()
                                                    .withIncludeEmojis(
                                                            replaceCircledOrSquaredCharacters
                                                                    .isIncludeEmojis()))),
                            false);
        }
        return ctx;
    }
}
