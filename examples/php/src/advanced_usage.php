<?php

declare(strict_types=1);

/**
 * Advanced usage example for Yosina PHP library.
 * This example demonstrates complex text processing scenarios.
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Yosina\TransliterationRecipe;
use Yosina\Yosina;

function main(): void
{
    echo "=== Advanced Yosina PHP Usage Examples ===\n\n";

    // 1. Web scraping text normalization
    echo "1. Web Scraping Text Normalization\n";
    echo "   (Typical use case: cleaning scraped Japanese web content)\n";

    $webScrapingRecipe = new TransliterationRecipe(
        kanjiOldNew: true,
        replaceSpaces: true,
        replaceSuspiciousHyphensToProlongedSoundMarks: true,
        replaceIdeographicAnnotations: true,
        replaceRadicals: true,
        combineDecomposedHiraganasAndKatakanas: true,
    );

    $normalizer = Yosina::makeTransliterator($webScrapingRecipe);

    // Simulate messy web content
    $messyContent = [
        ["これは　テスト です。", "Mixed spaces from different sources"],
        ["コンピューター-プログラム", "Suspicious hyphens in katakana"],
        ["古い漢字：廣島、檜、國", "Old-style kanji forms"],
        ["部首：⺅⻌⽊", "CJK radicals instead of regular kanji"],
    ];

    foreach ($messyContent as [$text, $description]) {
        $cleaned = $normalizer($text);
        echo "  {$description}:\n";
        echo "    Before: '{$text}'\n";
        echo "    After:  '{$cleaned}'\n";
        echo "\n";
    }

    // 2. Document standardization
    echo "2. Document Standardization\n";
    echo "   (Use case: preparing documents for consistent formatting)\n";

    $documentRecipe = new TransliterationRecipe(
        toFullwidth: true,
        replaceSpaces: true,
        kanjiOldNew: true,
        combineDecomposedHiraganasAndKatakanas: true,
    );

    $normalizer = Yosina::makeTransliterator($documentRecipe);

    $documentSamples = [
        ["Hello World 123", "ASCII text to full-width"],
        ["カ゛", "Decomposed katakana with combining mark"],
        ["檜原村", "Old kanji in place names"],
    ];

    foreach ($documentSamples as [$text, $description]) {
        $standardized = $normalizer($text);
        echo "  {$description}:\n";
        echo "    Input:  '{$text}'\n";
        echo "    Output: '{$standardized}'\n";
        echo "\n";
    }

    // 3. Search index preparation
    echo "3. Search Index Preparation\n";
    echo "   (Use case: normalizing text for search engines)\n";

    $searchRecipe = new TransliterationRecipe(
        kanjiOldNew: true,
        replaceSpaces: true,
        toHalfwidth: true,
        replaceSuspiciousHyphensToProlongedSoundMarks: true,
    );

    $normalizer = Yosina::makeTransliterator($searchRecipe);

    $searchSamples = [
        ["東京スカイツリー", "Famous landmark name"],
        ["プログラミング言語", "Technical terms"],
        ["コンピューター-サイエンス", "Academic field with suspicious hyphen"],
    ];

    foreach ($searchSamples as [$text, $description]) {
        $normalized = $normalizer($text);
        echo "  {$description}:\n";
        echo "    Original:   '{$text}'\n";
        echo "    Normalized: '{$normalized}'\n";
        echo "\n";
    }

    // 4. Custom pipeline example
    echo "4. Custom Processing Pipeline\n";
    echo "   (Use case: step-by-step text transformation)\n";

    // Create multiple transliterators for pipeline processing
    $steps = [
        ["Spaces", [["spaces", []]]],
        [
            "Old Kanji",
            [
                ["ivs-svs-base", ["mode" => "ivs-or-svs", "charset" => "unijis_2004"]],
                ["kanji-old-new", []],
                ["ivs-svs-base", ["mode" => "base", "charset" => "unijis_2004"]],
            ],
        ],
        [
            "Width",
            [
                ["jisx0201-and-alike", ["u005c_as_yen_sign" => false]],
            ],
        ],
        [
            "ProlongedSoundMarks",
            [
                ["prolonged-sound-marks", []],
            ],
        ],
    ];

    $transliterators = array_map(
        fn($step) => [$step[0], Yosina::makeTransliterator($step[1])],
        $steps
    );

    $pipelineText = "hello\u{3000}world ﾃｽﾄ 檜-システム";
    $currentText = $pipelineText;

    echo "  Starting text: '{$currentText}'\n";

    foreach ($transliterators as [$stepName, $transliterator]) {
        $previousText = $currentText;
        $currentText = $transliterator($currentText);
        if ($previousText !== $currentText) {
            echo "  After {$stepName}: '{$currentText}'\n";
        }
    }

    echo "  Final result: '{$currentText}'\n";

    // 5. Unicode normalization showcase
    echo "\n5. Unicode Normalization Showcase\n";
    echo "   (Demonstrating various Unicode edge cases)\n";

    $unicodeRecipe = new TransliterationRecipe(
        replaceSpaces: true,
        replaceMathematicalAlphanumerics: true,
        replaceRadicals: true,
    );

    $normalizer = Yosina::makeTransliterator($unicodeRecipe);

    $unicodeSamples = [
        ["\u{2003}\u{2002}\u{2000}", "Various em/en spaces"],
        ["\u{3000}\u{00a0}\u{202f}", "Ideographic and narrow spaces"],
        ["⺅⻌⽊", "CJK radicals"],
        ["\u{1d400}\u{1d401}\u{1d402}", "Mathematical bold letters"],
    ];

    echo "\n   Processing text samples with character codes:\n";
    foreach ($unicodeSamples as [$text, $description]) {
        echo "   {$description}:\n";
        echo "     Original: '{$text}'\n";

        // Show character codes for clarity
        $charCodes = implode(' ', array_map(
            fn($char) => sprintf('U+%04X', mb_ord($char, 'UTF-8')),
            mb_str_split($text, 1, 'UTF-8')
        ));
        $transliterated = ($normalizer)($text);
        echo "     Codes:    {$charCodes}\n";
        echo "     Result:   '{$transliterated}'\n\n";
    }

    // 6. Performance considerations
    echo "6. Performance Considerations\n";
    echo "   (Reusing transliterators for better performance)\n";

    $perfRecipe = new TransliterationRecipe(
        kanjiOldNew: true,
        replaceSpaces: true,
    );

    $perfTransliterator = Yosina::makeTransliterator($perfRecipe);

    // Simulate processing multiple texts
    $texts = [
        "これはテストです",
        "檜原村は美しい",
        "hello　world",
        "プログラミング",
    ];

    echo "  Processing " . count($texts) . " texts with the same transliterator:\n";
    $i = 1;
    foreach ($texts as $text) {
        $result = $perfTransliterator($text);
        echo "    {$i}: '{$text}' → '{$result}'\n";
        $i++;
    }

    echo "\n=== Advanced Examples Complete ===\n";
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    main();
}