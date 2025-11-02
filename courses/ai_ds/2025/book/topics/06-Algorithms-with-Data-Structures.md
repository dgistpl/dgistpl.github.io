---
layout: splash
author_profile: false
---
# Algorithms with Data Structures

Combine structures and algorithms to solve problems efficiently.


### Sorting algorithms overview

Sorting algorithms arrange elements in a specific order (ascending or descending). Different algorithms have different time/space complexities and stability properties.

**Comparison-based sorting algorithms:**

1. **Bubble Sort**: Repeatedly swap adjacent elements if they're in wrong order
   - Time: O(n²) worst/average, O(n) best (already sorted)
   - Space: O(1)
   - Stable: Yes
   - Use case: Educational purposes, very small datasets

2. **Selection Sort**: Find minimum element and swap with first unsorted position
   - Time: O(n²) in all cases
   - Space: O(1)
   - Stable: No (standard version)
   - Use case: Small datasets, memory-constrained environments

3. **Insertion Sort**: Build sorted array one element at a time by inserting each element into proper position
   - Time: O(n²) worst/average, O(n) best
   - Space: O(1)
   - Stable: Yes
   - Use case: Small datasets, nearly sorted data, online sorting

4. **Merge Sort**: Divide-and-conquer algorithm that splits array, sorts halves, and merges them
   - Time: O(n log n) in all cases
   - Space: O(n)
   - Stable: Yes
   - Use case: External sorting, linked lists, guaranteed O(n log n)

5. **Quick Sort**: Choose pivot, partition array around pivot, recursively sort partitions
   - Time: O(n log n) average, O(n²) worst
   - Space: O(log n) average (recursion stack)
   - Stable: No (standard version)
   - Use case: General-purpose sorting, in-place sorting needed

6. **Heap Sort**: Build max-heap, repeatedly extract maximum
   - Time: O(n log n) in all cases
   - Space: O(1)
   - Stable: No
   - Use case: When O(n log n) guarantee needed with O(1) space

**Non-comparison-based sorting:**

7. **Counting Sort**: Count occurrences of each value, reconstruct sorted array
   - Time: O(n + k) where k is range of input
   - Space: O(k)
   - Stable: Yes
   - Use case: Small integer range, duplicate values

8. **Radix Sort**: Sort digit by digit using stable sort as subroutine
   - Time: O(d * (n + k)) where d is number of digits
   - Space: O(n + k)
   - Stable: Yes
   - Use case: Integers, strings with fixed length

9. **Bucket Sort**: Distribute elements into buckets, sort each bucket
   - Time: O(n + k) average, O(n²) worst
   - Space: O(n + k)
   - Stable: Can be
   - Use case: Uniformly distributed data

**Sorting algorithm comparison table:**

| Algorithm      | Best Time  | Avg Time   | Worst Time | Space   | Stable | In-place |
|---------------|-----------|-----------|-----------|---------|--------|----------|
| Bubble Sort   | O(n)      | O(n²)     | O(n²)     | O(1)    | Yes    | Yes      |
| Selection Sort| O(n²)     | O(n²)     | O(n²)     | O(1)    | No     | Yes      |
| Insertion Sort| O(n)      | O(n²)     | O(n²)     | O(1)    | Yes    | Yes      |
| Merge Sort    | O(n log n)| O(n log n)| O(n log n)| O(n)    | Yes    | No       |
| Quick Sort    | O(n log n)| O(n log n)| O(n²)     | O(log n)| No     | Yes      |
| Heap Sort     | O(n log n)| O(n log n)| O(n log n)| O(1)    | No     | Yes      |
| Counting Sort | O(n + k)  | O(n + k)  | O(n + k)  | O(k)    | Yes    | No       |
| Radix Sort    | O(d(n+k)) | O(d(n+k)) | O(d(n+k)) | O(n+k)  | Yes    | No       |
| Bucket Sort   | O(n + k)  | O(n + k)  | O(n²)     | O(n)    | Yes    | No       |

**Example implementations:**

```python
# Quick Sort - Most commonly used general-purpose algorithm
def quick_sort(arr):
    if len(arr) <= 1:
        return arr

    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]

    return quick_sort(left) + middle + quick_sort(right)

# In-place version (more efficient)
def quick_sort_inplace(arr, low=0, high=None):
    if high is None:
        high = len(arr) - 1

    if low < high:
        pi = partition(arr, low, high)
        quick_sort_inplace(arr, low, pi - 1)
        quick_sort_inplace(arr, pi + 1, high)

    return arr

def partition(arr, low, high):
    pivot = arr[high]
    i = low - 1

    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]

    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1

# Merge Sort - Guaranteed O(n log n) and stable
def merge_sort(arr):
    if len(arr) <= 1:
        return arr

    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])

    return merge(left, right)

def merge(left, right):
    result = []
    i = j = 0

    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1

    result.extend(left[i:])
    result.extend(right[j:])
    return result

# Counting Sort - For small integer ranges
def counting_sort(arr):
    if not arr:
        return arr

    min_val = min(arr)
    max_val = max(arr)
    range_size = max_val - min_val + 1

    count = [0] * range_size
    output = [0] * len(arr)

    # Count occurrences
    for num in arr:
        count[num - min_val] += 1

    # Cumulative count
    for i in range(1, len(count)):
        count[i] += count[i - 1]

    # Build output (backward for stability)
    for i in range(len(arr) - 1, -1, -1):
        num = arr[i]
        output[count[num - min_val] - 1] = num
        count[num - min_val] -= 1

    return output

# Heap Sort - O(n log n) with O(1) space
def heap_sort(arr):
    n = len(arr)

    # Build max heap
    for i in range(n // 2 - 1, -1, -1):
        heapify(arr, n, i)

    # Extract elements from heap
    for i in range(n - 1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]
        heapify(arr, i, 0)

    return arr

def heapify(arr, n, i):
    largest = i
    left = 2 * i + 1
    right = 2 * i + 2

    if left < n and arr[left] > arr[largest]:
        largest = left

    if right < n and arr[right] > arr[largest]:
        largest = right

    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        heapify(arr, n, largest)

# Example usage:
arr = [64, 34, 25, 12, 22, 11, 90]
print("Original:", arr)
print("Quick Sort:", quick_sort(arr.copy()))
print("Merge Sort:", merge_sort(arr.copy()))
print("Heap Sort:", heap_sort(arr.copy()))
print("Counting Sort:", counting_sort(arr.copy()))
```

**Choosing the right sorting algorithm:**

1. **Use Quick Sort** when:
   - General-purpose sorting
   - Average O(n log n) is acceptable
   - In-place sorting is needed

2. **Use Merge Sort** when:
   - Stability is required
   - Guaranteed O(n log n) is needed
   - Sorting linked lists (no extra space needed)
   - External sorting (large datasets on disk)

3. **Use Heap Sort** when:
   - O(n log n) guarantee with O(1) space
   - Priority queue operations needed

4. **Use Insertion Sort** when:
   - Array is small (< 10-20 elements)
   - Array is nearly sorted
   - Online sorting (elements arrive one at a time)

5. **Use Counting/Radix Sort** when:
   - Sorting integers with small range
   - O(n) time is achievable
   - Stability is needed

**Hybrid approaches:**

Many production sorting implementations use hybrid approaches:

