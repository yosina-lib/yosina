// Copyright (c) Yosina. All rights reserved.

using System.Reflection;

namespace Yosina;

public static class TransliteratorFactory
{
    private static readonly Lazy<Dictionary<string, Func<object?, ITransliterator>>> Transliterators =
        new(DiscoverTransliterators);

    private static Dictionary<string, Func<object?, ITransliterator>> DiscoverTransliterators()
    {
        var transliterators = new Dictionary<string, Func<object?, ITransliterator>>(StringComparer.Ordinal);

        var assembly = Assembly.GetExecutingAssembly();
        var transliteratorTypes = assembly.GetTypes()
            .Where(type => type.GetCustomAttribute<RegisteredTransliteratorAttribute>() != null)
            .Where(type => typeof(ITransliterator).IsAssignableFrom(type))
            .Where(type => !type.IsAbstract && !type.IsInterface);

        foreach (var type in transliteratorTypes)
        {
            var attribute = type.GetCustomAttribute<RegisteredTransliteratorAttribute>()!;
            var factory = CreateFactory(type);
            transliterators[attribute.Name] = factory;
        }

        return transliterators;
    }

    private static Func<object?, ITransliterator> CreateFactory(Type transliteratorType)
    {
        var defaultConstructor = transliteratorType.GetConstructor(Type.EmptyTypes);
        var optionsConstructor = transliteratorType.GetConstructors()
            .FirstOrDefault(c => c.GetParameters().Length == 1 &&
string.Equals(c.GetParameters()[0].Name, "options", StringComparison.Ordinal));

        return options =>
        {
            if (options != null && optionsConstructor != null)
            {
                var parameterType = optionsConstructor.GetParameters()[0].ParameterType;
                if (parameterType.IsAssignableFrom(options.GetType()))
                {
                    return (ITransliterator)optionsConstructor.Invoke(new[] { options });
                }
            }

            if (defaultConstructor != null)
            {
                return (ITransliterator)defaultConstructor.Invoke(Array.Empty<object>());
            }

            throw new InvalidOperationException(
                $"Cannot create instance of {transliteratorType.Name}: no suitable constructor found");
        };
    }

    public static ITransliterator Create(string name, object? options = null)
    {
        if (Transliterators.Value.TryGetValue(name, out var factory))
        {
            return factory(options);
        }

        throw new ArgumentException($"Unknown transliterator: {name}");
    }

    public static void Register(string name, Func<object?, ITransliterator> factory)
    {
        Transliterators.Value[name] = factory;
    }

    public static IEnumerable<string> GetRegisteredNames()
    {
        return Transliterators.Value.Keys;
    }
}
