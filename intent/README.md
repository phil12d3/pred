# intent

Corpus-driven intent and utterance-type discovery built on the existing
`text-stat` semantic tooling.

The module now trains from one large text input or a list of documents. It does
not require labeled rows. It learns:

- topic / intent groupings from semantic content
- utterance types from repeated corpus structure
- question-like vs statement-like behavior from pattern reuse, not hardcoded words

## Input shape

Pass either:

- one large string
- a list of strings

If one string contains multiple non-empty lines, each line is treated as a
separate corpus unit before chunking.

## Example

```ns
intent = import("./intent.ns").intent;

corpus = "
how do reset password use reset link now
forgot password use reset link now
where see invoices open billing page now
download invoice pdf open billing page now
";

system = intent.train(corpus, intent.defaultConfig());
analysis = intent.analyze(system, "change password reset", 3);
replyRows = intent.responses(system, "change password reset", 3);
```

## Public API

- `intent.defaultConfig()`
- `intent.train(corpusInput, config)`
- `intent.analyze(system, inputText, limit)`
- `intent.responses(system, inputText, limit)`
