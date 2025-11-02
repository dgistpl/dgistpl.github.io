---
layout: splash
author_profile: false
---

# Sorting Algorithms

Organize data to enable efficient access and computation.


### 1. Comparison sorts: quick/merge/heap
The three most important O(n log n) comparison-based sorting algorithms:

#### **Quick Sort**:
- **Approach**: Divide and conquer using partitioning
- **Time**: O(n log n) average, O(n²) worst case
- **Space**: O(log n) for recursion stack
- **In-place**: Yes
- **Stable**: No

**Implementation**:
```python
def quick_sort(arr, low, high):
    """Sort array using quick sort"""
    if low < high:
        # Partition and get pivot index
        pivot_idx = partition(arr, low, high)
        
        # Recursively sort left and right
        quick_sort(arr, low, pivot_idx - 1)
        quick_sort(arr, pivot_idx + 1, high)

def partition(arr, low, high):
    """Lomuto partition scheme"""
    pivot = arr[high]  # Choose last element as pivot
    i = low - 1  # Index of smaller element
    
    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    
    # Place pivot in correct position
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1

# Usage
arr = [64, 34, 25, 12, 22, 11, 90]
quick_sort(arr, 0, len(arr) - 1)
```

**Hoare partition (more efficient)**:
```python
def partition_hoare(arr, low, high):
    """Hoare partition scheme - fewer swaps"""
    pivot = arr[low]
    i = low - 1
    j = high + 1
    
    while True:
        i += 1
        while arr[i] < pivot:
            i += 1
        
        j -= 1
        while arr[j] > pivot:
            j -= 1
        
        if i >= j:
            return j
        
        arr[i], arr[j] = arr[j], arr[i]
```

**Optimizations**:
```python
def quick_sort_optimized(arr, low, high):
    """Quick sort with optimizations"""
    # Use insertion sort for small subarrays
    if high - low < 10:
        insertion_sort(arr, low, high)
        return
    
    if low < high:
        # Median-of-three pivot selection
        mid = (low + high) // 2
        if arr[mid] < arr[low]:
            arr[low], arr[mid] = arr[mid], arr[low]
        if arr[high] < arr[low]:
            arr[low], arr[high] = arr[high], arr[low]
        if arr[mid] < arr[high]:
            arr[mid], arr[high] = arr[high], arr[mid]
        
        pivot_idx = partition(arr, low, high)
        quick_sort_optimized(arr, low, pivot_idx - 1)
        quick_sort_optimized(arr, pivot_idx + 1, high)
```

#### **Merge Sort**:
- **Approach**: Divide and conquer with merging
- **Time**: O(n log n) always
- **Space**: O(n) for auxiliary array
- **In-place**: No
- **Stable**: Yes

**Implementation**:
```python
def merge_sort(arr):
    """Sort array using merge sort"""
    if len(arr) <= 1:
        return arr
    
    # Divide
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    
    # Conquer (merge)
    return merge(left, right)

def merge(left, right):
    """Merge two sorted arrays"""
    result = []
    i = j = 0
    
    # Merge while both have elements
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    
    # Add remaining elements
    result.extend(left[i:])
    result.extend(right[j:])
    
    return result
```

**In-place merge sort (more complex)**:
```python
def merge_sort_inplace(arr, left, right):
    """In-place merge sort"""
    if left < right:
        mid = (left + right) // 2
        merge_sort_inplace(arr, left, mid)
        merge_sort_inplace(arr, mid + 1, right)
        merge_inplace(arr, left, mid, right)

def merge_inplace(arr, left, mid, right):
    """Merge in-place using O(n) extra space"""
    temp = []
    i, j = left, mid + 1
    
    while i <= mid and j <= right:
        if arr[i] <= arr[j]:
            temp.append(arr[i])
            i += 1
        else:
            temp.append(arr[j])
            j += 1
    
    temp.extend(arr[i:mid+1])
    temp.extend(arr[j:right+1])
    
    for i, val in enumerate(temp):
        arr[left + i] = val
```

