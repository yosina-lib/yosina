/***
 * This module implements a transliterator that substitutes commoner counterparts for hyphens and a number of symbols.
 *
 * @module
 */
type Char = {
  c: string;
  offset: number;
  source: Char | undefined;
};

type HyphensRecord = {
  ascii: string | null;
  jisx0201: string | null;
  jisx0208_90: string | null;
  jisx0208_90_windows: string | null;
  jisx0208_verbatim: string | null;
};

type Mappings = Record<string, HyphensRecord>;

/**
 * Mapping supported by the transliterator.
 *
 * Please refer to *Hyphens transliterator specification* for the details of the values.
 */
export type Mapping = "ascii" | "jisx0201" | "jisx0208_90" | "jisx0208_90_windows" | "jisx0208_verbatim";

/**
 * Options for the transliterator.
 */
export type Options = {
  /**
   * The application precedence of mappings.
   *
   * If the target character is found in the mapping, it will be replaced with the counterpart, and will not be applied against the subsequent mappings.
   */
  precedence?: Mapping[];
};

/**
 * Default precedence of mappings.
 */
export const DEFAULT_PRECEDENCE: Mapping[] = ["jisx0208_90"];
const mappings: Mappings = {};

/**
 * Replaces hyphens and a number of symbols to such common counterparts that are part of JIS X 0201 or JIS X 0208.
 * For the details of the target character and mapping rules, please refer to *Hyphens transliterator specification*.
 *
 * @param options - Options for the transliterator.
 */
export default (options: Options): ((_: Iterable<Char>) => Iterable<Char>) => {
  const yieldCharFor = (r: HyphensRecord) => {
    // coalesce
    for (const k of options.precedence ?? DEFAULT_PRECEDENCE) {
      if (r[k] != null) {
        return r[k];
      }
    }
    return null;
  };

  return function* (in_: Iterable<Char>) {
    let offset = 0;
    for (const c of in_) {
      const r = mappings[c.c];
      const cc = r && yieldCharFor(r);
      if (cc != null && cc !== c.c) {
        yield { c: cc, offset: offset, source: c };
        offset += cc.length;
      } else {
        yield { c: c.c, offset: offset, source: c };
        offset += c.c.length;
      }
    }
  };
};
