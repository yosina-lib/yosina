import { makeTransliterator } from "./dist/esm/index.js";

const translit = await makeTransliterator({
  replaceSuspiciousHyphensToProlongedSoundMarks: true,
});

console.log(translit("東京都渋谷区東１－４－２３"))