#### **Heap Sort**:
- **Approach**: Build max heap, repeatedly extract maximum
- **Time**: O(n log n) always
- **Space**: O(1)
- **In-place**: Yes
- **Stable**: No

**Implementation**:
```python
def heap_sort(arr):
    """Sort array using heap sort"""
    n = len(arr)
    
    # Build max heap
    for i in range(n // 2 - 1, -1, -1):
        heapify(arr, n, i)
    
    # Extract elements from heap
    for i in range(n - 1, 0, -1):
        # Move current root to end
        arr[0], arr[i] = arr[i], arr[0]
        
        # Heapify reduced heap
        heapify(arr, i, 0)

def heapify(arr, n, i):
    """Maintain max heap property"""
    largest = i
    left = 2 * i + 1
    right = 2 * i + 2
    
    # Check if left child is larger
    if left < n and arr[left] > arr[largest]:
        largest = left
    
    # Check if right child is larger
    if right < n and arr[right] > arr[largest]:
        largest = right
    
    # If largest is not root
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        heapify(arr, n, largest)
```

#### **Comparison**:

| Algorithm | Best | Average | Worst | Space | Stable | In-place |
|-----------|------|---------|-------|-------|--------|----------|
| Quick Sort | O(n log n) | O(n log n) | O(n²) | O(log n) | No | Yes |
| Merge Sort | O(n log n) | O(n log n) | O(n log n) | O(n) | Yes | No |
| Heap Sort | O(n log n) | O(n log n) | O(n log n) | O(1) | No | Yes |

### 2. Stability and in-place properties
Understanding important sorting algorithm characteristics:

#### **Stability**:
- **Definition**: Maintains relative order of equal elements
- **Example**: Sorting [(3, "a"), (1, "b"), (3, "c")] by first element
  - Stable: [(1, "b"), (3, "a"), (3, "c")] - "a" before "c"
  - Unstable: [(1, "b"), (3, "c"), (3, "a")] - order changed

**Why stability matters**:
```python
# Example: Sort students by grade, then by name
students = [
    ("Alice", 85),
    ("Bob", 90),
    ("Charlie", 85),
    ("David", 90)
]

# First sort by name (stable)
students.sort(key=lambda x: x[0])
# [("Alice", 85), ("Bob", 90), ("Charlie", 85), ("David", 90)]

# Then sort by grade (stable)
students.sort(key=lambda x: x[1])
# [("Alice", 85), ("Charlie", 85), ("Bob", 90), ("David", 90)]
# Within same grade, alphabetical order preserved!
```

**Stable algorithms**:
- ✓ Merge Sort
- ✓ Insertion Sort
- ✓ Bubble Sort
- ✓ Counting Sort
- ✓ Radix Sort

**Unstable algorithms**:
- ✗ Quick Sort (can be made stable with extra space)
- ✗ Heap Sort
- ✗ Selection Sort

**Making Quick Sort stable**:
```python
def stable_quick_sort(arr):
    """Stable quick sort using extra space"""
    if len(arr) <= 1:
        return arr
    
    pivot = arr[len(arr) // 2]
    
    # Maintain order of equal elements
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    
    return stable_quick_sort(left) + middle + stable_quick_sort(right)
```

#### **In-place sorting**:
- **Definition**: Uses O(1) extra space (excluding recursion stack)
- **Benefit**: Memory-efficient for large datasets

**In-place algorithms**:
- ✓ Quick Sort: O(log n) stack space
- ✓ Heap Sort: O(1) extra space
- ✓ Insertion Sort: O(1) extra space
- ✓ Selection Sort: O(1) extra space
- ✓ Bubble Sort: O(1) extra space

**Not in-place**:
- ✗ Merge Sort: O(n) auxiliary array
- ✗ Counting Sort: O(k) where k is range
- ✗ Radix Sort: O(n + k)

