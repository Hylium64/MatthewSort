# MatthewSort

An incredibly fast, multithreaded sorting algorithm implemented in Cython.

This library provides a high-performance sorting implementation that uses a parallelized bucket sort strategy and my own approximated index for fast speeds.

## Installation

Install `matthewsort` directly from PyPI:

```bash
pip install matthewsort
```

## Commands

 `<list>.matthewsort.sort()` Un-parallelized sort
  `<list>.matthewsort.supersort()` Parallelized sort
