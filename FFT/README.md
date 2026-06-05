# FFT (ns)

Standalone fast Fourier transform module for ns.

## Features

- Complex-number helpers
- Radix-2 FFT for power-of-two sequence lengths
- DFT fallback for non-power-of-two lengths
- Inverse FFT
- Real-signal helpers
- Spectrum and dominant-bin utilities

## Layout

- `FFT.ns` umbrella import
- `src/core.ns` FFT and complex helpers
- `examples/` runnable scripts
- `tests/` Nova-style tests

## Quick Start

```bash
fft = import("./FFT.ns");

signal = [1, 0, 0, 0];
bins = fft.core.fftReal(signal);
printline(bins[0].re);
```

## Run

```bash
../../ns/bin/ns tests/run_tests.ns
../../ns/bin/ns examples/demo.ns
```
