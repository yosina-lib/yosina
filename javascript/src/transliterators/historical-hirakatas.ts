/***
 * This module implements a transliterator that converts historical hiragana/katakana
 * characters into their modern equivalents.
 *
 * @module
 */
import type { Char, Transliterator, TransliteratorFactory } from "../types.js";

export type ConversionMode = "simple" | "decompose" | "skip";

export type Options = {
  hiraganas?: ConversionMode;
  katakanas?: ConversionMode;
  voicedKatakanas?: "decompose" | "skip";
};

const historicalHiraganaMappings: Record<string, Record<"simple" | "decompose", string>> = {
  "\u3090": { simple: "\u3044", decompose: "\u3046\u3043" }, // ゐ → い / うぃ
  "\u3091": { simple: "\u3048", decompose: "\u3046\u3047" }, // ゑ → え / うぇ
};

const historicalKatakanaMappings: Record<string, Record<"simple" | "decompose", string>> = {
  "\u30F0": { simple: "\u30A4", decompose: "\u30A6\u30A3" }, // ヰ → イ / ウィ
  "\u30F1": { simple: "\u30A8", decompose: "\u30A6\u30A7" }, // ヱ → エ / ウェ
};

const voicedHistoricalKanaMappings: Record<string, string> = {
  "\u30F7": "\u30A1", // ヷ → ァ
  "\u30F8": "\u30A3", // ヸ → ィ
  "\u30F9": "\u30A7", // ヹ → ェ
  "\u30FA": "\u30A9", // ヺ → ォ
};

const voicedHistoricalKanaDecomposedMappings: Record<string, string> = {
  "\u30EF": "\u30A1", // ヷ → ァ
  "\u30F0": "\u30A3", // ヸ → ィ
  "\u30F1": "\u30A7", // ヹ → ェ
  "\u30F2": "\u30A9", // ヺ → ォ
};

const COMBINING_DAKUTEN = "\u3099";
const VU = "\u30F4";
const U = "\u30A6";

const factory: TransliteratorFactory = (options: Record<string, unknown>): Transliterator => {
  const opts = options as Options;
  const hiraganas = opts.hiraganas ?? "simple";
  const katakanas = opts.katakanas ?? "simple";
  const voicedKatakanas = opts.voicedKatakanas ?? "skip";

  return function* (chars: Iterable<Char>): Generator<Char> {
    let offset = 0;

    function* emitChar(char: Char): Generator<Char> {
      // Historical hiragana
      const hiraMapping = historicalHiraganaMappings[char.c];
      if (hiraMapping !== undefined && hiraganas !== "skip") {
        const replacement = hiraMapping[hiraganas];
        yield { c: replacement, offset, source: char };
        offset += replacement.length;
        return;
      }

      // Historical katakana
      const kataMapping = historicalKatakanaMappings[char.c];
      if (kataMapping !== undefined && katakanas !== "skip") {
        const replacement = kataMapping[katakanas];
        yield { c: replacement, offset, source: char };
        offset += replacement.length;
        return;
      }

      // Voiced historical katakana (precomposed)
      if (voicedKatakanas === "decompose") {
        const decomposed = voicedHistoricalKanaMappings[char.c];
        if (decomposed !== undefined) {
          yield { c: VU, offset, source: char };
          offset += VU.length;
          yield { c: decomposed, offset, source: char };
          offset += decomposed.length;
          return;
        }
      }

      yield { c: char.c, offset, source: char };
      offset += char.c.length;
    }

    let pending: Char | undefined;

    for (const char of chars) {
      if (pending === undefined) {
        pending = char;
        continue;
      }
      if (char.c === COMBINING_DAKUTEN) {
        // Check if pending char could be a decomposed voiced base
        const decomposed = voicedHistoricalKanaDecomposedMappings[pending.c];
        if (voicedKatakanas === "skip" || decomposed === undefined) {
          yield { c: pending.c, offset, source: pending };
          offset += pending.c.length;
          pending = char;
          continue;
        }
        yield { c: U, offset, source: pending };
        offset += U.length;
        yield { c: char.c, offset, source: char };
        offset += char.c.length;
        yield { c: decomposed, offset, source: pending };
        offset += decomposed.length;
        pending = undefined;
        continue;
      }
      yield* emitChar(pending);
      pending = char;
    }

    // Flush remaining pending char
    if (pending !== undefined) {
      yield* emitChar(pending);
    }
  };
};

export default factory;