```python
# Timsort (Python's built-in sort) - hybrid of merge sort and insertion sort
# Used in Python's sorted() and list.sort()

def timsort_concept(arr):
    """
    Simplified concept of Timsort:
    1. Divide array into small runs
    2. Sort each run with insertion sort (efficient for small arrays)
    3. Merge runs using merge sort
    """
    MIN_RUN = 32

    # Sort individual runs with insertion sort
    for start in range(0, len(arr), MIN_RUN):
        end = min(start + MIN_RUN, len(arr))
        insertion_sort_range(arr, start, end)

    # Merge runs
    size = MIN_RUN
    while size < len(arr):
        for start in range(0, len(arr), size * 2):
            mid = min(start + size, len(arr))
            end = min(start + size * 2, len(arr))
            if mid < end:
                merge_inplace(arr, start, mid, end)
        size *= 2

    return arr

def insertion_sort_range(arr, left, right):
    for i in range(left + 1, right):
        key = arr[i]
        j = i - 1
        while j >= left and arr[j] > key:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key

def merge_inplace(arr, left, mid, right):
    left_arr = arr[left:mid]
    right_arr = arr[mid:right]

    i = j = 0
    k = left

    while i < len(left_arr) and j < len(right_arr):
        if left_arr[i] <= right_arr[j]:
            arr[k] = left_arr[i]
            i += 1
        else:
            arr[k] = right_arr[j]
            j += 1
        k += 1

    while i < len(left_arr):
        arr[k] = left_arr[i]
        i += 1
        k += 1

    while j < len(right_arr):
        arr[k] = right_arr[j]
        j += 1
        k += 1

# Introsort (C++'s std::sort) - hybrid of quick sort, heap sort, insertion sort
def introsort_concept(arr):
    """
    Simplified concept of Introsort:
    1. Start with quick sort
    2. Switch to heap sort if recursion depth exceeds threshold (avoid O(n²))
    3. Use insertion sort for small subarrays
    """
    import math
    max_depth = 2 * math.floor(math.log2(len(arr)))
    return introsort_helper(arr, 0, len(arr) - 1, max_depth)

def introsort_helper(arr, low, high, max_depth):
    size = high - low + 1

    # Use insertion sort for small arrays
    if size < 16:
        insertion_sort_range(arr, low, high + 1)
        return arr

    # Switch to heap sort if max depth exceeded
    if max_depth == 0:
        heap_sort_range(arr, low, high)
        return arr

    # Use quick sort
    if low < high:
        pi = partition(arr, low, high)
        introsort_helper(arr, low, pi - 1, max_depth - 1)
        introsort_helper(arr, pi + 1, high, max_depth - 1)

    return arr

def heap_sort_range(arr, low, high):
    # Heap sort on arr[low:high+1]
    temp = arr[low:high+1]
    heap_sort(temp)
    arr[low:high+1] = temp
```

### Searching algorithms overview

Searching algorithms find the position of a target element in a data structure. The choice depends on whether data is sorted and the data structure used.

**Linear Search:**
- Sequentially check each element
- Works on unsorted and sorted data
- Time: O(n)
- Space: O(1)

```python
def linear_search(arr, target):
    """
    Search for target in array.
    Returns index if found, -1 otherwise.
    """
    for i, val in enumerate(arr):
        if val == target:
            return i
    return -1

# Sentinel linear search (one less comparison per iteration)
def sentinel_linear_search(arr, target):
    n = len(arr)
    if n == 0:
        return -1

    # Save last element and put target there
    last = arr[n - 1]
    arr[n - 1] = target

    i = 0
    while arr[i] != target:
        i += 1

    # Restore last element
    arr[n - 1] = last

    # Check if target was found before sentinel
    if i < n - 1 or arr[n - 1] == target:
        return i
    return -1
```

**Binary Search:**
- Repeatedly divide sorted array in half
- Only works on sorted data
- Time: O(log n)
- Space: O(1) iterative, O(log n) recursive

```python
# Iterative binary search (preferred)
def binary_search(arr, target):
    """
    Search for target in sorted array.
    Returns index if found, -1 otherwise.
    """
    left, right = 0, len(arr) - 1

    while left <= right:
        mid = left + (right - left) // 2  # Avoid overflow

        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1

    return -1

# Recursive binary search
def binary_search_recursive(arr, target, left=0, right=None):
    if right is None:
        right = len(arr) - 1

    if left > right:
        return -1

    mid = left + (right - left) // 2

    if arr[mid] == target:
        return mid
    elif arr[mid] < target:
        return binary_search_recursive(arr, target, mid + 1, right)
    else:
        return binary_search_recursive(arr, target, left, mid - 1)

# Binary search variants
def binary_search_leftmost(arr, target):
    """Find leftmost (first) occurrence of target."""
    left, right = 0, len(arr)

    while left < right:
        mid = left + (right - left) // 2
        if arr[mid] < target:
            left = mid + 1
        else:
            right = mid

    if left < len(arr) and arr[left] == target:
        return left
    return -1

def binary_search_rightmost(arr, target):
    """Find rightmost (last) occurrence of target."""
    left, right = 0, len(arr)

    while left < right:
        mid = left + (right - left) // 2
        if arr[mid] <= target:
            left = mid + 1
        else:
            right = mid

    if left > 0 and arr[left - 1] == target:
        return left - 1
    return -1

def binary_search_insert_position(arr, target):
    """Find position where target should be inserted to maintain sorted order."""
    left, right = 0, len(arr)

    while left < right:
        mid = left + (right - left) // 2
        if arr[mid] < target:
            left = mid + 1
        else:
            right = mid

    return left
```

**Interpolation Search:**
- Improved binary search for uniformly distributed sorted data
- Estimates position based on value
- Time: O(log log n) average, O(n) worst
- Space: O(1)

```python
def interpolation_search(arr, target):
    """
    Search in uniformly distributed sorted array.
    More efficient than binary search when data is uniformly distributed.
    """
    left, right = 0, len(arr) - 1

    while left <= right and target >= arr[left] and target <= arr[right]:
        # Avoid division by zero
        if arr[left] == arr[right]:
            if arr[left] == target:
                return left
            return -1

        # Estimate position
        pos = left + ((target - arr[left]) * (right - left) //
                      (arr[right] - arr[left]))

        if arr[pos] == target:
            return pos
        elif arr[pos] < target:
            left = pos + 1
        else:
            right = pos - 1

    return -1
```

**Exponential Search:**
- Find range where target exists, then binary search
- Good for unbounded/infinite arrays
- Time: O(log n)
- Space: O(1)

```python
def exponential_search(arr, target):
    """
    Useful for unbounded arrays or when target is near beginning.
    """
    if not arr:
        return -1

    if arr[0] == target:
        return 0

    # Find range for binary search
    i = 1
    while i < len(arr) and arr[i] <= target:
        i *= 2

    # Binary search in found range
    return binary_search_range(arr, target, i // 2, min(i, len(arr) - 1))

def binary_search_range(arr, target, left, right):
    while left <= right:
        mid = left + (right - left) // 2

        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1

    return -1
```

**Jump Search:**
- Jump ahead by fixed steps, then linear search
- Time: O(√n)
- Space: O(1)

```python
import math

def jump_search(arr, target):
    """
    Jump ahead by √n steps, then linear search in block.
    Good balance between linear and binary search.
    """
    n = len(arr)
    step = int(math.sqrt(n))
    prev = 0

    # Find block where target may exist
    while prev < n and arr[min(step, n) - 1] < target:
        prev = step
        step += int(math.sqrt(n))
        if prev >= n:
            return -1

    # Linear search in block
    while prev < n and arr[prev] < target:
        prev += 1
        if prev == min(step, n):
            return -1

    # Check if target found
    if prev < n and arr[prev] == target:
        return prev

    return -1
```

**Ternary Search:**
- Divide array into three parts
- Time: O(log₃ n) ≈ O(log n) (but slower than binary search in practice)
- Space: O(1)
- Useful for finding maximum/minimum of unimodal functions

```python
def ternary_search(arr, target):
    """
    Divides array into three parts.
    Generally slower than binary search for discrete arrays.
    """
    left, right = 0, len(arr) - 1

    while left <= right:
        mid1 = left + (right - left) // 3
        mid2 = right - (right - left) // 3

        if arr[mid1] == target:
            return mid1
        if arr[mid2] == target:
            return mid2

        if target < arr[mid1]:
            right = mid1 - 1
        elif target > arr[mid2]:
            left = mid2 + 1
        else:
            left = mid1 + 1
            right = mid2 - 1

    return -1

# Ternary search for finding maximum of unimodal function
def ternary_search_max(f, left, right, epsilon=1e-9):
    """
    Find maximum of unimodal function f in range [left, right].
    """
    while right - left > epsilon:
        mid1 = left + (right - left) / 3
        mid2 = right - (right - left) / 3

        if f(mid1) < f(mid2):
            left = mid1
        else:
            right = mid2

    return (left + right) / 2
```

**Hash-based Search:**
- Use hash table for O(1) average search
- Time: O(1) average, O(n) worst
- Space: O(n)

```python
def hash_search_setup(arr):
    """Build hash table for O(1) searches."""
    hash_table = {}
    for i, val in enumerate(arr):
        if val not in hash_table:
            hash_table[val] = []
        hash_table[val].append(i)
    return hash_table

def hash_search(hash_table, target):
    """Search using prebuilt hash table."""
    return hash_table.get(target, [])

# Example:
arr = [4, 2, 7, 2, 9, 2]
ht = hash_search_setup(arr)
print(hash_search(ht, 2))  # [1, 3, 5]
```

**Search algorithm comparison:**

