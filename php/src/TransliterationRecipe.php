<?php

declare(strict_types=1);

namespace Yosina;

readonly class TransliterationRecipe
{
    public function __construct(
        /**
         * Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai) with their modern equivalents (新字体; shin-ji-tai).
         * @example
         *   Input:  "舊字體の變換"
         *   Output: "旧字体の変換"
         */
        public bool $kanjiOldNew = false,
        /**
         * Convert between hiragana and katakana scripts.
         * @example
         *   Input:  "ひらがな" (with "hira-to-kata")
         *   Output: "ヒラガナ"
         *   Input:  "カタカナ" (with "kata-to-hira")
         *   Output: "かたかな"
         */
        public ?string $hiraKata = null,
        /**
         * Replace Japanese iteration marks with the characters they represent.
         * @example
         *   Input:  "時々"
         *   Output: "時時"
         *   Input:  "いすゞ"
         *   Output: "いすず"
         */
        public bool $replaceJapaneseIterationMarks = false,
        /**
         * Replace "suspicious" hyphens with prolonged sound marks, and vice versa.
         * @example
         *   Input:  "スーパ-" (with hyphen-minus)
         *   Output: "スーパー" (becomes prolonged sound mark)
         */
        public bool $replaceSuspiciousHyphensToProlongedSoundMarks = false,
        /**
         * Replace circled or squared characters with their corresponding templates.
         * @example
         *   Input:  "①②③"
         *   Output: "(1)(2)(3)"
         *   Input:  "㊙㊗"
         *   Output: "(秘)(祝)"
         */
        public bool|string $replaceCircledOrSquaredCharacters = false,
        /**
         * Replace combined characters with their corresponding characters.
         * @example
         *   Input:  "㍻" (single character for Heisei era)
         *   Output: "平成"
         *   Input:  "㈱"
         *   Output: "(株)"
         */
        public bool $replaceCombinedCharacters = false,
        /**
         * Replace ideographic annotations used in the traditional method of Chinese-to-Japanese translation devised in ancient Japan.
         * @example
         *   Input:  "㆖㆘" (ideographic annotations)
         *   Output: "上下"
         */
        public bool $replaceIdeographicAnnotations = false,
        /**
         * Replace codepoints for the Kang Xi radicals whose glyphs resemble those of CJK ideographs with the CJK ideograph counterparts.
         * @example
         *   Input:  "⾔⾨⾷" (Kangxi radicals)
         *   Output: "言門食" (CJK ideographs)
         */
        public bool $replaceRadicals = false,
        /**
         * Replace various space characters with plain whitespaces or empty strings.
         * @example
         *   Input:  "A　B" (ideographic space U+3000)
         *   Output: "A B" (half-width space)
         *   Input:  "A B" (non-breaking space U+00A0)
         *   Output: "A B" (regular space)
         */
        public bool $replaceSpaces = false,
        /**
         * Replace various dash or hyphen symbols with those common in Japanese writing.
         * @var bool|array<string>
         * @example
         *   Input:  "2019—2020" (em dash)
         *   Output: "2019-2020" (hyphen-minus)
         *   Input:  "A–B" (en dash)
         *   Output: "A-B"
         */
        public bool|array $replaceHyphens = false,
        /**
         * Replace mathematical alphanumerics with their plain ASCII equivalents.
         * @example
         *   Input:  "𝐀𝐁𝐂" (mathematical bold)
         *   Output: "ABC"
         *   Input:  "𝟏𝟐𝟑" (mathematical bold digits)
         *   Output: "123"
         */
        public bool $replaceMathematicalAlphanumerics = false,
        /**
         * Replace roman numeral characters with their ASCII letter equivalents.
         * @example
         *   Input:  "Ⅲ" (Roman numeral III)
         *   Output: "III"
         *   Input:  "ⅻ" (Roman numeral xii)
         *   Output: "xii"
         */
        public bool $replaceRomanNumerals = false,
        /**
         * Combine decomposed hiraganas and katakanas into single counterparts.
         * @example
         *   Input:  "が" (か + ゙)
         *   Output: "が" (single character)
         *   Input:  "ヘ゜" (ヘ + ゜)
         *   Output: "ペ" (single character)
         */
        public bool $combineDecomposedHiraganasAndKatakanas = false,
        /**
         * Replace archaic kana (hentaigana) with their modern equivalents.
         * @example
         *   Input:  archaic kana character
         *   Output: modern kana equivalent
         */
        public bool $archaicHirakatas = false,
        /**
         * Replace small hiragana/katakana with their ordinary-sized equivalents.
         * @example
         *   Input:  "ぁ" (small a)
         *   Output: "あ" (normal a)
         */
        public bool $smallHirakatas = false,
        /**
         * Convert historical hiragana/katakana characters to their modern equivalents.
         * - false: not applied
         * - 'simple': simple replacement (hiraganas=simple, katakanas=simple, voicedKatakanas=skip)
         * - 'decompose': decompose into component sounds (hiraganas=decompose, katakanas=decompose, voicedKatakanas=decompose)
         * @example
         *   Input:  "ゐ" (historical wi)
         *   Output: "い" (modern i, simple mode)
         *   Output: "うぃ" (decomposed, decompose mode)
         * @var false|'simple'|'decompose'
         */
        public false|string $historicalHirakatas = false,
        /**
         * Replace half-width characters to fullwidth equivalents. Specify "u005c-as-yen-sign" to treat backslash (U+005C) as yen sign in JIS X 0201.
         * @example
         *   Input:  "ABC123"
         *   Output: "ＡＢＣ１２３"
         *   Input:  "ｶﾀｶﾅ"
         *   Output: "カタカナ"
         */
        public bool|string $toFullwidth = false,
        /**
         * Replace full-width characters with their half-width equivalents. Specify "hankaku-kana" to handle half-width katakanas too.
         * @example
         *   Input:  "ＡＢＣ１２３"
         *   Output: "ABC123"
         *   Input:  "カタカナ" (with hankaku-kana)
         *   Output: "ｶﾀｶﾅ"
         */
        public bool|string $toHalfwidth = false,
        /**
         * Replace CJK ideographs followed by IVSes and SVSes with those without selectors based on Adobe-Japan1 character mappings.
         * @example
         *   Input:  "葛󠄀" (葛 + IVS U+E0100)
         *   Output: "葛" (without selector)
         *   Input:  "辻󠄀" (辻 + IVS)
         *   Output: "辻"
         */
        public bool|string $removeIvsSvs = false,
        /** Charset assumed during IVS/SVS transliteration. Default is "unijis_2004". */
        public string $charset = 'unijis_2004',
    ) {}

    /**
     * Build transliterator configurations from this recipe.
     *
     * @return array<int, array{0: string, 1: array<string, mixed>}>
     * @throws \InvalidArgumentException if the recipe contains mutually exclusive options
     */
    public function buildTransliteratorConfigs(): array
    {
        // Check for mutually exclusive options
        $errors = [];
        if (($this->toFullwidth !== false) && ($this->toHalfwidth !== false)) {
            $errors[] = 'toFullwidth and toHalfwidth are mutually exclusive';
        }

        if (!empty($errors)) {
            throw new \InvalidArgumentException(implode('; ', $errors));
        }

        $ctx = new TransliteratorConfigListBuilder();

        // Apply transformations in the specified order (following Java implementation)
        $ctx = $this->applyKanjiOldNew($ctx);
        $ctx = $this->applyReplaceSuspiciousHyphensToProlongedSoundMarks($ctx);
        $ctx = $this->applyReplaceCircledOrSquaredCharacters($ctx);
        $ctx = $this->applyReplaceCombinedCharacters($ctx);
        $ctx = $this->applyReplaceIdeographicAnnotations($ctx);
        $ctx = $this->applyReplaceRadicals($ctx);
        $ctx = $this->applyReplaceSpaces($ctx);
        $ctx = $this->applyReplaceHyphens($ctx);
        $ctx = $this->applyReplaceMathematicalAlphanumerics($ctx);
        $ctx = $this->applyReplaceRomanNumerals($ctx);
        $ctx = $this->applyArchaicHirakatas($ctx);
        $ctx = $this->applySmallHirakatas($ctx);
        $ctx = $this->applyHistoricalHirakatas($ctx);
        $ctx = $this->applyCombineDecomposedHiraganasAndKatakanas($ctx);
        $ctx = $this->applyToFullwidth($ctx);
        $ctx = $this->applyHiraKata($ctx);
        $ctx = $this->applyReplaceJapaneseIterationMarks($ctx);
        $ctx = $this->applyToHalfwidth($ctx);
        $ctx = $this->applyRemoveIvsSvs($ctx);

        return $ctx->build();
    }

    private function removeIvsSvsHelper(TransliteratorConfigListBuilder $ctx, bool $dropAllSelectors): TransliteratorConfigListBuilder
    {
        // First insert IVS-or-SVS mode at head
        $ctx = $ctx->insertHead(['ivs-svs-base', [
            'mode' => 'ivs-or-svs',
            'charset' => $this->charset,
        ]], true);

        $ctx = $ctx->insertTail(['ivs-svs-base', [
            'mode' => 'base',
            'drop_selectors_altogether' => $dropAllSelectors,
            'charset' => $this->charset,
        ]], true);

        return $ctx;
    }

    private function applyKanjiOldNew(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->kanjiOldNew) {
            $ctx = $this->removeIvsSvsHelper($ctx, false);
            $ctx = $ctx->insertMiddle(['kanji-old-new', []], false);
        }
        return $ctx;
    }

    private function applyHiraKata(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->hiraKata !== null) {
            $ctx = $ctx->insertTail(['hira-kata', ['mode' => $this->hiraKata]], false);
        }
        return $ctx;
    }

    private function applyReplaceJapaneseIterationMarks(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceJapaneseIterationMarks) {
            // Insert HiraKataComposition at head to ensure composed forms
            $ctx = $ctx->insertHead(['hira-kata-composition', [
                'compose_non_combining_marks' => true,
            ]], false);
            // Then insert the japanese-iteration-marks in the middle
            $ctx = $ctx->insertMiddle(['japanese-iteration-marks', []], false);
        }
        return $ctx;
    }

    private function applyReplaceSuspiciousHyphensToProlongedSoundMarks(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceSuspiciousHyphensToProlongedSoundMarks) {
            $ctx = $ctx->insertMiddle(['prolonged-sound-marks', [
                'replace_prolonged_marks_following_alnums' => true,
            ]], false);
        }
        return $ctx;
    }

    private function applyReplaceCircledOrSquaredCharacters(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceCircledOrSquaredCharacters !== false) {
            $includeEmojis = $this->replaceCircledOrSquaredCharacters !== 'exclude-emojis';
            $ctx = $ctx->insertMiddle(['circled-or-squared', [
                'includeEmojis' => $includeEmojis,
            ]], false);
        }
        return $ctx;
    }

    private function applyReplaceCombinedCharacters(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceCombinedCharacters) {
            $ctx = $ctx->insertMiddle(['combined', []], false);
        }
        return $ctx;
    }

    private function applyReplaceIdeographicAnnotations(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceIdeographicAnnotations) {
            $ctx = $ctx->insertMiddle(['ideographic-annotations', []], false);
        }
        return $ctx;
    }

    private function applyReplaceRadicals(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceRadicals) {
            $ctx = $ctx->insertMiddle(['radicals', []], false);
        }
        return $ctx;
    }

    private function applyReplaceSpaces(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceSpaces) {
            $ctx = $ctx->insertMiddle(['spaces', []], false);
        }
        return $ctx;
    }

    private function applyReplaceHyphens(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceHyphens !== false) {
            $precedence = is_array($this->replaceHyphens)
                ? $this->replaceHyphens
                : ['jisx0208_90_windows', 'jisx0201'];
            $ctx = $ctx->insertMiddle(['hyphens', ['precedence' => $precedence]], false);
        }
        return $ctx;
    }

    private function applyReplaceMathematicalAlphanumerics(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceMathematicalAlphanumerics) {
            $ctx = $ctx->insertMiddle(['mathematical-alphanumerics', []], false);
        }
        return $ctx;
    }

    private function applyReplaceRomanNumerals(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->replaceRomanNumerals) {
            $ctx = $ctx->insertMiddle(['roman-numerals', []], false);
        }
        return $ctx;
    }

    private function applyCombineDecomposedHiraganasAndKatakanas(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->combineDecomposedHiraganasAndKatakanas) {
            $ctx = $ctx->insertHead(['hira-kata-composition', [
                'decompose' => true,
            ]], false);
        }
        return $ctx;
    }

    private function applyArchaicHirakatas(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->archaicHirakatas) {
            $ctx = $ctx->insertMiddle(['archaic-hirakatas', []], false);
        }
        return $ctx;
    }

    private function applySmallHirakatas(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->smallHirakatas) {
            $ctx = $ctx->insertMiddle(['small-hirakatas', []], false);
        }
        return $ctx;
    }

    private function applyHistoricalHirakatas(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->historicalHirakatas !== false) {
            $options = match ($this->historicalHirakatas) {
                'simple' => ['hiraganas' => 'simple', 'katakanas' => 'simple', 'voicedKatakanas' => 'skip'],
                'decompose' => ['hiraganas' => 'decompose', 'katakanas' => 'decompose', 'voicedKatakanas' => 'decompose'],
            };
            $ctx = $ctx->insertMiddle(['historical-hirakatas', $options], false);
        }
        return $ctx;
    }

    private function applyToFullwidth(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->toFullwidth !== false) {
            $u005cAsYenSign = $this->toFullwidth === 'u005c-as-yen-sign';
            $ctx = $ctx->insertTail(['jisx0201-and-alike', [
                'fullwidthToHalfwidth' => false,
                'u005c_as_yen_sign' => $u005cAsYenSign,
                'combineVoicedSoundMarks' => true,
            ]], false);
        }
        return $ctx;
    }

    private function applyToHalfwidth(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->toHalfwidth !== false) {
            $convertGR = $this->toHalfwidth === 'hankaku-kana';
            $ctx = $ctx->insertTail(['jisx0201-and-alike', [
                'fullwidthToHalfwidth' => true,
                'convertGL' => true,
                'convertGR' => $convertGR,
            ]], false);
        }
        return $ctx;
    }

    private function applyRemoveIvsSvs(TransliteratorConfigListBuilder $ctx): TransliteratorConfigListBuilder
    {
        if ($this->removeIvsSvs !== false) {
            $dropAllSelectors = $this->removeIvsSvs === 'drop-all-selectors';
            $ctx = $this->removeIvsSvsHelper($ctx, $dropAllSelectors);
        }
        return $ctx;
    }
}