**Trade-offs**:
```python
# In-place but unstable
heap_sort(arr)  # O(1) space, unstable

# Stable but not in-place
merge_sort(arr)  # O(n) space, stable

# For most practical purposes:
arr.sort()  # Python's Timsort: stable, O(n) space worst case
```

### 3. Partitioning and recursion
Core concepts in divide-and-conquer sorting:

#### **Partitioning**:
- **Goal**: Rearrange array so elements < pivot are left, elements > pivot are right
- **Key operation**: In Quick Sort

**Lomuto partition**:
```python
def lomuto_partition(arr, low, high):
    """
    Simple but does more swaps
    Pivot: last element
    """
    pivot = arr[high]
    i = low - 1
    
    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1

# Example: [7, 2, 1, 6, 8, 5, 3, 4]
# Pivot = 4
# After partition: [2, 1, 3, 4, 8, 5, 7, 6]
#                           ↑ pivot at index 3
```

**Hoare partition**:
```python
def hoare_partition(arr, low, high):
    """
    More efficient, fewer swaps
    Pivot: first element
    """
    pivot = arr[low]
    i = low - 1
    j = high + 1
    
    while True:
        # Find element >= pivot from left
        i += 1
        while arr[i] < pivot:
            i += 1
        
        # Find element <= pivot from right
        j -= 1
        while arr[j] > pivot:
            j -= 1
        
        if i >= j:
            return j
        
        arr[i], arr[j] = arr[j], arr[i]
```

**3-way partitioning (Dutch National Flag)**:
```python
def three_way_partition(arr, low, high):
    """
    Partition into <pivot, =pivot, >pivot
    Efficient for many duplicates
    """
    if low >= high:
        return
    
    pivot = arr[high]
    i = low  # Boundary of < pivot
    j = low  # Current element
    k = high  # Boundary of > pivot
    
    while j <= k:
        if arr[j] < pivot:
            arr[i], arr[j] = arr[j], arr[i]
            i += 1
            j += 1
        elif arr[j] > pivot:
            arr[j], arr[k] = arr[k], arr[j]
            k -= 1
        else:
            j += 1
    
    return i, k

# Example: [3, 5, 2, 5, 1, 5, 4, 5]
# Pivot = 5
# After: [3, 2, 1, 4, 5, 5, 5, 5]
#                    ↑ all 5s together
```

#### **Recursion in sorting**:

**Recursion tree for Quick Sort**:
```
Array: [8, 3, 1, 7, 0, 10, 2]

                [8,3,1,7,0,10,2]
                      ↓ partition(pivot=2)
                [1,0,2,7,3,10,8]
               /                \
        [1,0]                    [7,3,10,8]
          ↓ pivot=0                ↓ pivot=8
       [0,1]                   [7,3,8,10]
                              /          \
                          [7,3]          [10]
                           ↓ pivot=3
                          [3,7]

Depth: O(log n) average, O(n) worst case
```

**Tail recursion optimization**:
```python
def quick_sort_tail_recursive(arr, low, high):
    """Optimize tail recursion to reduce stack space"""
    while low < high:
        pivot_idx = partition(arr, low, high)
        
        # Recurse on smaller partition
        if pivot_idx - low < high - pivot_idx:
            quick_sort_tail_recursive(arr, low, pivot_idx - 1)
            low = pivot_idx + 1
        else:
            quick_sort_tail_recursive(arr, pivot_idx + 1, high)
            high = pivot_idx - 1
```

**Iterative Quick Sort** (no recursion):
```python
def quick_sort_iterative(arr):
    """Quick sort without recursion"""
    stack = [(0, len(arr) - 1)]
    
    while stack:
        low, high = stack.pop()
        
        if low < high:
            pivot_idx = partition(arr, low, high)
            
            # Push subproblems to stack
            stack.append((low, pivot_idx - 1))
            stack.append((pivot_idx + 1, high))
```

