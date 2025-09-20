<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Replace roman numeral characters with their ASCII letter equivalents.
 */
class RomanNumeralsTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
        'Ⅰ' => ["I"],
        'ⅰ' => ["i"],
        'Ⅱ' => ["I", "I"],
        'ⅱ' => ["i", "i"],
        'Ⅲ' => ["I", "I", "I"],
        'ⅲ' => ["i", "i", "i"],
        'Ⅳ' => ["I", "V"],
        'ⅳ' => ["i", "v"],
        'Ⅴ' => ["V"],
        'ⅴ' => ["v"],
        'Ⅵ' => ["V", "I"],
        'ⅵ' => ["v", "i"],
        'Ⅶ' => ["V", "I", "I"],
        'ⅶ' => ["v", "i", "i"],
        'Ⅷ' => ["V", "I", "I", "I"],
        'ⅷ' => ["v", "i", "i", "i"],
        'Ⅸ' => ["I", "X"],
        'ⅸ' => ["i", "x"],
        'Ⅹ' => ["X"],
        'ⅹ' => ["x"],
        'Ⅺ' => ["X", "I"],
        'ⅺ' => ["x", "i"],
        'Ⅻ' => ["X", "I", "I"],
        'ⅻ' => ["x", "i", "i"],
        'Ⅼ' => ["L"],
        'ⅼ' => ["l"],
        'Ⅽ' => ["C"],
        'ⅽ' => ["c"],
        'Ⅾ' => ["D"],
        'ⅾ' => ["d"],
        'Ⅿ' => ["M"],
        'ⅿ' => ["m"],
    ];

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(/* @phpstan-ignore constructor.unusedParameter */ array $options = []) {}

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        foreach ($inputChars as $char) {
            $replacement = self::MAPPINGS[$char->c] ?? null;
            if ($replacement !== null && is_array($replacement)) {
                foreach ($replacement as $replacementChar) {
                    yield new Char($replacementChar, $offset, $char);
                    $offset += strlen($replacementChar);
                }
            } else {
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
            }
        }
    }
}
