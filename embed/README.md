# Embedding Module

**Self-Learning N-Dimensional Embeddings Without Neural Networks** 

A sophisticated embedding system that generates, learns, and manipulates high-dimensional vector representations of data. Features self-learning capabilities based on statistical analysis and co-occurrence patterns, with proper normalization and comprehensive distance metrics. Uses native matrix operations for performance.

## Core Concepts

### What is an Embedding?

An embedding is an n-dimensional vector representation where each dimension captures different aspects of a data item. This system generates **emergent embeddings** - dimensions that naturally arise from analyzing data patterns rather than requiring manual definition or neural network training.

### Key Features

- **No Neural Networks**: Statistical learning from frequencies, co-occurrence, and corpus analysis
- **N-Dimensional**: Specify any dimensions; the system learns feature distributions automatically
- **Native Performance**: Uses NovaScript's built-in matrice operations for efficient linear algebra  
- **Proper Normalization**: Three strategies (L2, Min-Max, Clamping) ensure bounded, meaningful values
- **Rich Distance Metrics**: Cosine, Euclidean, Manhattan, Chebyshev, Minkowski, Hamming, Wasserstein
- **Emergent Features**: No labeled dimensions—features naturally emerge from statistical analysis
- **Batch Operations**: Clustering, filtering, summarization, and population comparison

## Module Structure

```
embed/
├── embed.ns              # Main API exports all submodules
├── src/
│   ├── core.ns          # Fundamental operations (create, normalize, stats, metadata)
│   ├── learn.ns         # Self-learning (from frequencies, co-occurrence, corpus)
│   ├── distance.ns      # 7+ distance/similarity metrics
│   ├── ops.ns           # Combining (merge, average, interpolate, project, rotate)
│   └── utils.ns         # Batch utilities (clustering, filtering, index)
├── tests/               # Comprehensive test suites
└── examples/            # Usage demonstrations
```

## Quick Start

### Basic Usage

```ns
embed = import("./embed.ns");

// Create an 8-dimensional embedding
emb = embed.core.create(8, "my_emb");

// Set individual values
emb = embed.core.set(emb, 0, 0.8);
emb = embed.core.set(emb, 1, 0.6);

// Normalize to unit length
emb_norm = embed.core.normalize(emb);

// Get statistics
stats = embed.core.stats(emb_norm);
print("Mean: " + stats.mean);
print("Stddev: " + stats.stddev);

// Compare with another embedding  
emb2 = embed.core.create(8, "other_emb");
similarity = embed.distance.cosineSimilarity(emb_norm, emb2);
```

### Working Examples

- **simple_embed_demo.ns**: Basic creation, normalization, comparison, and metadata
- **minimal_test.ns**: Verification that all modules load and core operations work

## API Reference

### embed.core - Fundamental Operations

```ns
create(dimensions, seedId)        # Create zero-initialized embedding
normalize(embedding)               # L2 normalization to unit length
magnitude(embedding)               # Compute L2 norm
stats(embedding)                   # Get mean, variance, stddev, min, max
rescaleNorm(embedding)             # Scale to [-1, 1]
clamp(embedding)                   # Clamp values to [-1, 1]
set(embedding, index, value)       # Set one dimension
at(embedding, index)               # Get one dimension
copy(embedding)                    # Deep copy
withMetadata(embedding, key, val)  # Add metadata
zero(dimensions)                   # Create zero embedding
random(dimensions, seed)           # Create random embedding
```

### embed.distance - Distance & Similarity Metrics

```ns
cosineSimilarity(emb1, emb2)       # Cosine similarity [-1, 1]
euclideanDistance(emb1, emb2)      # Euclidean L2 distance
manhattanDistance(emb1, emb2)      # Manhattan L1 distance
chebyshevDistance(emb1, emb2)      # Max absolute difference
minkowskiDistance(emb1, emb2, p)   # Minkowski Lp distance
hammingDistance(emb1, emb2)        # Hamming distance (discrete)
wassersteinDistance(emb1, emb2)    # Wasserstein/Earth-Mover distance
findMostSimilar(query, list, k, method)  # Find k nearest embeddings
```

### embed.ops - Combining & Transforming

