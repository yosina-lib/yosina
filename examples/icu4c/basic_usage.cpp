/**
 * Basic usage example for Yosina ICU transliteration rules with ICU4C.
 *
 * Demonstrates loading rule files, creating transliterators, and chaining
 * them into a pipeline — the ICU equivalent of Yosina's recipe system.
 *
 * Build (pkg-config):
 *   g++ -std=c++17 -o basic_usage basic_usage.cpp \
 *       $(pkg-config --cflags --libs icu-uc icu-i18n)
 *
 * Build (manual):
 *   g++ -std=c++17 -o basic_usage basic_usage.cpp \
 *       -licuuc -licui18n
 *
 * Run:
 *   ./basic_usage
 */

#include <unicode/translit.h>
#include <unicode/unistr.h>
#include <unicode/utypes.h>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>

// Path to the ICU rule files relative to the project root.
// Adjust if running from a different directory.
static const std::string RULES_DIR = "../../icu/rules/";

/**
 * Load ICU transliteration rules from a file.
 */
static std::string loadRules(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: cannot open " << filename << std::endl;
        std::exit(1);
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

/**
 * Create a Transliterator from a rule file and register it globally
 * so it can be referenced by ID in compound transliterators.
 *
 * Note: registerInstance() takes ownership, so a clone is returned
 * for immediate use.
 */
static std::unique_ptr<icu::Transliterator> createAndRegister(
    const char* id, const std::string& ruleFile) {
    UErrorCode status = U_ZERO_ERROR;
    UParseError parseError;
    icu::UnicodeString rules =
        icu::UnicodeString::fromUTF8(loadRules(RULES_DIR + ruleFile));

    std::unique_ptr<icu::Transliterator> t(
        icu::Transliterator::createFromRules(
            id, rules, UTRANS_FORWARD, parseError, status));

    if (U_FAILURE(status)) {
        std::cerr << "Error creating transliterator '" << id
                  << "': " << u_errorName(status)
                  << " at line " << parseError.line
                  << ", offset " << parseError.offset << std::endl;
        std::exit(1);
    }

    // Clone before registering, since registerInstance() takes ownership.
    std::unique_ptr<icu::Transliterator> clone(t->clone());
    icu::Transliterator::registerInstance(t.release());
    return clone;
}

/**
 * Transliterate a UTF-8 string and print the result.
 */
static void demonstrate(icu::Transliterator& t,
                        const std::string& label,
                        const std::string& input) {
    icu::UnicodeString text = icu::UnicodeString::fromUTF8(input);
    t.transliterate(text);
    std::string output;
    text.toUTF8String(output);
    std::cout << label << std::endl;
    std::cout << "  Input:  " << input << std::endl;
    std::cout << "  Output: " << output << std::endl;
    std::cout << std::endl;
}

int main() {
    std::cout << "=== Yosina ICU4C Basic Usage Example ===" << std::endl
              << std::endl;

    // --- Individual transliterators ---

    std::cout << "--- Individual transliterators ---" << std::endl
              << std::endl;

    auto spaces = createAndRegister("Yosina-Spaces", "spaces.txt");
    demonstrate(*spaces, "Spaces (normalize Unicode spaces to ASCII):",
        u8"Hello\u3000World");

    auto kanjiOldNew =
        createAndRegister("Yosina-KanjiOldNew", "kanji_old_new.txt");
    demonstrate(*kanjiOldNew, "Kanji Old-New (modernize old-style kanji):",
        u8"舊字體の變換");

    auto hiraToKata =
        createAndRegister("Yosina-HiraToKata", "hira_to_kata.txt");
    demonstrate(*hiraToKata, "Hira-to-Kata (convert hiragana to katakana):",
        u8"ひらがな");

    auto fw2hw = createAndRegister("Yosina-Fw2Hw", "jisx0201_and_alike.txt");
    demonstrate(*fw2hw, "Fullwidth-to-Halfwidth:",
        u8"\uFF21\uFF22\uFF23\uFF11\uFF12\uFF13");

    auto iterMarks =
        createAndRegister("Yosina-IterMarks", "japanese_iteration_marks.txt");
    demonstrate(*iterMarks,
        "Japanese Iteration Marks (expand \xE3\x80\x85, "
        "\xE3\x82\x9D, etc.):",
        u8"時々佐々木");

    auto prolonged =
        createAndRegister("Yosina-Prolonged", "prolonged_sound_marks.txt");
    demonstrate(*prolonged,
        "Prolonged Sound Marks (hyphen after katakana to prolonged mark):",
        u8"カトラリ-");

    // --- Chained pipeline ---

    std::cout << "--- Chained pipeline ---" << std::endl << std::endl;

    // Build a pipeline equivalent to a Yosina recipe with:
    //   spaces + kanji_old_new + jisx0201_and_alike
    //
    // Since transliterators are registered above, we can reference them
    // by ID using ICU's compound transliterator syntax (semicolons).
    UErrorCode status = U_ZERO_ERROR;
    std::unique_ptr<icu::Transliterator> pipeline(
        icu::Transliterator::createInstance(
            "Yosina-Spaces; Yosina-KanjiOldNew; Yosina-Fw2Hw",
            UTRANS_FORWARD, status));

    if (U_FAILURE(status)) {
        std::cerr << "Error creating pipeline: "
                  << u_errorName(status) << std::endl;
        return 1;
    }

    demonstrate(*pipeline,
        "Pipeline (spaces + kanji_old_new + jisx0201_and_alike):",
        u8"東京醫科大學\u3000附屬病院");

    // --- Chaining with NFC for composition ---

    std::cout << "--- Chaining with NFC ---" << std::endl << std::endl;

    // hira_kata_composition handles non-combining marks (゛ ゜);
    // chain with ::NFC; to also compose combining marks (U+3099, U+309A).
    std::string compositionRulesStr =
        loadRules(RULES_DIR + "hira_kata_composition.txt");
    compositionRulesStr += "\n::NFC;";
    icu::UnicodeString compositionRules =
        icu::UnicodeString::fromUTF8(compositionRulesStr);

    UParseError parseError;
    status = U_ZERO_ERROR;
    std::unique_ptr<icu::Transliterator> composition(
        icu::Transliterator::createFromRules(
            "Yosina-Composition", compositionRules,
            UTRANS_FORWARD, parseError, status));

    if (U_FAILURE(status)) {
        std::cerr << "Error creating composition transliterator: "
                  << u_errorName(status) << std::endl;
        return 1;
    }

    demonstrate(*composition,
        "Composition with NFC (non-combining and combining marks):",
        u8"か\u309Bき\u3099は\u309C");

    return 0;
}
