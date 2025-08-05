<?php

declare(strict_types=1);

/**
 * Basic usage example for Yosina PHP library.
 * This example demonstrates the fundamental transliteration functionality.
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Yosina\TransliteratorRecipe;
use Yosina\Yosina;

function main(): void
{
    echo "=== Yosina PHP Basic Usage Example ===\n\n";

    // Create a simple recipe for kanji old-to-new conversion
    $recipe = new TransliteratorRecipe(kanjiOldNew: true);
    $transliterator = Yosina::makeTransliterator($recipe);

    // Test text with old-style kanji
    $testText = "舊字體の變換テスト";
    $result = $transliterator($testText);

    echo "Original: {$testText}\n";
    echo "Result:   {$result}\n";

    // More comprehensive example
    echo "\n--- Comprehensive Example ---\n";

    $comprehensiveRecipe = new TransliteratorRecipe(
        kanjiOldNew: true,
        replaceSpaces: true,
        replaceSuspiciousHyphensToProlongedSoundMarks: true,
        toFullwidth: true,
        combineDecomposedHiraganasAndKatakanas: true,
        replaceRadicals: true,
        replaceCircledOrSquaredCharacters: true,
        replaceCombinedCharacters: true,
    );

    $comprehensiveTransliterator = Yosina::makeTransliterator($comprehensiveRecipe);

    // Test with various Japanese text issues
    $testCases = [
        ["hello　world", "Ideographic space"],
        ["カタカナ-テスト", "Suspicious hyphen"],
        ["ABC123", "Half-width to full-width"],
        ["舊字體の變換テスト", "Old kanji"],
        ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana"],
        ["①②③ⒶⒷⒸ", "Circled characters"],
        ["㋿㍿", "CJK compatibility characters"],
    ];

    foreach ($testCases as [$testCase, $description]) {
        $result = $comprehensiveTransliterator($testCase);
        echo "{$description}: '{$testCase}' → '{$result}'\n";
    }
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    main();
}