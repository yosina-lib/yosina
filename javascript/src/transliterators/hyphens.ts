/***
 * This module implements a transliterator that substitutes commoner counterparts for hyphens and a number of symbols.
 *
 * @module
 */
import type { Char } from "../types.ts";
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
const mappings: Mappings = {
  "-": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2212",
    jisx0208_90_windows: "\u2212",
    jisx0208_verbatim: null,
  },
  "|": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: null,
  },
  "~": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\uFF5E",
    jisx0208_verbatim: null,
  },
  "\u00A2": {
    ascii: null,
    jisx0201: null,
    jisx0208_90: "\u00A2",
    jisx0208_90_windows: "\uFFE0",
    jisx0208_verbatim: "\u00A2",
  },
  "\u00A3": {
    ascii: null,
    jisx0201: null,
    jisx0208_90: "\u00A3",
    jisx0208_90_windows: "\uFFE1",
    jisx0208_verbatim: "\u00A3",
  },
  "\u00A6": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: "\u00A6",
  },
  "\u02D7": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2212",
    jisx0208_90_windows: "\uFF0D",
    jisx0208_verbatim: null,
  },
  "\u2010": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\u2010",
    jisx0208_verbatim: "\u2010",
  },
  "\u2011": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\u2010",
    jisx0208_verbatim: null,
  },
  "\u2012": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2015",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: null,
  },
  "\u2013": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2015",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: "\u2013",
  },
  "\u2014": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2014",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: "\u2014",
  },
  "\u2015": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2015",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: "\u2015",
  },
  "\u2016": {
    ascii: null,
    jisx0201: null,
    jisx0208_90: "\u2016",
    jisx0208_90_windows: "\u2225",
    jisx0208_verbatim: "\u2016",
  },
  "\u203E": {
    ascii: null,
    jisx0201: "~",
    jisx0208_90: "\uFFE3",
    jisx0208_90_windows: "\uFFE3",
    jisx0208_verbatim: "\u203D",
  },
  "\u2043": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\u2010",
    jisx0208_verbatim: null,
  },
  "\u2053": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\u301C",
    jisx0208_verbatim: null,
  },
  "\u2212": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2212",
    jisx0208_90_windows: "\uFF0D",
    jisx0208_verbatim: "\u2212",
  },
  "\u2225": {
    ascii: null,
    jisx0201: null,
    jisx0208_90: "\u2016",
    jisx0208_90_windows: "\u2225",
    jisx0208_verbatim: "\u2225",
  },
  "\u223C": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\uFF5E",
    jisx0208_verbatim: null,
  },
  "\u223D": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\uFF5E",
    jisx0208_verbatim: null,
  },
  "\u2500": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2015",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: "\u2500",
  },
  "\u2501": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2015",
    jisx0208_90_windows: "\u2015",
    jisx0208_verbatim: "\u2501",
  },
  "\u2502": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: "\u2502",
  },
  "\u2796": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2212",
    jisx0208_90_windows: "\uFF0D",
    jisx0208_verbatim: null,
  },
  "\u29FF": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\uFF0D",
    jisx0208_verbatim: null,
  },
  "\u2E3A": {
    ascii: "--",
    jisx0201: "--",
    jisx0208_90: "\u2014\u2014",
    jisx0208_90_windows: "\u2015\u2015",
    jisx0208_verbatim: null,
  },
  "\u2E3B": {
    ascii: "---",
    jisx0201: "---",
    jisx0208_90: "\u2014\u2014\u2014",
    jisx0208_90_windows: "\u2015\u2015\u2015",
    jisx0208_verbatim: null,
  },
  "\u301C": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\uFF5E",
    jisx0208_verbatim: "\u301C",
  },
  "\u30A0": {
    ascii: "=",
    jisx0201: "=",
    jisx0208_90: "\uFF1D",
    jisx0208_90_windows: "\uFF1D",
    jisx0208_verbatim: "\u30A0",
  },
  "\u30FB": {
    ascii: null,
    jisx0201: "\uFF65",
    jisx0208_90: "\u30FB",
    jisx0208_90_windows: "\u30FB",
    jisx0208_verbatim: "\u30FB",
  },
  "\u30FC": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u30FC",
    jisx0208_90_windows: "\u30FC",
    jisx0208_verbatim: "\u30FC",
  },
  "\uFE31": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: null,
  },
  "\uFE58": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\u2010",
    jisx0208_verbatim: null,
  },
  "\uFE63": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2010",
    jisx0208_90_windows: "\u2010",
    jisx0208_verbatim: null,
  },
  "\uFF0D": {
    ascii: "-",
    jisx0201: "-",
    jisx0208_90: "\u2212",
    jisx0208_90_windows: "\uFF0D",
    jisx0208_verbatim: null,
  },
  "\uFF5C": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: "\uFF5C",
  },
  "\uFF5E": {
    ascii: "~",
    jisx0201: "~",
    jisx0208_90: "\u301C",
    jisx0208_90_windows: "\uFF5E",
    jisx0208_verbatim: null,
  },
  "\uFFE4": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFFE4",
    jisx0208_verbatim: "\uFFE4",
  },
  "\uFF70": {
    ascii: "-",
    jisx0201: "\uFF70",
    jisx0208_90: "\u30FC",
    jisx0208_90_windows: "\u30FC",
    jisx0208_verbatim: null,
  },
  "\uFFE8": {
    ascii: "|",
    jisx0201: "|",
    jisx0208_90: "\uFF5C",
    jisx0208_90_windows: "\uFF5C",
    jisx0208_verbatim: null,
  },
};
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