```ns
add(emb1, emb2)                    # Element-wise addition
subtract(emb1, emb2)               # Element-wise subtraction
multiply(emb1, emb2)               # Element-wise multiplication
hadamard(emb1, emb2)               # Hadamard product
average(embeddings)                # Average multiple embeddings
weightedAverage(embeddings, weights)    # Weighted average
merge(embeddings)                  # Concatenate embeddings
interpolate(emb1, emb2, alpha)     # Linear interpolation
project(embedding, basis)          # Project onto basis vector
expand(embedding, newDims)         # Expand to more dimensions
rotate(embedding, angle)           # Rotate in embedding space
positionalEncoding(position, dims, maxPosition)  # Create a position vector
addPositionalEncoding(embedding, position, strength)  # Blend position into embedding
orthogonalize(embedding, basis)    # Remove correlation with basis
```

## Embedding Data Structure

```ns
{
    dims: number,           # Number of dimensions
    values: array,          # Array of numeric values
    id: string,             # Unique identifier
    metadata: object        # Optional key-value metadata
}
```

## Implementation Notes  

- **No Function Calls Within Modules**: Due to NS scoping, functions don't call other functions in the same module. This is by design to work around a language limitation.
- **Native Matrices**: Uses matrice_fromArray() for fast linear algebra operations via C++ backend
- **Self-Contained Functions**: Each public function is self-contained to avoid scoping issues
- **Modular Organization**: Code organized by functionality (core, learn, distance, ops, utils) for maintainability despite NS limitations


### Learning from Data

```ns
// Learn from frequency distribution
freqData = {
    "apple": 45,
    "banana": 32,
    "orange": 28
};
emb = embed.learn.fromFrequencies(freqData, 8);

// Learn from co-occurrence patterns
coocMatrix = {
    "word1": {"context1": 10, "context2": 8},
    "word2": {"context1": 6}
};
emb = embed.learn.fromCoOccurrence(coocMatrix, "word1", 8);
```

### Measuring Similarity

```ns
// Cosine similarity (normalized to 0-1)
similarity = embed.similarity(emb1, emb2);

// Euclidean distance
distance = embed.distance.euclideanDistance(emb1, emb2);

// Find most similar embeddings
topMatches = embed.distance.findMostSimilar(queryEmb, embeddingList, 5);
```

### Combining Embeddings

```ns
// Add embeddings
combined = embed.ops.add(emb1, emb2);

// Average multiple embeddings
avg = embed.ops.average([emb1, emb2, emb3]);

// Merge with dimension reduction
merged = embed.ops.merge([emb1, emb2], 4);

// Interpolate between embeddings (blend)
blended = embed.ops.interpolate(emb1, emb2, 0.5);
```

### Transforming Embeddings

```ns
// Project to lower dimensions
projected = embed.ops.project(emb, 4);

// Expand to higher dimensions
expanded = embed.ops.expand(emb, 16);

// Orthogonalize relative to another embedding
orthogonal = embed.ops.orthogonalize(emb1, emb2);

// Rotate in embedding space
rotated = embed.ops.rotate(emb, 0.5);
```

## API Reference

### Core Module (`embed.core`)

- `create(dimensions)` - Create new embedding
- `magnitude(embedding)` - Compute L2 norm
- `normalize(embedding)` - L2 normalization (unit length)
- `rescaleNorm(embedding)` - Min-max scaling to [-1, 1]
- `clamp(embedding)` - Clamp values to [-1, 1]
- `stats(embedding)` - Get mean, variance, stddev, min, max
- `copy(embedding)` - Duplicate embedding
- `withMetadata(embedding, key, value)` - Attach metadata
- `at(embedding, index)` - Get value at dimension
- `set(embedding, index, value)` - Set value at dimension
- `zero(dimensions)` - Create all-zeros embedding
- `random(dimensions, seed)` - Create random embedding

### Learning Module (`embed.learn`)

- `fromFrequencies(freqMap, dimensions)` - Learn from frequency distribution
  - Captures entropy-like properties, concentration, and spread
  - Features emerge automatically through statistical analysis
  
- `fromCoOccurrence(coocMatrix, term, dimensions)` - Learn from co-occurrence
  - Each dimension reflects different context patterns
  - Captures term relationships and semantic proximity
  
