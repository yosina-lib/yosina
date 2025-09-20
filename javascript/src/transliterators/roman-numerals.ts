/***
 * {{moduleDescription}}
 *
 * @module
 */
import type { Char } from "../types.ts";

type Mappings = Record<string, string[]>;
export type Options = Record<string, never>;
const mappings: Mappings = {
  "\u2160": ["I"],
  "\u2170": ["i"],
  "\u2161": ["I", "I"],
  "\u2171": ["i", "i"],
  "\u2162": ["I", "I", "I"],
  "\u2172": ["i", "i", "i"],
  "\u2163": ["I", "V"],
  "\u2173": ["i", "v"],
  "\u2164": ["V"],
  "\u2174": ["v"],
  "\u2165": ["V", "I"],
  "\u2175": ["v", "i"],
  "\u2166": ["V", "I", "I"],
  "\u2176": ["v", "i", "i"],
  "\u2167": ["V", "I", "I", "I"],
  "\u2177": ["v", "i", "i", "i"],
  "\u2168": ["I", "X"],
  "\u2178": ["i", "x"],
  "\u2169": ["X"],
  "\u2179": ["x"],
  "\u216A": ["X", "I"],
  "\u217A": ["x", "i"],
  "\u216B": ["X", "I", "I"],
  "\u217B": ["x", "i", "i"],
  "\u216C": ["L"],
  "\u217C": ["l"],
  "\u216D": ["C"],
  "\u217D": ["c"],
  "\u216E": ["D"],
  "\u217E": ["d"],
  "\u216F": ["M"],
  "\u217F": ["m"],
};
/**
 * {{functionDescription}}
 *
 * @param _ Options for the transliterator. (Unused; only an empty object is accepted.)
 * @returns An iterable that yields transliterated characters.
 */
export default (_: Options): ((_: Iterable<Char>) => Iterable<Char>) =>
  function* (in_: Iterable<Char>) {
    let offset = 0;
    for (const c of in_) {
      const r = mappings[c.c];
      if (r != null) {
        for (const rc of r) {
          yield { c: rc, offset: offset, source: c };
          offset += rc.length;
        }
      } else {
        yield { c: c.c, offset: offset, source: c };
        offset += c.c.length;
      }
    }
  };
