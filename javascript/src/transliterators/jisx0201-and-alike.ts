/**
 * This module deals with conversion between the following character sets:
 *
 * - Half-width group:
 *   - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E.
 *   - Half-width katakanas: U+FF61 - U+FF9F.
 * - Full-width group:
 *   - Full-width alphabets, numerics, and symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5.
 *   - Wave dash: U+301C.
 *   - Hiraganas: U+3041 - U+3094.
 *   - Katakanas: U+30A1 - U+30F7 and U+30FA.
 *   - Hiragana/katakana voicing marks: U+309B, U+309C, and U+30FC.
 *   - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
 *
 *  For the details of the mapping rules, please refer to *JIS X 0201 and Alike transliterator specification*.
 *
 * @module
 */
import type { Char } from "../types.js";

import { hiraganaKatakanaSmallTable, hiraganaKatakanaTable } from "./hira-kata-table.js";

const jisx0201GLTable: [string, string][] = [
  ["\u3000", "\u0020"],
  ["\uff01", "\u0021"],
  ["\uff02", "\u0022"],
  ["\uff03", "\u0023"],
  ["\uff04", "\u0024"],
  ["\uff05", "\u0025"],
  ["\uff06", "\u0026"],
  ["\uff07", "\u0027"],
  ["\uff08", "\u0028"],
  ["\uff09", "\u0029"],
  ["\uff0a", "\u002a"],
  ["\uff0b", "\u002b"],
  ["\uff0c", "\u002c"],
  ["\uff0d", "\u002d"],
  ["\uff0e", "\u002e"],
  ["\uff0f", "\u002f"],
  ["\uff10", "\u0030"],
  ["\uff11", "\u0031"],
  ["\uff12", "\u0032"],
  ["\uff13", "\u0033"],
  ["\uff14", "\u0034"],
  ["\uff15", "\u0035"],
  ["\uff16", "\u0036"],
  ["\uff17", "\u0037"],
  ["\uff18", "\u0038"],
  ["\uff19", "\u0039"],
  ["\uff1a", "\u003a"],
  ["\uff1b", "\u003b"],
  ["\uff1c", "\u003c"],
  ["\uff1d", "\u003d"],
  ["\uff1e", "\u003e"],
  ["\uff1f", "\u003f"],
  ["\uff20", "\u0040"],
  ["\uff21", "\u0041"],
  ["\uff22", "\u0042"],
  ["\uff23", "\u0043"],
  ["\uff24", "\u0044"],
  ["\uff25", "\u0045"],
  ["\uff26", "\u0046"],
  ["\uff27", "\u0047"],
  ["\uff28", "\u0048"],
  ["\uff29", "\u0049"],
  ["\uff2a", "\u004a"],
  ["\uff2b", "\u004b"],
  ["\uff2c", "\u004c"],
  ["\uff2d", "\u004d"],
  ["\uff2e", "\u004e"],
  ["\uff2f", "\u004f"],
  ["\uff30", "\u0050"],
  ["\uff31", "\u0051"],
  ["\uff32", "\u0052"],
  ["\uff33", "\u0053"],
  ["\uff34", "\u0054"],
  ["\uff35", "\u0055"],
  ["\uff36", "\u0056"],
  ["\uff37", "\u0057"],
  ["\uff38", "\u0058"],
  ["\uff39", "\u0059"],
  ["\uff3a", "\u005a"],
  ["\uff3b", "\u005b"],
  ["\uff3d", "\u005d"],
  ["\uff3e", "\u005e"],
  ["\uff3f", "\u005f"],
  ["\uff40", "\u0060"],
  ["\uff41", "\u0061"],
  ["\uff42", "\u0062"],
  ["\uff43", "\u0063"],
  ["\uff44", "\u0064"],
  ["\uff45", "\u0065"],
  ["\uff46", "\u0066"],
  ["\uff47", "\u0067"],
  ["\uff48", "\u0068"],
  ["\uff49", "\u0069"],
  ["\uff4a", "\u006a"],
  ["\uff4b", "\u006b"],
  ["\uff4c", "\u006c"],
  ["\uff4d", "\u006d"],
  ["\uff4e", "\u006e"],
  ["\uff4f", "\u006f"],
  ["\uff50", "\u0070"],
  ["\uff51", "\u0071"],
  ["\uff52", "\u0072"],
  ["\uff53", "\u0073"],
  ["\uff54", "\u0074"],
  ["\uff55", "\u0075"],
  ["\uff56", "\u0076"],
  ["\uff57", "\u0077"],
  ["\uff58", "\u0078"],
  ["\uff59", "\u0079"],
  ["\uff5a", "\u007a"],
  ["\uff5b", "\u007b"],
  ["\uff5c", "\u007c"],
  ["\uff5d", "\u007d"],
];

