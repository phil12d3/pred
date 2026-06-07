# respond

Corpus-grounded text response tool that combines the same ideas used across the
repo:

- intent-style request classification
- semantic co-occurrence analysis
- lightweight embeddings for evidence ranking

This package takes a natural-language request, identifies what the user is
asking for, ranks the most relevant evidence segments, and returns both:

- a structured result object
- a direct answer string ready to show to the user

## Quick Start

```ns
respond = import("./respond.ns").respond;

corpus = "
poodles are dogs
dogs are animals
poodles have curly coats
dogs can swim
";

system = respond.train(corpus, respond.defaultConfig());
result = respond.answer(system, "can dogs swim", 3);

printline(result.intent);
printline(result.answer);
```

## Public API

- `respond.defaultConfig()`
- `respond.train(corpusInput, config)`
- `respond.analyze(system, inputText, limit)`
- `respond.answer(system, inputText, limit)`
- `respond.reply(system, inputText, limit)` alias of `answer`
- `respond.render(result)`
- `respond.saveSystem(system, path)`
- `respond.loadSystem(path)`

## Saved Models

`respond` can persist a trained system to disk and load it back later.

```ns
respond = import("./respond.ns").respond;

system = respond.train(corpus, respond.defaultConfig());
respond.saveSystem(system, "./tmp/respond_model.bin");

restored = respond.loadSystem("./tmp/respond_model.bin");
result = respond.answer(restored, "can dogs swim", 3);
```

The package root also includes CLI helpers:

- `train.ns`
- `load.ns`

Examples:

```text
../ns/bin/ns train.ns -text "dogs are animals\ndogs can swim" -modelPath ./tmp/respond_model.bin
../ns/bin/ns load.ns -modelPath ./tmp/respond_model.bin -query "can dogs swim"
```

## Rules

`respond` now supports optional manual intent rules through
`config.intentRules`. These follow the same general shape as the `intent`
module rules and can:

- override the public `intent` label with `label`
- override the top inferred relation with `relation`
- match on lexical gates such as `containsAny`, `containsAll`, `containsNone`
- match ordered token shapes with `sequence`
- refer to detected `topic` and `parentTopic` items
- constrain against inferred relations with `relationAny` and `relationAll`

See:

- `examples/rules_demo.ns` for label overrides, relation overrides, and pattern examples
- `examples/japanese_demo.ns` for Japanese-script examples
- `examples/romaji_demo.ns` for Romaji examples
- `examples/french_demo.ns` for French examples
- `docs.html` for the full rule-field reference

## Returned Result Shape

`respond.answer(...)` returns:

```ns
{
    input: "can dogs swim",
    intent: "capability_check",
    analysis: {...},
    queryTokens: [...],
    candidates: [...],
    answer: "dogs can swim."
}
```

The `analysis` field contains the inferred topics, parent topics, requested
relation, and evidence rows. `candidates` contains the re-ranked evidence rows
with lexical, topic, embedding, and evidence scores folded into one final
score.
