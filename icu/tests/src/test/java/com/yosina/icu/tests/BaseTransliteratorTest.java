package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * Base class for ICU transliterator tests.
 */
public abstract class BaseTransliteratorTest {
    
    /**
     * Load ICU rules from a resource file.
     */
    protected String loadRules(String ruleName) throws IOException {
        String resourcePath = "/rules/" + ruleName + ".txt";
        try (InputStream is = getClass().getResourceAsStream(resourcePath)) {
            if (is == null) {
                throw new IOException("Rule file not found: " + resourcePath);
            }
            return new String(is.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
    
    /**
     * Create a transliterator from a rule file.
     */
    protected Transliterator createTransliterator(String ruleName) throws IOException {
        String rules = loadRules(ruleName);
        return Transliterator.createFromRules(
            ruleName, 
            rules, 
            Transliterator.FORWARD
        );
    }
    
    /**
     * Apply transliteration to a string.
     */
    protected String transliterate(Transliterator trans, String input) {
        return trans.transliterate(input);
    }
}