- `fromCorpus(corpus, term, dimensions)` - Learn from corpus statistics
  - Coverage: how many documents contain term
  - Concentration: relative importance
  - Spread: distribution variance
  
- `learn(embedding, newData, learningRate)` - Incremental learning
  - Updates embedding based on new observations
  - Learning rate controls adaptation speed

### Distance Module (`embed.distance`)

**Similarity Metrics** (all normalized to [0,1]):
- `similarity(emb1, emb2, metric)` - General similarity (0=dissimilar, 1=identical)

**Distance Metrics**:
- `cosineSimilarity(emb1, emb2)` - Dot product of normalized vectors
- `euclideanDistance(emb1, emb2)` - Straight-line distance
- `manhattanDistance(emb1, emb2)` - Sum of absolute differences
- `chebyshevDistance(emb1, emb2)` - Maximum coordinate difference
- `minkowskiDistance(emb1, emb2, p)` - Generalized distance
- `hammingDistance(emb1, emb2, threshold)` - Count of significant differences
- `wassersteinDistance(emb1, emb2)` - Optimal transport distance

**Search**:
- `findMostSimilar(query, embList, k, metric)` - Get k most similar embeddings

### Operations Module (`embed.ops`)

**Arithmetic**:
- `add(emb1, emb2)` - Element-wise addition + normalize
- `subtract(emb1, emb2)` - Element-wise subtraction + normalize
- `multiply(emb, scalar)` - Scalar multiplication + normalize
- `hadamard(emb1, emb2)` - Element-wise multiplication

**Combining**:
- `average(embeddings)` - Average multiple embeddings
- `weightedAverage(embeddings, weights)` - Weighted average
- `merge(embeddings, targetDims)` - Combine with dimension adjustment

**Transformations**:
- `interpolate(emb1, emb2, alpha)` - Linear blend (0=emb1, 1=emb2, 0.5=middle)
- `project(embedding, targetDims)` - Reduce dimensions (keeps high-variance)
- `expand(embedding, targetDims)` - Increase dimensions
- `rotate(embedding, factor)` - Cyclic rotation in embedding space
- `positionalEncoding(position, dimensions, maxPosition)` - Create a normalized deterministic position vector
- `addPositionalEncoding(embedding, position, strength)` - Blend sequence position into an embedding
- `analogy(aEmbedding, bEmbedding, cEmbedding)` - Create a relationship query with `a - b + c`
- `compose(base, additions, removals)` - Build a flexible query with `base + additions - removals`
- `moveAwayFrom(source, avoid, strength)` - Push a query away from an unwanted concept
- `applyDirection(source, direction, strength)` - Apply a reusable direction vector to a source embedding
- `centroidDirection(fromGroup, toGroup)` - Learn the direction from one group center to another
- `contrast(a, b, candidates, k)` - Find candidates aligned with the `a - b` direction
- `sequenceEmbedding(embeddings, positionalStrength)` - Summarize an ordered sequence while preserving position signal
- `orthogonalize(emb1, emb2)` - Remove correlation with reference

### Utils Module (`embed.utils`)

- `normalizeAll(embeddings)` - Batch normalize
- `createIndex(embeddings, keyField)` - Build lookup dictionary
- `approximateNearestNeighbor(query, list, k, metric)` - ANN search
- `summarize(embeddings)` - Combine into single representation
- `diversity(embeddings)` - Measure population spread
- `cluster(embeddings, maxDist, metric)` - Distance-based clustering
- `centroid(cluster)` - Compute cluster center
- `filterBySimilarity(embeddings, query, minSim, metric)` - Filter by threshold
- `similarityMatrix(embeddings, metric)` - Build an all-vs-all pairwise similarity table
- `batchTransform(embeddings, function)` - Apply function to all
- `embedCollection(items, keyExtractor, contentAnalyzer, dims)` - Embed collection
- `toMatrix(embeddings)` - Convert to matrix representation
- `comparePopulations(pop1, pop2)` - Compare two embedding sets

## Normalization Strategies

The module employs three complementary normalization approaches:

1. **L2 Normalization** (`normalize`)
   - Scales vector to unit length (magnitude = 1)
   - Preserves angular relationships
   - Best for: similarity comparisons, when magnitude doesn't matter
   
