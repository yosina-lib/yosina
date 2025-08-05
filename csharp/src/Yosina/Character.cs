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

    public static bool operator ==(Character? left, Character? right) =>
        ReferenceEquals(left, right) || (left?.Equals(right) == true);

    public static bool operator !=(Character? left, Character? right) => !(left == right);

    public Character WithOffset(int newOffset) => new(this.CodePoint, newOffset, this.Source);

    public Character WithSource(Character? newSource) => new(this.CodePoint, this.Offset, newSource);

    public override string ToString()
    {
        return $"Char({this.CodePoint}, {this.Offset}, {this.Source?.ToString() ?? "null"})";
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
