# Discrepancy Analysis for NS

`discrep` is a small analysis package for finding unusual values, comparing rows, and checking whether one history has drifted away from another.

## Start here

Run the beginner demo:

```bash
../ns/bin/ns examples/demo.ns
```

More focused examples:

```bash
../ns/bin/ns examples/outlier_review.ns
../ns/bin/ns examples/row_compare.ns
../ns/bin/ns examples/drift_review.ns
```

## What it does

- `detectSeries(values, config)` summarizes one series and flags outliers.
- `profileHistory(history, config)` applies series profiling to every stream in a history.
- `compareRows(expectedRow, actualRow, streamNames, config)` compares two rows stream by stream.
- `detectDrift(baselineHistory, currentHistory, config)` compares two histories and reports shift.

## Example files

- `examples/demo.ns` shows all of the main functions in one walkthrough.
- `examples/outlier_review.ns` focuses on one numeric series and its outlier list.
- `examples/row_compare.ns` shows how row-by-row comparison reports matches and differences.
- `examples/drift_review.ns` compares two histories and prints the drift rows.

## Return values

- `detectSeries` returns counts, mean, median, quartiles, mode information, and a list of outliers.
- `profileHistory` returns `streams` and a combined `flagged` list.
- `compareRows` returns `report`, `matches`, `comparisons`, and `score`.
- `detectDrift` returns `streams`, `flagged`, `baseline`, and `current`.
