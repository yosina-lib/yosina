package io.yosina.codegen;

import java.nio.ByteBuffer;
import java.nio.file.Path;

public class Artifact {
    public static enum Type {
        SOURCE,
        RESOURCE
    }

    private final Type type;
    private final Path path;
    private final ByteBuffer content;

    public Type getType() {
        return type;
    }

    public Path getPath() {
        return path;
    }

    public ByteBuffer getContent() {
        return content;
    }

    public Artifact(Type type, Path path, ByteBuffer content) {
        this.type = type;
        this.path = path;
        this.content = content;
    }
}
