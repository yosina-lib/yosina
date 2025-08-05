/***
 * This module implements a transliterator that replaces spaces with U+0020.
 *
 * @module
 */
import type { Char } from "../types.ts";

type Mappings = Record<string, string>;
export type Options = Record<string, never>;
const mappings: Mappings = {
  "\u00A0": " ",
  "\u180E": "",
  "\u2000": " ",
  "\u2001": " ",
  "\u2002": " ",
  "\u2003": " ",
  "\u2004": " ",
  "\u2005": " ",
  "\u2006": " ",
  "\u2007": " ",
  "\u2008": " ",
  "\u2009": " ",
  "\u200A": " ",
  "\u200B": " ",
  "\u202F": " ",
  "\u205F": " ",
  "\u3000": " ",
  "\u3164": " ",
  "\uFFA0": " ",
  "\uFEFF": "",
};
/**
 * Replaces spaces with U+0020.
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
