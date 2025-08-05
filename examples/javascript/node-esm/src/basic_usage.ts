import { makeTransliterator, TransliterationRecipe } from "@yosina-lib/yosina";

async function main() {
  console.log("=== Yosina JavaScript Basic Usage Example ===\n");

  // Create a recipe with desired transformations (matching README example)
  const recipe: TransliterationRecipe = {
    kanjiOldNew: true,
    replaceSpaces: true,
    replaceSuspiciousHyphensToProlongedSoundMarks: true,
    replaceCircledOrSquaredCharacters: true,
    replaceCombinedCharacters: true,
    replaceJapaneseIterationMarks: true, // Expand iteration marks
    toFullwidth: true,
  };
  
  // Create the transliterator
  const transliterator = await makeTransliterator(recipe);
  
  // Use it with various special characters (matching README example)
  const input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
  const result = transliterator(input);
  
  console.log(`Input:  ${input}`);
  console.log(`Output: ${result}`);
  console.log("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和");
  
  // Convert old kanji to new
  console.log("\n--- Old Kanji to New ---");
  const oldKanji = "舊字體";
  const kanjiResult = transliterator(oldKanji);
  console.log(`Input:  ${oldKanji}`);
  console.log(`Output: ${kanjiResult}`);
  console.log("Expected: 旧字体");
  
  // Convert half-width katakana to full-width
  console.log("\n--- Half-width to Full-width ---");
  const halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
  const fullWidthResult = transliterator(halfWidth);
  console.log(`Input:  ${halfWidth}`);
  console.log(`Output: ${fullWidthResult}`);
  console.log("Expected: テストモジレツ");
  
  // Demonstrate Japanese iteration marks expansion
  console.log("\n--- Japanese Iteration Marks Examples ---");
  const iterationExamples = [
    "佐々木", // kanji iteration
    "すゝき", // hiragana iteration
    "いすゞ", // hiragana voiced iteration
    "サヽキ", // katakana iteration  
    "ミスヾ"  // katakana voiced iteration
  ];
  
  iterationExamples.forEach(text => {
    const result = transliterator(text);
    console.log(`${text} → ${result}`);
  });
  
  // Demonstrate hiragana to katakana conversion separately
  console.log("\n--- Hiragana to Katakana Conversion ---");
  // Create a separate recipe for just hiragana to katakana conversion
  const hiraKataRecipe: TransliterationRecipe = {
    hiraKata: "hira-to-kata", // Convert hiragana to katakana
  };
  
  const hiraKataTransliterator = await makeTransliterator(hiraKataRecipe);
  
  const hiraKataExamples = [
    "ひらがな", // pure hiragana
    "これはひらがなです", // hiragana sentence
    "ひらがなとカタカナ", // mixed hiragana and katakana
  ];
  
  hiraKataExamples.forEach(text => {
    const result = hiraKataTransliterator(text);
    console.log(`${text} → ${result}`);
  });
  
  // Also demonstrate katakana to hiragana conversion
  console.log("\n--- Katakana to Hiragana Conversion ---");
  const kataHiraRecipe: TransliterationRecipe = {
    hiraKata: "kata-to-hira", // Convert katakana to hiragana
  };
  
  const kataHiraTransliterator = await makeTransliterator(kataHiraRecipe);
  
  const kataHiraExamples = [
    "カタカナ", // pure katakana
    "コレハカタカナデス", // katakana sentence
    "カタカナとひらがな", // mixed katakana and hiragana
  ];
  
  kataHiraExamples.forEach(text => {
    const result = kataHiraTransliterator(text);
    console.log(`${text} → ${result}`);
  });
}

main().catch(console.error);