const jisx0201GLOverrides: Record<
  | "u005cAsYenSign"
  | "u005cAsBackslash"
  | "u007eAsFullwidthTilde"
  | "u007eAsWaveDash"
  | "u007eAsOverline"
  | "u007eAsFullwidthMacron"
  | "u00a5AsYenSign",
  [string, string][]
> = {
  u005cAsYenSign: [["\uffe5", "\u005c"]],
  u005cAsBackslash: [["\uff3c", "\u005c"]],
  u007eAsFullwidthTilde: [["\uff5e", "\u007e"]],
  u007eAsWaveDash: [["\u301c", "\u007e"]],
  u007eAsOverline: [["\u203e", "\u007e"]],
  u007eAsFullwidthMacron: [["\uffe3", "\u007e"]],
  u00a5AsYenSign: [["\uffe5", "\u00a5"]],
};

const lettersGLFwdMappingsBase = Object.fromEntries(jisx0201GLTable);

const jisx0201GRTable: [string, string][] = [
  ["\u3002", "\uff61"],
  ["\u300c", "\uff62"],
  ["\u300d", "\uff63"],
  ["\u3001", "\uff64"],
  ["\u30fb", "\uff65"],
  ["\u30fc", "\uff70"],
  ["\u309b", "\uff9e"],
  ["\u309c", "\uff9f"],
  ...hiraganaKatakanaTable.flatMap(([_, katakana, halfwidth]) =>
    halfwidth === undefined ? [] : [[katakana[0], halfwidth] satisfies [string, string]],
  ),
  ...hiraganaKatakanaSmallTable.flatMap(([_, katakana, halfwidth]) =>
    halfwidth === undefined ? [] : [[katakana, halfwidth] satisfies [string, string]],
  ),
];

const specialPunctuationsTable: [string, string][] = [["\u30a0", "\u003d"]];

const voicedLettersTable: [string, string][] = hiraganaKatakanaTable.flatMap(([_, katakana, halfwidth]) =>
  halfwidth === undefined
    ? []
    : [
        ...(katakana[1] === undefined ? [] : ([[katakana[1], `${halfwidth}\u{ff9e}`]] satisfies [string, string][])),
        ...(katakana[2] === undefined ? [] : ([[katakana[2], `${halfwidth}\u{ff9f}`]] satisfies [string, string][])),
      ],
);

const lettersGRFwdMappingsBase: Record<string, string> = {
  ...Object.fromEntries(jisx0201GRTable),
  ...Object.fromEntries(voicedLettersTable),
  "\u3099": "\uff9e",
  "\u309a": "\uff9f",
};

const lettersGRFwdMappingsHiragana: Record<string, string> = Object.fromEntries([
  ...hiraganaKatakanaTable.flatMap(([hiragana, _, halfwidth]) =>
    hiragana === undefined || halfwidth === undefined
      ? []
      : [
          [hiragana[0], halfwidth] satisfies [string, string],
          ...(hiragana[1] === undefined ? [] : ([[hiragana[1], `${halfwidth}\u{ff9e}`]] satisfies [string, string][])),
          ...(hiragana[2] === undefined ? [] : ([[hiragana[2], `${halfwidth}\u{ff9f}`]] satisfies [string, string][])),
        ],
  ),
  ...hiraganaKatakanaSmallTable.flatMap(([hiragana, _, halfwidth]) =>
    hiragana === undefined || halfwidth === undefined ? [] : [[hiragana, halfwidth] satisfies [string, string]],
  ),
]);

const buildMutuallyExclusiveErrorMessage = (...names: string[]): string => {
  const last = names.pop();
  return `${names.join(", ")} and ${last} are mutually exclusive, and cannot be set to true at the same time.`;
};

