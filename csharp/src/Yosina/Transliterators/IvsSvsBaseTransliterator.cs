// Copyright (c) Yosina. All rights reserved.

using System.Reflection;
using System.Text.Json.Serialization;
using CodePointTuple = (int First, int Second);

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for handling IVS (Ideographic Variation Sequence) and SVS (Standardized Variation Sequence) base characters.
/// </summary>
[RegisteredTransliterator("ivs-svs-base")]
public class IvsSvsBaseTransliterator : ITransliterator
{
    private readonly Options options;

    public IvsSvsBaseTransliterator()
        : this(new Options())
    {
    }

    public IvsSvsBaseTransliterator(Options options)
    {
        this.options = options ?? throw new ArgumentNullException(nameof(options));
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum Mode
    {
        [JsonStringEnumMemberName("ivs-svs")]
        IvsSvs,
        [JsonStringEnumMemberName("base")]
        Base,
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum Charset
    {
        [JsonStringEnumMemberName("unijis-90")]
        UniJis90,
        [JsonStringEnumMemberName("unijis-2004")]
        UniJis2004,
    }

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return this.options.Mode switch
        {
            Mode.IvsSvs => new IvsSvsBaseFwdCharEnumerator(input.GetEnumerator(), this.options),
            Mode.Base => new IvsSvsBaseRevCharEnumerator(input.GetEnumerator(), this.options),
            _ => throw new NotSupportedException($"Unsupported mode: {this.options.Mode}"),
        };
    }

    public class Options
    {
        [JsonPropertyName("mode")]
        public Mode Mode { get; set; } = Mode.IvsSvs;

        [JsonPropertyName("drop_selectors_altogether")]
        public bool DropSelectorsAltogether { get; set; }

        [JsonPropertyName("charset")]
        public Charset Charset { get; set; } = Charset.UniJis2004;

        [JsonPropertyName("prefer_svs")]
        public bool PreferSvs { get; set; }
    }

    private static class IvsSvsBaseMappings
    {
        public static readonly Lazy<IDictionary<CodePointTuple, IvsSvsBaseRecord>> FwdBase90Mappings = new(() =>
        {
            var fwdBase90Mappings = new Dictionary<CodePointTuple, IvsSvsBaseRecord>();
            foreach (var record in Mappings?.Value!)
            {
                var ivs = record.Ivs;
                var svs = record.Svs;
                var base90Tuple = record.Base90;
                var base2004Tuple = record.Base2004;

                fwdBase90Mappings[ivs] = record;
                if (!svs.IsEmpty())
                {
                    fwdBase90Mappings[svs] = record;
                }

                if (!base90Tuple.IsEmpty())
                {
                    fwdBase90Mappings[base90Tuple] = record;
                }
            }

            return fwdBase90Mappings;
        });

        public static readonly Lazy<IDictionary<CodePointTuple, IvsSvsBaseRecord>> FwdBase2004Mappings = new(() =>
        {
            var fwdBase2004Mappings = new Dictionary<CodePointTuple, IvsSvsBaseRecord>();
            foreach (var record in Mappings?.Value!)
            {
                var ivs = record.Ivs;
                var svs = record.Svs;
                var base90Tuple = record.Base90;
                var base2004Tuple = record.Base2004;

                fwdBase2004Mappings[ivs] = record;
                if (!svs.IsEmpty())
                {
                    fwdBase2004Mappings[svs] = record;
                }

                if (!base2004Tuple.IsEmpty())
                {
                    fwdBase2004Mappings[base2004Tuple] = record;
                }
            }

            return fwdBase2004Mappings;
        });

        public static readonly Lazy<IDictionary<CodePointTuple, IvsSvsBaseRecord>> RevMappings = new(() =>
        {
            var revMappings = new Dictionary<CodePointTuple, IvsSvsBaseRecord>();
            foreach (var record in Mappings?.Value!)
            {
                revMappings[record.Ivs] = record;
            }

            return revMappings;
        });

        private static readonly Lazy<IList<IvsSvsBaseRecord>> Mappings = new(() =>
        {
            var assembly = Assembly.GetExecutingAssembly();
            using var stream = assembly.GetManifestResourceStream("Yosina.Transliterators.ivs_svs_base.data");
            if (stream == null)
            {
                throw new InvalidOperationException("Could not find embedded resource ivs_svs_base.data");
            }

            using var reader = new BinaryReader(stream);
            var recordCount = reader.ReadInt32();
            if (BitConverter.IsLittleEndian)
            {
                recordCount = ReverseBytes(recordCount);
            }

            var records = new List<IvsSvsBaseRecord>(recordCount);
            for (int i = 0; i < recordCount; i++)
            {
                var ivsFirst = reader.ReadInt32();
                var ivsSecond = reader.ReadInt32();
                var svsFirst = reader.ReadInt32();
                var svsSecond = reader.ReadInt32();
                var base90 = reader.ReadInt32();
                var base2004 = reader.ReadInt32();

                if (BitConverter.IsLittleEndian)
                {
                    ivsFirst = ReverseBytes(ivsFirst);
                    ivsSecond = ReverseBytes(ivsSecond);
                    svsFirst = ReverseBytes(svsFirst);
                    svsSecond = ReverseBytes(svsSecond);
                    base90 = ReverseBytes(base90);
                    base2004 = ReverseBytes(base2004);
                }

                var ivs = ivsSecond != 0 ? (ivsFirst, ivsSecond) : (ivsFirst, -1);
                var svs = svsFirst != 0 ? (svsSecond != 0 ? (svsFirst, svsSecond) : (svsFirst, -1)) : (-1, -1);
                var base90Tuple = base90 != 0 ? (base90, -1) : (-1, -1);
                var base2004Tuple = base2004 != 0 ? (base2004, -1) : (-1, -1);

                var record = new IvsSvsBaseRecord
                {
                    Ivs = ivs,
                    Svs = svs,
                    Base90 = base90Tuple,
                    Base2004 = base2004Tuple,
                };
                records.Add(record);
            }

            return records;
        });

        private static int ReverseBytes(int value)
        {
            return (int)((value & 0x000000FFU) << 24 | (value & 0x0000FF00U) << 8 |
                         (value & 0x00FF0000U) >> 8 | (value & 0xFF000000U) >> 24);
        }
    }

    private class IvsSvsBaseFwdCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly IDictionary<CodePointTuple, IvsSvsBaseRecord> mappings;
        private readonly bool preferSvs;
        private int offset;
        private bool disposed;

        public IvsSvsBaseFwdCharEnumerator(IEnumerator<Character> input, Options options)
        {
            this.input = input;
            this.mappings = options.Charset == Charset.UniJis90 ? IvsSvsBaseMappings.FwdBase90Mappings.Value : IvsSvsBaseMappings.FwdBase2004Mappings.Value;
            this.preferSvs = options.PreferSvs;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed || !this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;
            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            if (this.mappings.TryGetValue(c.CodePoint, out var replacement))
            {
                var ct = this.preferSvs && !replacement.Svs.IsEmpty() ? replacement.Svs : replacement.Ivs;
                this.Current = new Character(ct, this.offset, c);
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
            }

            this.offset += this.Current.CharCount;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input?.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }

    private class IvsSvsBaseRecord
    {
        public CodePointTuple Ivs { get; set; }

        public CodePointTuple Svs { get; set; }

        public CodePointTuple Base90 { get; set; }

        public CodePointTuple Base2004 { get; set; }
    }

    private class IvsSvsBaseRevCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly IDictionary<CodePointTuple, IvsSvsBaseRecord> mappings;
        private readonly Charset charset;
        private readonly bool dropSelectorsAltogether;
        private int offset;
        private bool disposed;

        public IvsSvsBaseRevCharEnumerator(IEnumerator<Character> input, Options options)
        {
            this.input = input;
            this.mappings = IvsSvsBaseMappings.RevMappings.Value;
            this.charset = options.Charset;
            this.dropSelectorsAltogether = options.DropSelectorsAltogether;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed || !this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;
            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            if (this.mappings.TryGetValue(c.CodePoint, out var replacement))
            {
                var ct = this.charset switch
                {
                    Charset.UniJis90 => replacement.Base90,
                    Charset.UniJis2004 => replacement.Base2004,
                    _ => (-1, -1),
                };

                if (!ct.IsEmpty())
                {
                    this.Current = new Character(ct, this.offset, c);
                    this.offset += this.Current.CharCount;
                    return true;
                }
            }

            if (this.dropSelectorsAltogether && c.CodePoint.Size() > 1)
            {
                this.Current = new Character((c.CodePoint.First, -1), this.offset, c);
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
            }

            this.offset += this.Current.CharCount;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input?.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
