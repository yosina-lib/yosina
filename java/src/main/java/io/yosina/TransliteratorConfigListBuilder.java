package io.yosina;

import java.util.ArrayList;
import java.util.List;

/** Internal builder for creating lists of transliterator configurations. */
class TransliteratorConfigListBuilder {
    private final List<Yosina.TransliteratorConfig> head;
    private final List<Yosina.TransliteratorConfig> tail;

    public TransliteratorConfigListBuilder() {
        this(new ArrayList<>(), new ArrayList<>());
    }

    private TransliteratorConfigListBuilder(
            List<Yosina.TransliteratorConfig> head, List<Yosina.TransliteratorConfig> tail) {
        this.head = new ArrayList<>(head);
        this.tail = new ArrayList<>(tail);
    }

    public TransliteratorConfigListBuilder insertHead(
            Yosina.TransliteratorConfig config, boolean forceReplace) {
        List<Yosina.TransliteratorConfig> newHead = new ArrayList<>(this.head);
        int existingIndex = findConfigIndex(newHead, config.getName());

        if (existingIndex >= 0) {
            if (forceReplace) {
                newHead.set(existingIndex, config);
            }
        } else {
            newHead.add(0, config);
        }

        return new TransliteratorConfigListBuilder(newHead, this.tail);
    }

    public TransliteratorConfigListBuilder insertMiddle(
            Yosina.TransliteratorConfig config, boolean forceReplace) {
        List<Yosina.TransliteratorConfig> newTail = new ArrayList<>(this.tail);
        int existingIndex = findConfigIndex(newTail, config.getName());

        if (existingIndex >= 0) {
            if (forceReplace) {
                newTail.set(existingIndex, config);
            }
        } else {
            newTail.add(config); // Add to end of tail to maintain order
        }

        return new TransliteratorConfigListBuilder(this.head, newTail);
    }

    public TransliteratorConfigListBuilder insertTail(
            Yosina.TransliteratorConfig config, boolean forceReplace) {
        List<Yosina.TransliteratorConfig> newTail = new ArrayList<>(this.tail);
        int existingIndex = findConfigIndex(newTail, config.getName());

        if (existingIndex >= 0) {
            if (forceReplace) {
                newTail.set(existingIndex, config);
            }
        } else {
            newTail.add(config);
        }

        return new TransliteratorConfigListBuilder(this.head, newTail);
    }

    private int findConfigIndex(List<Yosina.TransliteratorConfig> configs, String name) {
        for (int i = 0; i < configs.size(); i++) {
            if (configs.get(i).getName().equals(name)) {
                return i;
            }
        }
        return -1;
    }

    public List<Yosina.TransliteratorConfig> build() {
        List<Yosina.TransliteratorConfig> result = new ArrayList<>();
        result.addAll(head);
        result.addAll(tail);
        return result;
    }
}