const getFwdMappings = (() => {
  type KeyType =
    `${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}`;
  const mappingsVariations: Record<KeyType, Record<string, string>> = {};
  return ({ convertGL, convertGR, convertUnsafeSpecials, convertHiraganas, ...overrides }: FwdOptions) => {
    if (overrides.u005cAsYenSign && overrides.u00a5AsYenSign) {
      throw new Error(buildMutuallyExclusiveErrorMessage("u005cAsYenSign", "u00a5AsYenSign"));
    }
    const key: KeyType = `${Number(!!convertGL)}-${Number(!!convertGR)}-${Number(!!convertUnsafeSpecials)}-${Number(
      !!convertHiraganas,
    )}-${Number(!!overrides.u005cAsYenSign)}-${Number(!!overrides.u005cAsBackslash)}-${Number(
      !!overrides.u007eAsFullwidthTilde,
    )}-${Number(!!overrides.u007eAsWaveDash)}-${Number(!!overrides.u007eAsOverline)}-${Number(
      !!overrides.u007eAsFullwidthMacron,
    )}-${Number(!!overrides.u00a5AsYenSign)}`;
    // biome-ignore lint/suspicious/noAssignInExpressions: efficiency
    return (mappingsVariations[key] ??= {
      ...(convertGL ? lettersGLFwdMappingsBase : {}),
      ...(convertGL
        ? Object.fromEntries(
            Object.entries(overrides)
              .filter((pair) => !!pair[1])
              .flatMap((pair) => jisx0201GLOverrides[pair[0] as keyof typeof overrides]),
          )
        : {}),
      ...(convertGL && convertUnsafeSpecials ? Object.fromEntries(specialPunctuationsTable) : {}),
      ...(convertGR ? lettersGRFwdMappingsBase : {}),
      ...(convertGR && convertHiraganas ? lettersGRFwdMappingsHiragana : {}),
    });
  };
})();

const lettersGLRevMappingsBase = Object.fromEntries(jisx0201GLTable.map((pair) => [pair[1], pair[0]]));

const lettersGRRevMappingsBase = Object.fromEntries(jisx0201GRTable.map((pair) => [pair[1], pair[0]]));

const voicedLettersRevMappings = (() => {
  const result: Record<string, Record<string, string>> = {};
  for (const pair of voicedLettersTable) {
    // biome-ignore lint/suspicious/noAssignInExpressions: as intended
    (result[pair[1][0]] ??= {})[pair[1][1]] = pair[0];
  }
  return result;
})();

const getRevMappings = (() => {
  type KeyType = `${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}-${number}`;
  const mappingsVariations: Record<KeyType, Record<string, string>> = {};
  return ({ combineVoicedSoundMarks, convertGL, convertGR, convertUnsafeSpecials, ...overrides }: RevOptions) => {
    const groups = (
      Object.entries(jisx0201GLOverrides) as [keyof typeof jisx0201GLOverrides, [string, string][]][]
    ).reduce(
      (acc, [key, pairs]) => {
        for (const pair of pairs) {
          const revCode = pair[1];
          if (acc[revCode] !== undefined) {
            acc[revCode].push(key);
          } else {
            acc[revCode] = [key];
          }
        }
        return acc;
      },
      {} as Record<string, (keyof typeof jisx0201GLOverrides)[]>,
    );
    for (const [_, keys] of Object.entries(groups)) {
      const specifiedKeys = keys.filter((key) => overrides[key]);
      if (specifiedKeys.length > 1) {
        throw new Error(buildMutuallyExclusiveErrorMessage(...specifiedKeys));
      }
    }
    const key: KeyType = `${Number(!!convertGL)}-${Number(!!convertGR)}-${Number(!!convertUnsafeSpecials)}-${Number(!!overrides.u005cAsYenSign)}-${Number(
      !!overrides.u005cAsBackslash,
    )}-${Number(
      !!overrides.u007eAsFullwidthTilde,
    )}-${Number(!!overrides.u007eAsWaveDash)}-${Number(!!overrides.u007eAsOverline)}-${Number(
      !!overrides.u007eAsFullwidthMacron,
    )}-${Number(!!overrides.u00a5AsYenSign)}`;
    // biome-ignore lint/suspicious/noAssignInExpressions: efficiency
    return (mappingsVariations[key] ??= {
      ...(convertGL ? lettersGLRevMappingsBase : {}),
      ...(convertGL
        ? Object.fromEntries(
            Object.entries(overrides)
              .filter((pair) => !!pair[1])
              .flatMap((pair) => jisx0201GLOverrides[pair[0] as keyof typeof overrides])
              .map((pair) => [pair[1], pair[0]]),
          )
        : {}),
      ...(convertGR ? lettersGRRevMappingsBase : {}),
      ...(convertGL && convertUnsafeSpecials
        ? Object.fromEntries(specialPunctuationsTable.map((pair) => [pair[1], pair[0]]))
        : {}),
    });
  };
})();

