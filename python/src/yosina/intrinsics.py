"""Core transliterator intrinsics and chaining functionality."""

from collections.abc import Iterable

from .transliterators import TransliteratorConfig, TransliteratorIdentifier, get_transliterator_factory
from .types import Transliterator

__all__ = [
    "make_chained_transliterator",
]


def make_chained_transliterator(
    transliterator_configs: Iterable[TransliteratorConfig | TransliteratorIdentifier | Transliterator],
) -> Transliterator:
    """Create a chained transliterator from a list of configurations.

    :param transliterator_configs: List of transliterator configs or string names
    :returns: A transliterator function that applies all configs in sequence
    :raises ValueError: If no transliterators are specified or if any config is invalid
    """
    if not transliterator_configs:
        raise ValueError("at least one transliterator must be specified")

    result: Transliterator | None = None

    def compose(transliterator: Transliterator, prev: Transliterator) -> Transliterator:
        return lambda input_chars: transliterator(prev(input_chars))

    for config in transliterator_configs:
        transliterator: Transliterator
        if isinstance(config, str):
            factory = get_transliterator_factory(config)
            transliterator = factory()
        elif isinstance(config, Transliterator):
            transliterator = config
        else:
            name, options = config
            factory = get_transliterator_factory(name)
            transliterator = factory(**options)

        if result is None:
            result = transliterator
        else:
            # Chain the transliterators
            result = compose(transliterator, result)

    if result is None:
        raise ValueError("at least one transliterator must be specified")

    return result
