# Multi-Stream Prediction Handoff

This repository contains an ns-script prototype for explainable multi-stream prediction.
It is designed so another agent can continue extending the system without reverse-engineering the current code.

## Goal

Predict the next state of every stream in a history table, while keeping the prediction explainable and cross-checkable.

The current system is not a neural sequence model.
It is a compact, explicit, tree-based predictor that uses engineered history features and produces:

1. a next-state forecast for all streams
2. a feature-path explanation for each predicted stream
3. a consistency check that compares the direct next-state forecast against counterfactual predictions
4. a counterfactual influence report showing how one stream affects the others

## Repository Layout

- `src/history.ns`
  - stores stream names and rows of history
  - creates copies of histories
  - applies counterfactual changes to the last row

- `src/features.ns`
  - extracts features from history
  - builds training rows for each target stream

- `src/tree.ns`
  - trains a small decision-tree style model
  - predicts a target from a feature map

- `src/predictor.ns`
  - trains one model per stream
  - predicts the next state
  - checks consistency against counterfactual predictions
  - reports cross-stream influence

- `src/explain.ns`
  - turns prediction paths and influence output into readable summaries

- `examples/demo.ns`
  - prints the history table
  - prints the next-state forecast
  - prints the consistency table
  - prints the counterfactual influence summary

- `tests/prediction_tests.ns`
  - verifies feature extraction, one-step prediction, consistency checking, and influence behavior

## Current User-Facing Behavior

The demo currently does this:

1. build a small synthetic history with streams `A`, `B`, and `C`
2. train the predictor
3. print the last observed history rows as a table
4. predict the next state for each stream
5. print the forecast as a table
6. run a full consistency check
7. print a source-by-target cross-check table
8. print a counterfactual influence summary

The key point is that the forecast is not only a number or label.
Each stream prediction includes:

- predicted value
- support score
- leaf sample count
- leaf depth
- decision path features

## Terminology

### Stream

A named column of time-ordered data.

Examples:

- numeric stream: `A = 3`, `B = 2.5`
- categorical stream: `C = "idle"` or `"active"`

### History

The history is a table of past rows.
Each row contains one value per stream.

The most recent row is treated as the current state for forecasting.

### Target Stream

The stream being predicted by one model.

The system trains one model per stream, so `A`, `B`, and `C` each get their own predictor.

### Feature

A derived value computed from the history to help prediction.

Current features:

- `current`: the current observed value
- `lag.N`: the value `N` rows back
- `delta.N`: `current - lag.N` for numeric values
- `rolling.W`: rolling average over the last `W` rows for numeric values
- `timeSinceChange`: number of rows since the stream last changed
- `pattern.W`: encoded recent pattern string for the last `W` values

### Support

A rough confidence signal returned with each prediction.

Current calculation:

`support = predicted_leaf_samples / root_samples`

So a value near `1` means the prediction lands in a large, common leaf.
A low value means the leaf is narrow or sparse.

### Consistency Score

The consistency score measures whether the direct next-state forecast agrees with the model’s own counterfactual predictions.

Current calculation:

`score = matches / comparisons`

where:

- `comparisons` = all source-target checks in the consistency matrix
- `matches` = checks where the direct forecast equals the counterfactual prediction

This is a self-consistency metric, not accuracy against ground truth.

### Counterfactual Influence

This asks:

“If I perturb one source stream, how do the predicted next values of the other streams change?”

This is reported as:

- source stream
- original value
- perturbed value
- predicted effect on each target stream

## Feature Calculations

### `current`

The current observed value from the last input row.

For categorical values, the system encodes them to numeric IDs internally so the tree can work with them.

### `lag.N`

The value from `N` rows back.

Example:

If the recent values of `A` are `[1, 3, 8]`, then:

- `A.lag.1 = 3`
- `A.lag.2 = 1`

### `delta.N`

The difference between the current numeric value and the lagged numeric value.

Formula:

`delta.N = current - lag.N`

Example:

If `A.current = 8` and `A.lag.1 = 3`, then:

