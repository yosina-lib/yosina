import * as intrinsics from "./intrinsics.js";
import type { Mapping } from "./transliterators/hyphens.js";
import type { TransliteratorConfig } from "./transliterators/index.js";
import type { Charset } from "./transliterators/ivs-svs-base.js";

export type TransliterationRecipe = {
  /**
   * Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai) with their modern equivalents (新字体; shin-ji-tai).
   * @example
   * ```js
   * // Input:  "舊字體の變換"
   * // Output: "旧字体の変換"
   * ```
   */
  kanjiOldNew?: boolean;
  /**
   * Convert between hiragana and katakana scripts.
   * @example
   * ```js
   * // Input:  "ひらがな" (with "hira-to-kata")
   * // Output: "ヒラガナ"
   * // Input:  "カタカナ" (with "kata-to-hira")
   * // Output: "かたかな"
   * ```
   */
  hiraKata?: "hira-to-kata" | "kata-to-hira";
  /**
   * Replace Japanese iteration marks with the characters they represent.
   * @example
   * ```js
   * // Input:  "時々"
   * // Output: "時時"
   * // Input:  "いすゞ"
   * // Output: "いすず"
   * ```
   */
  replaceJapaneseIterationMarks?: boolean;
  /**
   * Replace "suspicious" hyphens with prolonged sound marks, and vice versa.
   * @example
   * ```js
   * // Input:  "スーパ-" (with hyphen-minus)
   * // Output: "スーパー" (becomes prolonged sound mark)
   * ```
   */
  replaceSuspiciousHyphensToProlongedSoundMarks?: boolean;
  /**
   * Replace circled or squared characters with their corresponding templates.
   * @example
   * ```js
   * // Input:  "①②③"
   * // Output: "(1)(2)(3)"
   * // Input:  "㊙㊗"
   * // Output: "(秘)(祝)"
   * ```
   */
  replaceCircledOrSquaredCharacters?: boolean | "exclude-emojis";
  /**
   * Replace combined characters with their corresponding characters.
   * @example
   * ```js
   * // Input:  "㍻" (single character for Heisei era)
   * // Output: "平成"
   * // Input:  "㈱"
   * // Output: "(株)"
   * ```
   */
  replaceCombinedCharacters?: boolean;
  /**
   * Replace ideographic annotations used in the traditional method of Chinese-to-Japanese translation deviced in the ancient Japan.
   * @example
   * ```js
   * // Input:  "㆖㆘" (ideographic annotations)
   * // Output: "上下"
   * ```
   */
  replaceIdeographicAnnotations?: boolean;
  /**
   * Replace codepoints for the Kang Xi radicals whose glyphs resemble those of CJK ideographs with the CJK ideograph counterparts.
   * @example
   * ```js
   * // Input:  "⾔⾨⾷" (Kangxi radicals)
   * // Output: "言門食" (CJK ideographs)
   * ```
   */
  replaceRadicals?: boolean;
  /**
   * Replace various space characters with plain whitespaces or empty strings.
   * @example
   * ```js
   * // Input:  "A　B" (ideographic space U+3000)
   * // Output: "A B" (half-width space)
   * // Input:  "A B" (non-breaking space U+00A0)
   * // Output: "A B" (regular space)
   * ```
   */
  replaceSpaces?: boolean;
  /**
   * Replace various dash or hyphen symbols with those common in Japanese writing.
   * @example
   * ```js
   * // Input:  "2019—2020" (em dash)
   * // Output: "2019-2020" (hyphen-minus)
   * // Input:  "A–B" (en dash)
   * // Output: "A-B"
   * ```
   */
  replaceHyphens?: boolean | Mapping[];
  /**
   * Replace mathematical alphanumerics with their plain ASCII equivalents.
   * @example
   * ```js
   * // Input:  "𝐀𝐁𝐂" (mathematical bold)
   * // Output: "ABC"
   * // Input:  "𝟏𝟐𝟑" (mathematical bold digits)
   * // Output: "123"
   * ```
   */
  replaceMathematicalAlphanumerics?: boolean;
  /**
   * Replace Roman numeral characters with their ASCII equivalents.
   * @example
   * ```js
   * // Input:  "Ⅰ Ⅱ Ⅲ" (Roman numeral characters)
   * // Output: "I II III"
   * // Input:  "ⅰ ⅱ ⅲ" (lowercase Roman numerals)
   * // Output: "i ii iii"
   * ```
   */
  replaceRomanNumerals?: boolean;
  /**
   * Combine decomposed hiraganas and katakanas into single counterparts.
   * @example
   * ```js
   * // Input:  "が" (か + ゙)
   * // Output: "が" (single character)
   * // Input:  "ヘ゜" (ヘ + ゜)
   * // Output: "ペ" (single character)
   * ```
   */
  combineDecomposedHiraganasAndKatakanas?: boolean;
  /**
   * Replace half-width characters in that they are marked as half-width or ambiguous in the East Asian Width table to the fullwidth equivalents.
   * Specify `"u005c-as-yen-sign"` instead of a boolean to treat the backslash character (U+005C) as the yen sign in JIS X 0201.
   * @example
   * ```js
   * // Input:  "ABC123"
   * // Output: "ＡＢＣ１２３"
   * // Input:  "ｶﾀｶﾅ"
   * // Output: "カタカナ"
   * ```
   */
  toFullwidth?: boolean | "u005c-as-yen-sign";
  /**
   * Replace full-width characters with their half-width equivalents.
   * Specify `"hankaku-kana"` instead of a boolean to handle half-width katakanas too.
   * @example
   * ```js
   * // Input:  "ＡＢＣ１２３"
   * // Output: "ABC123"
   * // Input:  "カタカナ" (with hankaku-kana)
   * // Output: "ｶﾀｶﾅ"
   * ```
   */
  toHalfwidth?: boolean | "hankaku-kana";
  /**
   * Replace CJK ideographs followed by IVSes and SVSes with those without selectors based on Adobe-Japan1 character mappings.
   * Specify `"drop-all-selectors"` to get rid of all selectors from the result.
   * @example
   * ```js
   * // Input:  "葛󠄀" (葛 + IVS U+E0100)
   * // Output: "葛" (without selector)
   * // Input:  "辻󠄀" (辻 + IVS)
   * // Output: "辻"
   * ```
   */
  removeIVSSVS?: boolean | "drop-all-selectors";
  /**
   * Charset assumed during IVS/SVS transliteration. The default is `"unijis_2004"`.
   */
  charset?: Charset;
};

