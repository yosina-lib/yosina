<?php

declare(strict_types=1);

/**
 * Basic usage example for Yosina PHP library.
 * This example demonstrates the fundamental transliteration functionality
 * as shown in the README documentation.
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Yosina\TransliteratorRecipe;
use Yosina\Yosina;

function main(): void
{
    echo "=== Yosina PHP Basic Usage Example ===\n\n";

    // Create a recipe with desired transformations (matching README example)
    $recipe = new TransliteratorRecipe(
        replaceSpaces: true,
        replaceCircledOrSquaredCharacters: true,
        replaceCombinedCharacters: true,
        kanjiOldNew: true,
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
    
    // Additional examples to demonstrate individual transformations
    echo "\n--- Individual Transformation Examples ---\n";
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    main();
}