# Multi-stream Prediction for NS

This project is a modular, explainable multi-stream prediction package written in ns.

The system stores streams as a time-indexed table, extracts lagged/history features, trains one small tree model per target stream, predicts the next value/event for each stream, and reports counterfactual cross-stream influence.

## Quick Start

Use the umbrella entrypoint for a clean module surface:

```bash
predict = import("./predict.ns");

rows = [
	{A: 1, B: 2, C: "idle"},
	{A: 2, B: 3, C: "idle"},
	{A: 3, B: 4, C: "active"}
];

system = predict.streams.train(["A", "B", "C"], rows, {
	feature: {lags: 2, rolling: 2, pattern: 2},
	tree: {maxDepth: 4, minSamples: 2}
});

forecast = predict.streams.forecast(system, rows);
printline("next A:", forecast.row.A);
```

## Layout

- `predict.ns` umbrella entrypoint (recommended import).
- `src/streams.ns` high-level API for training, forecasting, consistency checks, and influence.
- `src/history.ns` keeps stream histories and counterfactual snapshots.
- `src/features.ns` extracts current values, lagged values, deltas, rolling averages, time since change, and recent pattern codes.
- `src/tree.ns` trains a compact decision-tree style predictor.
- `src/predictor.ns` low-level per-stream training and prediction internals.
- `src/explain.ns` turns model paths and influence reports into readable summaries.
- `examples/demo.ns` shows prediction plus influence mapping.
- `tests/` contains focused ns tests.

## Run

```bash
../ns/bin/ns tests/run_tests.ns
../ns/bin/ns examples/demo.ns
```