| Algorithm        | Data Structure | Sorted? | Time (Avg)  | Time (Worst) | Space  | Best Use Case                |
|-----------------|----------------|---------|-------------|--------------|--------|------------------------------|
| Linear          | Array/List     | No      | O(n)        | O(n)         | O(1)   | Small/unsorted data          |
| Binary          | Array          | Yes     | O(log n)    | O(log n)     | O(1)   | General sorted data          |
| Interpolation   | Array          | Yes     | O(log log n)| O(n)         | O(1)   | Uniformly distributed data   |
| Jump            | Array          | Yes     | O(√n)       | O(√n)        | O(1)   | Jump cost < comparison cost  |
| Exponential     | Array          | Yes     | O(log n)    | O(log n)     | O(1)   | Unbounded/target near start  |
| Hash            | Hash Table     | No      | O(1)        | O(n)         | O(n)   | Multiple searches            |

**Practical search scenarios:**

```python
# Finding all occurrences in sorted array
def find_all_occurrences(arr, target):
    """Find all indices where target appears in sorted array."""
    left = binary_search_leftmost(arr, target)
    if left == -1:
        return []

    right = binary_search_rightmost(arr, target)
    return list(range(left, right + 1))

# Finding closest element in sorted array
def find_closest(arr, target):
    """Find element closest to target in sorted array."""
    if not arr:
        return -1

    pos = binary_search_insert_position(arr, target)

    if pos == 0:
        return 0
    if pos == len(arr):
        return len(arr) - 1

    # Compare neighbors
    if abs(arr[pos - 1] - target) <= abs(arr[pos] - target):
        return pos - 1
    return pos

# Finding peak element (element greater than neighbors)
def find_peak(arr):
    """Find any peak element in array using binary search."""
    left, right = 0, len(arr) - 1

    while left < right:
        mid = left + (right - left) // 2

        if arr[mid] < arr[mid + 1]:
            left = mid + 1
        else:
            right = mid

    return left

# Searching in rotated sorted array
def search_rotated(arr, target):
    """Search in rotated sorted array (e.g., [4,5,6,7,0,1,2])."""
    left, right = 0, len(arr) - 1

    while left <= right:
        mid = left + (right - left) // 2

        if arr[mid] == target:
            return mid

        # Determine which half is sorted
        if arr[left] <= arr[mid]:  # Left half is sorted
            if arr[left] <= target < arr[mid]:
                right = mid - 1
            else:
                left = mid + 1
        else:  # Right half is sorted
            if arr[mid] < target <= arr[right]:
                left = mid + 1
            else:
                right = mid - 1

    return -1

# Example usage:
arr = [1, 2, 2, 2, 3, 4, 5]
print("All occurrences of 2:", find_all_occurrences(arr, 2))  # [1, 2, 3]
print("Closest to 2.7:", arr[find_closest(arr, 2.7)])  # 3

peaks = [1, 3, 20, 4, 1, 0]
print("Peak element index:", find_peak(peaks))  # 2 (value 20)

rotated = [4, 5, 6, 7, 0, 1, 2]
print("5 in rotated array at:", search_rotated(rotated, 5))  # 1
```

### Graph algorithms: shortest path/MST

Graph algorithms solve problems on networks of connected nodes. Two fundamental problem categories are finding shortest paths and constructing minimum spanning trees.

**Shortest Path Algorithms:**

**1. Dijkstra's Algorithm** (Single-source shortest paths, non-negative weights)
- Time: O((V + E) log V) with min-heap
- Space: O(V)
- Greedy approach: always expand nearest unvisited node

```python
import heapq
from collections import defaultdict

def dijkstra(graph, start):
    """
    Find shortest paths from start to all vertices.
    Graph: adjacency list {node: [(neighbor, weight), ...]}
    Returns: {node: (distance, parent)}
    """
    distances = {start: 0}
    parents = {start: None}
    pq = [(0, start)]  # (distance, node)
    visited = set()

    while pq:
        dist, node = heapq.heappop(pq)

        if node in visited:
            continue

        visited.add(node)

        for neighbor, weight in graph[node]:
            if neighbor in visited:
                continue

            new_dist = dist + weight

            if neighbor not in distances or new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                parents[neighbor] = node
                heapq.heappush(pq, (new_dist, neighbor))

    return distances, parents

def reconstruct_path(parents, start, end):
    """Reconstruct shortest path from start to end."""
    if end not in parents:
        return None

    path = []
    current = end
    while current is not None:
        path.append(current)
        current = parents[current]

    return path[::-1]

# Example usage:
graph = {
    'A': [('B', 4), ('C', 2)],
    'B': [('C', 1), ('D', 5)],
    'C': [('D', 8), ('E', 10)],
    'D': [('E', 2)],
    'E': []
}

distances, parents = dijkstra(graph, 'A')
print("Distances from A:", distances)
# {'A': 0, 'C': 2, 'B': 4, 'D': 8, 'E': 10}

print("Path A to E:", reconstruct_path(parents, 'A', 'E'))
# ['A', 'C', 'B', 'D', 'E'] or similar shortest path
```

**2. Bellman-Ford Algorithm** (Single-source, handles negative weights)
- Time: O(VE)
- Space: O(V)
- Can detect negative cycles

```python
def bellman_ford(graph, start, num_vertices):
    """
    Find shortest paths, can handle negative weights.
    Graph: list of edges [(u, v, weight), ...]
    Returns: (distances, parents) or None if negative cycle
    """
    distances = {i: float('inf') for i in range(num_vertices)}
    distances[start] = 0
    parents = {i: None for i in range(num_vertices)}

    # Relax edges V-1 times
    for _ in range(num_vertices - 1):
        for u, v, weight in graph:
            if distances[u] != float('inf') and distances[u] + weight < distances[v]:
                distances[v] = distances[u] + weight
                parents[v] = u

    # Check for negative cycles
    for u, v, weight in graph:
        if distances[u] != float('inf') and distances[u] + weight < distances[v]:
            return None  # Negative cycle detected

    return distances, parents

# Example:
edges = [
    (0, 1, 4), (0, 2, 2),
    (1, 2, 1), (1, 3, 5),
    (2, 3, 8), (2, 4, 10),
    (3, 4, 2)
]

result = bellman_ford(edges, 0, 5)
if result:
    distances, parents = result
    print("Distances:", distances)
else:
    print("Negative cycle detected")
```

**3. Floyd-Warshall Algorithm** (All-pairs shortest paths)
- Time: O(V³)
- Space: O(V²)
- Finds shortest paths between all pairs

```python
def floyd_warshall(graph, num_vertices):
    """
    Find shortest paths between all pairs of vertices.
    Graph: adjacency matrix (graph[i][j] = weight or inf)
    Returns: distance matrix and next matrix for path reconstruction
    """
    dist = [[float('inf')] * num_vertices for _ in range(num_vertices)]
    next_node = [[None] * num_vertices for _ in range(num_vertices)]

    # Initialize
    for i in range(num_vertices):
        dist[i][i] = 0

    for i in range(num_vertices):
        for j in range(num_vertices):
            if graph[i][j] != float('inf'):
                dist[i][j] = graph[i][j]
                next_node[i][j] = j

    # Floyd-Warshall main loop
    for k in range(num_vertices):
        for i in range(num_vertices):
            for j in range(num_vertices):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
                    next_node[i][j] = next_node[i][k]

    return dist, next_node

def reconstruct_path_floyd(next_node, start, end):
    """Reconstruct path from Floyd-Warshall next matrix."""
    if next_node[start][end] is None:
        return None

    path = [start]
    while start != end:
        start = next_node[start][end]
        path.append(start)

    return path

# Example:
INF = float('inf')
graph = [
    [0, 4, 2, INF],
    [INF, 0, 1, 5],
    [INF, INF, 0, 8],
    [INF, INF, INF, 0]
]

dist, next_node = floyd_warshall(graph, 4)
print("All-pairs shortest distances:")
for row in dist:
    print(row)

print("Path 0 to 3:", reconstruct_path_floyd(next_node, 0, 3))
```

**4. A* Algorithm** (Heuristic-guided shortest path)
- Time: O(E) best case, O(b^d) worst (b=branching, d=depth)
- Space: O(V)
- Uses heuristic to guide search

