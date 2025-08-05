/***
 * {{moduleDescription}}
 *
 * @module
 */
type Char = {
  c: string;
  offset: number;
  source: Char | undefined;
};

type Mappings = Record<string, string[]>;

export type Options = Record<string, never>;

const mappings: Mappings = {};

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
