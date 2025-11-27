# MatthewSort

An incredibly fast, multithreaded sorting algorithm implemented in Cython.

This library provides a high-performance sorting implementation that uses a bucket sort strategy, and my own approximated index for fast speeds.
It also includes a Parallelized version if you want to be unfair.


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

## Algorithm Struture and Future Plans

Within each bucket, the program uses my own variation on insersion sort, where instead if iterating through the unsorted list to find the min, it can take any value from the unsorted list, and determine the index it should be placed in the sorted list.
This process has an average time complexity of `O(log(log(n)))` making incredibly fast. 
The algorithm is inherintly slowed down by the time complexity of lst.insert() and thus a bucket sort improves its speed.
I plan to come up with a new method of insersion such that the time complexity of inserting is much faster while still being able to index lookup fast. Or perhaps a method that doesn't require an insert.

Doing said improvements should increase the speed of its worst case to `O(nlog(n))` and its best case will remain `O(n)`, however the amount of computations per iteration will be much faster.
