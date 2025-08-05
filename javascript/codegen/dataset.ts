import * as path from "node:path";
import loaders from "./loaders";

export type HyphensRecord = {
  ascii: string | null;
  jisx0201: string | null;
  jisx0208_90: string | null;
  jisx0208_90_windows: string | null;
  jisx0208_verbatim: string | null;
};

export type IVSSVSBaseRecord = {
  ivs: string;
  svs: string | null;
  base90: string | null;
  base2004: string | null;
};

export type CircledOrSquaredRecord = {
  rendering: string[];
  type: "circle" | "square";
  emoji: boolean;
};

export type Dataset = {
  spaces: [string, string][];
  radicals: [string, string][];
  mathematicalAlphanumerics: [string, string][];
  ideographicAnnotations: [string, string][];
  hyphens: [string, HyphensRecord][];
  ivsSVSBase: IVSSVSBaseRecord[];
  kanjiOldNew: [string, string][];
  combined: [string, string[]][];
  circledOrSquared: [string, CircledOrSquaredRecord][];
};

export type DatasetSourceDefs = Record<keyof Dataset, string>;

export const buildDatasetSourceFromDataRoot = async (root: string, defs: DatasetSourceDefs) =>
  Object.fromEntries(
    await Promise.all(
      (Object.keys(loaders) as (keyof Dataset)[]).map((k) => loaders[k](path.join(root, defs[k])).then((r) => [k, r])),
    ),
  ) as Dataset;
