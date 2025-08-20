// Copyright (c) Yosina. All rights reserved.

using System.Reflection;
using Yosina.JsonConverters;

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
            .Where(type =>
                type.GetCustomAttribute<RegisteredTransliteratorAttribute>() != null &&
                typeof(ITransliterator).IsAssignableFrom(type) &&
                !type.IsAbstract &&
                !type.IsInterface);

        foreach (var type in transliteratorTypes)
        {
            var attribute = type.GetCustomAttribute<RegisteredTransliteratorAttribute>()!;
            transliterators[attribute.Name] = CreateFactory(type);
        }

        return transliterators;
    }

    private static bool CoerceValue(Type targetType, object? value, out object? result)
    {
        if (targetType == typeof(Nullable))
        {
            if (value == null)
            {
                result = null;
                return true;
            }
        }

        if (value is object value_)
        {
            if (targetType.IsAssignableFrom(value_.GetType()))
            {
                result = value_;
                return true;
            }

            if (targetType.IsEnum && value is string stringValue)
            {
                foreach (var field in targetType.GetFields(BindingFlags.Public | BindingFlags.Static))
                {
                    if (field.GetCustomAttribute<JsonEnumValueAttribute>() is JsonEnumValueAttribute enumAttr)
                    {
                        if (enumAttr.Value.Equals(stringValue, StringComparison.Ordinal))
                        {
                            result = field.GetRawConstantValue();
                            return true;
                        }
                    }
                }

                try
                {
                    result = Enum.Parse(targetType, stringValue);
                    return true;
                }
                catch (ArgumentException)
                {
                }
            }

            if (Activator.CreateInstance(targetType) is object options_)
            {
                var valueType = value_.GetType();
                foreach (var prop in valueType.GetProperties())
                {
                    if (targetType.GetProperty(prop.Name) == null)
                    {
                        throw new ArgumentException($"Option '{prop.Name}' is not valid for '{targetType.FullName}'");
                    }
                }

                foreach (var prop in targetType.GetProperties())
                {
                    if (valueType.GetProperty(prop.Name)?.GetValue(value_, null) is object propValue)
                    {
                        TryAssignProperty(prop, options_, propValue);
                    }
                }

                result = options_;
                return true;
            }
        }

        result = false;
        return false;
    }

    private static void TryAssignProperty(PropertyInfo prop, object target, object value)
    {
        if (prop.PropertyType.IsAssignableFrom(value.GetType()))
        {
            prop.SetValue(target, value, null);
        }
        else
        {
            if (CoerceValue(prop.PropertyType, value, out var value_))
            {
                prop.SetValue(target, value_, null);
            }
        }
    }

    private static Func<object?, ITransliterator> CreateFactory(Type transliteratorType)
    {
        var optionsConstructor = transliteratorType.GetConstructors()
            .FirstOrDefault(c =>
                c.GetParameters().Length == 1 &&
                string.Equals(c.GetParameters()[0].Name, "options", StringComparison.Ordinal));

        return options =>
        {
            if (options != null && optionsConstructor != null)
            {
                var parameterType = optionsConstructor.GetParameters()[0].ParameterType;
                var optionsType = options.GetType();

                if (!parameterType.IsAssignableFrom(optionsType))
                {
                    if (!CoerceValue(parameterType, options, out options))
                    {
                        options = null;
                    }
                }

                if (options != null)
                {
                    return (ITransliterator)optionsConstructor.Invoke([options]);
                }
            }

            if (Activator.CreateInstance(transliteratorType) is ITransliterator instance)
            {
                return instance;
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
