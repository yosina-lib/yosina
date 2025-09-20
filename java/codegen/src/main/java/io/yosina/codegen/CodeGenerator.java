package io.yosina.codegen;

import io.yosina.codegen.generators.*;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.AbstractMap.SimpleImmutableEntry;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/** Generates Java transliterator code from data files. */
public class CodeGenerator {
    private final Path sourceDir;
    private final Path resourceDir;

    public CodeGenerator(Path sourceDir, Path resourceDir) {
        this.sourceDir = sourceDir;
        this.resourceDir = resourceDir;
    }

    /** Writes the generated content to a file. */
    protected void writeToFile(List<Artifact> artifacts) {
        for (Artifact artifact : artifacts) {
            final Path outputPath;
            switch (artifact.getType()) {
                case SOURCE:
                    outputPath = sourceDir.resolve(artifact.getPath());
                    break;
                case RESOURCE:
                    outputPath = resourceDir.resolve(artifact.getPath());
                    break;
                default:
                    throw new IllegalArgumentException(
                            "Unknown artifact type: " + artifact.getType());
            }
            try {
                Files.createDirectories(outputPath.getParent());
                final FileChannel ch =
                        FileChannel.open(
                                outputPath,
                                StandardOpenOption.CREATE,
                                StandardOpenOption.WRITE,
                                StandardOpenOption.TRUNCATE_EXISTING);
                try {
                    ch.write(artifact.getContent().rewind());
                } finally {
                    ch.close();
                }
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
            System.out.println("Generated " + outputPath);
        }
    }

    /** Generates a simple transliterator that maps single characters to single characters. */
    public void generateSimpleTransliterator(String name, Map<int[], int[]> mappings)
            throws IOException {
        SimpleTransliteratorGenerator generator = new SimpleTransliteratorGenerator(name, mappings);
        writeToFile(generator.generate());
    }

    /** Generates the hyphens transliterator. */
    public void generateHyphensTransliterator(List<HyphensRecord> records) throws IOException {
        HyphensTransliteratorGenerator generator = new HyphensTransliteratorGenerator(records);
        writeToFile(generator.generate());
    }

    /** Generates the IVS/SVS base transliterator. */
    public void generateIvsSvsBaseTransliterator(List<IvsSvsBaseRecord> records)
            throws IOException {
        IvsSvsBaseTransliteratorGenerator generator =
                new IvsSvsBaseTransliteratorGenerator(records);
        writeToFile(generator.generate());
    }

    /** Generates the kanji old-new transliterator. */
    public void generateKanjiOldNewTransliterator(List<KanjiOldNewRecord> records)
            throws IOException {
        final Map<int[], int[]> records_ =
                records.stream()
                        .flatMap(
                                record -> {
                                    final int[] svs = record.getTraditional().getSvs();
                                    return svs != null
                                            ? Stream.of(
                                                    new SimpleImmutableEntry<>(
                                                            record.getTraditional().getIvs(),
                                                            record.getNew().getIvs()),
                                                    new SimpleImmutableEntry<>(
                                                            svs, record.getNew().getIvs()))
                                            : Stream.of(
                                                    new SimpleImmutableEntry<>(
                                                            record.getTraditional().getIvs(),
                                                            record.getNew().getIvs()));
                                })
                        .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
        final SimpleTransliteratorGenerator generator =
                new SimpleTransliteratorGenerator("kanji_old_new", records_);
        writeToFile(generator.generate());
    }

    /** Generates the combined transliterator. */
    public void generateCombinedTransliterator(Map<String, String> mappings) throws IOException {
        CombinedTransliteratorGenerator generator =
                new CombinedTransliteratorGenerator(mappings, "CombinedTransliterator", "combined");
        writeToFile(generator.generate());
    }

    /** Generates the circled-or-squared transliterator. */
    public void generateCircledOrSquaredTransliterator(Map<String, CircledOrSquaredRecord> mappings)
            throws IOException {
        CircledOrSquaredTransliteratorGenerator generator =
                new CircledOrSquaredTransliteratorGenerator(mappings);
        writeToFile(generator.generate());
    }

    /** Generates the roman numerals transliterator. */
    public void generateRomanNumeralsTransliterator(List<RomanNumeralsRecord> records)
            throws IOException {
        // Convert records to a Map format similar to combined transliterator
        // Keep the Unicode notation format (e.g., "U+2160") for the keys
        Map<String, String> mappings =
                records.stream()
                        .filter(
                                record ->
                                        record.getCodes() != null && record.getDecomposed() != null)
                        .flatMap(
                                record -> {
                                    Stream.Builder<SimpleImmutableEntry<String, String>> builder =
                                            Stream.builder();

                                    if (record.getCodes().getUpper() != null
                                            && record.getDecomposed().getUpper() != null) {
                                        builder.add(
                                                new SimpleImmutableEntry<String, String>(
                                                        record.getCodes()
                                                                .getUpper(), // Keep as "U+XXXX"
                                                        // format
                                                        record.getDecomposed().getUpper().stream()
                                                                .map(UnicodeUtils::unicodeToString)
                                                                .collect(Collectors.joining())));
                                    }

                                    if (record.getCodes().getLower() != null
                                            && record.getDecomposed().getLower() != null) {
                                        builder.add(
                                                new SimpleImmutableEntry<String, String>(
                                                        record.getCodes()
                                                                .getLower(), // Keep as "U+XXXX"
                                                        // format
                                                        record.getDecomposed().getLower().stream()
                                                                .map(UnicodeUtils::unicodeToString)
                                                                .collect(Collectors.joining())));
                                    }

                                    return builder.build();
                                })
                        .collect(
                                Collectors.toMap(
                                        entry -> entry.getKey(), entry -> entry.getValue()));

        // Reuse the combined transliterator generator since the structure is similar
        CombinedTransliteratorGenerator generator =
                new CombinedTransliteratorGenerator(
                        mappings, "RomanNumeralsTransliterator", "roman-numerals");
        writeToFile(generator.generate());
    }
}
