# ngram

Simple n-gram sequence modeling for `ns`.

The package learns fixed-length context transitions by counting observed
continuations. It works with:

- numeric sequences such as `[1, 2, 3, 4]`
- character-level text such as `"hello"`
- token-level text such as `"hello world"`

Generation is probability-based and deterministic for a given seed. No neural
networks or transformers are involved.

## Public API

- `ngram.defaultConfig()`
- `ngram.sequence(value, config)`
- `ngram.train(data, order, config)`
- `ngram.predictNext(model, history, limit)`
- `ngram.generate(model, start, options)`
- `ngram.render(sequenceValues, config)`

## Quick Start

```ns
pkg = import("./ngram.ns");
ng = pkg.ngram;

model = ng.train(
  [[1, 2, 3], [1, 2, 4], [1, 2, 3]],
  2,
  {unit: "items", addStopToken: false}
);

rows = ng.predictNext(model, [1, 2], 5);
printline(rows[0].value);   // 3
printline(rows[0].probability);
```

Character text:

```ns
charModel = ng.train(["abba", "abca"], 2, {unit: "chars", stopToken: "<END>"});
result = ng.generate(charModel, "ab", {maxSteps: 5, seed: 7});
printline(result.rendered);
```

Token text:

```ns
tokenModel = ng.train(
  ["red blue stop", "red green stop"],
  1,
  {unit: "tokens", stopToken: "stop", separator: " "}
);
result = ng.generate(tokenModel, "red", {maxSteps: 4, seed: 5});
printline(result.rendered);
```

## Config

- `unit`: `"chars"`, `"tokens"`, or `"items"`
- `stopToken`: token that ends generation
- `addStopToken`: append `stopToken` during training when missing
- `lowercase`: normalize text input before sequencing
- `separator`: joiner used by `render()` for token mode
- `seed`: default deterministic generation seed

## Run

```bash
../ns/bin/ns tests/run_tests.ns
../ns/bin/ns examples/demo.ns
```