```python
def a_star(graph, start, goal, heuristic):
    """
    Find shortest path using A* with heuristic.
    heuristic: function(node, goal) -> estimated distance
    """
    from heapq import heappush, heappop

    open_set = [(0, start)]  # (f_score, node)
    came_from = {}
    g_score = {start: 0}
    f_score = {start: heuristic(start, goal)}

    while open_set:
        _, current = heappop(open_set)

        if current == goal:
            # Reconstruct path
            path = []
            while current in came_from:
                path.append(current)
                current = came_from[current]
            path.append(start)
            return path[::-1]

        for neighbor, weight in graph[current]:
            tentative_g = g_score[current] + weight

            if neighbor not in g_score or tentative_g < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + heuristic(neighbor, goal)
                heappush(open_set, (f_score[neighbor], neighbor))

    return None  # No path found

# Example: Grid pathfinding with Manhattan distance
def manhattan_distance(pos1, pos2):
    return abs(pos1[0] - pos2[0]) + abs(pos1[1] - pos2[1])

# Grid graph
grid_graph = {
    (0, 0): [((0, 1), 1), ((1, 0), 1)],
    (0, 1): [((0, 0), 1), ((1, 1), 1), ((0, 2), 1)],
    (0, 2): [((0, 1), 1), ((1, 2), 1)],
    (1, 0): [((0, 0), 1), ((2, 0), 1), ((1, 1), 1)],
    (1, 1): [((0, 1), 1), ((1, 0), 1), ((1, 2), 1), ((2, 1), 1)],
    (1, 2): [((0, 2), 1), ((1, 1), 1), ((2, 2), 1)],
    (2, 0): [((1, 0), 1), ((2, 1), 1)],
    (2, 1): [((2, 0), 1), ((1, 1), 1), ((2, 2), 1)],
    (2, 2): [((2, 1), 1), ((1, 2), 1)]
}

path = a_star(grid_graph, (0, 0), (2, 2), manhattan_distance)
print("A* path:", path)  # [(0, 0), (1, 1), (2, 2)] or similar
```

**Minimum Spanning Tree (MST) Algorithms:**

An MST connects all vertices with minimum total edge weight, forming a tree (no cycles).

**1. Kruskal's Algorithm** (Edge-based, uses Union-Find)
- Time: O(E log E) or O(E log V)
- Space: O(V)
- Sort edges, add if doesn't create cycle

```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)

        if root_x == root_y:
            return False

        if self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        elif self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1

        return True

def kruskal(num_vertices, edges):
    """
    Find MST using Kruskal's algorithm.
    edges: list of (weight, u, v)
    Returns: list of edges in MST and total weight
    """
    edges = sorted(edges)  # Sort by weight
    uf = UnionFind(num_vertices)
    mst = []
    total_weight = 0

    for weight, u, v in edges:
        if uf.union(u, v):
            mst.append((u, v, weight))
            total_weight += weight

            if len(mst) == num_vertices - 1:
                break

    return mst, total_weight

# Example:
edges = [
    (1, 0, 1), (2, 0, 2), (3, 1, 2),
    (4, 1, 3), (5, 2, 3), (6, 2, 4),
    (7, 3, 4)
]

mst, weight = kruskal(5, edges)
print("MST edges:", mst)
print("Total weight:", weight)
```

**2. Prim's Algorithm** (Vertex-based, uses priority queue)
- Time: O((V + E) log V) with min-heap
- Space: O(V)
- Grow MST one vertex at a time

```python
def prim(graph, start=0):
    """
    Find MST using Prim's algorithm.
    graph: adjacency list {node: [(neighbor, weight), ...]}
    Returns: list of edges in MST and total weight
    """
    import heapq

    visited = set()
    mst = []
    total_weight = 0

    # Start with arbitrary vertex
    visited.add(start)
    edges = [(weight, start, neighbor) for neighbor, weight in graph[start]]
    heapq.heapify(edges)

    while edges and len(visited) < len(graph):
        weight, u, v = heapq.heappop(edges)

        if v in visited:
            continue

        # Add edge to MST
        mst.append((u, v, weight))
        total_weight += weight
        visited.add(v)

        # Add new edges from v
        for neighbor, edge_weight in graph[v]:
            if neighbor not in visited:
                heapq.heappush(edges, (edge_weight, v, neighbor))

    return mst, total_weight

# Example:
graph = {
    0: [(1, 1), (2, 2)],
    1: [(0, 1), (2, 3), (3, 4)],
    2: [(0, 2), (1, 3), (3, 5), (4, 6)],
    3: [(1, 4), (2, 5), (4, 7)],
    4: [(2, 6), (3, 7)]
}

mst, weight = prim(graph)
print("MST edges:", mst)
print("Total weight:", weight)
```

**Shortest Path vs MST Comparison:**

| Algorithm      | Problem Type | Graph Type     | Time Complexity    | Space | Notes                    |
|---------------|--------------|----------------|--------------------|-------|--------------------------|
| Dijkstra      | Single-source| Weighted, ≥0   | O((V+E) log V)    | O(V)  | Greedy, min-heap         |
| Bellman-Ford  | Single-source| Weighted, any  | O(VE)             | O(V)  | Detects negative cycles  |
| Floyd-Warshall| All-pairs    | Weighted, any  | O(V³)             | O(V²) | Dense graphs             |
| A*            | Single-pair  | Weighted, ≥0   | Varies            | O(V)  | Heuristic-guided         |
| Kruskal       | MST          | Weighted       | O(E log E)        | O(V)  | Edge-based, Union-Find   |
| Prim          | MST          | Weighted       | O((V+E) log V)    | O(V)  | Vertex-based, min-heap   |

**Practical applications:**

```python
# Network routing: Find shortest path with bandwidth constraints
def dijkstra_with_bandwidth(graph, start, min_bandwidth):
    """Modified Dijkstra that only uses edges with sufficient bandwidth."""
    distances = {start: 0}
    parents = {start: None}
    pq = [(0, start)]
    visited = set()

    while pq:
        dist, node = heapq.heappop(pq)

        if node in visited:
            continue

        visited.add(node)

        for neighbor, weight, bandwidth in graph[node]:
            if bandwidth < min_bandwidth or neighbor in visited:
                continue

            new_dist = dist + weight

            if neighbor not in distances or new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                parents[neighbor] = node
                heapq.heappush(pq, (new_dist, neighbor))

    return distances, parents

# Road network: Find alternative routes (k shortest paths)
def k_shortest_paths(graph, start, end, k):
    """Find k shortest paths from start to end."""
    import heapq

    # This is a simplified version using Yen's algorithm concept
    paths = []
    potential_paths = [(0, [start], set())]

    while len(paths) < k and potential_paths:
        dist, path, removed_edges = heapq.heappop(potential_paths)

        if path[-1] == end:
            paths.append((dist, path))
            continue

        current = path[-1]
        for neighbor, weight in graph[current]:
            if neighbor not in path:
                new_path = path + [neighbor]
                new_dist = dist + weight
                heapq.heappush(potential_paths, (new_dist, new_path, removed_edges))

    return paths

# MST with degree constraints
def mst_degree_constrained(graph, max_degree):
    """
    Find MST where no vertex has degree > max_degree.
    This is NP-hard in general; this is a greedy approximation.
    """
    # Track degree of each vertex
    degree = defaultdict(int)
    mst = []
    total_weight = 0
    uf = UnionFind(len(graph))

    # Sort edges by weight
    all_edges = []
    for u in graph:
        for v, weight in graph[u]:
            if u < v:  # Avoid duplicates
                all_edges.append((weight, u, v))

    all_edges.sort()

    for weight, u, v in all_edges:
        # Check degree constraint and cycle
        if (degree[u] < max_degree and degree[v] < max_degree and
            uf.union(u, v)):
            mst.append((u, v, weight))
            total_weight += weight
            degree[u] += 1
            degree[v] += 1

            if len(mst) == len(graph) - 1:
                break

    return mst, total_weight
```

### Dynamic programming with structures

Dynamic Programming (DP) optimizes by storing solutions to subproblems, avoiding redundant computation. The choice of data structure significantly impacts DP efficiency.

**Common DP data structures:**

1. **1D Array/List**: For problems with single-dimensional state
2. **2D Array/Matrix**: For problems with two-dimensional state
3. **Hash Table/Dictionary**: For sparse state space or complex state representation
4. **Custom structures**: Trees, graphs for hierarchical/networked states

**Classic DP problems with data structure usage:**

**1. Fibonacci (1D array)**

