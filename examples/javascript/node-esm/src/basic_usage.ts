import { makeTransliterator, TransliteratorRecipe } from "@yosina-lib/yosina";

async function main() {
  console.log("=== Yosina JavaScript Basic Usage Example ===\n");

  // Create a recipe with desired transformations (matching README example)
  const recipe: TransliteratorRecipe = {
    kanjiOldNew: true,
    replaceSpaces: true,
    replaceSuspiciousHyphensToProlongedSoundMarks: true,
    replaceCircledOrSquaredCharacters: true,
    replaceCombinedCharacters: true,
    toFullwidth: true,
  };
  
  // Create the transliterator
  const transliterator = await makeTransliterator(recipe);
  
  // Use it with various special characters (matching README example)
  const input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
  const result = transliterator(input);
  
  console.log("Input: ", input);
  console.log("Output:", result);
  console.log("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和");
  
  // Convert old kanji to new
  console.log("\n--- Old Kanji to New ---");
  const oldKanji = "舊字體";
  const kanjiResult = transliterator(oldKanji);
  console.log("Input: ", oldKanji);
  console.log("Output:", kanjiResult);
  console.log("Expected: 旧字体");
  
  // Convert half-width katakana to full-width
  console.log("\n--- Half-width to Full-width ---");
  const halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
  const fullWidthResult = transliterator(halfWidth);
  console.log("Input: ", halfWidth);
  console.log("Output:", fullWidthResult);
  console.log("Expected: テストモジレツ");
}

main().catch(console.error);
