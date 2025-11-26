# distutils: language=c++
# distutils: extra_compile_args = -fopenmp
# distutils: extra_link_args = -fopenmp
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: nonecheck=False
# cython: initializedcheck=False

from libcpp.vector cimport vector
from libcpp.algorithm cimport sort as std_sort
from cython.parallel import prange
import multiprocessing

# --- INTERNAL ALGORITHM (Marked 'nogil' for parallel execution) ---
cdef vector[double] sort_internal(vector[double] lst) nogil:
    cdef Py_ssize_t n = lst.size()
    if n <= 1: return lst

    cdef vector[double] sorted_vec
    sorted_vec.reserve(n)

    # 1. Handle first 9 items
    cdef int limit = 9
    if n < 9: limit = n

    cdef Py_ssize_t i
    for i in range(limit):
        sorted_vec.push_back(lst[i])

    std_sort(sorted_vec.begin(), sorted_vec.end())

    # 2. Main Logic Variables
    cdef double value
    cdef Py_ssize_t start, end, estimated_index
    cdef double denom_diff, denom_index
    cdef double start_val, end_val

    # 3. Main Loop
    for i in range(limit, n):
        value = lst[i]
        start = 0
        end = sorted_vec.size() - 1

        while True:
            start_val = sorted_vec[start]
            end_val = sorted_vec[end]
            denom_diff = end_val - start_val

            if denom_diff == 0:
                estimated_index = start
            else:
                denom_index = <double>(end - start)
                estimated_index = <Py_ssize_t>(
                    (value - start_val) * denom_index / denom_diff
                ) + start

            if estimated_index < start: estimated_index = start
            if estimated_index > end: estimated_index = end

            if sorted_vec[estimated_index] == value:
                sorted_vec.insert(sorted_vec.begin() + estimated_index, value)
                break
            elif value > sorted_vec[estimated_index]:
                if estimated_index >= end:
                    if value >= sorted_vec[end]:
                        sorted_vec.push_back(value)
                        break
                    estimated_index = end
                if value <= sorted_vec[estimated_index + 1]:
                    sorted_vec.insert(sorted_vec.begin() + estimated_index + 1, value)
                    break
                else:
                    start = estimated_index + 1
            else:
                if estimated_index <= start:
                    sorted_vec.insert(sorted_vec.begin() + start, value)
                    break
                if value >= sorted_vec[estimated_index - 1]:
                    sorted_vec.insert(sorted_vec.begin() + estimated_index, value)
                    break
                else:
                    end = estimated_index - 1
    return sorted_vec


# --- SINGLE-THREADED WRAPPER (Your Original) ---
def sort(list input_list):
    """
    Sorts a list of numbers using a high-speed single-threaded bucket sort.
    """
    cdef Py_ssize_t n = len(input_list)
    cdef vector[double] lst = input_list

    if n < 5000:
        return sort_internal(lst)

    # 1. Find Min/Max
    cdef double min_val = lst[0], max_val = lst[0]
    cdef double v
    for v in lst:
        if v < min_val: min_val = v
        if v > max_val: max_val = v
    if min_val == max_val: return input_list

    # 2. Create & Distribute Buckets
    cdef int bucket_count = <int>(n / 750) + 1
    cdef vector[vector[double]] buckets
    buckets.resize(bucket_count)
    cdef double range_val = max_val - min_val
    cdef int bucket_idx
    cdef double factor = (bucket_count - 1) / range_val
    for v in lst:
        bucket_idx = <int>((v - min_val) * factor)
        buckets[bucket_idx].push_back(v)

    # 3. Sort each bucket and combine
    cdef vector[double] final_result
    final_result.reserve(n)
    cdef vector[double] sorted_bucket
    cdef Py_ssize_t i
    for i in range(bucket_count):
        if buckets[i].size() > 0:
            sorted_bucket = sort_internal(buckets[i])
            final_result.insert(final_result.end(), sorted_bucket.begin(), sorted_bucket.end())

    return final_result

# --- MULTI-THREADED WRAPPER (The Throttled Super Sort) ---
def supersort(list input_list, int num_threads=-1):
    """
    Sorts a list of numbers using a multithreaded bucket sort.

    Args:
        input_list (list): The list of floats/integers to sort.
        num_threads (int): The number of threads to use.
                             -1 (default) uses all available CPU cores.
    """
    cdef Py_ssize_t n = len(input_list)
    cdef vector[double] lst = input_list

    if n < 20000: # Higher threshold for threading due to overhead
        return sort(input_list)

    # Determine thread count
    cdef int actual_num_threads = num_threads
    if actual_num_threads <= 0:
        actual_num_threads = multiprocessing.cpu_count()

    # 1. Find Min/Max
    cdef double min_val = lst[0], max_val = lst[0]
    cdef double v
    for v in lst:
        if v < min_val: min_val = v
        if v > max_val: max_val = v
    if min_val == max_val: return input_list

    # 2. Create & Distribute Buckets (Sequential is fastest to avoid locks)
    cdef int bucket_count = <int>(n / 1000) + 1
    cdef vector[vector[double]] buckets
    buckets.resize(bucket_count)
    cdef double range_val = max_val - min_val
    cdef int bucket_idx
    cdef double factor = (bucket_count - 1) / range_val
    for v in lst:
        bucket_idx = <int>((v - min_val) * factor)
        buckets[bucket_idx].push_back(v)

    # 3. PARALLEL SORTING OF BUCKETS
    cdef Py_ssize_t i
    # The 'nogil' block releases the Python Global Interpreter Lock,
    # allowing true C-level multithreading.
    with nogil:
        # prange distributes the loop across threads.
        # 'dynamic' schedule is best for uneven bucket sizes.
        for i in prange(bucket_count, num_threads=actual_num_threads, schedule='dynamic'):
            if buckets[i].size() > 0:
                # Each thread sorts its assigned bucket in-place.
                buckets[i] = sort_internal(buckets[i])

    # 4. Merge results (must be sequential to maintain order)
    cdef vector[double] final_result
    final_result.reserve(n)
    for i in range(bucket_count):
        if buckets[i].size() > 0:
            final_result.insert(final_result.end(), buckets[i].begin(), buckets[i].end())

    return final_result