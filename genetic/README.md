# genetic

Differential evolution and symbolic algorithm discovery for `ns`.

## Features

- Unified `run(fitness, problem, config)` entry point with `searchMode: "parameter"` or `searchMode: "discovery"`
- Parameter optimisation with `de.optimize(fitness, bounds, config)`
- Optional `de.optimizeBatch(batchFitness, bounds, config)` for population scoring in one call
- Matrix-backed dense vector helpers where native `matrice` operations fit
- Configurable `threads` value passed into fitness contexts for runtimes or callers that parallelize evaluation
- Algorithm discovery over math and logic expression trees
- Beam-search rule discovery for typed decision-rule problems
- Runtime tools for evaluating and rendering generated algorithms inside fitness tests

## Quick Start

```ns
genetic = import("./genetic.ns");

rows = [
    {week: 1, price: 10.0, promo: 0, sales: 121},
    {week: 2, price: 10.2, promo: 0, sales: 123},
    {week: 3, price: 9.8, promo: 1, sales: 148}
];

fitness = func(values, ctx) {
    total = 0;
    for (i = 0; i < rows.count(); i = i + 1) {
        forecast = values[0] + (values[1] * rows[i].week) + (values[2] * rows[i].promo);
        diff = forecast - rows[i].sales;
        if (diff < 0) diff = 0 - diff;
        total = total + diff;
    }
    return total / rows.count();
};

result = genetic.de.optimize(fitness, [
    {min: 80, max: 160},
    {min: -2, max: 6},
    {min: 0, max: 60}
], {
    populationSize: 48,
    generations: 100,
    threads: 4
});
```

The same search can be called through the framework entry point:

```ns
result = genetic.run(fitness, [{min: -10, max: 10}], {searchMode: "parameter"});
```

## Algorithm Discovery

```ns
discovery = import("./src/discover.ns");

rows = [
    {tickets: 3, daysIdle: 8, outage: 0, escalated: 1},
    {tickets: 1, daysIdle: 2, outage: 0, escalated: 0},
    {tickets: 4, daysIdle: 4, outage: 1, escalated: 1}
];

fitness = func(program, tools, ctx) {
    mistakes = 0;
    for (i = 0; i < rows.count(); i = i + 1) {
        score = tools.run(program, rows[i]);
        predicted = score >= 0.5 ? 1 : 0;
        if (predicted != rows[i].escalated) mistakes = mistakes + 1;
    }
    return mistakes;
};

result = discovery.evolve(fitness, {
    variables: ["tickets", "daysIdle", "outage"],
    constants: [0, 1, 2, 3, 5, 7, 10],
    operatorPreset: "rules"
});

printline(discovery.formatAlgorithm(result));
```

For decision-rule discovery, use the rule beam strategy. It builds typed atomic predicates, keeps the best beam, and composes those predicates with boolean operators:

```ns
result = discovery.evolve(fitness, {
    searchStrategy: "beam",
    beamWidth: 8,
    maxDepth: 3,
    variables: ["tickets", "daysIdle", "outage"],
    booleanVariables: ["outage"],
    comparisonOperators: ["gt"],
    constants: [0, 1, 2, 3, 5, 7, 10],
    operatorPreset: "rules"
});
```

Use the default evolutionary strategy for open-ended numeric formulas. Use `searchStrategy: "beam"` for professional rule induction where readable boolean rules are the desired output.

Operator presets keep the search space manageable:

- `math`: arithmetic expressions
- `compare`: comparisons and min/max
- `logic`: comparisons plus boolean operators
- `rules`: compact boolean decision rules
- `arithmeticRules`: arithmetic plus comparisons and boolean operators
- `all`: every built-in operator

You can still pass `operators: [...]` directly when a fitness test needs a precise custom set.

Useful discovery output helpers:

- `discovery.programToText(program)` renders the raw expression tree with internal operator names.
- `discovery.formatAlgorithm(resultOrProgram)` renders a human-readable algorithm and folds constant truthy subexpressions.
- `tools.human(program)` exposes the same human-readable rendering inside fitness callbacks.

Or through the unified entry point:

```ns
genetic = import("./genetic.ns");

result = genetic.run(fitness, {
    variables: ["x"],
    constants: [0, 1]
}, {
    searchMode: "discovery",
    searchStrategy: "beam",
    beamWidth: 4,
    maxDepth: 1,
    operatorPreset: "rules"
});
```

## Layout

- `genetic.ns` umbrella import
- `src/de.ns` differential evolution optimizer
- `src/discover.ns` symbolic algorithm discovery and runtime
- `genetic.discovery` umbrella export for the discovery module
- `src/vectors.ns` dense vector helpers
- `examples/` runnable demos
- `tests/` Nova-style tests

## Examples

- `examples/parameter_optimisation.ns` calibrates a demand forecast model against observed sales.
- `examples/batch_parameter_optimisation.ns` scores each generation through `de.optimizeBatch(batchFitness, bounds, config)`.
- `examples/algorithm_discovery.ns` discovers a readable escalation-risk rule from labelled operational rows.

## Run

```bash
ns tests/run_tests.ns
ns examples/parameter_optimisation.ns
ns examples/batch_parameter_optimisation.ns
ns examples/algorithm_discovery.ns
```
