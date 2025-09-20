// Copyright (c) Yosina. All rights reserved.

using System.Runtime.InteropServices;
using Yosina.Transliterators;
using Charset = Yosina.Transliterators.IvsSvsBaseTransliterator.Charset;
using HiraKataMode = Yosina.Transliterators.HiraKataTransliterator.Mode;
using Mapping = Yosina.Transliterators.HyphensTransliterator.Mapping;

namespace Yosina;
/// <summary>
/// Configuration recipe for building transliterator chains. This record provides a declarative way to
/// configure complex transliterator chains using high-level options that are automatically converted
/// to the appropriate transliterator configurations.
/// </summary>
public record class TransliterationRecipe
{
    /// <summary>Options for full-width conversion.</summary>
    [StructLayout(LayoutKind.Auto)]
    public readonly struct ToFullwidthOptions
    {
        public static readonly ToFullwidthOptions Disabled = new(false, false);
        public static readonly ToFullwidthOptions Enabled = new(true, false);
        public static readonly ToFullwidthOptions U005cAsYenSign = new(true, true);

        private readonly bool enabled;
        private readonly bool u005cAsYenSign;

        public bool IsEnabled => this.enabled;

        public bool IsU005cAsYenSign => this.u005cAsYenSign;

        public static implicit operator ToFullwidthOptions(bool enabled)
        {
            return enabled ? Enabled : Disabled;
        }

        public ToFullwidthOptions(bool enabled, bool u005cAsYenSign)
        {
            this.enabled = enabled;
            this.u005cAsYenSign = u005cAsYenSign;
        }
    }

    /// <summary>Options for half-width conversion.</summary>
    [StructLayout(LayoutKind.Auto)]
    public readonly struct ToHalfwidthOptions
    {
        public static readonly ToHalfwidthOptions Disabled = new(false, false);
        public static readonly ToHalfwidthOptions Enabled = new(true, false);
        public static readonly ToHalfwidthOptions HankakuKana = new(true, true);

        private readonly bool enabled;
        private readonly bool hankakuKana;

        public bool IsEnabled => this.enabled;

        public bool IsHankakuKana => this.hankakuKana;

        public static implicit operator ToHalfwidthOptions(bool enabled)
        {
            return enabled ? Enabled : Disabled;
        }

        public ToHalfwidthOptions(bool enabled, bool hankakuKana)
        {
            this.enabled = enabled;
            this.hankakuKana = hankakuKana;
        }
    }

    /// <summary>Options for IVS/SVS removal.</summary>
    [StructLayout(LayoutKind.Auto)]
    public readonly struct RemoveIvsSvsOptions
    {
        public static readonly RemoveIvsSvsOptions Disabled = new(false, false);
        public static readonly RemoveIvsSvsOptions Enabled = new(true, false);
        public static readonly RemoveIvsSvsOptions DropAllSelectors = new(true, true);

        private readonly bool enabled;
        private readonly bool dropAllSelectors;

        public bool IsEnabled => this.enabled;

        public bool IsDropAllSelectors => this.dropAllSelectors;

        public static implicit operator RemoveIvsSvsOptions(bool enabled)
        {
            return enabled ? Enabled : Disabled;
        }

        private RemoveIvsSvsOptions(bool enabled, bool dropAllSelectors)
        {
            this.enabled = enabled;
            this.dropAllSelectors = dropAllSelectors;
        }
    }

    /// <summary>Options for hyphens replacement.</summary>
    public readonly struct ReplaceHyphensOptions
    {
        public static readonly ReplaceHyphensOptions Disabled = new(false, null);
        public static readonly ReplaceHyphensOptions Enabled = new(true, new List<Mapping> { Mapping.JISX0208_90_WINDOWS, Mapping.JISX0201 });

        private readonly bool enabled;
        private readonly IList<Mapping>? precedence;

        public bool IsEnabled => this.enabled;

        public IList<Mapping>? Precedence => this.precedence;

        public static ReplaceHyphensOptions WithPrecedence(IList<Mapping> precedence)
        {
            return new ReplaceHyphensOptions(true, precedence);
        }

        public static implicit operator ReplaceHyphensOptions(bool enabled)
        {
            return enabled ? Enabled : Disabled;
        }

        private ReplaceHyphensOptions(bool enabled, IList<Mapping>? precedence)
        {
            this.enabled = enabled;
            this.precedence = precedence;
        }
    }

