# MatthewSort

An incredibly fast, multithreaded sorting algorithm implemented in Cython.

This library provides a high-performance sorting implementation that uses a parallelized bucket sort strategy and my own approximated index for fast speeds.

## Installation

Install `matthewsort` directly from PyPI:

```bash
pip install matthewsort
```

## Commands

Un-parallelized sort
```python
matthewsort.sort(<list>)
```
Parallelized sort
```python
matthewsort.supersort(<list>)
```

Both return a copy of the sorted list.

## Speed details

Time Complexity:
Best Case O(1)
Average Case: O(n)
Worst Case: O(n^2)
