<?php

declare(strict_types=1);

/**
 * Basic usage example for Yosina PHP library.
 * This example demonstrates the fundamental transliteration functionality
 * as shown in the README documentation.
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Yosina\TransliterationRecipe;
use Yosina\Yosina;

function main(): void
{
    echo "=== Yosina PHP Basic Usage Example ===\n\n";

    // Create a recipe with desired transformations (matching README example)
    $recipe = new TransliterationRecipe(
        kanjiOldNew: true,
        replaceSpaces: true,
        replaceSuspiciousHyphensToProlongedSoundMarks: true,
        replaceCircledOrSquaredCharacters: true,
        replaceCombinedCharacters: true,
        replaceJapaneseIterationMarks: true, // Expand iteration marks
        toFullwidth: true
    );
    
    // Create the transliterator
    $transliterator = Yosina::makeTransliterator($recipe);
    
    // Use it with various special characters (matching README example)
    $input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿";  // circled numbers, letters, space, combined characters
    $result = $transliterator($input);
    
    echo "Input:  {$input}\n";
    echo "Output: {$result}\n";
    echo "Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和\n";
    
    // Convert old kanji to new
    echo "\n--- Old Kanji to New ---\n";
    $oldKanji = "舊字體";
    $result = $transliterator($oldKanji);
    echo "Input:  {$oldKanji}\n";
    echo "Output: {$result}\n";
    echo "Expected: 旧字体\n";
    
    // Convert half-width katakana to full-width
    echo "\n--- Half-width to Full-width ---\n";
    $halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
    $result = $transliterator($halfWidth);
    echo "Input:  {$halfWidth}\n";
    echo "Output: {$result}\n";
    echo "Expected: テストモジレツ\n";
    
    // Demonstrate Japanese iteration marks expansion
    echo "\n--- Japanese Iteration Marks Examples ---\n";
    $iterationExamples = [
        "佐々木", // kanji iteration
        "すゝき", // hiragana iteration
        "いすゞ", // hiragana voiced iteration
        "サヽキ", // katakana iteration
        "ミスヾ"  // katakana voiced iteration
    ];
    
    foreach ($iterationExamples as $text) {
        $result = $transliterator($text);
        echo "{$text} → {$result}\n";
    }
    
    // Demonstrate hiragana to katakana conversion separately
    echo "\n--- Hiragana to Katakana Conversion ---\n";
    // Create a separate recipe for just hiragana to katakana conversion
    $hiraKataRecipe = new TransliterationRecipe(
        hiraKata: "hira-to-kata" // Convert hiragana to katakana
    );
    
    $hiraKataTransliterator = Yosina::makeTransliterator($hiraKataRecipe);
    
    $hiraKataExamples = [
        "ひらがな", // pure hiragana
        "これはひらがなです", // hiragana sentence
        "ひらがなとカタカナ" // mixed hiragana and katakana
    ];
    
    foreach ($hiraKataExamples as $text) {
        $result = $hiraKataTransliterator($text);
        echo "{$text} → {$result}\n";
    }
    
    // Also demonstrate katakana to hiragana conversion
    echo "\n--- Katakana to Hiragana Conversion ---\n";
    $kataHiraRecipe = new TransliterationRecipe(
        hiraKata: "kata-to-hira" // Convert katakana to hiragana
    );
    
    $kataHiraTransliterator = Yosina::makeTransliterator($kataHiraRecipe);
    
    $kataHiraExamples = [
        "カタカナ", // pure katakana
        "コレハカタカナデス", // katakana sentence
        "カタカナとひらがな" // mixed katakana and hiragana
    ];
    
    foreach ($kataHiraExamples as $text) {
        $result = $kataHiraTransliterator($text);
        echo "{$text} → {$result}\n";
    }
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    main();
}