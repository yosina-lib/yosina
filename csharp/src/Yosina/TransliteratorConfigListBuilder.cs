// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

/// <summary>Internal builder for creating lists of transliterator configurations.</summary>
internal class TransliteratorConfigListBuilder
{
    private readonly List<TransliteratorConfig> head;
    private readonly List<TransliteratorConfig> tail;

    public TransliteratorConfigListBuilder()
    {
        this.head = new List<TransliteratorConfig>();
        this.tail = new List<TransliteratorConfig>();
    }

    private TransliteratorConfigListBuilder(List<TransliteratorConfig> head, List<TransliteratorConfig> tail)
    {
        this.head = new List<TransliteratorConfig>(head);
        this.tail = new List<TransliteratorConfig>(tail);
    }

    public TransliteratorConfigListBuilder InsertHead(TransliteratorConfig config, bool forceReplace)
    {
        var newHead = new List<TransliteratorConfig>(this.head);
        int existingIndex = this.FindConfigIndex(newHead, config.Name);

        if (existingIndex >= 0)
        {
            if (forceReplace)
            {
                newHead[existingIndex] = config;
            }
        }
        else
        {
            newHead.Insert(0, config);
        }

        return new TransliteratorConfigListBuilder(newHead, this.tail);
    }

    public TransliteratorConfigListBuilder InsertMiddle(TransliteratorConfig config, bool forceReplace)
    {
        var newTail = new List<TransliteratorConfig>(this.tail);
        int existingIndex = this.FindConfigIndex(newTail, config.Name);

        if (existingIndex >= 0)
        {
            if (forceReplace)
            {
                newTail[existingIndex] = config;
            }
        }
        else
        {
            newTail.Insert(0, config); // Insert at beginning of tail (middle position)
        }

        return new TransliteratorConfigListBuilder(this.head, newTail);
    }

    public TransliteratorConfigListBuilder InsertTail(TransliteratorConfig config, bool forceReplace)
    {
        var newTail = new List<TransliteratorConfig>(this.tail);
        int existingIndex = this.FindConfigIndex(newTail, config.Name);

        if (existingIndex >= 0)
        {
            if (forceReplace)
            {
                newTail[existingIndex] = config;
            }
        }
        else
        {
            newTail.Add(config);
        }

        return new TransliteratorConfigListBuilder(this.head, newTail);
    }

    private int FindConfigIndex(List<TransliteratorConfig> configs, string name)
    {
        for (int i = 0; i < configs.Count; i++)
        {
            if (string.Equals(configs[i].Name, name, StringComparison.Ordinal))
            {
                return i;
            }
        }

        return -1;
    }

    public List<TransliteratorConfig> Build()
    {
        var result = new List<TransliteratorConfig>();
        result.AddRange(this.head);
        result.AddRange(this.tail);
        return result;
    }
}