/**
 * Options for the transliterator.
 */
export type Options = {
  /**
   * If set to `true`, the transliterator will replace full-width characters with half-width equivalents.
   *
   * If set to `false`, the transliterator will replace half-width characters with full-width equivalents.
   */
  fullwidthToHalfwidth?: boolean;
  /** `true` to convert characters belonging to GL area of JIS X 0201; namely alphanumerics and symbols. */
  convertGL?: boolean;
  /** `true` to convert characters belonging to GR area of JIS X 0201; namely (half-width) katakanas. */
  convertGR?: boolean;
  /**
   * `true` to convert U+30A0 (`゠`, KATAKANA-HIRAGANA DOUBLE HYPHEN) to
   * U+003D (`=`, EQUALS SIGN) when `fullwidthToHalfwidth` is `true` and vice versa.
   */
  convertUnsafeSpecials?: boolean;
  /** `true` to convert half-width hiraganas to full-width katakanas when `fullwidthToHalfwidth` is `true`, and vice versa. */
  convertHiraganas?: boolean;
  /**
   * If set to `true`, along with `fullwidthToHalfwidth` being `false`, and `convertGR` being `true`,
   * the transliterator will render the pair of a half-width katakana and a voiced sound mark
   * (濁点 — voiced sound mark or 半濁点 — semi-voiced sound mark)
   * into the literally equilavent single full-width katakana character.
   */
  combineVoicedSoundMarks?: boolean;
  /** `true` to treat U+005C (REVERSE SOLIDUS) as if it were U+00A5 (YEN SIGN) */
  u005cAsYenSign?: boolean;
  /** `true` to treat U+005C verbatim */
  u005cAsBackslash?: boolean;
  /** `true` to convert U+007E (TILDE) to U+FF5E (FULLWIDTH TILDE). When `halfwidthToFullwidth` is `true`, this option, `u007eAsWaveDash`, `u007eAsOverline`, and `u007eAsFullwidthMacron` are mutually exclusive. */
  u007eAsFullwidthTilde?: boolean;
  /** `true` to convert U+007E (TILDE) to U+301C (WAVE DASH). When `halfwidthToFullwidth` is `true`, this option, `u007eAsFullwidthTilde`, `u007eAsOverline`, and `u007eAsFullwidthMacron` are mutually exclusive. */
  u007eAsWaveDash?: boolean;
  /** `true` to convert U+007E (TILDE) to U+203E (OVERLINE). When `halfwidthToFullwidth` is `true`, this option, `u007eAsFullwidthTilde`, `u007eAsWaveDash`, and `u007eAsFullwidthMacron` are mutually exclusive. */
  u007eAsOverline?: boolean;
  /** `true` to convert U+007E (TILDE) to U+FFE3 (FULLWIDTH MACRON). When `halfwidthToFullwidth` is `true`, this option, `u007eAsFullwidthTilde`, `u007eAsWaveDash`, and `u007eAsOverline` are mutually exclusive. */
  u007eAsFullwidthMacron?: boolean;
  /** `true` to convert U+00A5 (YEN SIGN) to U+005C (REVERSE SOLIDUS) */
  u00a5AsYenSign?: boolean;
};

type OverrideOptions = Pick<Required<Options>, keyof typeof jisx0201GLOverrides>;

type FwdOptions = {
  convertGL: boolean;
  convertGR: boolean;
  convertUnsafeSpecials: boolean;
  convertHiraganas: boolean;
} & OverrideOptions;

type RevOptions = {
  convertGL: boolean;
  convertGR: boolean;
  convertUnsafeSpecials: boolean;
  combineVoicedSoundMarks: boolean;
} & OverrideOptions;