    /// <summary>Options for circled or squared characters replacement.</summary>
    [StructLayout(LayoutKind.Auto)]
    public readonly struct ReplaceCircledOrSquaredCharactersOptions
    {
        public static readonly ReplaceCircledOrSquaredCharactersOptions Disabled = new(false, false);
        public static readonly ReplaceCircledOrSquaredCharactersOptions Enabled = new(true, true);
        public static readonly ReplaceCircledOrSquaredCharactersOptions ExcludeEmojis = new(true, false);

        private readonly bool enabled;
        private readonly bool includeEmojis;

        public bool IsEnabled => this.enabled;

        public bool IncludeEmojis => this.includeEmojis;

        public static implicit operator ReplaceCircledOrSquaredCharactersOptions(bool enabled)
        {
            return enabled ? Enabled : Disabled;
        }

        private ReplaceCircledOrSquaredCharactersOptions(bool enabled, bool includeEmojis)
        {
            this.enabled = enabled;
            this.includeEmojis = includeEmojis;
        }
    }

    // Recipe properties with default values

    /// <summary>
    /// Gets a value indicating whether replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai) with their modern equivalents (新字体; shin-ji-tai).
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "舊字體の變換"
    /// // Output: "旧字体の変換"
    /// var recipe = new TransliterationRecipe { KanjiOldNew = true };
    /// </code>
    /// </example>
    public bool KanjiOldNew { get; init; }

