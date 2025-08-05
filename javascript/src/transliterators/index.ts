import type { TransliteratorFactory } from "../types.js";
import type { default as CircledOrSquaredTF } from "./circled-or-squared.js";
import type { default as CombinedCharsTF } from "./combined.js";
import type { default as HiraKataTF } from "./hira-kata.js";
import type { default as HiraKataCompositionTF } from "./hira-kata-composition.js";
import type { default as HyphensTF } from "./hyphens.js";
import type { default as IdeographicAnnotationsTF } from "./ideographic-annotations.js";
import type { default as IVSSVSBaseTF } from "./ivs-svs-base.js";
import type { default as JapaneseIterationMarksTF } from "./japanese-iteration-marks.js";
import type { default as JISX0201AndAlikeTF } from "./jisx0201-and-alike.js";
import type { default as KanjiOldNewTF } from "./kanji-old-new.js";
import type { default as mathematicalAlphanumericsTF } from "./mathematical-alphanumerics.js";
import type { default as ProlongedSoundMarksTF } from "./prolonged-sound-marks.js";
import type { default as RadicalsTF } from "./radicals.js";
import type { default as SpacesTF } from "./spaces.js";

type TransliteratorModule = {
  default: TransliteratorFactory;
};

export type TransliteratorConfig =
  | ["hira-kata-composition", Parameters<typeof HiraKataCompositionTF>[0]]
  | ["hira-kata", Parameters<typeof HiraKataTF>[0]]
  | ["hyphens", Parameters<typeof HyphensTF>[0]]
  | ["ideographic-annotations", Parameters<typeof IdeographicAnnotationsTF>[0]]
  | ["japanese-iteration-marks", Parameters<typeof JapaneseIterationMarksTF>[0]]
  | ["ivs-svs-base", Parameters<typeof IVSSVSBaseTF>[0]]
  | ["jisx0201-and-alike", Parameters<typeof JISX0201AndAlikeTF>[0]]
  | ["kanji-old-new", Parameters<typeof KanjiOldNewTF>[0]]
  | ["mathematical-alphanumerics", Parameters<typeof mathematicalAlphanumericsTF>[0]]
  | ["prolonged-sound-marks", Parameters<typeof ProlongedSoundMarksTF>[0]]
  | ["radicals", Parameters<typeof RadicalsTF>[0]]
  | ["spaces", Parameters<typeof SpacesTF>[0]]
  | ["combined", Parameters<typeof CombinedCharsTF>[0]]
  | ["circled-or-squared", Parameters<typeof CircledOrSquaredTF>[0]];

export const supportedTransliterators = [
  "hira-kata-composition",
  "hira-kata",
  "hyphens",
  "ideographic-annotations",
  "japanese-iteration-marks",
  "ivs-svs-base",
  "jisx0201-and-alike",
  "kanji-old-new",
  "mathematical-alphanumerics",
  "prolonged-sound-marks",
  "radicals",
  "spaces",
  "combined",
  "circled-or-squared",
] as const;

const esInteropDynImportShim = <T extends { [key: string]: unknown }>(
  mod: { __esModule: boolean; default?: T } | T,
): { default?: T } =>
  mod.__esModule && (globalThis as { import?: { meta?: unknown } }).import?.meta !== undefined
    ? mod
    : { default: mod as T };

export type SupportedTransliterators = (typeof supportedTransliterators)[number];

export const getTransliteratorFactory = async (name: SupportedTransliterators): Promise<TransliteratorFactory> => {
  if (/[^0-9A-Za-z_-]/.test(name)) {
    throw new Error(`invalid transliterator name: ${name}`);
  }
  const f = esInteropDynImportShim<TransliteratorModule>(await import(`./${name}.js`))?.default?.default;
  if (f === undefined) {
    throw new Error("unexpected module structure");
  }
  return f;
};