```python
# Top-down with memoization (dict)
def fib_memo(n, memo=None):
    if memo is None:
        memo = {}

    if n in memo:
        return memo[n]

    if n <= 1:
        return n

    memo[n] = fib_memo(n-1, memo) + fib_memo(n-2, memo)
    return memo[n]

# Bottom-up with array
def fib_dp(n):
    if n <= 1:
        return n

    dp = [0] * (n + 1)
    dp[1] = 1

    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]

    return dp[n]

# Space-optimized (constant space)
def fib_optimized(n):
    if n <= 1:
        return n

    prev2, prev1 = 0, 1

    for _ in range(2, n + 1):
        current = prev1 + prev2
        prev2, prev1 = prev1, current

    return prev1
```

**2. 0/1 Knapsack (2D array)**

```python
def knapsack_01(weights, values, capacity):
    """
    0/1 Knapsack: maximize value with weight constraint.
    dp[i][w] = max value using first i items with capacity w
    """
    n = len(weights)
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]

    for i in range(1, n + 1):
        for w in range(capacity + 1):
            # Don't take item i-1
            dp[i][w] = dp[i-1][w]

            # Take item i-1 if it fits
            if weights[i-1] <= w:
                dp[i][w] = max(dp[i][w],
                              dp[i-1][w - weights[i-1]] + values[i-1])

    return dp[n][capacity]

# Space-optimized version (1D array)
def knapsack_01_optimized(weights, values, capacity):
    dp = [0] * (capacity + 1)

    for i in range(len(weights)):
        # Traverse backwards to avoid using updated values
        for w in range(capacity, weights[i] - 1, -1):
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i])

    return dp[capacity]

# With item tracking
def knapsack_with_items(weights, values, capacity):
    n = len(weights)
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]

    # Fill DP table
    for i in range(1, n + 1):
        for w in range(capacity + 1):
            dp[i][w] = dp[i-1][w]
            if weights[i-1] <= w:
                dp[i][w] = max(dp[i][w],
                              dp[i-1][w - weights[i-1]] + values[i-1])

    # Reconstruct solution
    w = capacity
    items = []
    for i in range(n, 0, -1):
        if dp[i][w] != dp[i-1][w]:
            items.append(i-1)
            w -= weights[i-1]

    return dp[n][capacity], items[::-1]

# Example:
weights = [2, 3, 4, 5]
values = [3, 4, 5, 6]
capacity = 8

max_value, items = knapsack_with_items(weights, values, capacity)
print(f"Max value: {max_value}, Items: {items}")
```

**3. Longest Common Subsequence (2D array)**

```python
def lcs(s1, s2):
    """
    Find length of longest common subsequence.
    dp[i][j] = LCS length of s1[:i] and s2[:j]
    """
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])

    return dp[m][n]

# With subsequence reconstruction
def lcs_with_string(s1, s2):
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]

    # Fill DP table
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])

    # Reconstruct LCS
    lcs_str = []
    i, j = m, n
    while i > 0 and j > 0:
        if s1[i-1] == s2[j-1]:
            lcs_str.append(s1[i-1])
            i -= 1
            j -= 1
        elif dp[i-1][j] > dp[i][j-1]:
            i -= 1
        else:
            j -= 1

    return dp[m][n], ''.join(reversed(lcs_str))

# Example:
s1, s2 = "ABCDGH", "AEDFHR"
length, lcs_str = lcs_with_string(s1, s2)
print(f"LCS length: {length}, LCS: {lcs_str}")  # 3, "ADH"
```

**4. Edit Distance (2D array)**

```python
def edit_distance(s1, s2):
    """
    Minimum edits (insert, delete, replace) to transform s1 to s2.
    dp[i][j] = min edits to transform s1[:i] to s2[:j]
    """
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]

    # Base cases
    for i in range(m + 1):
        dp[i][0] = i  # Delete all characters
    for j in range(n + 1):
        dp[0][j] = j  # Insert all characters

    # Fill DP table
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1]  # No operation needed
            else:
                dp[i][j] = 1 + min(
                    dp[i-1][j],      # Delete from s1
                    dp[i][j-1],      # Insert to s1
                    dp[i-1][j-1]     # Replace in s1
                )

    return dp[m][n]

# With operation tracking
def edit_distance_with_ops(s1, s2):
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    ops = [[None] * (n + 1) for _ in range(m + 1)]

    # Base cases
    for i in range(m + 1):
        dp[i][0] = i
        if i > 0:
            ops[i][0] = 'delete'
    for j in range(n + 1):
        dp[0][j] = j
        if j > 0:
            ops[0][j] = 'insert'

    # Fill DP table
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1]
                ops[i][j] = 'match'
            else:
                costs = [
                    (dp[i-1][j] + 1, 'delete'),
                    (dp[i][j-1] + 1, 'insert'),
                    (dp[i-1][j-1] + 1, 'replace')
                ]
                min_cost, op = min(costs)
                dp[i][j] = min_cost
                ops[i][j] = op

    # Reconstruct operations
    operations = []
    i, j = m, n
    while i > 0 or j > 0:
        op = ops[i][j]
        if op == 'match':
            i -= 1
            j -= 1
        elif op == 'delete':
            operations.append(f"Delete '{s1[i-1]}' at {i-1}")
            i -= 1
        elif op == 'insert':
            operations.append(f"Insert '{s2[j-1]}' at {i}")
            j -= 1
        elif op == 'replace':
            operations.append(f"Replace '{s1[i-1]}' with '{s2[j-1]}' at {i-1}")
            i -= 1
            j -= 1

    return dp[m][n], operations[::-1]

# Example:
s1, s2 = "kitten", "sitting"
dist, ops = edit_distance_with_ops(s1, s2)
print(f"Edit distance: {dist}")
print("Operations:", ops)
```

**5. Coin Change (1D array or dict)**

```python
# Minimum coins needed
def coin_change_min(coins, amount):
    """
    Minimum number of coins to make amount.
    dp[i] = min coins to make amount i
    """
    dp = [float('inf')] * (amount + 1)
    dp[0] = 0

    for i in range(1, amount + 1):
        for coin in coins:
            if coin <= i:
                dp[i] = min(dp[i], dp[i - coin] + 1)

    return dp[amount] if dp[amount] != float('inf') else -1

# Number of ways to make amount
def coin_change_ways(coins, amount):
    """
    Number of ways to make amount with given coins.
    dp[i] = number of ways to make amount i
    """
    dp = [0] * (amount + 1)
    dp[0] = 1

    for coin in coins:
        for i in range(coin, amount + 1):
            dp[i] += dp[i - coin]

    return dp[amount]

# With coin tracking
def coin_change_with_coins(coins, amount):
    dp = [float('inf')] * (amount + 1)
    dp[0] = 0
    parent = [-1] * (amount + 1)

    for i in range(1, amount + 1):
        for coin in coins:
            if coin <= i and dp[i - coin] + 1 < dp[i]:
                dp[i] = dp[i - coin] + 1
                parent[i] = coin

    if dp[amount] == float('inf'):
        return -1, []

    # Reconstruct coins used
    result = []
    curr = amount
    while curr > 0:
        coin = parent[curr]
        result.append(coin)
        curr -= coin

    return dp[amount], result

# Example:
coins = [1, 5, 10, 25]
amount = 63

min_coins, coin_list = coin_change_with_coins(coins, amount)
print(f"Min coins: {min_coins}, Coins used: {coin_list}")

ways = coin_change_ways(coins, amount)
print(f"Number of ways: {ways}")
```

**6. DP with Hash Table (Climbing Stairs with variable steps)**

```python
def climbing_stairs_memo(n, allowed_steps, memo=None):
    """
    Count ways to climb n stairs with allowed step sizes.
    Uses hash table for memoization with arbitrary allowed steps.
    """
    if memo is None:
        memo = {}

    if n in memo:
        return memo[n]

    if n == 0:
        return 1
    if n < 0:
        return 0

    ways = 0
    for step in allowed_steps:
        ways += climbing_stairs_memo(n - step, allowed_steps, memo)

    memo[n] = ways
    return ways

# Bottom-up with array
def climbing_stairs_dp(n, allowed_steps):
    dp = [0] * (n + 1)
    dp[0] = 1

    for i in range(1, n + 1):
        for step in allowed_steps:
            if i >= step:
                dp[i] += dp[i - step]

    return dp[n]

# Example:
n = 10
allowed_steps = [1, 2, 3]
print(f"Ways to climb {n} stairs: {climbing_stairs_dp(n, allowed_steps)}")
```

**7. DP on Trees (Tree diameter)**

