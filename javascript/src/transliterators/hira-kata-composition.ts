import type { Char } from "../types.js";
import { semivoicedCharacters, voicedCharacters } from "./hira-kata-table.js";

export type Options = {
  composeNonCombiningMarks?: boolean;
};

const voicedTable = Object.fromEntries([...voicedCharacters, ["\u309d", "\u309e"], ["\u30fd", "\u30fe"]]);
const semiVoicedTable = Object.fromEntries(semivoicedCharacters);

/**
 * Combines decomposed hiraganas and katakanas into composed equivalents.
 *
 * @param options - Options for the transliterator.
 */
export default (options: Options): ((_: Iterable<Char>) => Iterable<Char>) => {
  const table: Record<string, Record<string, string>> = options.composeNonCombiningMarks
    ? {
        "\u3099": voicedTable,
        "\u309a": semiVoicedTable,
        "\u309b": voicedTable,
        "\u309c": semiVoicedTable,
      }
    : {
        "\u3099": voicedTable,
        "\u309a": semiVoicedTable,
      };

  return function* (in_: Iterable<Char>) {
    let offset = 0;
    let pc: Char | undefined;
    for (const c of in_) {
      if (pc !== undefined) {
        const rc = table[c.c]?.[pc.c];
        if (rc !== undefined) {
          yield { c: rc, offset: offset, source: pc };
          offset += rc.length;
          pc = undefined;
          continue;
        }
        yield { c: pc.c, offset: offset, source: pc };
        offset += pc.c.length;
      }
      pc = c;
    }
    if (pc !== undefined) {
      yield { c: pc.c, offset: offset, source: pc };
      offset += pc.c.length;
    }
  };
};
