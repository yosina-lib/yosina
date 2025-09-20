import { json } from "node:stream/consumers";
import type { ReadableStream } from "node:stream/web";
import * as zod from "zod";
import type { CircledOrSquaredRecord, HyphensRecord, IVSSVSBaseRecord, RomanNumeralsRecord } from "./dataset";

const simpleTransliterationFileSchema = zod.record(zod.string(), zod.nullable(zod.string()));

const hyphensFileRecordSchema = zod.object({
  code: zod.string(),
  ascii: zod.nullable(zod.array(zod.string())),
  shift_jis: zod.nullable(zod.array(zod.number())),
  jisx0201: zod.nullable(zod.array(zod.string())),
  "jisx0208-1978": zod.nullable(zod.array(zod.string())),
  "jisx0208-1978-windows": zod.nullable(zod.array(zod.string())),
  "jisx0208-verbatim": zod.nullable(zod.string()),
});

const hyphensFileSchema = zod.array(hyphensFileRecordSchema);

const ivsSVSSchema = zod.object({
  ivs: zod.array(zod.string()),
  svs: zod.nullable(zod.array(zod.string())),
});

const ivsSVSFileRecordSchema = ivsSVSSchema.extend({
  base90: zod.nullable(zod.string()),
  base2004: zod.nullable(zod.string()),
});

const ivsSVSFileSchema = zod.array(ivsSVSFileRecordSchema);

const kanjiOldNewRecordSchema = zod.tuple([ivsSVSSchema, ivsSVSSchema]);

const kanjiOldNewFileSchema = zod.array(kanjiOldNewRecordSchema);

const combinedCharsFileSchema = zod.record(zod.string(), zod.string());

const circledOrSquaredFileSchema = zod.record(
  zod.string(),
  zod.object({
    rendering: zod.string(),
    type: zod.enum(["circle", "square"]),
    emoji: zod.boolean(),
  }),
);

const romanNumeralsFileSchema = zod.array(
  zod.object({
    value: zod.number(),
    codes: zod.object({
      upper: zod.string(),
      lower: zod.string(),
    }),
    shift_jis: zod.object({
      upper: zod.array(zod.number()),
      lower: zod.array(zod.number()),
    }),
    decomposed: zod.object({
      upper: zod.array(zod.string()),
      lower: zod.array(zod.string()),
    }),
  }),
);

const parseUnicodeCodepoint = (cpRepr: string) => {
  const m = /^U\+([0-9A-Fa-f]+)/.exec(cpRepr);
  if (m == null) {
    throw new Error(`invalid Unicode codepoint representation: ${cpRepr}`);
  }
  return Number.parseInt(m[1], 16);
};

export const parseSimpleTransliterationRecords = async (f: ReadableStream): Promise<[string, string][]> => {
  const data = await simpleTransliterationFileSchema.parseAsync(await json(f));
  return Object.entries(data).map((pair) => [
    String.fromCodePoint(parseUnicodeCodepoint(pair[0])),
    pair[1] != null ? String.fromCodePoint(parseUnicodeCodepoint(pair[1])) : "",
  ]);
};

export const parseHyphenTransliterationRecord = async (f: ReadableStream): Promise<[string, HyphensRecord][]> =>
  (await hyphensFileSchema.parseAsync(await json(f))).map((record) => [
    String.fromCodePoint(parseUnicodeCodepoint(record.code)),
    {
      ascii: record.ascii && String.fromCodePoint(...record.ascii.map(parseUnicodeCodepoint)),
      jisx0201: record.jisx0201 && String.fromCodePoint(...record.jisx0201.map(parseUnicodeCodepoint)),
      jisx0208_90:
        record["jisx0208-1978"] && String.fromCodePoint(...record["jisx0208-1978"].map(parseUnicodeCodepoint)),
      jisx0208_90_windows:
        record["jisx0208-1978-windows"] &&
        String.fromCodePoint(...record["jisx0208-1978-windows"].map(parseUnicodeCodepoint)),
      jisx0208_verbatim:
        record["jisx0208-verbatim"] && String.fromCodePoint(parseUnicodeCodepoint(record["jisx0208-verbatim"])),
    },
  ]);

export const parseIVSSVSBaseTransliterationRecord = async (f: ReadableStream): Promise<IVSSVSBaseRecord[]> =>
  (await ivsSVSFileSchema.parseAsync(await json(f))).map((record) => ({
    ivs: String.fromCodePoint(...record.ivs.map(parseUnicodeCodepoint)),
    svs: record.svs && String.fromCodePoint(...record.svs.map(parseUnicodeCodepoint)),
    base90: record.base90 && String.fromCodePoint(parseUnicodeCodepoint(record.base90)),
    base2004: record.base2004 && String.fromCodePoint(parseUnicodeCodepoint(record.base2004)),
  }));

export const parseKanjiOldNewTransliterationRecord = async (f: ReadableStream): Promise<[string, string][]> =>
  (await kanjiOldNewFileSchema.parseAsync(await json(f))).map((record) => [
    String.fromCodePoint(...record[0].ivs.map(parseUnicodeCodepoint)),
    String.fromCodePoint(...record[1].ivs.map(parseUnicodeCodepoint)),
  ]);

export const parseCombinedCharsTransliterationRecord = async (f: ReadableStream): Promise<[string, string[]][]> => {
  const data = await combinedCharsFileSchema.parseAsync(await json(f));
  return Object.entries(data).map((pair) => [String.fromCodePoint(parseUnicodeCodepoint(pair[0])), [...pair[1]]]);
};

export const parseCircledOrSquaredTransliterationRecord = async (
  f: ReadableStream,
): Promise<[string, CircledOrSquaredRecord][]> => {
  const data = await circledOrSquaredFileSchema.parseAsync(await json(f));
  return Object.entries(data).map((pair) => [
    String.fromCodePoint(parseUnicodeCodepoint(pair[0])),
    {
      rendering: [...pair[1].rendering],
      type: pair[1].type,
      emoji: pair[1].emoji,
    },
  ]);
};

export const parseRomanNumeralsRecord = async (f: ReadableStream): Promise<[string, string[]][]> => {
  const data = await romanNumeralsFileSchema.parseAsync(await json(f));
  const result: [string, string[]][] = [];
  data.forEach((record) => {
    // Parse upper and lower codes
    const upperChar = String.fromCodePoint(parseUnicodeCodepoint(record.codes.upper));
    const lowerChar = String.fromCodePoint(parseUnicodeCodepoint(record.codes.lower));

    // Parse decomposed forms
    const upperDecomposed = record.decomposed.upper.map((cp) => String.fromCodePoint(parseUnicodeCodepoint(cp)));
    const lowerDecomposed = record.decomposed.lower.map((cp) => String.fromCodePoint(parseUnicodeCodepoint(cp)));

    // Add both upper and lower mappings
    result.push([upperChar, upperDecomposed]);
    result.push([lowerChar, lowerDecomposed]);
  });
  return result;
};