type TransliterationRecipeKeys = keyof Omit<Required<TransliterationRecipe>, "charset">;

const applicationOrder: TransliterationRecipeKeys[] = [
  "kanjiOldNew",
  "replaceSuspiciousHyphensToProlongedSoundMarks",
  "replaceCircledOrSquaredCharacters",
  "replaceCombinedCharacters",
  "replaceIdeographicAnnotations",
  "replaceRadicals",
  "replaceSpaces",
  "replaceHyphens",
  "replaceMathematicalAlphanumerics",
  "replaceRomanNumerals",
  "combineDecomposedHiraganasAndKatakanas",
  "toFullwidth",
  "hiraKata",
  "replaceJapaneseIterationMarks",
  "toHalfwidth",
  "removeIVSSVS",
];

type TransliteratorConfigListBuilder = {
  head: TransliteratorConfig[];
  tail: TransliteratorConfig[];
};

const insertHead = (
  ctx: TransliteratorConfigListBuilder,
  config: TransliteratorConfig,
  forceReplace?: boolean,
): TransliteratorConfigListBuilder => {
  const i = ctx.head.findIndex((c) => c[0] === config[0]);
  if (i >= 0) {
    return forceReplace
      ? {
          ...ctx,
          head: [...ctx.head.slice(0, i), config, ...ctx.head.slice(i + 1)],
        }
      : ctx;
  }
  return {
    ...ctx,
    head: [config, ...ctx.head],
  };
};

const insertMiddle = (
  ctx: TransliteratorConfigListBuilder,
  config: TransliteratorConfig,
  forceReplace?: boolean,
): TransliteratorConfigListBuilder => {
  const i = ctx.tail.findIndex((c) => c[0] === config[0]);
  if (i >= 0) {
    return forceReplace
      ? {
          ...ctx,
          tail: [...ctx.tail.slice(0, i), config, ...ctx.tail.slice(i + 1)],
        }
      : ctx;
  }
  return {
    ...ctx,
    tail: [config, ...ctx.tail],
  };
};

const insertTail = (
  ctx: TransliteratorConfigListBuilder,
  config: TransliteratorConfig,
  forceReplace?: boolean,
): TransliteratorConfigListBuilder => {
  const i = ctx.tail.findIndex((c) => c[0] === config[0]);
  if (i >= 0) {
    return forceReplace
      ? {
          ...ctx,
          tail: [...ctx.tail.slice(0, i), ...ctx.tail.slice(i + 1), config],
        }
      : ctx;
  }
  return {
    ...ctx,
    tail: [...ctx.tail, config],
  };
};

const removeIVSSVS = (ctx: TransliteratorConfigListBuilder, dropSelectorsAltogether: boolean, charset?: Charset) =>
  insertTail(
    insertHead(ctx, ["ivs-svs-base", { mode: "ivs-or-svs" }], true),
    ["ivs-svs-base", { mode: "base", dropSelectorsAltogether, charset: charset }],
    true,
  );

