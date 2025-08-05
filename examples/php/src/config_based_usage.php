<?php

declare(strict_types=1);

/**
 * Configuration-based usage example for Yosina PHP library.
 * This example demonstrates using direct transliterator configurations.
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Yosina\Yosina;

function main(): void
{
    echo "=== Yosina PHP Configuration-based Usage Example ===\n\n";

    // Create transliterator with direct configurations
    $configs = [
        ["spaces", []],
        ["prolonged-sound-marks", ["replace_prolonged_marks_following_alnums" => true]],
        ["jisx0201-and-alike", []],
    ];

    $transliterator = Yosina::makeTransliterator($configs);

    echo "--- Configuration-based Transliteration ---\n";

    // Test cases demonstrating different transformations
    $testCases = [
        ["hello　world", "Space normalization"],
        ["カタカナーテスト", "Prolonged sound mark handling"],
        ["ＡＢＣ１２３", "Full-width conversion"],
        ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"],
    ];

    foreach ($testCases as [$testText, $description]) {
        $result = $transliterator($testText);
        echo "{$description}:\n";
        echo "  Input:  '{$testText}'\n";
        echo "  Output: '{$result}'\n";
        echo "\n";
    }

    // Demonstrate individual transliterators
    echo "--- Individual Transliterator Examples ---\n";

    // Spaces only
    $spacesOnly = Yosina::makeTransliterator([["spaces", []]]);
    $spaceTest = "hello　world　test";  // ideographic spaces
    echo "Spaces only: '{$spaceTest}' → '" . $spacesOnly($spaceTest) . "'\n";

    // Kanji old-new only
    $kanjiOnly = Yosina::makeTransliterator([
        ["ivs-svs-base", ["mode" => "ivs-or-svs", "charset" => "unijis_2004"]],
        ["kanji-old-new", []],
        ["ivs-svs-base", ["mode" => "base", "charset" => "unijis_2004"]],
    ]);
    $kanjiTest = "廣島檜";
    echo "Kanji only: '{$kanjiTest}' → '" . $kanjiOnly($kanjiTest) . "'\n";

    // JIS X 0201 conversion only
    $jisx0201Only = Yosina::makeTransliterator([
        ["jisx0201-and-alike", ['fullwidthToHalfwidth' => false]],
    ]);
    $jisxTest = "ﾊﾛｰ ﾜｰﾙﾄﾞ";
    echo "JIS X 0201 only: '{$jisxTest}' → '" . $jisx0201Only($jisxTest) . "'\n";
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    main();
}