### 4. Time/space complexities
Comprehensive complexity analysis:

#### **Time complexity table**:

| Algorithm | Best | Average | Worst | Notes |
|-----------|------|---------|-------|-------|
| Bubble Sort | O(n) | O(n²) | O(n²) | Best when nearly sorted |
| Selection Sort | O(n²) | O(n²) | O(n²) | Always O(n²) |
| Insertion Sort | O(n) | O(n²) | O(n²) | Best for small/nearly sorted |
| Merge Sort | O(n log n) | O(n log n) | O(n log n) | Consistent performance |
| Quick Sort | O(n log n) | O(n log n) | O(n²) | Worst with bad pivot |
| Heap Sort | O(n log n) | O(n log n) | O(n log n) | Consistent, in-place |
| Counting Sort | O(n + k) | O(n + k) | O(n + k) | k = range of values |
| Radix Sort | O(d(n + k)) | O(d(n + k)) | O(d(n + k)) | d = number of digits |
| Bucket Sort | O(n + k) | O(n + k) | O(n²) | Depends on distribution |

#### **Space complexity**:

| Algorithm | Space | Type |
|-----------|-------|------|
| Bubble Sort | O(1) | In-place |
| Selection Sort | O(1) | In-place |
| Insertion Sort | O(1) | In-place |
| Merge Sort | O(n) | Not in-place |
| Quick Sort | O(log n) | In-place (stack) |
| Heap Sort | O(1) | In-place |
| Counting Sort | O(k) | Not in-place |
| Radix Sort | O(n + k) | Not in-place |

#### **Lower bound for comparison sorts**:
```python
# Theorem: Any comparison-based sort needs Ω(n log n) comparisons
# Proof: Decision tree has n! leaves (all permutations)
# Height >= log₂(n!) ≈ n log n

import math

def min_comparisons(n):
    """Minimum comparisons needed to sort n elements"""
    return math.ceil(math.log2(math.factorial(n)))

# Examples:
# n=10: ~22 comparisons
# n=100: ~525 comparisons
```

#### **Practical performance**:
```python
import time
import random

def benchmark_sorts(n=10000):
    """Compare sorting algorithms"""
    arr = [random.randint(1, 1000) for _ in range(n)]
    
    # Quick Sort
    arr1 = arr.copy()
    start = time.time()
    quick_sort(arr1, 0, len(arr1) - 1)
    print(f"Quick Sort: {time.time() - start:.4f}s")
    
    # Merge Sort
    arr2 = arr.copy()
    start = time.time()
    merge_sort(arr2)
    print(f"Merge Sort: {time.time() - start:.4f}s")
    
    # Heap Sort
    arr3 = arr.copy()
    start = time.time()
    heap_sort(arr3)
    print(f"Heap Sort: {time.time() - start:.4f}s")
    
    # Python's built-in (Timsort)
    arr4 = arr.copy()
    start = time.time()
    arr4.sort()
    print(f"Timsort: {time.time() - start:.4f}s")

# Typical results (n=10000):
# Quick Sort: 0.0120s
# Merge Sort: 0.0180s
# Heap Sort: 0.0250s
# Timsort: 0.0015s (highly optimized C implementation)
```

### 5. Non-comparison sorts: counting/radix
Sorting algorithms that don't compare elements:

#### **Counting Sort**:
- **Idea**: Count occurrences of each value
- **Time**: O(n + k) where k = range of values
- **Space**: O(k)
- **Stable**: Yes
- **Limitation**: Only works for integers in known range