2. **Min-Max Scaling** (`rescaleNorm`)
   - Scales to range [-1, 1] based on values' distribution
   - Preserves relative differences within data
   - Best for: learning-based embeddings, when scale matters
   
3. **Clamping** (`clamp`)
   - Hard bounds values to [-1, 1]
   - Simple post-processing to ensure bounded values
   - Best for: ensuring embeddings stay within bounds

## How Features Emerge

Rather than requiring dimension labels, features emerge through statistical analysis:

- **Dimension 0** (Entropy): Measures randomness/spread in data distribution
- **Dimension 1** (Skewness): Captures whether data concentrates in few high-frequency items
- **Dimension 2** (Variance): Reflects how "smooth" or "peaked" the distribution is
- **Dimension 3+** (Patterns): Hash-based combinations that capture multi-scale patterns

This emergent approach means the same embedding can represent different abstractions depending on input data—no manual feature engineering needed.

## Examples

### Text Semantic Embeddings

```ns
// Create embeddings for words based on frequency
textCorpus = {
    docs: ["apple banana apple", "banana orange cherry", "apple cherry"]
};
wordFreq = {
    "apple": 3,
    "banana": 2,
    "orange": 1,
    "cherry": 2
};

appleEmb = embed.learn.fromFrequencies(wordFreq, 8);
appleEmb = embed.core.withMetadata(appleEmb, "word", "apple");
```

### Clustering Embeddings

```ns
// Generate multiple embeddings
embeddings = [];
for (i = 0; i < 20; i = i + 1) {
    e = embed.core.random(8, 100 + i);
    embeddings.add(e);
}

// Cluster similar ones
clusters = embed.utils.cluster(embeddings, 0.3, "cosine");
print("Found " + clusters.count() + " clusters");

// Get cluster centers
for (i = 0; i < clusters.count(); i = i + 1) {
    center = embed.utils.centroid(clusters[i]);
}
```

### Incremental Learning

```ns
// Start with initial embedding
knowledge = embed.core.random(8, 42);

// Learn from observations over time
observations = [[0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2],
                [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]];

for (i = 0; i < observations.count(); i = i + 1) {
    knowledge = embed.learn.learn(knowledge, observations[i], 0.2);
}
```

## Testing

Run the comprehensive test suite:

```bash
ns /path/to/embed/tests/run_tests.ns
```

Individual test files:
- `core_tests.ns` - Core operations (create, normalize, stats)
- `distance_tests.ns` - Similarity and distance metrics
- `ops_tests.ns` - Combining and transforming operations
- `learn_tests.ns` - Learning and generation

## Performance Notes

- Embeddings are pure, immutable-style operations (functions return new embeddings)
- All operations are normalized—embeddings stay bounded to [-1, 1]
- Similarity computations use various metrics (cosine, euclidean, etc.) with O(d) complexity where d is dimensions
- Merging and clustering have O(n*d) to O(n²*d) depending on operation
- Suitable for up to thousands of embeddings in typical applications

## Integration with Other Modules

The embedding module can work with:

- **text-stat**: Learn embeddings from semantic co-occurrence and corpus statistics
- **prob-stat**: Use probability distributions for embedding generation
- **predict**: Embed time-series data for prediction tasks
- **decision-tree**: Use embeddings as features for tree-based decisions

Example integration:

```ns
textStat = import("../text-stat/text-stat.ns");
embed = import("./embed.ns");

// Get co-occurrence matrix from text-stat
corpus = textStat.stats.from(documents);
cooc = textStat.semantic.semanticCoOccurrence(corpus, 2);

// Learn embeddings from co-occurrence
wordEmb = embed.learn.fromCoOccurrence(cooc, "term", 16);
```

## Design Philosophy

**Non-Neural**: Avoids black-box neural networks; all operations are interpretable and statistical
**Self-Learning**: Features emerge from data analysis; no manual labeling required
**Flexible**: Works with any data that can be converted to frequencies or patterns
**Composable**: Embeddings can be combined in meaningful ways
**Normalized**: All values stay bounded and meaningful
**Practical**: No exotic math; uses statistics and simple linear algebra