const transliteratorAppliers: {
  [Key in TransliterationRecipeKeys]: (
    ctx: TransliteratorConfigListBuilder,
    recipe: TransliterationRecipe,
  ) => TransliteratorConfigListBuilder;
} = {
  kanjiOldNew: (ctx, recipe) =>
    recipe.kanjiOldNew ? insertMiddle(removeIVSSVS(ctx, false, recipe.charset), ["kanji-old-new", {}]) : ctx,
  hiraKata: (ctx, recipe) => (recipe.hiraKata ? insertTail(ctx, ["hira-kata", { mode: recipe.hiraKata }]) : ctx),
  replaceJapaneseIterationMarks: (ctx, recipe) => {
    if (!recipe.replaceJapaneseIterationMarks) return ctx;
    // Insert HiraKataComposition at head to ensure composed forms
    ctx = insertHead(ctx, ["hira-kata-composition", { composeNonCombiningMarks: true }]);
    // Then insert the japanese-iteration-marks in the middle
    return insertMiddle(ctx, ["japanese-iteration-marks", {}]);
  },
  replaceSuspiciousHyphensToProlongedSoundMarks: (ctx, recipe) =>
    recipe.replaceSuspiciousHyphensToProlongedSoundMarks
      ? insertMiddle(ctx, ["prolonged-sound-marks", { replaceProlongedMarksFollowingAlnums: true }])
      : ctx,
  replaceCircledOrSquaredCharacters: (ctx, recipe) =>
    recipe.replaceCircledOrSquaredCharacters
      ? insertMiddle(ctx, [
          "circled-or-squared",
          {
            includeEmojis: recipe.replaceCircledOrSquaredCharacters !== "exclude-emojis",
          },
        ])
      : ctx,
  replaceCombinedCharacters: (ctx, recipe) =>
    recipe.replaceCombinedCharacters ? insertMiddle(ctx, ["combined", {}]) : ctx,
  replaceIdeographicAnnotations: (ctx, recipe) =>
    recipe.replaceIdeographicAnnotations ? insertMiddle(ctx, ["ideographic-annotations", {}]) : ctx,
  replaceRadicals: (ctx, recipe) => (recipe.replaceRadicals ? insertMiddle(ctx, ["radicals", {}]) : ctx),
  replaceSpaces: (ctx, recipe) => (recipe.replaceSpaces ? insertMiddle(ctx, ["spaces", {}]) : ctx),
  replaceHyphens: (ctx, recipe) =>
    recipe.replaceHyphens
      ? insertMiddle(ctx, [
          "hyphens",
          {
            precedence:
              typeof recipe.replaceHyphens === "boolean" ? ["jisx0208_90_windows", "jisx0201"] : recipe.replaceHyphens,
          },
        ])
      : ctx,
  replaceMathematicalAlphanumerics: (ctx, recipe) =>
    recipe.replaceMathematicalAlphanumerics ? insertMiddle(ctx, ["mathematical-alphanumerics", {}]) : ctx,
  replaceRomanNumerals: (ctx, recipe) =>
    recipe.replaceRomanNumerals ? insertMiddle(ctx, ["roman-numerals", {}]) : ctx,
  combineDecomposedHiraganasAndKatakanas: (ctx, recipe) =>
    recipe.combineDecomposedHiraganasAndKatakanas
      ? insertHead(ctx, ["hira-kata-composition", { composeNonCombiningMarks: true }])
      : ctx,
  toHalfwidth: (ctx, recipe) => {
    if (recipe.toHalfwidth && recipe.toFullwidth) {
      throw ["toHalfwidth and toFullwidth are mutually exclusive"];
    }
    return recipe.toHalfwidth
      ? insertTail(ctx, [
          "jisx0201-and-alike",
          { fullwidthToHalfwidth: true, convertGL: true, convertGR: recipe.toHalfwidth === "hankaku-kana" },
        ])
      : ctx;
  },
  toFullwidth: (ctx, recipe) => {
    if (recipe.toFullwidth && recipe.toHalfwidth) {
      throw ["toFullwidth and toHalfwidth are mutually exclusive"];
    }
    return recipe.toFullwidth
      ? insertTail(ctx, [
          "jisx0201-and-alike",
          { fullwidthToHalfwidth: false, u005cAsYenSign: recipe.toFullwidth === "u005c-as-yen-sign" },
        ])
      : ctx;
  },
  removeIVSSVS: (ctx, recipe) =>
    recipe.removeIVSSVS ? removeIVSSVS(ctx, recipe.removeIVSSVS === "drop-all-selectors", recipe.charset) : ctx,
};

/**
 * Builds an array of {@link TransliteratorConfig} from a recipe object.
 *
 * @param recipe An object that conforms to {@link TransliterationRecipe}.
 * @returns An array of {@link TransliteratorConfig} that can be passed to {@link intrinsics.makeChainedTransliterator}.
 */
export const buildTransliteratorConfigsFromRecipe = (recipe: TransliterationRecipe): TransliteratorConfig[] => {
  let ctx: TransliteratorConfigListBuilder = { head: [], tail: [] };
  const errors: [string, string[]][] = [];
  for (const k of applicationOrder) {
    try {
      ctx = transliteratorAppliers[k](ctx, recipe);
    } catch (e) {
      if (!Array.isArray(e)) {
        throw e;
      }
      errors.push([k, e as string[]]);
    }
  }
  if (errors.length) {
    throw new Error(errors.map(([tl, errors]) => `${tl}: ${errors.join(", ")}`).join("; "));
  }
  return [...ctx.head, ...ctx.tail];
};
