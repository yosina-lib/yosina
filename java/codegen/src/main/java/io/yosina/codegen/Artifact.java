package io.yosina.codegen;

import java.nio.ByteBuffer;
import java.nio.file.Path;

/** Represents a generated code or resource artifact produced during code generation. */
public class Artifact {
    /** The type of the artifact, either source code or a resource file. */
    public static enum Type {
        /** A Java source file artifact. */
        SOURCE,
        /** A resource file artifact. */
        RESOURCE
    }

    private final Type type;
    private final Path path;
    private final ByteBuffer content;

    /**
     * Returns the type of this artifact.
     *
     * @return the artifact type
     */
    public Type getType() {
        return type;
    }

    /**
     * Returns the relative path of this artifact.
     *
     * @return the artifact path
     */
    public Path getPath() {
        return path;
    }

    /**
     * Returns the content of this artifact.
     *
     * @return the artifact content as a {@link ByteBuffer}
     */
    public ByteBuffer getContent() {
        return content;
    }

    /**
     * Constructs an {@code Artifact} with the given type, path, and content.
     *
     * @param type the artifact type
     * @param path the relative path of the artifact
     * @param content the content of the artifact
     */
    public Artifact(Type type, Path path, ByteBuffer content) {
        this.type = type;
        this.path = path;
        this.content = content;
    }
}
