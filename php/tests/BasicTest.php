<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Yosina\Char;
use Yosina\Chars;
use Yosina\TransliterationRecipe;
use Yosina\Yosina;

/**
 * Basic test for Yosina PHP implementation.
 */
class BasicTest extends TestCase
{
    public function testCharsBuilding(): void
    {
        $input = "hello　world"; // Contains U+3000 (ideographic space)
        $chars = Chars::buildCharArray($input);
        
        
        // Should have chars for: h, e, l, l, o, 　, w, o, r, l, d, + sentinel
        $this->assertCount(12, $chars, "Expected 12 chars including sentinel");
        
        // Test converting back
        $output = Chars::fromChars($chars);
        $this->assertEquals($input, $output, "Round-trip conversion failed");
    }
    
    public function testSpacesTransliterator(): void
    {
        $input = "hello　world"; // U+3000 ideographic space
        $expected = "hello world"; // Regular ASCII space
        
        $transliterator = Yosina::makeTransliterator([['spaces', []]]);
        $result = $transliterator($input);
        
        
        $this->assertEquals($expected, $result, "Spaces transliterator failed");
    }
    
    public function testRecipeBasedTransliterator(): void
    {
        $input = "hello　world⼀"; // Contains ideographic space and radical
        
        $recipe = new TransliterationRecipe(
            replaceSpaces: true,
            replaceRadicals: true
        );
        
        $transliterator = Yosina::makeTransliterator($recipe);
        $result = $transliterator($input);
        
        
        // Should replace ideographic space with regular space and radical with equivalent CJK ideograph
        $this->assertStringContainsString("hello world", $result, "Space replacement failed");
        $this->assertStringNotContainsString("　", $result, "Ideographic space still present");
    }
    
    public function testHyphensTransliterator(): void
    {
        $input = "test-hyphen~tilde|pipe"; // Contains different hyphen-like characters
        
        $transliterator = Yosina::makeTransliterator([
            ['hyphens', ['precedence' => ['jisx0208_90']]]
        ]);
        $result = $transliterator($input);
        
        
        // Should normalize hyphen characters based on precedence
        $this->assertNotEquals($input, $result, "Hyphen transliterator should transform some characters");
    }
    
    public function testComplexRecipe(): void
    {
        $recipe = new TransliterationRecipe(
            replaceSpaces: true,
            replaceRadicals: true,
            replaceHyphens: true,
            replaceMathematicalAlphanumerics: true
        );
        
        $transliterator = Yosina::makeTransliterator($recipe);
        $result = $transliterator("test　text⼀with-hyphens");
        
        
        $this->assertNotEquals("test　text⼀with-hyphens", $result, "Complex recipe should transform input");
    }
}