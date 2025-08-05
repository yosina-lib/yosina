// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

[AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
public class RegisteredTransliteratorAttribute : Attribute
{
    public string Name { get; }

    public RegisteredTransliteratorAttribute(string name)
    {
        this.Name = name ?? throw new ArgumentNullException(nameof(name));
    }
}