const convertFullwidthToHalfWidth = (options: FwdOptions): ((_: Iterable<Char>) => Iterable<Char>) => {
  const mappings = getFwdMappings(options);

  return function* (chars: Iterable<Char>) {
    let offset = 0;
    for (const c of chars) {
      const cc = mappings[c.c];
      if (cc !== undefined) {
        yield {
          c: cc,
          offset: offset++,
          source: c,
        };
      } else {
        yield {
          c: c.c,
          offset: offset++,
          source: c,
        };
      }
    }
  };
};

const convertHalfwidthToFullwidth = (options: RevOptions): ((_: Iterable<Char>) => Iterable<Char>) => {
  const combineVoicedSoundMarks = options.combineVoicedSoundMarks && options.convertGR;
  const lettersRevMappings = getRevMappings(options);

  return function* (chars: Iterable<Char>): Iterable<Char> {
    let voiced: [Char, Record<string, string>] | undefined;
    let offset = 0;
    for (const c of chars) {
      if (voiced !== undefined) {
        const [bc, secondMappings] = voiced;
        voiced = undefined;
        {
          const cc = secondMappings[c.c];
          if (cc !== undefined) {
            yield {
              c: cc,
              offset: offset++,
              source: bc,
            };
            voiced = undefined;
            continue;
          }
        }
        {
          const cc = lettersRevMappings[bc.c];
          if (cc !== undefined) {
            yield {
              c: cc,
              offset: offset++,
              source: bc,
            };
          } else {
            yield {
              c: bc.c,
              offset: offset++,
              source: bc,
            };
          }
        }
      }
      if (combineVoicedSoundMarks) {
        const sm = voicedLettersRevMappings[c.c];
        if (sm !== undefined) {
          voiced = [c, sm];
          continue;
        }
      }
      {
        const cc = lettersRevMappings[c.c];
        if (cc !== undefined) {
          yield {
            c: cc,
            offset: offset++,
            source: c,
          };
        } else {
          yield {
            c: c.c,
            offset: offset++,
            source: c,
          };
        }
      }
    }
  };
};

const mergeWithDefaultsFwd = (options: Options) => ({
  convertGL: options.convertGL ?? true,
  convertGR: options.convertGR ?? true,
  convertUnsafeSpecials: options.convertUnsafeSpecials ?? true,
  convertHiraganas: options.convertHiraganas ?? false,
  u005cAsYenSign: options.u005cAsYenSign ?? options.u00a5AsYenSign === undefined,
  u005cAsBackslash: options.u005cAsBackslash ?? false,
  u007eAsFullwidthTilde: options.u007eAsFullwidthTilde ?? true,
  u007eAsWaveDash: options.u007eAsWaveDash ?? true,
  u007eAsOverline: options.u007eAsOverline ?? false,
  u007eAsFullwidthMacron: options.u007eAsFullwidthMacron ?? false,
  u00a5AsYenSign: options.u00a5AsYenSign ?? false,
});

const mergeWithDefaultsRev = (options: Options) => ({
  convertGL: options.convertGL ?? true,
  convertGR: options.convertGR ?? true,
  convertUnsafeSpecials: options.convertUnsafeSpecials ?? false,
  combineVoicedSoundMarks: options.combineVoicedSoundMarks ?? true,
  u005cAsYenSign: options.u005cAsYenSign ?? options.u005cAsBackslash === undefined,
  u005cAsBackslash: options.u005cAsBackslash ?? false,
  u007eAsFullwidthTilde:
    options.u007eAsFullwidthTilde ??
    (options.u007eAsWaveDash === undefined &&
      options.u007eAsOverline === undefined &&
      options.u007eAsFullwidthMacron === undefined),
  u007eAsWaveDash: options.u007eAsWaveDash ?? false,
  u007eAsOverline: options.u007eAsOverline ?? false,
  u007eAsFullwidthMacron: options.u007eAsFullwidthMacron ?? false,
  u00a5AsYenSign: options.u00a5AsYenSign ?? true,
});

/**
 * Replace fullwidth characters with halfwidth equivalents and vice versa.
 *
 * See the module description for detail.
 *
 * @param options Options for the transliterator.
 */
export default (options: Options) => {
  return (options.fullwidthToHalfwidth ?? true)
    ? convertFullwidthToHalfWidth(mergeWithDefaultsFwd(options))
    : convertHalfwidthToFullwidth(mergeWithDefaultsRev(options));
};
