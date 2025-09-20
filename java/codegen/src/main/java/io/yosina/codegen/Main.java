package io.yosina.codegen;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** Main class for generating Java transliterator code from JSON data files. */
public class Main {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static void main(String[] args) throws IOException {
        // Find project root by looking for build.gradle
        Path projectRoot = findProjectRoot();
        Path dataRoot = projectRoot.getParent().resolve("data");
        Path sourceDir = projectRoot.resolve("src/main/java/io/yosina/transliterators");
        Path resourceDir = projectRoot.resolve("src/main/resources/io/yosina/transliterators");

        System.out.println("Data root: " + dataRoot);
        System.out.println("Source dir: " + sourceDir);
        System.out.println("Resource dir: " + resourceDir);

        // Ensure output directory exists
        Files.createDirectories(resourceDir);

        CodeGenerator generator = new CodeGenerator(sourceDir, resourceDir);

        // Generate simple transliterators
        generateSimpleTransliterator(generator, dataRoot, "spaces", "spaces.json");
        generateSimpleTransliterator(generator, dataRoot, "radicals", "radicals.json");
        generateSimpleTransliterator(
                generator,
                dataRoot,
                "mathematical_alphanumerics",
                "mathematical-alphanumerics.json");
        generateSimpleTransliterator(
                generator,
                dataRoot,
                "ideographic_annotations",
                "ideographic-annotation-marks.json");

        // Generate complex transliterators
        generateHyphensTransliterator(generator, dataRoot);
        generateIvsSvsBaseTransliterator(generator, dataRoot);
        generateKanjiOldNewTransliterator(generator, dataRoot);
        generateCombinedTransliterator(generator, dataRoot);
        generateCircledOrSquaredTransliterator(generator, dataRoot);
        generateRomanNumeralsTransliterator(generator, dataRoot);

        System.out.println("Code generation complete!");
    }

    private static Path findProjectRoot() throws IOException {
        Path current = Paths.get("").toAbsolutePath();
        while (current != null) {
            if (Files.exists(current.resolve("build.gradle"))) {
                return current;
            }
            current = current.getParent();
        }
        throw new IOException("Could not find project root (build.gradle not found)");
    }

    private static void generateSimpleTransliterator(
            CodeGenerator generator, Path dataRoot, String name, String filename)
            throws IOException {
        System.out.println("Generating " + name + "...");

        Map<int[], int[]> data = loadSimpleData(dataRoot.resolve(filename));
        generator.generateSimpleTransliterator(name, data);
    }

    private static void generateHyphensTransliterator(CodeGenerator generator, Path dataRoot)
            throws IOException {
        System.out.println("Generating hyphens...");

        List<HyphensRecord> data = loadHyphensData(dataRoot.resolve("hyphens.json"));
        generator.generateHyphensTransliterator(data);
    }

    private static void generateIvsSvsBaseTransliterator(CodeGenerator generator, Path dataRoot)
            throws IOException {
        System.out.println("Generating ivs_svs_base...");

        List<IvsSvsBaseRecord> data =
                loadIvsSvsBaseData(dataRoot.resolve("ivs-svs-base-mappings.json"));
        generator.generateIvsSvsBaseTransliterator(data);
    }

    private static void generateKanjiOldNewTransliterator(CodeGenerator generator, Path dataRoot)
            throws IOException {
        System.out.println("Generating kanji_old_new...");

        List<KanjiOldNewRecord> data =
                loadKanjiOldNewData(dataRoot.resolve("kanji-old-new-form.json"));
        generator.generateKanjiOldNewTransliterator(data);
    }

    private static Map<int[], int[]> loadSimpleData(Path path) throws IOException {
        final Map<String, String> mappings =
                objectMapper.readValue(path.toFile(), new TypeReference<Map<String, String>>() {});
        return mappings.entrySet().stream()
                .collect(
                        Collectors.toMap(
                                e -> new int[] {UnicodeUtils.parseUnicodeCodepoint(e.getKey()), -1},
                                e ->
                                        new int[] {
                                            UnicodeUtils.parseUnicodeCodepoint(e.getValue()), -1
                                        }));
    }

    private static List<HyphensRecord> loadHyphensData(Path path) throws IOException {
        return objectMapper.readValue(path.toFile(), new TypeReference<List<HyphensRecord>>() {});
    }

    private static List<IvsSvsBaseRecord> loadIvsSvsBaseData(Path path) throws IOException {
        return objectMapper.readValue(
                path.toFile(), new TypeReference<List<IvsSvsBaseRecord>>() {});
    }

    private static List<KanjiOldNewRecord> loadKanjiOldNewData(Path path) throws IOException {
        return objectMapper.readValue(
                path.toFile(), new TypeReference<List<KanjiOldNewRecord>>() {});
    }

    private static void generateCombinedTransliterator(CodeGenerator generator, Path dataRoot)
            throws IOException {
        System.out.println("Generating combined...");

        Map<String, String> data = loadCombinedData(dataRoot.resolve("combined-chars.json"));
        generator.generateCombinedTransliterator(data);
    }

    private static void generateCircledOrSquaredTransliterator(
            CodeGenerator generator, Path dataRoot) throws IOException {
        System.out.println("Generating circled_or_squared...");

        Map<String, CircledOrSquaredRecord> data =
                loadCircledOrSquaredData(dataRoot.resolve("circled-or-squared.json"));
        generator.generateCircledOrSquaredTransliterator(data);
    }

    private static Map<String, String> loadCombinedData(Path path) throws IOException {
        return objectMapper.readValue(path.toFile(), new TypeReference<Map<String, String>>() {});
    }

    private static Map<String, CircledOrSquaredRecord> loadCircledOrSquaredData(Path path)
            throws IOException {
        return objectMapper.readValue(
                path.toFile(), new TypeReference<Map<String, CircledOrSquaredRecord>>() {});
    }

    private static void generateRomanNumeralsTransliterator(CodeGenerator generator, Path dataRoot)
            throws IOException {
        System.out.println("Generating roman_numerals...");

        List<RomanNumeralsRecord> data =
                loadRomanNumeralsData(dataRoot.resolve("roman-numerals.json"));
        generator.generateRomanNumeralsTransliterator(data);
    }

    private static List<RomanNumeralsRecord> loadRomanNumeralsData(Path path) throws IOException {
        return objectMapper.readValue(
                path.toFile(), new TypeReference<List<RomanNumeralsRecord>>() {});
    }
}