```python
class TreeNode:
    def __init__(self, val=0):
        self.val = val
        self.children = []

def tree_diameter(root):
    """
    Find diameter (longest path between any two nodes) of tree.
    Uses DP on tree structure.
    """
    diameter = [0]

    def dfs(node):
        if not node.children:
            return 0

        # Get two longest paths from children
        max_depths = []
        for child in node.children:
            max_depths.append(dfs(child) + 1)

        max_depths.sort(reverse=True)

        # Update diameter with path through this node
        if len(max_depths) >= 2:
            diameter[0] = max(diameter[0], max_depths[0] + max_depths[1])
        elif len(max_depths) == 1:
            diameter[0] = max(diameter[0], max_depths[0])

        return max_depths[0] if max_depths else 0

    dfs(root)
    return diameter[0]

# Example:
#       1
#      /|\
#     2 3 4
#    /|   |
#   5 6   7
root = TreeNode(1)
root.children = [TreeNode(2), TreeNode(3), TreeNode(4)]
root.children[0].children = [TreeNode(5), TreeNode(6)]
root.children[2].children = [TreeNode(7)]

print(f"Tree diameter: {tree_diameter(root)}")  # 4 (5->2->1->4->7)
```

**DP Structure Selection Guide:**

| Problem Characteristics | Recommended Structure | Example |
|------------------------|----------------------|---------|
| Single parameter state | 1D array | Fibonacci, Climbing Stairs |
| Two parameter state | 2D array/matrix | LCS, Edit Distance, Knapsack |
| Sparse state space | Hash table/dict | Large range with few states |
| Negative/non-sequential indices | Hash table/dict | Subarray sum problems |
| Tree/graph structure | Custom (with dict/array) | Tree DP, Graph DP |
| State is complex object | Hash table with tuple keys | State machines, game states |
| Fixed small state count | Array with state encoding | Bitmask DP |

**Space optimization techniques:**

```python
# Rolling array: Use only last k rows of 2D DP
def lcs_space_optimized(s1, s2):
    """LCS using only two rows instead of full matrix."""
    m, n = len(s1), len(s2)
    prev = [0] * (n + 1)
    curr = [0] * (n + 1)

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                curr[j] = prev[j-1] + 1
            else:
                curr[j] = max(prev[j], curr[j-1])
        prev, curr = curr, prev

    return prev[n]

# State compression: Use bit manipulation for states
def tsp_bitmask_dp(dist):
    """
    Traveling Salesman Problem using bitmask DP.
    State: (current_city, visited_set) encoded as (city, mask)
    """
    n = len(dist)
    ALL_VISITED = (1 << n) - 1

    # dp[mask][city] = min cost to visit cities in mask ending at city
    dp = [[float('inf')] * n for _ in range(1 << n)]
    dp[1][0] = 0  # Start at city 0

    for mask in range(1 << n):
        for u in range(n):
            if dp[mask][u] == float('inf'):
                continue

            for v in range(n):
                if mask & (1 << v):  # Already visited
                    continue

                new_mask = mask | (1 << v)
                dp[new_mask][v] = min(dp[new_mask][v],
                                     dp[mask][u] + dist[u][v])

    # Find minimum cost to visit all cities and return to start
    min_cost = float('inf')
    for city in range(1, n):
        min_cost = min(min_cost, dp[ALL_VISITED][city] + dist[city][0])

    return min_cost

# Example:
dist = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0]
]
print(f"TSP min cost: {tsp_bitmask_dp(dist)}")
```

### Complexity-driven design

Complexity-driven design means choosing data structures and algorithms based on time/space constraints and input characteristics.

**Decision framework:**

```
1. Analyze constraints:
   - Input size (n)
   - Time limit
   - Space limit
   - Query frequency

2. Calculate required complexity:
   - 10^8 operations per second (rough estimate)
   - If n ≤ 10: O(n!) might work
   - If n ≤ 20: O(2^n) might work
   - If n ≤ 500: O(n^3) might work
   - If n ≤ 5000: O(n^2) might work
   - If n ≤ 10^6: O(n log n) required
   - If n ≤ 10^8: O(n) or O(log n) required

3. Choose structure/algorithm:
   - Match complexity to constraints
   - Consider trade-offs
```

**Example scenarios:**

**Scenario 1: Frequent membership queries**

```python
# Bad: O(n) per query
def membership_list(items, queries):
    """Linear search for each query - O(m*n) total."""
    results = []
    for q in queries:
        results.append(q in items)  # O(n) for list
    return results

# Good: O(1) average per query
def membership_set(items, queries):
    """Hash set for each query - O(n + m) total."""
    item_set = set(items)  # O(n) setup
    results = []
    for q in queries:
        results.append(q in item_set)  # O(1) average
    return results

# Analysis:
# If n = 10^6, m = 10^6:
# List approach: 10^12 operations (too slow!)
# Set approach: 2*10^6 operations (fast!)
```

**Scenario 2: Range queries**

```python
# Bad: O(n) per query
def range_sum_naive(arr, queries):
    """Calculate sum for each query - O(m*n) total."""
    results = []
    for left, right in queries:
        results.append(sum(arr[left:right+1]))
    return results

# Good: O(1) per query with O(n) preprocessing
def range_sum_prefix(arr, queries):
    """Prefix sum array - O(n + m) total."""
    n = len(arr)
    prefix = [0] * (n + 1)

    # Build prefix sum: O(n)
    for i in range(n):
        prefix[i + 1] = prefix[i] + arr[i]

    # Answer queries: O(1) each
    results = []
    for left, right in queries:
        results.append(prefix[right + 1] - prefix[left])

    return results

# For dynamic updates: use Segment Tree or Fenwick Tree
class FenwickTree:
    def __init__(self, n):
        self.n = n
        self.tree = [0] * (n + 1)

    def update(self, i, delta):
        """Add delta to element at index i. O(log n)"""
        i += 1  # 1-indexed
        while i <= self.n:
            self.tree[i] += delta
            i += i & (-i)

    def query(self, i):
        """Sum of elements [0, i]. O(log n)"""
        i += 1
        s = 0
        while i > 0:
            s += self.tree[i]
            i -= i & (-i)
        return s

    def range_query(self, left, right):
        """Sum of elements [left, right]. O(log n)"""
        if left == 0:
            return self.query(right)
        return self.query(right) - self.query(left - 1)

# Complexity comparison:
# Static array, m queries:
#   Naive: O(m*n)
#   Prefix sum: O(n + m)
#
# Dynamic array (u updates, m queries):
#   Naive: O(u + m*n)
#   Fenwick/Segment Tree: O((u + m) log n)
```

**Scenario 3: Sorted data operations**

```python
# Design choice based on operations
class SortedStructure:
    """
    Choose implementation based on operation frequency:
    - Mostly searches: Sorted array + binary search
    - Mostly insertions: Balanced BST or sorted list
    - Mix: Balanced BST
    """

    def __init__(self, use_bst=True):
        if use_bst:
            # Use balanced BST (e.g., sortedcontainers.SortedList in Python)
            from sortedcontainers import SortedList
            self.data = SortedList()
        else:
            # Use sorted array
            self.data = []

    def insert(self, val):
        if isinstance(self.data, list):
            # Sorted array: O(n) insertion
            import bisect
            bisect.insort(self.data, val)
        else:
            # Balanced BST: O(log n) insertion
            self.data.add(val)

    def search(self, val):
        if isinstance(self.data, list):
            # Sorted array: O(log n) search
            import bisect
            idx = bisect.bisect_left(self.data, val)
            return idx < len(self.data) and self.data[idx] == val
        else:
            # Balanced BST: O(log n) search
            return val in self.data

# Decision matrix:
# Operations (n total):
# - 90% search, 10% insert: Use sorted array
# - 50% search, 50% insert: Use balanced BST
# - Bulk inserts then only searches: Sort once, then binary search
```

**Scenario 4: Graph algorithm selection**

