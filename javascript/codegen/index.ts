import * as fs from "node:fs/promises";
import * as path from "node:path";
import { default as ts } from "typescript";
import { buildDatasetSourceFromDataRoot } from "./dataset";
import {
  renderCircledOrSquaredTransliterator,
  renderHyphensTransliterator,
  renderIVSSVSVBaseTransliterator,
  renderMultiCharsTransliterator,
  renderSimpleTransliterator,
} from "./emitters";

const parseTSProgram = async (sourceFileName: string, filter?: (script: string) => string) => {
  const script = (filter != null ? filter : (_: string) => _)(await fs.readFile(sourceFileName, "utf-8"));
  return ts.createSourceFile(sourceFileName, script, ts.ScriptTarget.ESNext);
};

const renderTSProgram = (source: ts.SourceFile) =>
  ts.createPrinter({ newLine: ts.NewLineKind.LineFeed }).printFile(source);

type SimpleTransliteratorName =
  | "spaces"
  | "radicals"
  | "mathematicalAlphanumerics"
  | "ideographicAnnotations"
  | "kanjiOldNew";

type TransliteratorTemplates = {
  [key in
    | SimpleTransliteratorName
    | "spaces"
    | "hyphens"
    | "ivsSVSBase"
    | "combined"
    | "circledOrSquared"
    | "romanNumerals"]: ts.SourceFile;
};

type TransliteratorDescriptions = { moduleDescription: string; functionDescription: string };

const readTemplates = async (
  baseDir: string,
  simpleTemplateDescriptions: Record<SimpleTransliteratorName, TransliteratorDescriptions>,
): Promise<TransliteratorTemplates> => {
  const simpleTransliteratorPath = path.join(baseDir, "simple.ts");
  const resultPromises = Object.entries({
    ...Object.fromEntries(
      (Object.entries(simpleTemplateDescriptions) as [SimpleTransliteratorName, TransliteratorDescriptions][]).map(
        ([name, descriptions]) => {
          return [
            name,
            parseTSProgram(simpleTransliteratorPath, (script) =>
              script.replace(/^( \* )\{\{(moduleDescription|functionDescription)\}\}/gm, (_, p, k) =>
                descriptions[k as keyof TransliteratorDescriptions]
                  .split(/\n/)
                  .map((l) => `${p}${l}`)
                  .join("\n"),
              ),
            ),
          ];
        },
      ),
    ),
    hyphens: parseTSProgram(path.join(baseDir, "hyphens.ts")),
    ivsSVSBase: parseTSProgram(path.join(baseDir, "ivs-svs-base.ts")),
    combined: parseTSProgram(path.join(baseDir, "multi-chars.ts"), (script) =>
      script.replace(
        /^( \* )\{\{moduleDescription\}\}/gm,
        (_, p) =>
          `${p}This module implements a transliterator that replaces each combined character with its corresponding characters.`,
      ),
    ),
    circledOrSquared: parseTSProgram(path.join(baseDir, "circled-or-squared.ts")),
    romanNumerals: parseTSProgram(path.join(baseDir, "multi-chars.ts")),
  });
  const results = await Promise.all(resultPromises.map((pair) => pair[1]));
  return Object.fromEntries(resultPromises.map((pair, i) => [pair[0], results[i]])) as TransliteratorTemplates;
};

declare const __dirname: string | undefined;
const dirname = (__dirname ?? import.meta.dirname) as string;

const dataRoot = path.join(path.dirname(path.dirname(dirname)), "data");

const destRoot = path.join(path.dirname(dirname), "src/transliterators");

const templateDir = path.join(dirname, "_templates");

(async () => {
  const dataset = await buildDatasetSourceFromDataRoot(dataRoot, {
    spaces: "spaces.json",
    radicals: "radicals.json",
    mathematicalAlphanumerics: "mathematical-alphanumerics.json",
    ideographicAnnotations: "ideographic-annotation-marks.json",
    hyphens: "hyphens.json",
    ivsSVSBase: "ivs-svs-base-mappings.json",
    kanjiOldNew: "kanji-old-new-form.json",
    combined: "combined-chars.json",
    circledOrSquared: "circled-or-squared.json",
    romanNumerals: "roman-numerals.json",
  });

  const templates = await readTemplates(templateDir, {
    spaces: {
      moduleDescription: "This module implements a transliterator that replaces spaces with U+0020.",
      functionDescription: "Replaces spaces with U+0020.",
    },
    radicals: {
      moduleDescription:
        "This module imlements a transliterator that replaces radicals with their corresponding characters.",
      functionDescription: "Replaces radicals with their corresponding characters.",
    },
    mathematicalAlphanumerics: {
      moduleDescription:
        "This module implements a transliterator that replaces mathematical decorated alnums with their corresponding characters.",
      functionDescription: "Replaces mathematical decorated alnums with their corresponding characters.",
    },
    ideographicAnnotations: {
      moduleDescription:
        "This module implements a transliterator that replaces ideographic annotation marks with their corresponding characters.",
      functionDescription: "Replaces ideographic annotation marks with their corresponding characters.",
    },
    kanjiOldNew: {
      moduleDescription:
        "This module implements a transliterator that replaces old forms of kanji with their new forms.",
      functionDescription: "Replace old forms of kanji with their new forms.",
    },
  });

  await Promise.all([
    ...(
      ["spaces", "radicals", "mathematicalAlphanumerics", "ideographicAnnotations"] satisfies (keyof typeof dataset)[]
    ).map((kind) =>
      fs.writeFile(
        path.join(destRoot, `${kind.replace(/[A-Z]/g, (m) => `-${m[0].toLowerCase()}`)}.ts`),
        renderTSProgram(renderSimpleTransliterator(templates[kind], dataset[kind])),
      ),
    ),
    fs.writeFile(
      path.join(destRoot, "hyphens.ts"),
      renderTSProgram(renderHyphensTransliterator(templates.hyphens, dataset.hyphens)),
    ),
    fs.writeFile(
      path.join(destRoot, "ivs-svs-base.ts"),
      renderTSProgram(renderIVSSVSVBaseTransliterator(templates.ivsSVSBase, dataset.ivsSVSBase)),
    ),
    fs.writeFile(
      path.join(destRoot, "kanji-old-new.ts"),
      renderTSProgram(renderSimpleTransliterator(templates.kanjiOldNew, dataset.kanjiOldNew)),
    ),
    fs.writeFile(
      path.join(destRoot, "combined.ts"),
      renderTSProgram(renderMultiCharsTransliterator(templates.combined, dataset.combined)),
    ),
    fs.writeFile(
      path.join(destRoot, "circled-or-squared.ts"),
      renderTSProgram(renderCircledOrSquaredTransliterator(templates.circledOrSquared, dataset.circledOrSquared)),
    ),
    fs.writeFile(
      path.join(destRoot, "roman-numerals.ts"),
      renderTSProgram(renderMultiCharsTransliterator(templates.romanNumerals, dataset.romanNumerals)),
    ),
  ]);
})();
