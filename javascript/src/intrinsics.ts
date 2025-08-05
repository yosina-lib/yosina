import type { SupportedTransliterators, TransliteratorConfig } from "./transliterators/index.js";
import { getTransliteratorFactory } from "./transliterators/index.js";
import type { Char, Transliterator } from "./types.js";

export const makeChainedTransliterator = async (
  transliteratorConfigs: (TransliteratorConfig | string)[],
): Promise<Transliterator> => {
  let result: Transliterator | undefined;
  for (const config of transliteratorConfigs) {
    const t =
      typeof config === "string"
        ? (await getTransliteratorFactory(config as SupportedTransliterators))({})
        : (await getTransliteratorFactory(config[0]))(config[1]);
    result = ((tt: Transliterator | undefined) => (tt !== undefined ? (in_: Iterable<Char>) => t(tt(in_)) : t))(result);
  }
  if (result === undefined) {
    throw new Error("at least one transliterator must be specified");
  }
  return result;
};

export const isTransliterated = (c: Char) => {
  for (;;) {
    const s = c.source;
    if (s === undefined) {
      break;
    }
    if (s.c !== c.c) {
      return true;
    }
    c = s;
  }
  return false;
};