```python
def choose_shortest_path_algorithm(graph_info):
    """
    Select algorithm based on graph characteristics.
    """
    num_vertices = graph_info['vertices']
    num_edges = graph_info['edges']
    has_negative_weights = graph_info['negative_weights']
    is_sparse = num_edges < num_vertices * num_vertices / 2
    query_type = graph_info['query_type']  # 'single', 'all-pairs'

    if query_type == 'single':
        if has_negative_weights:
            return "Bellman-Ford", "O(VE)"
        else:
            return "Dijkstra", "O((V+E) log V)"
    else:  # all-pairs
        if is_sparse and not has_negative_weights:
            return "Dijkstra V times", "O(V(V+E) log V)"
        else:
            return "Floyd-Warshall", "O(V³)"

# Example decision:
graphs = [
    {'vertices': 1000, 'edges': 5000, 'negative_weights': False, 'query_type': 'single'},
    {'vertices': 100, 'edges': 4000, 'negative_weights': False, 'query_type': 'all-pairs'},
    {'vertices': 1000, 'edges': 2000, 'negative_weights': True, 'query_type': 'single'}
]

for g in graphs:
    algo, complexity = choose_shortest_path_algorithm(g)
    print(f"Graph: V={g['vertices']}, E={g['edges']}")
    print(f"  Choose: {algo} ({complexity})\n")
```

**Scenario 5: String matching**

```python
def choose_string_matching(pattern_info):
    """
    Select string matching algorithm based on use case.
    """
    pattern_count = pattern_info['patterns']
    pattern_length = pattern_info['pattern_length']
    text_length = pattern_info['text_length']
    query_frequency = pattern_info['queries']

    if pattern_count == 1:
        if query_frequency == 'once':
            return "KMP or Boyer-Moore", "O(n + m)"
        else:
            return "Build suffix array/tree", "O(n) build, O(m) per query"
    else:
        if query_frequency == 'once':
            return "Aho-Corasick", "O(n + m + matches)"
        else:
            return "Trie or suffix tree", "O(total pattern length) build"

# Practical implementations
class StringMatcher:
    # KMP for single pattern, multiple searches
    def kmp_build_table(self, pattern):
        """Build KMP failure function. O(m)"""
        m = len(pattern)
        table = [0] * m
        j = 0

        for i in range(1, m):
            while j > 0 and pattern[i] != pattern[j]:
                j = table[j - 1]

            if pattern[i] == pattern[j]:
                j += 1

            table[i] = j

        return table

    def kmp_search(self, text, pattern, table):
        """Search using KMP. O(n)"""
        n, m = len(text), len(pattern)
        matches = []
        j = 0

        for i in range(n):
            while j > 0 and text[i] != pattern[j]:
                j = table[j - 1]

            if text[i] == pattern[j]:
                j += 1

            if j == m:
                matches.append(i - m + 1)
                j = table[j - 1]

        return matches

    # Aho-Corasick for multiple patterns
    def build_aho_corasick(self, patterns):
        """Build Aho-Corasick automaton."""
        from collections import deque, defaultdict

        # Build trie
        trie = {}
        output = defaultdict(list)
        node_id = [0]

        def add_pattern(pattern, pattern_id):
            node = 0
            for char in pattern:
                if (node, char) not in trie:
                    node_id[0] += 1
                    trie[(node, char)] = node_id[0]
                node = trie[(node, char)]
            output[node].append(pattern_id)

        for i, pattern in enumerate(patterns):
            add_pattern(pattern, i)

        # Build failure links (simplified)
        # In production, use proper Aho-Corasick implementation
        return trie, output
```

**Complexity-driven design principles:**

1. **Analyze first, optimize later**
   - Measure actual performance
   - Identify bottlenecks
   - Don't prematurely optimize

2. **Trade-offs**
   - Time vs Space: Hash tables use more space for faster lookups
   - Preprocessing vs Query: Precompute when many queries expected
   - Average vs Worst case: Quick sort (fast average) vs Merge sort (guaranteed)

3. **Amortized analysis**
   - Dynamic array append: O(1) amortized
   - Union-Find with path compression: O(α(n)) amortized

4. **Data structure augmentation**
   - Add metadata to improve specific operations
   - Example: Size field in tree nodes for rank queries

```python
class AugmentedBST:
    """BST with subtree size for order statistics."""

    class Node:
        def __init__(self, val):
            self.val = val
            self.left = None
            self.right = None
            self.size = 1  # Augmentation: size of subtree

    def __init__(self):
        self.root = None

    def size(self, node):
        return node.size if node else 0

    def update_size(self, node):
        if node:
            node.size = 1 + self.size(node.left) + self.size(node.right)

    def kth_smallest(self, k):
        """Find kth smallest element. O(log n) with augmentation."""
        def helper(node, k):
            if not node:
                return None

            left_size = self.size(node.left)

            if k == left_size + 1:
                return node.val
            elif k <= left_size:
                return helper(node.left, k)
            else:
                return helper(node.right, k - left_size - 1)

        return helper(self.root, k)
```

### Practical optimization patterns

Common algorithmic patterns that frequently appear in problem-solving.

**1. Two Pointers**

Used for problems involving arrays or linked lists where you need to track two positions.

```python
# Pattern: Opposite direction pointers
def two_sum_sorted(arr, target):
    """Find pair that sums to target in sorted array."""
    left, right = 0, len(arr) - 1

    while left < right:
        current_sum = arr[left] + arr[right]

        if current_sum == target:
            return (left, right)
        elif current_sum < target:
            left += 1
        else:
            right -= 1

    return None

# Pattern: Same direction pointers (fast/slow)
def remove_duplicates(arr):
    """Remove duplicates from sorted array in-place."""
    if not arr:
        return 0

    slow = 0
    for fast in range(1, len(arr)):
        if arr[fast] != arr[slow]:
            slow += 1
            arr[slow] = arr[fast]

    return slow + 1

# Pattern: Slow and fast pointers (cycle detection)
def has_cycle(head):
    """Detect cycle in linked list."""
    slow = fast = head

    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next

        if slow == fast:
            return True

    return False

# Pattern: Partition (Dutch National Flag)
def sort_colors(arr):
    """Sort array of 0s, 1s, 2s in-place. O(n) one pass."""
    low, mid, high = 0, 0, len(arr) - 1

    while mid <= high:
        if arr[mid] == 0:
            arr[low], arr[mid] = arr[mid], arr[low]
            low += 1
            mid += 1
        elif arr[mid] == 1:
            mid += 1
        else:  # arr[mid] == 2
            arr[mid], arr[high] = arr[high], arr[mid]
            high -= 1

    return arr

# Example:
arr = [2, 0, 2, 1, 1, 0]
print(sort_colors(arr))  # [0, 0, 1, 1, 2, 2]
```

**2. Sliding Window**

Maintain a window over contiguous elements, useful for subarray/substring problems.

```python
# Pattern: Fixed-size window
def max_sum_subarray(arr, k):
    """Maximum sum of subarray of size k."""
    if len(arr) < k:
        return None

    # Initial window
    window_sum = sum(arr[:k])
    max_sum = window_sum

    # Slide window
    for i in range(k, len(arr)):
        window_sum = window_sum - arr[i - k] + arr[i]
        max_sum = max(max_sum, window_sum)

    return max_sum

# Pattern: Variable-size window
def longest_substring_k_distinct(s, k):
    """Longest substring with at most k distinct characters."""
    from collections import defaultdict

    char_count = defaultdict(int)
    left = 0
    max_length = 0

    for right in range(len(s)):
        char_count[s[right]] += 1

        # Shrink window if too many distinct chars
        while len(char_count) > k:
            char_count[s[left]] -= 1
            if char_count[s[left]] == 0:
                del char_count[s[left]]
            left += 1

        max_length = max(max_length, right - left + 1)

    return max_length

# Pattern: Expand window with condition
def min_window_substring(s, t):
    """Minimum window in s that contains all characters of t."""
    from collections import Counter

    if not s or not t:
        return ""

    required = Counter(t)
    need = len(required)
    formed = 0

    window_counts = {}
    left = 0
    min_len = float('inf')
    min_window = (0, 0)

    for right in range(len(s)):
        char = s[right]
        window_counts[char] = window_counts.get(char, 0) + 1

        if char in required and window_counts[char] == required[char]:
            formed += 1

        # Shrink window while valid
        while formed == need and left <= right:
            # Update result
            if right - left + 1 < min_len:
                min_len = right - left + 1
                min_window = (left, right + 1)

            # Remove leftmost character
            char = s[left]
            window_counts[char] -= 1
            if char in required and window_counts[char] < required[char]:
                formed -= 1
            left += 1

    return s[min_window[0]:min_window[1]] if min_len != float('inf') else ""

# Example:
s = "ADOBECODEBANC"
t = "ABC"
print(min_window_substring(s, t))  # "BANC"
```

**3. Prefix Sum / Cumulative Sum**

Precompute cumulative sums for efficient range queries.

