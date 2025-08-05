import { buildCharArray, fromChars } from "./chars.js";
import { makeChainedTransliterator } from "./intrinsics.js";
import type { TransliterationRecipe } from "./recipes.js";
import { buildTransliteratorConfigsFromRecipe } from "./recipes.js";
import type { TransliteratorConfig } from "./transliterators/index.js";

export { buildCharArray, fromChars } from "./chars.js";
export { makeChainedTransliterator } from "./intrinsics.js";
export type { TransliterationRecipe } from "./recipes.js";
export { buildTransliteratorConfigsFromRecipe } from "./recipes.js";
export type { TransliteratorConfig } from "./transliterators/index.js";

/**
 * Frontend convenience function to create a string-to-string transliterator from a recipe or a list of configs.
 *
 * ```typescript
 * export const makeTransliterator = async (configsOrRecipe: (TransliteratorConfig | string)[] | TransliterationRecipe) => {
 *   const tl = await makeChainedTransliterator(
 *     Array.isArray(configsOrRecipe) ? configsOrRecipe : buildTransliteratorConfigsFromRecipe(configsOrRecipe),
 *   );
 *   return (in_: string) => {
 *     return fromChars(tl(buildCharArray(in_)));
 *   };
 * };
 * ```
 *
 * The low-level functions used here are:
 *
 * - {@link makeChainedTransliterator}
 * - {@link fromChars}
 * - {@link buildCharArray}
 * - {@link buildTransliteratorConfigsFromRecipe}
 *
 * Please refer to the description of {@link buildTransliteratorConfigsFromRecipe} for the preferences that can be specified in a recipe. Also,
 * refer to the description of {@link makeChainedTransliterator} and {@link TransliteratorConfig} for the details of the configuration objects.
 *
 * @param configsOrRecipe A recipe or a list of `TransliteratorConfig`s.
 * @returns A transliterator function that takes a string and returns a string.
 */
export const makeTransliterator = async (
  configsOrRecipe: (TransliteratorConfig | string)[] | TransliterationRecipe,
) => {
  const tl = await makeChainedTransliterator(
    Array.isArray(configsOrRecipe) ? configsOrRecipe : buildTransliteratorConfigsFromRecipe(configsOrRecipe),
  );
  return (in_: string) => {
    return fromChars(tl(buildCharArray(in_)));
  };
};