**Implementation**:
```python
def counting_sort(arr):
    """Sort array of non-negative integers"""
    if not arr:
        return arr
    
    # Find range
    max_val = max(arr)
    min_val = min(arr)
    range_size = max_val - min_val + 1
    
    # Count occurrences
    count = [0] * range_size
    for num in arr:
        count[num - min_val] += 1
    
    # Calculate cumulative count
    for i in range(1, range_size):
        count[i] += count[i - 1]
    
    # Build output array (stable)
    output = [0] * len(arr)
    for i in range(len(arr) - 1, -1, -1):
        num = arr[i]
        index = count[num - min_val] - 1
        output[index] = num
        count[num - min_val] -= 1
    
    return output

# Example: [4, 2, 2, 8, 3, 3, 1]
# Count: [1, 2, 2, 1, 0, 0, 0, 1] for values 1-8
# Output: [1, 2, 2, 3, 3, 4, 8]
```

**When to use**:
- Small range of integers (k ≈ n)
- Need stable sort
- Need O(n) time

#### **Radix Sort**:
- **Idea**: Sort digit by digit using stable sort
- **Time**: O(d(n + k)) where d = digits, k = base
- **Space**: O(n + k)
- **Stable**: Yes

**Implementation (LSD - Least Significant Digit)**:
```python
def radix_sort(arr):
    """Sort array using radix sort (base 10)"""
    if not arr:
        return arr
    
    # Find maximum number to know number of digits
    max_num = max(arr)
    
    # Do counting sort for every digit
    exp = 1
    while max_num // exp > 0:
        counting_sort_by_digit(arr, exp)
        exp *= 10

def counting_sort_by_digit(arr, exp):
    """Counting sort by specific digit"""
    n = len(arr)
    output = [0] * n
    count = [0] * 10  # Base 10
    
    # Count occurrences of digits
    for num in arr:
        digit = (num // exp) % 10
        count[digit] += 1
    
    # Cumulative count
    for i in range(1, 10):
        count[i] += count[i - 1]
    
    # Build output (stable)
    for i in range(n - 1, -1, -1):
        digit = (arr[i] // exp) % 10
        output[count[digit] - 1] = arr[i]
        count[digit] -= 1
    
    # Copy to original array
    for i in range(n):
        arr[i] = output[i]

# Example: [170, 45, 75, 90, 802, 24, 2, 66]
# Pass 1 (1s): [170, 90, 802, 2, 24, 45, 75, 66]
# Pass 2 (10s): [802, 2, 24, 45, 66, 170, 75, 90]
# Pass 3 (100s): [2, 24, 45, 66, 75, 90, 170, 802]
```

#### **Bucket Sort**:
- **Idea**: Distribute elements into buckets, sort each bucket
- **Time**: O(n + k) average, O(n²) worst
- **Best for**: Uniformly distributed data

**Implementation**:
```python
def bucket_sort(arr):
    """Sort array using bucket sort"""
    if not arr:
        return arr
    
    # Create buckets
    bucket_count = len(arr)
    max_val = max(arr)
    min_val = min(arr)
    bucket_range = (max_val - min_val) / bucket_count
    
    buckets = [[] for _ in range(bucket_count)]
    
    # Distribute elements into buckets
    for num in arr:
        if num == max_val:
            buckets[-1].append(num)
        else:
            index = int((num - min_val) / bucket_range)
            buckets[index].append(num)
    
    # Sort each bucket and concatenate
    result = []
    for bucket in buckets:
        result.extend(sorted(bucket))  # Use any sort
    
    return result
```

#### **Comparison**:

| Algorithm | Best Use Case | Limitation |
|-----------|---------------|------------|
| Counting Sort | Small integer range | Requires known range |
| Radix Sort | Fixed-length integers/strings | Not for arbitrary data |
| Bucket Sort | Uniform distribution | Poor for skewed data |

### 6. Practical considerations
Real-world factors in choosing sorting algorithms:

#### **Python's Timsort**:
- **Used in**: Python's `sort()` and `sorted()`
- **Hybrid**: Merge sort + Insertion sort
- **Time**: O(n log n) worst case, O(n) best case
- **Stable**: Yes
- **Optimized for**: Real-world data with runs

