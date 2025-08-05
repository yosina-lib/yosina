// Copyright (c) Yosina. All rights reserved.

using CodePointTuple = (int First, int Second);

namespace Yosina;

public class Character : IEquatable<Character>
{
    public Character(CodePointTuple codePoint, int offset, Character? source = null)
    {
        this.CodePoint = codePoint;
        this.Offset = offset;
        this.Source = source;
    }

    public CodePointTuple CodePoint { get; }

    public int Offset { get; }

    public Character? Source { get; }

    public int CharCount => this.CodePoint.CharCount();

    public bool IsSentinel => this.CodePoint.IsEmpty();

    public bool IsTransliterated
    {
        get
        {
            Character c = this;
            while (true)
            {
                Character? s = c.Source;
                if (s == null)
                {
                    break;
                }

                if (c.CodePoint != s.CodePoint)
                {
                    return true;
                }

                c = s;
            }

            return false;
        }
    }

    public static bool operator ==(Character? left, Character? right) =>
        ReferenceEquals(left, right) || (left?.Equals(right) == true);

    public static bool operator !=(Character? left, Character? right) => !(left == right);

    public Character WithOffset(int newOffset) => new(this.CodePoint, newOffset, this);

    public override string ToString()
    {
        return $"Character({this.CodePoint}, {this.Offset}, {this.Source?.ToString() ?? "null"})";
    }

    public bool Equals(Character? other)
    {
        if (other is null)
        {
            return false;
        }

        return this.CodePoint.Equals(other.CodePoint) &&
               this.Offset == other.Offset &&
               Equals(this.Source, other.Source);
    }

    public override bool Equals(object? obj) => obj is Character other && this.Equals(other);

    public override int GetHashCode() => HashCode.Combine(this.CodePoint, this.Offset, this.Source);
}
