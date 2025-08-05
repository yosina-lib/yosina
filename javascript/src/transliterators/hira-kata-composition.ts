import type { Char } from "../types.js";

const compositionTable: [string, string][] = [
  ["\u{304b}\u{3099}", "\u{304c}"],
  ["\u{304d}\u{3099}", "\u{304e}"],
  ["\u{304f}\u{3099}", "\u{3050}"],
  ["\u{3051}\u{3099}", "\u{3052}"],
  ["\u{3053}\u{3099}", "\u{3054}"],

  ["\u{3055}\u{3099}", "\u{3056}"],
  ["\u{3057}\u{3099}", "\u{3058}"],
  ["\u{3059}\u{3099}", "\u{305a}"],
  ["\u{305b}\u{3099}", "\u{305c}"],
  ["\u{305d}\u{3099}", "\u{305e}"],

  ["\u{305f}\u{3099}", "\u{3060}"],
  ["\u{3061}\u{3099}", "\u{3062}"],
  ["\u{3064}\u{3099}", "\u{3065}"],
  ["\u{3066}\u{3099}", "\u{3067}"],
  ["\u{3069}\u{3099}", "\u{3069}"],

  ["\u{306f}\u{3099}", "\u{3070}"],
  ["\u{3072}\u{3099}", "\u{3073}"],
  ["\u{3075}\u{3099}", "\u{3076}"],
  ["\u{3078}\u{3099}", "\u{3079}"],
  ["\u{307b}\u{3099}", "\u{307c}"],

  ["\u{306f}\u{309a}", "\u{3071}"],
  ["\u{3072}\u{309a}", "\u{3074}"],
  ["\u{3075}\u{309a}", "\u{3077}"],
  ["\u{3078}\u{309a}", "\u{307a}"],
  ["\u{307b}\u{309a}", "\u{307d}"],

  ["\u{3046}\u{3099}", "\u{3094}"],
  ["\u{309d}\u{3099}", "\u{309e}"],

  ["\u{30ab}\u{3099}", "\u{30ac}"],
  ["\u{30ad}\u{3099}", "\u{30ae}"],
  ["\u{30af}\u{3099}", "\u{30b0}"],
  ["\u{30b1}\u{3099}", "\u{30b2}"],
  ["\u{30b3}\u{3099}", "\u{30b4}"],

  ["\u{30b5}\u{3099}", "\u{30b6}"],
  ["\u{30b7}\u{3099}", "\u{30b8}"],
  ["\u{30b9}\u{3099}", "\u{30ba}"],
  ["\u{30bb}\u{3099}", "\u{30bc}"],
  ["\u{30bd}\u{3099}", "\u{30be}"],

  ["\u{30bf}\u{3099}", "\u{30c0}"],
  ["\u{30c1}\u{3099}", "\u{30c2}"],
  ["\u{30c4}\u{3099}", "\u{30c5}"],
  ["\u{30c6}\u{3099}", "\u{30c7}"],
  ["\u{30c9}\u{3099}", "\u{30c9}"],

  ["\u{30cf}\u{3099}", "\u{30d0}"],
  ["\u{30d2}\u{3099}", "\u{30d3}"],
  ["\u{30d5}\u{3099}", "\u{30d6}"],
  ["\u{30d8}\u{3099}", "\u{30d9}"],
  ["\u{30db}\u{3099}", "\u{30dc}"],

  ["\u{30cf}\u{309a}", "\u{30d1}"],
  ["\u{30d2}\u{309a}", "\u{30d4}"],
  ["\u{30d5}\u{309a}", "\u{30d7}"],
  ["\u{30d8}\u{309a}", "\u{30da}"],
  ["\u{30db}\u{309a}", "\u{30dd}"],

  ["\u{30a6}\u{3099}", "\u{30f4}"],
  ["\u{30ef}\u{3099}", "\u{30f7}"],
  ["\u{30f0}\u{3099}", "\u{30f8}"],
  ["\u{30f1}\u{3099}", "\u{30f9}"],
  ["\u{30f2}\u{3099}", "\u{30fa}"],
];

export type Options = {
  composeNonCombiningMarks?: boolean;
};

const getCompositionMappings = (() => {
  const makeTrie = (modifier?: (arg: string) => [string, boolean]) => {
    const trie: Record<string, Record<string, string>> = {};
    for (const [decomposed, composed] of compositionTable) {
      const [_decomposed, extra] = modifier != null ? modifier(decomposed) : [decomposed, false];
      // biome-ignore lint/suspicious/noAssignInExpressions: efficiency
      (trie[_decomposed[0]] ??= {})[_decomposed[1]] = composed;
      if (extra) {
        // biome-ignore lint/suspicious/noAssignInExpressions: efficiency
        (trie[decomposed[0]] ??= {})[decomposed[1]] = composed;
      }
    }
    return trie;
  };

  const mappingsVariations: Record<string, Record<string, Record<string, string>>> = {};
  return ({ composeNonCombiningMarks }: Options) => {
    const v = Number(composeNonCombiningMarks).toString();
    // biome-ignore lint/suspicious/noAssignInExpressions: efficiency
    return (mappingsVariations[v] ??= makeTrie(
      composeNonCombiningMarks
        ? (decomposed) => [decomposed.replace(/\u3099/g, "\u{309b}").replace(/\u309a/g, "\u{309c}"), true]
        : undefined,
    ));
  };
})();

/**
 * Combines decomposed hiraganas and katakanas into composed equivalents.
 *
 * @param options - Options for the transliterator.
 */
export default (options: Options): ((_: Iterable<Char>) => Iterable<Char>) => {
  const m = getCompositionMappings(options);

  return function* (in_: Iterable<Char>) {
    let offset = 0;
    let pc: Char | undefined;
    let pn: Record<string, string> | undefined;
    for (const c of in_) {
      if (pn !== undefined && pc !== undefined) {
        const inn = pn[c.c];
        if (inn !== undefined) {
          yield { c: inn, offset: offset, source: pc };
          offset += inn.length;
          pc = pn = undefined;
          continue;
        }
        yield { ...pc, offset: offset };
        offset += pc.c.length;
        pc = pn = undefined;
      }
      const n = m[c.c];
      if (n !== undefined) {
        pn = n;
        pc = c;
        continue;
      }
      yield { ...c, offset: offset++ };
    }
    if (pc !== undefined) {
      yield { ...pc, offset: offset };
      offset += pc.c.length;
    }
  };
};
