import { makeTransliterator, TransliteratorRecipe } from "@yosina-lib/yosina";

async function main() {
  console.log("=== Yosina JavaScript Basic Usage Example ===\n");

  // Create a simple recipe for kanji old-to-new conversion
  const recipe: TransliteratorRecipe = {
    kanjiOldNew: true,
  };

  const transliterator = await makeTransliterator(recipe);

  // Test text with old-style kanji
  const testText = "舊字體の變換テスト";
  const result = transliterator(testText);

  console.log("Original:", testText);
  console.log("Result:  ", result);

  // More comprehensive example
  console.log("\n--- Comprehensive Example ---");

  const comprehensiveRecipe: TransliteratorRecipe = {
    kanjiOldNew: true,
    replaceSpaces: true,
    replaceSuspiciousHyphensToProlongedSoundMarks: true,
    toFullwidth: true,
    combineDecomposedHiraganasAndKatakanas: true,
    replaceRadicals: true,
    replaceCircledOrSquaredCharacters: true,
    replaceCombinedCharacters: true,
  };

  const comprehensiveTransliterator =
    await makeTransliterator(comprehensiveRecipe);

  // Test with various Japanese text issues
  const testCases: [string, string][] = [
    ["hello　world", "Ideographic space"],
    ["カタカナ-テスト", "Suspicious hyphen"],
    ["ABC123", "Half-width to full-width"],
    ["舊字體の變換テスト", "Old kanji"],
    ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana"],
    ["①②③ⒶⒷⒸ", "Circled characters"],
    ["㋿㍿", "CJK compatibility characters"],
  ];

  for (const [testCase, description] of testCases) {
    const result = comprehensiveTransliterator(testCase);
    console.log(`${description}: '${testCase}' → '${result}'`);
  }
}

main().catch(console.error);
