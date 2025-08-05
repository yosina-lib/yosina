/***
 * This module implements a transliterator that replaces ideographic annotation marks with their corresponding characters.
 *
 * @module
 */
import type { Char } from "../types.ts";

type Mappings = Record<string, string>;
export type Options = Record<string, never>;
const mappings: Mappings = {
  "\u3192": "\u4E00",
  "\u3193": "\u4E8C",
  "\u3194": "\u4E09",
  "\u3195": "\u56DB",
  "\u3196": "\u4E0A",
  "\u3197": "\u4E2D",
  "\u3198": "\u4E0B",
  "\u3199": "\u7532",
  "\u319A": "\u4E59",
  "\u319B": "\u4E19",
  "\u319C": "\u4E01",
  "\u319D": "\u5929",
  "\u319E": "\u5730",
  "\u319F": "\u4EBA",
};
/**
 * Replaces ideographic annotation marks with their corresponding characters.
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