    /// <summary>
    /// Gets the hiragana-katakana conversion mode.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "ひらがな" (with "hira-to-kata")
    /// // Output: "ヒラガナ"
    /// // Input:  "カタカナ" (with "kata-to-hira")
    /// // Output: "かたかな"
    /// var recipe = new TransliterationRecipe { HiraKata = HiraKataTransliterator.Mode.KataToHira };
    /// </code>
    /// </example>
    public HiraKataMode? HiraKata { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace Japanese iteration marks with the characters they represent.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "時々"
    /// // Output: "時時"
    /// // Input:  "いすゞ"
    /// // Output: "いすず"
    /// var recipe = new TransliterationRecipe { ReplaceJapaneseIterationMarks = true };
    /// </code>
    /// </example>
    public bool ReplaceJapaneseIterationMarks { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace "suspicious" hyphens with prolonged sound marks, and vice versa.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "スーパ-" (with hyphen-minus)
    /// // Output: "スーパー" (becomes prolonged sound mark)
    /// var recipe = new TransliterationRecipe { ReplaceSuspiciousHyphensToProlongedSoundMarks = true };
    /// </code>
    /// </example>
    public bool ReplaceSuspiciousHyphensToProlongedSoundMarks { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace combined characters with their corresponding characters.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "㍻" (single character for Heisei era)
    /// // Output: "平成"
    /// // Input:  "㈱"
    /// // Output: "(株)"
    /// var recipe = new TransliterationRecipe { ReplaceCombinedCharacters = true };
    /// </code>
    /// </example>
    public bool ReplaceCombinedCharacters { get; init; }

    /// <summary>
    /// Gets replace circled or squared characters with their corresponding templates.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "①②③"
    /// // Output: "(1)(2)(3)"
    /// // Input:  "㊙㊗"
    /// // Output: "(秘)(祝)"
    /// var recipe = new TransliterationRecipe { ReplaceCircledOrSquaredCharacters = ReplaceCircledOrSquaredCharactersOptions.Enabled };
    /// </code>
    /// </example>
    public ReplaceCircledOrSquaredCharactersOptions ReplaceCircledOrSquaredCharacters { get; init; } = ReplaceCircledOrSquaredCharactersOptions.Disabled;

    /// <summary>
    /// Gets a value indicating whether replace ideographic annotations used in the traditional method of Chinese-to-Japanese translation devised in ancient Japan.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "㆖㆘" (ideographic annotations)
    /// // Output: "上下"
    /// var recipe = new TransliterationRecipe { ReplaceIdeographicAnnotations = true };
    /// </code>
    /// </example>
    public bool ReplaceIdeographicAnnotations { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace codepoints for the Kang Xi radicals whose glyphs resemble those of CJK ideographs with the CJK ideograph counterparts.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "⾔⾨⾷" (Kangxi radicals)
    /// // Output: "言門食" (CJK ideographs)
    /// var recipe = new TransliterationRecipe { ReplaceRadicals = true };
    /// </code>
    /// </example>
    public bool ReplaceRadicals { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace various space characters with plain whitespaces or empty strings.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "A　B" (ideographic space U+3000)
    /// // Output: "A B" (half-width space)
    /// // Input:  "A B" (non-breaking space U+00A0)
    /// // Output: "A B" (regular space)
    /// var recipe = new TransliterationRecipe { ReplaceSpaces = true };
    /// </code>
    /// </example>
    public bool ReplaceSpaces { get; init; }

    /// <summary>
    /// Gets replace various dash or hyphen symbols with those common in Japanese writing.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "2019—2020" (em dash)
    /// // Output: "2019-2020" (hyphen-minus)
    /// // Input:  "A–B" (en dash)
    /// // Output: "A-B"
    /// var recipe = new TransliterationRecipe { ReplaceHyphens = ReplaceHyphensOptions.Enabled };
    /// </code>
    /// </example>
    public ReplaceHyphensOptions ReplaceHyphens { get; init; } = ReplaceHyphensOptions.Disabled;

    /// <summary>
    /// Gets a value indicating whether replace mathematical alphanumerics with their plain ASCII equivalents.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "𝐀𝐁𝐂" (mathematical bold)
    /// // Output: "ABC"
    /// // Input:  "𝟏𝟐𝟑" (mathematical bold digits)
    /// // Output: "123"
    /// var recipe = new TransliterationRecipe { ReplaceMathematicalAlphanumerics = true };
    /// </code>
    /// </example>
    public bool ReplaceMathematicalAlphanumerics { get; init; }

    /// <summary>
    /// Gets a value indicating whether replace roman numeral characters with their ASCII letter equivalents.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "Ⅻ"
    /// // Output: "XII"
    /// // Input:  "ⅻ"
    /// // Output: "xii"
    /// var recipe = new TransliterationRecipe { ReplaceRomanNumerals = true };
    /// </code>
    /// </example>
    public bool ReplaceRomanNumerals { get; init; }

    /// <summary>
    /// Gets a value indicating whether combine decomposed hiraganas and katakanas into single counterparts.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "が" (か + ゙)
    /// // Output: "が" (single character)
    /// // Input:  "ヘ゜" (ヘ + ゜)
    /// // Output: "ペ" (single character)
    /// var recipe = new TransliterationRecipe { CombineDecomposedHiraganasAndKatakanas = true };
    /// </code>
    /// </example>
    public bool CombineDecomposedHiraganasAndKatakanas { get; init; }

    /// <summary>
    /// Gets replace half-width characters to fullwidth equivalents.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "ABC123"
    /// // Output: "ＡＢＣ１２３"
    /// // Input:  "ｶﾀｶﾅ"
    /// // Output: "カタカナ"
    /// var recipe = new TransliterationRecipe { ToFullwidth = ToFullwidthOptions.Enabled };
    /// </code>
    /// </example>
    public ToFullwidthOptions ToFullwidth { get; init; } = ToFullwidthOptions.Disabled;

    /// <summary>
    /// Gets replace full-width characters with their half-width equivalents.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "ＡＢＣ１２３"
    /// // Output: "ABC123"
    /// // Input:  "カタカナ" (with hankaku-kana)
    /// // Output: "ｶﾀｶﾅ"
    /// var recipe = new TransliterationRecipe { ToHalfwidth = ToHalfwidthOptions.HankakuKana };
    /// </code>
    /// </example>
    public ToHalfwidthOptions ToHalfwidth { get; init; } = ToHalfwidthOptions.Disabled;

    /// <summary>
    /// Gets replace CJK ideographs followed by IVSes and SVSes with those without selectors based on Adobe-Japan1 character mappings.
    /// </summary>
    /// <example>
    /// <code>
    /// // Input:  "葛󠄀" (葛 + IVS U+E0100)
    /// // Output: "葛" (without selector)
    /// // Input:  "辻󠄀" (辻 + IVS)
    /// // Output: "辻"
    /// var recipe = new TransliterationRecipe { RemoveIvsSvs = RemoveIvsSvsOptions.Enabled };
    /// </code>
    /// </example>
    public RemoveIvsSvsOptions RemoveIvsSvs { get; init; } = RemoveIvsSvsOptions.Disabled;

    public Charset Charset { get; init; } = Charset.UniJis2004;

    /// <summary>
    /// Build transliterator configurations from this recipe.
    /// </summary>
    /// <returns>A list of TransliteratorConfig objects that can be passed to Yosina.MakeTransliterator.</returns>
    /// <exception cref="ArgumentException">If the recipe contains mutually exclusive options.</exception>
    public List<TransliteratorConfig> BuildTransliteratorConfigs()
    {
        // Check for mutually exclusive options
        var errors = new List<string>();
        if (this.ToFullwidth.IsEnabled && this.ToHalfwidth.IsEnabled)
        {
            errors.Add("toFullwidth and toHalfwidth are mutually exclusive");
        }

        if (errors.Any())
        {
            throw new ArgumentException(string.Join("; ", errors));
        }

        var ctx = new TransliteratorConfigListBuilder();

        // Apply transformations in the specified order
        ctx = this.ApplyKanjiOldNew(ctx);
        ctx = this.ApplyReplaceSuspiciousHyphensToProlongedSoundMarks(ctx);
        ctx = this.ApplyReplaceCircledOrSquaredCharacters(ctx);
        ctx = this.ApplyReplaceCombinedCharacters(ctx);
        ctx = this.ApplyReplaceIdeographicAnnotations(ctx);
        ctx = this.ApplyReplaceRadicals(ctx);
        ctx = this.ApplyReplaceSpaces(ctx);
        ctx = this.ApplyReplaceHyphens(ctx);
        ctx = this.ApplyReplaceMathematicalAlphanumerics(ctx);
        ctx = this.ApplyReplaceRomanNumerals(ctx);
        ctx = this.ApplyCombineDecomposedHiraganasAndKatakanas(ctx);
        ctx = this.ApplyToFullwidth(ctx);
        ctx = this.ApplyHiraKata(ctx);
        ctx = this.ApplyReplaceJapaneseIterationMarks(ctx);
        ctx = this.ApplyToHalfwidth(ctx);
        ctx = this.ApplyRemoveIvsSvs(ctx);

        return ctx.Build();
    }

    private TransliteratorConfigListBuilder RemoveIvsSvsHelper(TransliteratorConfigListBuilder ctx, bool dropAllSelectors)
    {
        // First insert IVS-or-SVS mode at head
        ctx = ctx.InsertHead(
            new TransliteratorConfig("ivs-svs-base", new IvsSvsBaseTransliterator.Options { Mode = IvsSvsBaseTransliterator.Mode.IvsSvs, Charset = this.Charset }),
            true);
        ctx = ctx.InsertTail(
            new TransliteratorConfig("ivs-svs-base", new IvsSvsBaseTransliterator.Options { Mode = IvsSvsBaseTransliterator.Mode.Base, DropSelectorsAltogether = dropAllSelectors, Charset = this.Charset }),
            true);

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyKanjiOldNew(TransliteratorConfigListBuilder ctx)
    {
        if (this.KanjiOldNew)
        {
            ctx = this.RemoveIvsSvsHelper(ctx, false);
            ctx = ctx.InsertMiddle(new TransliteratorConfig("kanji-old-new"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceSuspiciousHyphensToProlongedSoundMarks(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceSuspiciousHyphensToProlongedSoundMarks)
        {
            ctx = ctx.InsertMiddle(
                new TransliteratorConfig("prolonged-sound-marks", new ProlongedSoundMarksTransliterator.Options { ReplaceProlongedMarksFollowingAlnums = true }),
                false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceIdeographicAnnotations(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceIdeographicAnnotations)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("ideographic-annotations"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceRadicals(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceRadicals)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("radicals"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceSpaces(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceSpaces)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("spaces"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceHyphens(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceHyphens.IsEnabled)
        {
            var options = this.ReplaceHyphens.Precedence != null
                ? new HyphensTransliterator.Options { Precedence = this.ReplaceHyphens.Precedence }
                : null;
            ctx = ctx.InsertMiddle(new TransliteratorConfig("hyphens", options), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceMathematicalAlphanumerics(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceMathematicalAlphanumerics)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("mathematical-alphanumerics"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceRomanNumerals(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceRomanNumerals)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("roman-numerals"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyCombineDecomposedHiraganasAndKatakanas(TransliteratorConfigListBuilder ctx)
    {
        if (this.CombineDecomposedHiraganasAndKatakanas)
        {
            ctx = ctx.InsertHead(
                new TransliteratorConfig(
                    "hira-kata-composition",
                    new HiraKataCompositionTransliterator.Options { ComposeNonCombiningMarks = true }),
                false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyToFullwidth(TransliteratorConfigListBuilder ctx)
    {
        if (this.ToFullwidth.IsEnabled)
        {
            var options = new Jisx0201AndAlikeTransliterator.Options { FullwidthToHalfwidth = false, U005cAsYenSign = this.ToFullwidth.IsU005cAsYenSign };
            ctx = ctx.InsertTail(new TransliteratorConfig("jisx0201-and-alike", options), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyToHalfwidth(TransliteratorConfigListBuilder ctx)
    {
        if (this.ToHalfwidth.IsEnabled)
        {
            var options = new Jisx0201AndAlikeTransliterator.Options { FullwidthToHalfwidth = true, ConvertGL = true, ConvertGR = this.ToHalfwidth.IsHankakuKana };
            ctx = ctx.InsertTail(new TransliteratorConfig("jisx0201-and-alike", options), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyRemoveIvsSvs(TransliteratorConfigListBuilder ctx)
    {
        if (this.RemoveIvsSvs.IsEnabled)
        {
            ctx = this.RemoveIvsSvsHelper(ctx, this.RemoveIvsSvs.IsDropAllSelectors);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceCombinedCharacters(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceCombinedCharacters)
        {
            ctx = ctx.InsertMiddle(new TransliteratorConfig("combined"), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceCircledOrSquaredCharacters(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceCircledOrSquaredCharacters.IsEnabled)
        {
            var options = new CircledOrSquaredTransliterator.Options { IncludeEmojis = this.ReplaceCircledOrSquaredCharacters.IncludeEmojis };
            ctx = ctx.InsertMiddle(new TransliteratorConfig("circled-or-squared", options), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyHiraKata(TransliteratorConfigListBuilder ctx)
    {
        if (this.HiraKata is HiraKataMode hiraKata)
        {
            var options = new HiraKataTransliterator.Options { Mode = hiraKata };
            ctx = ctx.InsertMiddle(new TransliteratorConfig("hira-kata", options), false);
        }

        return ctx;
    }

    private TransliteratorConfigListBuilder ApplyReplaceJapaneseIterationMarks(TransliteratorConfigListBuilder ctx)
    {
        if (this.ReplaceJapaneseIterationMarks)
        {
            // Insert HiraKataComposition at head to ensure composed forms
            ctx = ctx.InsertHead(
                new TransliteratorConfig("hira-kata-composition"),
                false);

            // Then insert the japanese-iteration-marks in the middle
            ctx = ctx.InsertMiddle(new TransliteratorConfig("japanese-iteration-marks"), false);
        }

        return ctx;
    }
}