**Key features**:
```python
# Timsort exploits existing order
arr = [1, 2, 3, 4, 5, 100, 99, 98, 97, 96]
# Detects two runs: [1,2,3,4,5] and [100,99,98,97,96]
# Reverses second run, merges efficiently

# Much faster than O(n log n) for partially sorted data
```

#### **When to use each algorithm**:

**Small arrays (n < 50)**:
```python
def sort_small(arr):
    """Insertion sort for small arrays"""
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j] > key:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
```

**Nearly sorted data**:
```python
# Insertion sort: O(n) for nearly sorted
# Timsort: Excellent for real-world data
```

**Large arrays**:
```python
# Quick sort: Fastest average case
# Merge sort: Guaranteed O(n log n), stable
# Heap sort: In-place, guaranteed O(n log n)
```

**Limited memory**:
```python
# Heap sort: O(1) extra space
# Quick sort: O(log n) stack space
```

**Need stability**:
```python
# Merge sort
# Timsort
# Counting/Radix sort
```

#### **Optimization techniques**:

**1. Hybrid approaches**:
```python
def hybrid_sort(arr, low, high):
    """Quick sort with insertion sort for small subarrays"""
    if high - low < 10:
        insertion_sort(arr, low, high)
    else:
        pivot = partition(arr, low, high)
        hybrid_sort(arr, low, pivot - 1)
        hybrid_sort(arr, pivot + 1, high)
```

**2. Pivot selection**:
```python
def median_of_three(arr, low, high):
    """Choose median of first, middle, last"""
    mid = (low + high) // 2
    
    if arr[mid] < arr[low]:
        arr[low], arr[mid] = arr[mid], arr[low]
    if arr[high] < arr[low]:
        arr[low], arr[high] = arr[high], arr[low]
    if arr[mid] < arr[high]:
        arr[mid], arr[high] = arr[high], arr[mid]
    
    return high
```

**3. Parallel sorting**:
```python
from multiprocessing import Pool

def parallel_merge_sort(arr):
    """Parallel merge sort using multiple cores"""
    if len(arr) <= 1000:
        return sorted(arr)
    
    mid = len(arr) // 2
    
    with Pool(2) as pool:
        left, right = pool.map(parallel_merge_sort, 
                              [arr[:mid], arr[mid:]])
    
    return merge(left, right)
```

#### **Common mistakes**:
```python
# 1. Using bubble sort for large data
# BAD: O(n²) always
bubble_sort(large_array)

# GOOD: O(n log n)
large_array.sort()

# 2. Not considering stability
# BAD: May break secondary sort
quick_sort(students)  # Unstable

# GOOD: Preserves order
students.sort()  # Stable (Timsort)

# 3. Ignoring data characteristics
# BAD: Quick sort on already sorted data
quick_sort(sorted_array)  # O(n²) worst case!

# GOOD: Insertion sort or Timsort
insertion_sort(sorted_array)  # O(n) for sorted

# 4. Wrong algorithm for data type
# BAD: Comparison sort for small integers
merge_sort([1, 2, 3, 1, 2, 3])  # O(n log n)

# GOOD: Counting sort
counting_sort([1, 2, 3, 1, 2, 3])  # O(n)
```

#### **Decision tree**:
```python
def choose_sort_algorithm(arr, need_stable=False, memory_limited=False):
    """
    Choose appropriate sorting algorithm
    """
    n = len(arr)
    
    if n < 50:
        return "Insertion Sort"
    
    # Check if integers in small range
    if all(isinstance(x, int) for x in arr):
        range_size = max(arr) - min(arr) + 1
        if range_size < 2 * n:
            return "Counting Sort"
    
    if memory_limited:
        if need_stable:
            return "Merge Sort (in-place variant)"
        else:
            return "Heap Sort"
    
    if need_stable:
        return "Merge Sort or Timsort"
    
    return "Quick Sort (with optimizations)"
```
