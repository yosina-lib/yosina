package io.yosina.codegen;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.io.Writer;
import java.util.AbstractMap.SimpleImmutableEntry;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.TypeElement;
import javax.tools.FileObject;
import javax.tools.StandardLocation;

@SupportedAnnotationTypes("io.yosina.annotations.RegisteredTransliterator")
@SupportedSourceVersion(javax.lang.model.SourceVersion.RELEASE_17)
public class AnnotationProcessor extends AbstractProcessor {
    private static final String TRANSLITERATOR_ANNOTATION_TYPE =
            "io.yosina.annotations.RegisteredTransliterator";
    private static final String TRANSLITERATORS_PACKAGE = "io.yosina.transliterators";
    private static final String TRANSLITERATORS_MANIFEST_NAME = "TRANSLITERATORS";

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        final Optional<? extends TypeElement> annotation =
                annotations.stream()
                        .filter(
                                item ->
                                        item.getQualifiedName()
                                                .contentEquals(TRANSLITERATOR_ANNOTATION_TYPE))
                        .findFirst();
        if (!annotation.isPresent()) {
            return false;
        }
        final Map<String, TypeElement> targets =
                roundEnv.getElementsAnnotatedWith(annotation.get()).stream()
                        .filter(target -> target.getKind() == ElementKind.CLASS)
                        .map(TypeElement.class::cast)
                        .map(
                                target ->
                                        target.getAnnotationMirrors().stream()
                                                .filter(
                                                        ann ->
                                                                ann.getAnnotationType()
                                                                        .asElement()
                                                                        .getSimpleName()
                                                                        .contentEquals(
                                                                                "RegisteredTransliterator"))
                                                .findFirst()
                                                .flatMap(
                                                        ann ->
                                                                ann
                                                                        .getElementValues()
                                                                        .entrySet()
                                                                        .stream()
                                                                        .filter(
                                                                                entry ->
                                                                                        entry.getKey()
                                                                                                .getSimpleName()
                                                                                                .contentEquals(
                                                                                                        "name"))
                                                                        .findFirst()
                                                                        .map(
                                                                                entry ->
                                                                                        String.class
                                                                                                .cast(
                                                                                                        entry.getValue()
                                                                                                                .getValue())))
                                                .map(
                                                        annValue ->
                                                                new SimpleImmutableEntry<>(
                                                                        annValue, target)))
                        .filter(Optional::isPresent)
                        .map(Optional::get)
                        .collect(
                                Collectors.toUnmodifiableMap(
                                        Map.Entry::getKey, Map.Entry::getValue));
        try {
            final FileObject out =
                    processingEnv
                            .getFiler()
                            .createResource(
                                    StandardLocation.CLASS_OUTPUT,
                                    TRANSLITERATORS_PACKAGE,
                                    TRANSLITERATORS_MANIFEST_NAME,
                                    targets.values().stream().toArray(TypeElement[]::new));
            try (final Writer writer = out.openWriter()) {
                for (final Map.Entry<String, TypeElement> entry : targets.entrySet()) {
                    writer.write(
                            String.format(
                                    "%s\t%s\n",
                                    entry.getKey(), entry.getValue().getQualifiedName()));
                }
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return true;
    }
}