```python
# Pattern: Basic prefix sum
class PrefixSum:
    def __init__(self, arr):
        self.prefix = [0]
        for num in arr:
            self.prefix.append(self.prefix[-1] + num)

    def range_sum(self, left, right):
        """Sum of arr[left:right+1]. O(1)"""
        return self.prefix[right + 1] - self.prefix[left]

# Pattern: 2D prefix sum
class Matrix2DPrefixSum:
    def __init__(self, matrix):
        if not matrix or not matrix[0]:
            self.prefix = []
            return

        m, n = len(matrix), len(matrix[0])
        self.prefix = [[0] * (n + 1) for _ in range(m + 1)]

        for i in range(1, m + 1):
            for j in range(1, n + 1):
                self.prefix[i][j] = (matrix[i-1][j-1] +
                                    self.prefix[i-1][j] +
                                    self.prefix[i][j-1] -
                                    self.prefix[i-1][j-1])

    def region_sum(self, r1, c1, r2, c2):
        """Sum of submatrix from (r1,c1) to (r2,c2). O(1)"""
        return (self.prefix[r2+1][c2+1] -
                self.prefix[r1][c2+1] -
                self.prefix[r2+1][c1] +
                self.prefix[r1][c1])

# Pattern: Prefix sum with hash map
def subarray_sum_equals_k(arr, k):
    """Count subarrays with sum equal to k."""
    from collections import defaultdict

    prefix_sum = 0
    count = 0
    sum_count = defaultdict(int)
    sum_count[0] = 1  # Empty prefix

    for num in arr:
        prefix_sum += num

        # If (prefix_sum - k) exists, we found a subarray
        if prefix_sum - k in sum_count:
            count += sum_count[prefix_sum - k]

        sum_count[prefix_sum] += 1

    return count

# Example:
arr = [1, 2, 3, 4, 5]
ps = PrefixSum(arr)
print(ps.range_sum(1, 3))  # 2+3+4 = 9

arr2 = [1, 1, 1, 1]
print(subarray_sum_equals_k(arr2, 2))  # 3 subarrays: [1,1], [1,1], [1,1]
```

**4. Monotonic Stack/Queue**

Maintain elements in monotonic order for efficient min/max queries.

```python
# Pattern: Next greater element
def next_greater_element(arr):
    """For each element, find next greater element to the right."""
    n = len(arr)
    result = [-1] * n
    stack = []  # Monotonic decreasing stack (indices)

    for i in range(n):
        while stack and arr[stack[-1]] < arr[i]:
            idx = stack.pop()
            result[idx] = arr[i]
        stack.append(i)

    return result

# Pattern: Largest rectangle in histogram
def largest_rectangle_histogram(heights):
    """Find largest rectangle area in histogram."""
    stack = []  # Monotonic increasing stack
    max_area = 0
    heights = heights + [0]  # Sentinel

    for i, h in enumerate(heights):
        while stack and heights[stack[-1]] > h:
            height_idx = stack.pop()
            height = heights[height_idx]
            width = i if not stack else i - stack[-1] - 1
            max_area = max(max_area, height * width)
        stack.append(i)

    return max_area

# Pattern: Sliding window maximum
def sliding_window_maximum(arr, k):
    """Maximum in each window of size k."""
    from collections import deque

    dq = deque()  # Monotonic decreasing deque (indices)
    result = []

    for i in range(len(arr)):
        # Remove elements outside window
        while dq and dq[0] <= i - k:
            dq.popleft()

        # Maintain decreasing order
        while dq and arr[dq[-1]] < arr[i]:
            dq.pop()

        dq.append(i)

        # Add to result when window is full
        if i >= k - 1:
            result.append(arr[dq[0]])

    return result

# Example:
arr = [4, 5, 2, 10, 8]
print("Next greater:", next_greater_element(arr))
# [5, 10, 10, -1, -1]

heights = [2, 1, 5, 6, 2, 3]
print("Largest rectangle:", largest_rectangle_histogram(heights))
# 10 (5*2)

arr = [1, 3, -1, -3, 5, 3, 6, 7]
print("Sliding max:", sliding_window_maximum(arr, 3))
# [3, 3, 5, 5, 6, 7]
```

**5. Binary Search Patterns**

Binary search on answer space, not just for finding elements.

```python
# Pattern: Binary search on answer
def min_eating_speed(piles, h):
    """
    Minimum speed k to eat all bananas in h hours.
    Binary search on the answer (speed).
    """
    def can_finish(speed):
        hours = 0
        for pile in piles:
            hours += (pile + speed - 1) // speed  # Ceiling division
        return hours <= h

    left, right = 1, max(piles)

    while left < right:
        mid = left + (right - left) // 2

        if can_finish(mid):
            right = mid  # Try smaller speed
        else:
            left = mid + 1  # Need faster speed

    return left

# Pattern: Binary search for range
def search_range(arr, target):
    """Find first and last position of target in sorted array."""
    def binary_search_bound(find_first):
        left, right = 0, len(arr)

        while left < right:
            mid = left + (right - left) // 2

            if arr[mid] > target or (find_first and arr[mid] == target):
                right = mid
            else:
                left = mid + 1

        return left

    first = binary_search_bound(True)
    if first == len(arr) or arr[first] != target:
        return [-1, -1]

    last = binary_search_bound(False) - 1
    return [first, last]

# Pattern: Binary search on 2D matrix
def search_matrix(matrix, target):
    """Search in row and column sorted matrix."""
    if not matrix or not matrix[0]:
        return False

    # Start from top-right corner
    row, col = 0, len(matrix[0]) - 1

    while row < len(matrix) and col >= 0:
        if matrix[row][col] == target:
            return True
        elif matrix[row][col] > target:
            col -= 1  # Move left
        else:
            row += 1  # Move down

    return False

# Example:
piles = [3, 6, 7, 11]
h = 8
print("Min eating speed:", min_eating_speed(piles, h))  # 4

arr = [5, 7, 7, 8, 8, 10]
print("Range of 8:", search_range(arr, 8))  # [3, 4]
```

**6. Greedy Patterns**

Make locally optimal choices for globally optimal solution.

```python
# Pattern: Interval scheduling
def max_non_overlapping_intervals(intervals):
    """Maximum number of non-overlapping intervals."""
    if not intervals:
        return 0

    # Sort by end time
    intervals.sort(key=lambda x: x[1])

    count = 1
    end = intervals[0][1]

    for i in range(1, len(intervals)):
        if intervals[i][0] >= end:
            count += 1
            end = intervals[i][1]

    return count

# Pattern: Greedy with sorting
def min_arrows_burst_balloons(points):
    """Minimum arrows needed to burst all balloons."""
    if not points:
        return 0

    points.sort(key=lambda x: x[1])

    arrows = 1
    end = points[0][1]

    for start, finish in points[1:]:
        if start > end:
            arrows += 1
            end = finish

    return arrows

# Pattern: Two-pass greedy
def candy_distribution(ratings):
    """Minimum candies to distribute based on ratings."""
    n = len(ratings)
    candies = [1] * n

    # Left to right: ensure right neighbor gets more if higher rating
    for i in range(1, n):
        if ratings[i] > ratings[i-1]:
            candies[i] = candies[i-1] + 1

    # Right to left: ensure left neighbor gets more if higher rating
    for i in range(n-2, -1, -1):
        if ratings[i] > ratings[i+1]:
            candies[i] = max(candies[i], candies[i+1] + 1)

    return sum(candies)

# Example:
intervals = [[1,2], [2,3], [3,4], [1,3]]
print("Max non-overlapping:", max_non_overlapping_intervals(intervals))  # 3

balloons = [[10,16], [2,8], [1,6], [7,12]]
print("Min arrows:", min_arrows_burst_balloons(balloons))  # 2

ratings = [1, 0, 2]
print("Min candies:", candy_distribution(ratings))  # 5 (2+1+2)
```

**Pattern selection guide:**

| Pattern | When to Use | Complexity |
|---------|------------|------------|
| Two Pointers | Array/list with sorted property or need to track two positions | O(n) |
| Sliding Window | Contiguous subarray/substring problems | O(n) |
| Prefix Sum | Multiple range sum queries on static array | O(1) query |
| Monotonic Stack | Next/previous greater/smaller element | O(n) |
| Binary Search | Sorted data or search answer space | O(log n) |
| Greedy | Locally optimal leads to global optimal | Varies |
| DP | Overlapping subproblems, optimal substructure | Varies |
| BFS/DFS | Graph/tree traversal, shortest path | O(V+E) |
