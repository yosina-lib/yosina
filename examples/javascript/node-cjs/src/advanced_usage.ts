import type {
  TransliterationRecipe,
  TransliteratorConfig,
} from "@yosina-lib/yosina";
import { makeTransliterator } from "@yosina-lib/yosina";

const processTextSamples = (samples: [string, string][]) => {
  console.log("Processing text samples with character codes:");
  for (const [text, description] of samples) {
    console.log(`\n${description}:`);
    console.log(`  Original: '${text}'`);

    // Show character codes for clarity
    const charCodes = text
      .split("")
      .map(
        (c) =>
          `U+${c.codePointAt(0)?.toString(16).toUpperCase().padStart(4, "0")}`,
      )
      .join(" ");
    console.log(`  Codes:    ${charCodes}`);
  }
};

const main = async () => {
  console.log("=== Advanced Yosina JavaScript Usage Examples ===\n");

  // 1. Web scraping text normalization
  {
    console.log("1. Web Scraping Text Normalization");
    console.log("   (Typical use case: cleaning scraped Japanese web content)");

    const webScrapingRecipe: TransliterationRecipe = {
      kanjiOldNew: true,
      replaceSpaces: true,
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
      replaceIdeographicAnnotations: true,
      replaceRadicals: true,
      combineDecomposedHiraganasAndKatakanas: true,
    };

    const normalizer = await makeTransliterator(webScrapingRecipe);

    // Simulate messy web content
    const messyContent: [string, string][] = [
      [
        "これは　テスト です。",
        "Mixed spaces from different sources",
      ],
      ["コンピューター-プログラム", "Suspicious hyphens in katakana"],
      ["古い漢字：廣島、檜、國", "Old-style kanji forms"],
      ["部首：⺅⻌⽊", "CJK radicals instead of regular kanji"],
    ];

    for (const [text, description] of messyContent) {
      const cleaned = normalizer(text);
      console.log(`  ${description}:`);
      console.log(`    Before: '${text}'`);
      console.log(`    After:  '${cleaned}'`);
      console.log();
    }
  }

  // 2. Document standardization
  {
    console.log("2. Document Standardization");
    console.log("   (Use case: preparing documents for consistent formatting)");

    const documentRecipe: TransliterationRecipe = {
      toFullwidth: true,
      replaceSpaces: true,
      kanjiOldNew: true,
      combineDecomposedHiraganasAndKatakanas: true,
    };

    const documentStandardizer = await makeTransliterator(documentRecipe);

    const documentSamples: [string, string][] = [
      ["Hello World 123", "ASCII text to full-width"],
      ["カ゛", "Decomposed katakana with combining mark"],
      ["檜原村", "Old kanji in place names"],
    ];

    for (const [text, description] of documentSamples) {
      const standardized = documentStandardizer(text);
      console.log(`  ${description}:`);
      console.log(`    Input:  '${text}'`);
      console.log(`    Output: '${standardized}'`);
      console.log();
    }
  }

  // 3. Search index preparation
  {
    console.log("3. Search Index Preparation");
    console.log("   (Use case: normalizing text for search engines)");

    const searchRecipe: TransliterationRecipe = {
      kanjiOldNew: true,
      replaceSpaces: true,
      toHalfwidth: true,
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
    };

    const searchNormalizer = await makeTransliterator(searchRecipe);

    const searchSamples: [string, string][] = [
      ["東京スカイツリー", "Famous landmark name"],
      ["プログラミング言語", "Technical terms"],
      ["コンピューター-サイエンス", "Academic field with suspicious hyphen"],
    ];

    for (const [text, description] of searchSamples) {
      const normalized = searchNormalizer(text);
      console.log(`  ${description}:`);
      console.log(`    Original:   '${text}'`);
      console.log(`    Normalized: '${normalized}'`);
      console.log();
    }
  }

  // 4. Custom pipeline example
  {
    console.log("4. Custom Processing Pipeline");
    console.log("   (Use case: step-by-step text transformation)");

    // Create multiple transliterators for pipeline processing
    const steps: [string, TransliteratorConfig[]][] = [
      ["Spaces", [["spaces", {}]]],
      [
        "Old Kanji",
        [
          ["ivs-svs-base", { mode: "ivs-or-svs", charset: "unijis_2004" }],
          ["kanji-old-new", {}],
          ["ivs-svs-base", { mode: "base", charset: "unijis_2004" }],
        ],
      ],
      ["Width", [["jisx0201-and-alike", { u005cAsYenSign: false }]]],
      ["ProlongedSoundMarks", [["prolonged-sound-marks", {}]]],
    ];

    const transliterators: [string, (text: string) => string][] = [];
    for (const [name, config] of steps) {
      const transliterator = await makeTransliterator(config);
      transliterators.push([name, transliterator]);
    }

    const pipelineText = "hello\u{3000}world ﾃｽﾄ 檜-システム";
    let currentText = pipelineText;

    console.log(`  Starting text: '${currentText}'`);

    for (const [stepName, transliterator] of transliterators) {
      const previousText = currentText;
      currentText = transliterator(currentText);
      if (previousText !== currentText) {
        console.log(`  After ${stepName}: '${currentText}'`);
      }
    }

    console.log(`  Final result: '${currentText}'`);
  }

  // 5. Unicode normalization showcase
  {
    console.log("5. Unicode Normalization Showcase");
    console.log("   (Demonstrating various Unicode edge cases)");

    const unicodeRecipe: TransliterationRecipe = {
      replaceSpaces: true,
      replaceMathematicalAlphanumerics: true,
      replaceRadicals: true,
    };

    const unicodeNormalizer = await makeTransliterator(unicodeRecipe);

    const unicodeSamples: [string, string][] = [
      ["\u{2003}\u{2002}\u{2000}", "Various em/en spaces"],
      ["\u{3000}\u{00A0}\u{202F}", "Ideographic and narrow spaces"],
      ["⺅⻌⽊", "CJK radicals"],
      ["\u{1D400}\u{1D401}\u{1D402}", "Mathematical bold letters"],
    ];

    processTextSamples(unicodeSamples);

    for (const [text, description] of unicodeSamples) {
      const normalized = unicodeNormalizer(text);
      console.log(`  Result:   '${normalized}'`);
      console.log();
    }
  }

  // 6. Performance considerations
  {
    console.log("6. Performance Considerations");
    console.log("   (Reusing transliterators for better performance)");

    const perfRecipe: TransliterationRecipe = {
      kanjiOldNew: true,
      replaceSpaces: true,
    };

    const perfTransliterator = await makeTransliterator(perfRecipe);

    // Simulate processing multiple texts
    const texts = [
      "これはテストです",
      "檜原村は美しい",
      "hello　world",
      "プログラミング",
    ];

    console.log(
      `  Processing ${texts.length} texts with the same transliterator:`,
    );
    for (let i = 0; i < texts.length; i++) {
      const text = texts[i];
      const result = perfTransliterator(text);
      console.log(`    ${i + 1}: '${text}' → '${result}'`);
    }
  }

  console.log("\n=== Advanced Examples Complete ===");
};

main().catch(console.error);
