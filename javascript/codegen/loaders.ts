import * as fs from "node:fs/promises";
import {
  parseCircledOrSquaredTransliterationRecord,
  parseCombinedCharsTransliterationRecord,
  parseHyphenTransliterationRecord,
  parseIVSSVSBaseTransliterationRecord,
  parseKanjiOldNewTransliterationRecord,
  parseRomanNumeralsRecord,
  parseSimpleTransliterationRecords,
} from "./parsers";

const loadSimpleTransliterationRecords = async (path: string) => {
  const f = await fs.open(path);
  try {
    return await parseSimpleTransliterationRecords(f.readableWebStream());
  } finally {
    await f.close();
  }
};

export default {
  spaces: loadSimpleTransliterationRecords,
  radicals: loadSimpleTransliterationRecords,
  mathematicalAlphanumerics: loadSimpleTransliterationRecords,
  ideographicAnnotations: loadSimpleTransliterationRecords,
  hyphens: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseHyphenTransliterationRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
  ivsSVSBase: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseIVSSVSBaseTransliterationRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
  kanjiOldNew: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseKanjiOldNewTransliterationRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
  combined: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseCombinedCharsTransliterationRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
  circledOrSquared: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseCircledOrSquaredTransliterationRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
  romanNumerals: async (path: string) => {
    const f = await fs.open(path);
    try {
      return await parseRomanNumeralsRecord(f.readableWebStream());
    } finally {
      await f.close();
    }
  },
};
