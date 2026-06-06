# intent

Corpus-driven topic and intent discovery from raw text.

The module trains from one large text input or a list of documents. It does not
require labeled rows. It learns:

- topic candidates from the corpus segments
- relation families from repeated left-bridge-right patterns in the corpus
- stable intent labels by mapping learned relation kinds to configured names

## Input shape

Pass either:

- one large string
- a list of strings

If one string contains multiple non-empty lines, each line is treated as a
separate corpus unit first.

## Example

```ns
intent = import("./intent.ns").intent;

corpus = "
poodles are dogs
dogs are animals
cats are animals
poodles have curly coats
dogs can swim
";

system = intent.train(corpus, intent.defaultConfig());
analysis = intent.analyze(system, "what is a poodle", 3);
replyRows = intent.responses(system, "can dogs swim", 3);
```

`analysis` now returns:

- `topics`
- `parentTopics`
- `relationsRequested`
- `rulesMatched`
- `matchedRule`
- `intentSource`
- `intent`
- `evidence`

For the corpus above:

- `"what is a poodle"` typically resolves to topic `poodle` and intent `define`
- `"can dogs swim"` typically resolves to topic `dogs` and intent `capability_check`

It also exposes inherited parent topics. For example:

- `poodle -> dogs -> animals`
- `dogs -> animals`

## How intent is defined

The corpus learns relation families such as:

- `category_of`
- `capability_of`
- `attribute_of`
- `related_to`

The final intent string is not self-named by the corpus. It comes from
`config.intentLabels`, which defaults to:

```ns
{
    category_of: "define",
    capability_of: "capability_check",
    attribute_of: "attribute_query",
    compare_topics: "compare",
    related_to: "relation_query",
    explain_topic: "explain"
}
```

So `define` means: "the strongest learned relation request for this input is
`category_of`".

## Rule layer

You can add declarative rules in `config.intentRules` to override the relation
mapping. Rules can match:

- exact words or sets of words
- ordered token shapes with `sequence`
- detected topics with the `topic` pattern item
- detected parent topics with the `parentTopic` pattern item
- relation kinds with `relationAny` or `relationAll`

Example:

```ns
config.intentRules = [{
    label: "question",
    priority: 100,
    containsAny: ["what", "how", "why"],
    sequence: [
        { kind: "oneOf", words: ["what", "how", "why"] },
        { kind: "topic" }
    ]
}];
```

In that example, `containsAny` and the `oneOf` item overlap on purpose, but they
do different jobs:

- `containsAny` is a top-level lexical gate. It says at least one of those cue
  words must appear somewhere in the input.
- `oneOf` inside `sequence` is a positional match. It says one of those cue
  words must appear at that point in the ordered rule shape.

If your `sequence` already includes the same cue words, `containsAny` is often
redundant and the rule will usually still work without it. It is still useful
when you want a clearer top-level cue-word check, or when your `sequence` only
describes structure such as `topic`, `parentTopic`, or `wildcard` without
spelling out the cue words directly.

If a rule matches, `analysis.intent` comes from the rule label and
`analysis.intentSource` is `rule`. Otherwise the module falls back to the
relation-based intent mapping.

## Parent topics

The module also walks learned `category_of` links upward from the direct topic.
That means the queried term stays the main topic, while broader classes are
returned separately in `parentTopics`.

For example:

- `"what is a poodle"` can return topic `poodle` with parent topics `dogs`,
  then `animals`
- `"can dogs swim"` can return topic `dogs` with parent topic `animals`

This is useful for fallback reasoning and for showing broader context without
overwriting the original topic the user asked about.

## Public API

- `intent.defaultConfig()`
- `intent.train(corpusInput, config)`
- `intent.analyze(system, inputText, limit)`
- `intent.responses(system, inputText, limit)`
