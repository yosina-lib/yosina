import type { Char, Transliterator, TransliteratorFactory } from "../types.js";
import { hiraganaKatakanaSmallTable, hiraganaKatakanaTable } from "./hira-kata-table.js";

export type Options = {
  mode: "hira-to-kata" | "kata-to-hira";
};

// Cache for the mapping tables
const mappingCache: {
  [k in Options["mode"]]?: Record<string, string>;
} = {};

const buildMappingTable = (mode: Options["mode"]): Record<string, string> => {
  // Check cache first
  const cached = mappingCache[mode];
  if (cached !== undefined) {
    return cached;
  }

  const map: Record<string, string> = {};

  // Main table mappings
  for (const [hiraganaEntry, katakanaEntry] of hiraganaKatakanaTable) {
    if (hiraganaEntry !== undefined) {
      const [hira, hiraVoiced, hiraSemivoiced] = hiraganaEntry;
      const [kata, kataVoiced, kataSemivoiced] = katakanaEntry;

      if (mode === "hira-to-kata") {
        map[hira] = kata;
        if (hiraVoiced !== undefined && kataVoiced !== undefined) {
          map[hiraVoiced] = kataVoiced;
        }
        if (hiraSemivoiced !== undefined && kataSemivoiced !== undefined) {
          map[hiraSemivoiced] = kataSemivoiced;
        }
      } else {
        map[kata] = hira;
        if (kataVoiced !== undefined && hiraVoiced !== undefined) {
          map[kataVoiced] = hiraVoiced;
        }
        if (kataSemivoiced !== undefined && hiraSemivoiced !== undefined) {
          map[kataSemivoiced] = hiraSemivoiced;
        }
      }
    }
  }

  // Small character mappings
  for (const [hira, kata] of hiraganaKatakanaSmallTable) {
    if (mode === "hira-to-kata") {
      map[hira] = kata;
    } else {
      map[kata] = hira;
    }
  }

  // Cache the result
  mappingCache[mode] = map;

  return map;
};

const factory: TransliteratorFactory = (options: Record<string, unknown>): Transliterator => {
  const opts = options as Options;
  const mappingTable = buildMappingTable(opts.mode);

  return function* (chars: Iterable<Char>): Generator<Char> {
    for (const char of chars) {
      const mapped = mappingTable[char.c];
      if (mapped !== undefined) {
        yield { c: mapped, offset: char.offset, source: char };
      } else {
        yield char;
      }
    }
  };
};

export default factory;
