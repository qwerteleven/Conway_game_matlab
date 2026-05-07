# Conway's Game of Life — MATLAB

A collection of [MATLAB](https://www.mathworks.com/products/matlab.html) implementations of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life), progressing from a naive nested-loop approach to a fully vectorized convolution-based version capable of running at 1920×1080 resolution in real time.

---

## Overview

[Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) is a [cellular automaton](https://en.wikipedia.org/wiki/Cellular_automaton) devised by mathematician John Horton Conway in 1970. The universe is a 2D grid of cells, each either alive (1) or dead (0). At every time step the grid evolves according to four rules based on each cell's 8 neighbours:

1. A live cell with fewer than 2 live neighbours dies ([underpopulation](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules))
2. A live cell with 2 or 3 live neighbours survives
3. A live cell with more than 3 live neighbours dies ([overpopulation](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules))
4. A dead cell with exactly 3 live neighbours becomes alive ([reproduction](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules))

---

## Files

| File | Grid size | Method | Notes |
|------|-----------|--------|-------|
| `main.m` | 100×100 | Nested loops + modular indexing | Reference implementation with 30 ms pause |
| `conway_game.m` | 250×250 | Nested loops + modular indexing | Larger grid, no pause |
| `performance_quality.m` | 1000×1000 | `conv2('valid')` + inner loop | Hybrid: convolution for neighbour count, loop for rule application |
| `performance_quality_v2.m` | 700×700 | `conv2('same')` + fully vectorized | No loops at all |
| `conway_game_fast_1080.m` | 1920×1080 | `conv2('same')` + fully vectorized | HD resolution, non-square grid |

---

## Implementation Approaches

### 1. Naive Nested Loops (`main.m`, `conway_game.m`)

The original approach computes the neighbour count for each cell with a 3×3 loop over `(i-1:i+1, j-1:j+1)`, using [modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic) to wrap the grid edges (toroidal topology):

```matlab
t(mod(i_inner - 1, n) + 1, mod(j_inner - 1, n) + 1)
```

The rules are applied cell by cell in a double `for` loop over the entire grid. This is correct but scales as O(n²) iterations per frame with significant MATLAB overhead per loop iteration.

### 2. Convolution + Inner Loop (`performance_quality.m`)

Neighbour counting is replaced with a 2D [convolution](https://en.wikipedia.org/wiki/Convolution) using the kernel:

```
mask = [1 1 1
        1 0 1
        1 1 1]
```

`conv2(t, mask, 'valid')` computes the sum of all 8 neighbours for each interior cell in one vectorized operation. The centre of the kernel is 0, so the cell itself is excluded automatically. The result is an `(n-2)×(n-2)` matrix (border cells are skipped). The rule application still uses a double loop, but the expensive neighbour counting is eliminated.

### 3. Fully Vectorized (`performance_quality_v2.m`, `conway_game_fast_1080.m`)

Both neighbour counting and rule application are fully [vectorized](https://en.wikipedia.org/wiki/Array_programming) — no loops at all. Using `conv2(..., 'same')` preserves the original grid size (with zero-padding at edges). The four rules are encoded as element-wise logical operations:

```matlab
% Dead cells with exactly 3 neighbours become alive
t_0 = (t == 0);
t_0 = (poblations .* t_0) == 3;

% Live cells with 2 or 3 neighbours survive
t_1 = (t == 1);
t_1 = t_1 .* (poblations == 2 | poblations == 3);

t = t_0 + t_1;
```

This uses [element-wise multiplication](https://en.wikipedia.org/wiki/Hadamard_product_(matrices)) as a logical mask, avoiding any branching. The result is dramatically faster than the loop-based versions and scales to 1920×1080 (`conway_game_fast_1080.m`).

### Visualization

All versions use `image()` with `drawnow` to display the live grid:

```matlab
image(x, y, C .* 255)
drawnow
```

Cells are scaled by 255 to map binary (0/1) to the full display range. `drawnow` flushes the graphics queue each frame, enabling animation.

---

## Performance Comparison

| Approach | Grid | Neighbour count | Rule application |
|----------|------|-----------------|-----------------|
| Nested loops | 100–250 | 9-iteration inner loop per cell | Per-cell `if` |
| Conv + loop | 1000 | `conv2('valid')` — vectorized | Per-cell `if` (inner region only) |
| Full vectorized | 700–1080p | `conv2('same')` — vectorized | Element-wise logical ops |

The key insight is that MATLAB loop overhead makes cell-by-cell iteration very slow on large grids, while `conv2` is a single optimized C call. The vectorized rule application avoids the remaining bottleneck entirely.

---

## Key Concepts

| Concept | Wikipedia |
|---------|-----------|
| Conway's Game of Life | [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) |
| Cellular automaton | [Cellular automaton](https://en.wikipedia.org/wiki/Cellular_automaton) |
| 2D convolution | [Convolution](https://en.wikipedia.org/wiki/Convolution) |
| Array/vectorized programming | [Array programming](https://en.wikipedia.org/wiki/Array_programming) |
| Toroidal topology (wrap-around) | [Torus](https://en.wikipedia.org/wiki/Torus) |
| Modular arithmetic | [Modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic) |
| Hadamard (element-wise) product | [Hadamard product](https://en.wikipedia.org/wiki/Hadamard_product_(matrices)) |

---

## Requirements

- MATLAB (any recent version)
- No toolboxes required (`conv2` is built-in)

## Usage

```matlab
% Basic version (100×100)
main

% Larger grid (250×250)
conway_game

% High-performance (700×700, fully vectorized)
performance_quality_v2

% Full HD (1920×1080)
conway_game_fast_1080
```