`A.delta.1 = 5`

### `rolling.W`

The arithmetic mean of the last `W` numeric values.

Formula:

`rolling.W = sum(last W numeric values) / count(last W numeric values)`

If there are no numeric values in the window, the value is `0`.

### `timeSinceChange`

Counts how many rows have passed since the stream value changed.

Example:

If `C` has stayed `"idle"` for four rows, `timeSinceChange = 4`.

### `pattern.W`

Encodes the recent sequence of values as a string key.

Example:

`["idle", "idle", "active"] -> "String:idle|String:idle|String:active"`

This is then mapped to a numeric category ID.

## Tree Model Details

The predictor uses a compact decision-tree style learner.

### Training

For each target stream:

1. build training rows from the history
2. each training row contains extracted features from row `t`
3. the target value is taken from row `t+1`
4. train a tree on those feature/target pairs

### Split Search

The tree searches over numeric thresholds for each feature.

For every candidate split:

- split rows into `<= threshold` and `> threshold`
- compute child impurity
- compute information gain
- keep the best gain

### Numeric Targets

For numeric targets:

- prediction at a leaf is the mean target value in that leaf
- impurity is mean squared error around that mean

### Event/Categorical Targets

For non-numeric targets:

- prediction at a leaf is the most common target value
- impurity is `1 - majority_fraction`

### Tree Stopping Rules

Training stops when:

- max depth is reached
- sample count is too small
- best gain is below the minimum gain threshold

## Prediction Flow

The current one-step forecast path is:

1. take the latest history window
2. build features for the current row
3. predict each stream independently using its own trained tree
4. collect the forecast row for all streams

Returned data for each stream includes:

- `value`
- `support`
- `samples`
- `depth`
- `path`
- `features`

## Consistency Check

The system now cross-checks the forecast against every source stream, not only the streams that changed.

For each source stream:

1. take the last history row
2. replace that source stream with the forecast value for that stream
3. rerun prediction on the counterfactual history
4. compare every target stream in the counterfactual result to the direct forecast

This produces a matrix:

- source `A` vs target `A`, `B`, `C`
- source `B` vs target `A`, `B`, `C`
- source `C` vs target `A`, `B`, `C`

This is useful because it shows whether the model’s internal causal story is stable.

## Counterfactual Influence

This is related to, but distinct from, the consistency check.

Consistency asks:

“Does the forecast agree with the model when I plug forecast values back in?”

Influence asks:

“If I perturb source stream X, how do the other predictions move?”

The current implementation perturbs each source stream and reports the delta on every target stream.

## Important Current Limits

These are not bugs, just design boundaries to keep in mind:

1. It is one-step prediction, not long-horizon planning.
2. It is a tree-based heuristic learner, not a deep sequence model.
3. Counterfactual consistency is a self-check, not truth.
4. Support is a leaf-density style signal, not calibrated probability.
5. Categorical handling is encoded through category IDs and pattern strings, so it is explainable but not especially powerful.

## Current Files To Extend

If another agent wants to improve the system, the main files are:

- [src/predictor.ns](/home/phil/dev/pred/src/predictor.ns)
- [src/features.ns](/home/phil/dev/pred/src/features.ns)
- [src/tree.ns](/home/phil/dev/pred/src/tree.ns)
- [examples/demo.ns](/home/phil/dev/pred/examples/demo.ns)
- [tests/prediction_tests.ns](/home/phil/dev/pred/tests/prediction_tests.ns)

## Good Next Directions

1. Add backtesting against held-out history to measure real prediction accuracy.
2. Add ranked candidate next states instead of only one predicted row.
3. Add calibration for support/confidence.
4. Add explicit missing-value handling if real data contains gaps.
5. Add a scenario table that shows multiple possible futures instead of only one forecast.

## Run Commands

```bash
../ns/bin/ns tests/run_tests.ns
../ns/bin/ns examples/demo.ns
```

## Current Status

The repository is in a working state.
The tests pass and the demo prints:

- history table
- next-state forecast table
- full consistency matrix
- counterfactual influence summary

