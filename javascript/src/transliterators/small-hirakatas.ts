/***
 * This module implements a transliterator that replaces small hiragana/katakana with their ordinary-sized equivalents.
 *
 * @module
 */
import type { Char } from "../types.ts";

type Mappings = Record<string, string>;
export type Options = Record<string, never>;
const mappings: Mappings = {
  "\u3041": "\u3042",
  "\u3043": "\u3044",
  "\u3045": "\u3046",
  "\u3047": "\u3048",
  "\u3049": "\u304A",
  "\u3063": "\u3064",
  "\u3083": "\u3084",
  "\u3085": "\u3086",
  "\u3087": "\u3088",
  "\u308E": "\u308F",
  "\u3095": "\u304B",
  "\u3096": "\u3051",
  "\u30A1": "\u30A2",
  "\u30A3": "\u30A4",
  "\u30A5": "\u30A6",
  "\u30A7": "\u30A8",
  "\u30A9": "\u30AA",
  "\u30C3": "\u30C4",
  "\u30E3": "\u30E4",
  "\u30E5": "\u30E6",
  "\u30E7": "\u30E8",
  "\u30EE": "\u30EF",
  "\u30F5": "\u30AB",
  "\u30F6": "\u30B1",
  "\u31F0": "\u30AF",
  "\u31F1": "\u30B7",
  "\u31F2": "\u30B9",
  "\u31F3": "\u30C8",
  "\u31F4": "\u30CC",
  "\u31F5": "\u30CF",
  "\u31F6": "\u30D2",
  "\u31F7": "\u30D5",
  "\u31F8": "\u30D8",
  "\u31F9": "\u30DB",
  "\u31FA": "\u30E0",
  "\u31FB": "\u30E9",
  "\u31FC": "\u30EA",
  "\u31FD": "\u30EB",
  "\u31FE": "\u30EC",
  "\u31FF": "\u30ED",
  "\uFF67": "\uFF71",
  "\uFF68": "\uFF72",
  "\uFF69": "\uFF73",
  "\uFF6A": "\uFF74",
  "\uFF6B": "\uFF75",
  "\uFF6C": "\uFF94",
  "\uFF6D": "\uFF95",
  "\uFF6E": "\uFF96",
  "\uFF6F": "\uFF82",
  "\uD82C\uDD32": "\u3053",
  "\uD82C\uDD50": "\u3090",
  "\uD82C\uDD51": "\u3091",
  "\uD82C\uDD52": "\u3092",
  "\uD82C\uDD55": "\u30B3",
  "\uD82C\uDD64": "\u30F0",
  "\uD82C\uDD65": "\u30F1",
  "\uD82C\uDD66": "\u30F2",
  "\uD82C\uDD67": "\u30F3",
};
/**
 * Replaces small hiragana/katakana with their ordinary-sized equivalents.
 *
 * @param _ Options for the transliterator. (Unused; only an empty object is accepted.)
 * @returns An iterable that yields transliterated characters.
 */
export default (_: Options): ((_: Iterable<Char>) => Iterable<Char>) =>
  function* (in_: Iterable<Char>) {
    let offset = 0;
    for (const c of in_) {
      const cc = mappings[c.c];
      if (cc != null && cc !== c.c) {
        yield { c: cc, offset: offset, source: c };
        offset += cc.length;
      } else {
        yield { c: c.c, offset: offset, source: c };
        offset += c.c.length;
      }
    }
  };
