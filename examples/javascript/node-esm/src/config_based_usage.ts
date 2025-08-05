import { makeTransliterator, TransliteratorConfig } from "@yosina-lib/yosina";

async function main() {
  console.log("=== Yosina JavaScript Configuration-based Usage Example ===\n");

  // Create transliterator with direct configurations
  const configs: TransliteratorConfig[] = [
    ["spaces", {}],
    [
      "prolonged-sound-marks",
      {
        replaceProlongedMarksFollowingAlnums: true,
      },
    ],
    ["jisx0201-and-alike", {}],
  ];

  const transliterator = await makeTransliterator(configs);

  console.log("--- Configuration-based Transliteration ---");

  // Test cases demonstrating different transformations
  const testCases: [string, string][] = [
    ["hello　world", "Space normalization"],
    ["カタカナーテスト", "Prolonged sound mark handling"],
    ["ＡＢＣ１２３", "Full-width conversion"],
    ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"],
  ];

  for (const [testText, description] of testCases) {
    const result = transliterator(testText);
    console.log(`${description}:`);
    console.log(`  Input:  '${testText}'`);
    console.log(`  Output: '${result}'`);
    console.log();
  }

  // Demonstrate individual transliterators
  console.log("--- Individual Transliterator Examples ---");

  // Spaces only
  const spacesConfig: TransliteratorConfig[] = [["spaces", {}]];
  const spacesOnly = await makeTransliterator(spacesConfig);
  const spaceTest = "hello　world　test"; // ideographic spaces
  console.log(`Spaces only: '${spaceTest}' → '${spacesOnly(spaceTest)}'`);

  // Kanji old-new only
  const kanjiConfig: TransliteratorConfig[] = [
    ["ivs-svs-base", { mode: "ivs-or-svs", charset: "unijis_2004" }],
    ["kanji-old-new", {}],
    ["ivs-svs-base", { mode: "base", charset: "unijis_2004" }],
  ];
  const kanjiOnly = await makeTransliterator(kanjiConfig);
  const kanjiTest = "廣島檜";
  console.log(`Kanji only: '${kanjiTest}' → '${kanjiOnly(kanjiTest)}'`);

  // JIS X 0201 conversion only
  const jisx0201Config: TransliteratorConfig[] = [["jisx0201-and-alike", { fullwidthToHalfwidth: false }]];
  const jisx0201Only = await makeTransliterator(jisx0201Config);
  const jisxTest = "ﾊﾛｰ ﾜｰﾙﾄﾞ";
  console.log(`JIS X 0201 only: '${jisxTest}' → '${jisx0201Only(jisxTest)}'`);
}

main().catch(console.error);
