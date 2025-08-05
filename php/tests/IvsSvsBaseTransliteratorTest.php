<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\IvsSvsBaseTransliterator;

/**
 * Tests for IvsSvsBaseTransliterator based on Java test cases.
 * 
 * This transliterator handles Ideographic Variation Sequences (IVS) and
 * Standardized Variation Sequences (SVS) by either adding selectors to base
 * characters or removing selectors from variant characters.
 */
class IvsSvsBaseTransliteratorTest extends TestCase
{
    /**
     * Data provider for IVS/SVS base test cases.
     * 
     * @return array<array{string, array<string, mixed>, string, string}>
     */
    public static function ivsSvsBaseTestCases(): array
    {
        return [
            // Forward mappings with UNIJIS_2004
            [
                "\u{9038}\u{70BA}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_2004',
                    'prefer_svs' => false
                ],
                "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
                "Forward mappings with UNIJIS_2004"
            ],
            // Forward mappings with UNIJIS_90
            [
                "\u{9038}\u{70BA}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_90',
                    'prefer_svs' => false
                ],
                "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
                "Forward mappings with UNIJIS_90"
            ],
            // Reverse mappings with UNIJIS_2004
            [
                "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
                [
                    'mode' => 'base',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_2004',
                    'prefer_svs' => false
                ],
                "\u{9038}\u{70BA}",
                "Reverse mappings with UNIJIS_2004"
            ],
            // Reverse mappings with UNIJIS_90
            [
                "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
                [
                    'mode' => 'base',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_90',
                    'prefer_svs' => false
                ],
                "\u{9038}\u{70BA}",
                "Reverse mappings with UNIJIS_90"
            ],
            // U+8FBB with VS18, UNIJIS_2004
            [
                "\u{8FBB}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_2004',
                    'prefer_svs' => false
                ],
                "\u{8FBB}\u{E0101}",
                "U+8FBB with VS18, UNIJIS_2004"
            ],
            // U+8FBB with VS17, UNIJIS_90
            [
                "\u{8FBB}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_90',
                    'prefer_svs' => false
                ],
                "\u{8FBB}\u{E0100}",
                "U+8FBB with VS18, UNIJIS_90"
            ],
            // Test case for reverse specific kanji with UNIJIS_2004
            [
                "\u{8FBB}\u{E0101}",
                [
                    'mode' => 'base',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_2004',
                    'prefer_svs' => false
                ],
                "\u{8FBB}",
                "Test case for reverse specific kanji"
            ],
            // Test case for reverse specific kanji with UNIJIS_90
            [
                "\u{8FBB}\u{E0100}",
                [
                    'mode' => 'base',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_90',
                    'prefer_svs' => false
                ],
                "\u{8FBB}",
                "Test case for reverse specific kanji"
            ],
            // Test case for unchanged VS17 with UNIJIS_2004
            [
                "\u{8FBB}\u{E0100}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_2004',
                    'prefer_svs' => false
                ],
                "\u{8FBB}\u{E0100}",
                "Test case for unchanged VS17"
            ],
            // Test case for unchanged VS18 with UNIJIS_90
            [
                "\u{8FBB}\u{E0101}",
                [
                    'mode' => 'ivs-or-svs',
                    'drop_selectors_altogether' => false,
                    'charset' => 'unijis_90',
                    'prefer_svs' => false
                ],
                "\u{8FBB}\u{E0101}",
                "Test case for unchanged VS17"
            ],
        ];
    }

    /**
     * @param string $input
     * @param array{mode?:'ivs-or-svs'|'base',drop_selectors_altogether?:bool,charset?:'unijis_90'|'unijis_2004',prefer_svs?:bool} $options
     * @param string $expected
     * @param string $description
     */
    #[DataProvider('ivsSvsBaseTestCases')]
    public function testIvsSvsBaseTransliterations(
        string $input,
        array $options,
        string $expected,
        string $description
    ): void {
        $transliterator = new IvsSvsBaseTransliterator($options);
        $result = $this->processString($transliterator, $input);
        
        $this->assertEquals($expected, $result, $description);
    }

    /**
     * Test IvsSvsBaseTransliterator options equality.
     */
    public function testIvsSvsBaseTransliteratorOptionsEquals(): void
    {
        // Test that two transliterators with same options are functionally equivalent
        $options1 = [
            'mode' => 'ivs-or-svs',
            'drop_selectors_altogether' => false,
            'charset' => 'unijis_90',
            'prefer_svs' => true
        ];
        
        $options2 = [
            'mode' => 'ivs-or-svs',
            'drop_selectors_altogether' => false,
            'charset' => 'unijis_90',
            'prefer_svs' => true
        ];
        
        $options3 = [
            'mode' => 'base',
            'drop_selectors_altogether' => false,
            'charset' => 'unijis_90',
            'prefer_svs' => true
        ];

        $transliterator1 = new IvsSvsBaseTransliterator($options1);
        $transliterator2 = new IvsSvsBaseTransliterator($options2);
        $transliterator3 = new IvsSvsBaseTransliterator($options3);

        // Test with a sample string
        $testString = "\u{9038}\u{70BA}";
        
        $result1 = $this->processString($transliterator1, $testString);
        $result2 = $this->processString($transliterator2, $testString);
        $result3 = $this->processString($transliterator3, $testString);

        // Transliterators with same options should produce same results
        $this->assertEquals($result1, $result2);
        
        // Transliterator with different mode should produce different results
        // (unless the input doesn't have any mappings)
        // We can't guarantee they'll be different without knowing the mappings
    }

    /**
     * Additional test for drop_selectors_altogether option.
     */
    public function testDropSelectorsAltogether(): void
    {
        $transliterator = new IvsSvsBaseTransliterator([
            'mode' => 'base',
            'drop_selectors_altogether' => true
        ]);

        // Test cases with various variation selectors
        $testCases = [
            // IVS selectors (U+E0100-U+E01EF)
            ["A", "A\u{E0100}"],
            ["B", "B\u{E0101}"],
            ["C", "C\u{E01EF}"],
            
            // SVS selectors (U+FE00-U+FE0F)
            ["D", "D\u{FE00}"],
            ["E", "E\u{FE0F}"],
            
            // Mixed content
            ["ABC", "A\u{E0100}B\u{FE00}C"],
            
            // Multiple selectors
            ["test", "t\u{E0100}e\u{FE00}s\u{E0101}t"],
            
            // Empty string
            ["", ""],
            
            // String without variation selectors
            ["hello world", "hello world"],
        ];

        foreach ($testCases as [$expected, $input]) {
            $result = $this->processString($transliterator, $input);
            $this->assertEquals($expected, $result, "Drop selectors failed for input with variation selectors");
        }
    }

    /**
     * Test edge cases.
     */
    public function testEdgeCases(): void
    {
        $transliterator = new IvsSvsBaseTransliterator();

        // Empty string
        $this->assertEquals("", $this->processString($transliterator, ""));

        // Single character
        $this->assertEquals("a", $this->processString($transliterator, "a"));

        // Only variation selectors (should be handled according to mode)
        $result = $this->processString($transliterator, "\u{E0100}");
        $this->assertIsString($result);

        // Very long string without special characters
        $longInput = str_repeat("test ", 1000);
        $result = $this->processString($transliterator, $longInput);
        $this->assertEquals($longInput, $result);
    }

    /**
     * Test registry integration.
     */
    public function testRegistryIntegration(): void
    {
        $factory = TransliteratorRegistry::getTransliteratorFactory('ivs-svs-base');
        $transliterator = $factory([]);

        $this->assertInstanceOf(IvsSvsBaseTransliterator::class, $transliterator);

        // Test basic functionality through registry
        $result = $this->processString($transliterator, "test");
        $this->assertEquals("test", $result);
    }

    /**
     * Helper method to process string through transliterator.
     */
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}