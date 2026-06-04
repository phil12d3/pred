# text-stat (ns)

Standalone text statistics and analysis module for ns.

## Features

- Word usage frequency and ranked terms
- Leading words (top terms) and tail words (rare terms)
- Word similarity scoring (normalized Levenshtein)
- Co-occurrence matrix and neighbor lookup
- Bigram extraction
- Prefix-based grouping of related words
- Full report generator

## Layout

- `text-stat.ns` umbrella import
- `src/tokenize.ns` tokenization helpers
- `src/stats.ns` analytics functions
- `src/utils.ns` shared utilities
- `examples/demo.ns` example report
- `tests/` tests with `[test]` attributes and Nova-style runner

## Quick Start

```bash
ts = import("./text-stat.ns");

docs = [
  "leading words appear often",
  "tail words appear rarely"
];

report = ts.stats.report(docs, {topN: 5, tailN: 5, windowSize: 2, prefixLen: 4});
printline(report.leadingWords[0].word);
```

## Run

```bash
../../ns/bin/ns tests/run_tests.ns
../../ns/bin/ns examples/demo.ns
```
