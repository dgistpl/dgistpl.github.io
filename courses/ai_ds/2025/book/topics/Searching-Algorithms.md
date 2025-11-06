---
layout: splash
author_profile: false
---

# Searching Algorithms

Find elements efficiently within collections.

### 1. Linear vs binary search
Comparing the two fundamental search algorithms:

#### **Linear Search**:
- **Approach**: Check each element sequentially until found
- **Requirement**: None (works on unsorted data)
- **Time**: O(n)
- **Space**: O(1)

**Implementation**:
```python
def linear_search(arr, target):
    """Search for target in array"""
    for i in range(len(arr)):
        if arr[i] == target:
            return i  # Return index
    return -1  # Not found

# Example
arr = [64, 34, 25, 12, 22, 11, 90]
result = linear_search(arr, 22)  # Returns 4
```

**Advantages**:
- ✓ Works on unsorted data
- ✓ Simple to implement
- ✓ Good for small datasets
- ✓ No preprocessing needed

**Disadvantages**:
- ✗ Slow for large datasets: O(n)
- ✗ Inefficient when data is sorted

#### **Binary Search**:
- **Approach**: Divide and conquer on sorted array
- **Requirement**: Array must be sorted
- **Time**: O(log n)
- **Space**: O(1) iterative, O(log n) recursive

**Iterative implementation**:
```python
def binary_search(arr, target):
    """Search for target in sorted array"""
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2  # Avoid overflow
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1  # Search right half
        else:
            right = mid - 1  # Search left half
    
    return -1  # Not found
```

**Recursive implementation**:
```python
def binary_search_recursive(arr, target, left, right):
    if left > right:
        return -1
    
    mid = left + (right - left) // 2
    
    if arr[mid] == target:
        return mid
    elif arr[mid] < target:
        return binary_search_recursive(arr, target, mid + 1, right)
    else:
        return binary_search_recursive(arr, target, left, mid - 1)

# Usage
arr = [11, 12, 22, 25, 34, 64, 90]  # Must be sorted!
result = binary_search_recursive(arr, 22, 0, len(arr) - 1)
```

**Visual example**:
```
Array: [11, 12, 22, 25, 34, 64, 90]
Target: 22

Step 1: left=0, right=6, mid=3
        [11, 12, 22, 25, 34, 64, 90]
                     ↑
        arr[3]=25 > 22, search left

Step 2: left=0, right=2, mid=1
        [11, 12, 22]
             ↑
        arr[1]=12 < 22, search right

Step 3: left=2, right=2, mid=2
        [22]
         ↑
        arr[2]=22 == 22, found!
```

**Advantages**:
- ✓ Very fast: O(log n)
- ✓ Efficient for large datasets
- ✓ Predictable performance

**Disadvantages**:
- ✗ Requires sorted array
- ✗ More complex to implement
- ✗ Not suitable for linked lists

#### **Comparison**:

| Feature | Linear Search | Binary Search |
|---------|--------------|---------------|
| Time | O(n) | O(log n) |
| Space | O(1) | O(1) iterative |
| Sorted required | No | Yes |
| Best for | Small/unsorted | Large/sorted |
| Average comparisons (n=1000) | 500 | 10 |

#### **When to use each**:
- **Linear**: Small arrays (n < 100), unsorted data, simple implementation
- **Binary**: Large sorted arrays, frequent searches, performance critical

### 2. Binary search on answers (parametric)
Using binary search to find optimal values:

#### **Concept**:
- **Idea**: Binary search on the answer space, not the array
- **Pattern**: Find minimum/maximum value satisfying a condition
- **Key**: Monotonic property (if x works, all values > x work)

#### **Template**:
```python
def binary_search_answer(condition_func, low, high):
    """
    Find minimum value in [low, high] satisfying condition
    """
    result = -1
    
    while low <= high:
        mid = low + (high - low) // 2
        
        if condition_func(mid):
            result = mid
            high = mid - 1  # Try to find smaller
        else:
            low = mid + 1
    
    return result
```

#### **Example 1: Find square root**:
```python
def sqrt(x):
    """Find integer square root of x"""
    if x < 2:
        return x
    
    left, right = 1, x // 2
    
    while left <= right:
        mid = left + (right - left) // 2
        square = mid * mid
        
        if square == x:
            return mid
        elif square < x:
            left = mid + 1
        else:
            right = mid - 1
    
    return right  # Largest integer whose square <= x

# Example: sqrt(8) = 2 (since 2² = 4 ≤ 8 < 3² = 9)
```

#### **Example 2: Minimum capacity to ship packages**:
```python
def ship_within_days(weights, days):
    """
    Find minimum ship capacity to ship all packages in 'days' days
    """
    def can_ship(capacity):
        """Check if we can ship with given capacity"""
        days_needed = 1
        current_load = 0
        
        for weight in weights:
            if current_load + weight > capacity:
                days_needed += 1
                current_load = weight
            else:
                current_load += weight
        
        return days_needed <= days
    
    # Binary search on capacity
    left = max(weights)  # Min capacity: heaviest package
    right = sum(weights)  # Max capacity: all at once
    
    while left < right:
        mid = left + (right - left) // 2
        
        if can_ship(mid):
            right = mid  # Try smaller capacity
        else:
            left = mid + 1
    
    return left

# Example: weights=[1,2,3,4,5,6,7,8,9,10], days=5
# Answer: 15 (ship [1,2,3,4,5], [6,7], [8], [9], [10])
```

#### **Example 3: Koko eating bananas**:
```python
def min_eating_speed(piles, h):
    """
    Find minimum eating speed to finish all bananas in h hours
    """
    def can_finish(speed):
        """Check if can finish with given speed"""
        hours = 0
        for pile in piles:
            hours += (pile + speed - 1) // speed  # Ceiling division
        return hours <= h
    
    left, right = 1, max(piles)
    
    while left < right:
        mid = left + (right - left) // 2
        
        if can_finish(mid):
            right = mid
        else:
            left = mid + 1
    
    return left
```

#### **Common patterns**:
1. **Minimize maximum**: Find smallest value where all constraints satisfied
2. **Maximize minimum**: Find largest value where all constraints satisfied
3. **Find threshold**: Find boundary where condition changes from false to true

### 3. Search trees and hashing
Alternative search structures:

#### **Binary Search Tree (BST)**:
- **Structure**: Each node has left (smaller) and right (larger) children
- **Search**: O(log n) average, O(n) worst case
- **Advantage**: Dynamic insertions/deletions

**Implementation**:
```python
class TreeNode:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def search_bst(root, target):
    """Search in BST"""
    if not root or root.val == target:
        return root
    
    if target < root.val:
        return search_bst(root.left, target)
    else:
        return search_bst(root.right, target)

# Iterative version
def search_bst_iterative(root, target):
    while root and root.val != target:
        if target < root.val:
            root = root.left
        else:
            root = root.right
    return root
```

#### **Hash Table Search**:
- **Structure**: Key-value pairs with hash function
- **Search**: O(1) average, O(n) worst case
- **Advantage**: Fastest average case

**Implementation**:
```python
# Using Python dict (hash table)
hash_table = {}

# Insert
hash_table["apple"] = 5
hash_table["banana"] = 3

# Search: O(1) average
if "apple" in hash_table:
    print(hash_table["apple"])

# Custom hash table
class HashTable:
    def __init__(self, size=10):
        self.size = size
        self.table = [[] for _ in range(size)]
    
    def _hash(self, key):
        return hash(key) % self.size
    
    def insert(self, key, value):
        index = self._hash(key)
        for i, (k, v) in enumerate(self.table[index]):
            if k == key:
                self.table[index][i] = (key, value)
                return
        self.table[index].append((key, value))
    
    def search(self, key):
        index = self._hash(key)
        for k, v in self.table[index]:
            if k == key:
                return v
        return None
```

#### **Comparison**:

| Structure | Average | Worst | Sorted | Dynamic |
|-----------|---------|-------|--------|---------|
| Sorted Array + Binary Search | O(log n) | O(log n) | Yes | No |
| BST | O(log n) | O(n) | Yes | Yes |
| Balanced BST | O(log n) | O(log n) | Yes | Yes |
| Hash Table | O(1) | O(n) | No | Yes |

### 4. Interpolation and exponential search
Advanced search algorithms for specific scenarios:

#### **Interpolation Search**:
- **Idea**: Guess position based on value (like looking up in phone book)
- **Best for**: Uniformly distributed sorted data
- **Time**: O(log log n) average, O(n) worst case

**Implementation**:
```python
def interpolation_search(arr, target):
    """
    Search in uniformly distributed sorted array
    """
    left, right = 0, len(arr) - 1
    
    while left <= right and target >= arr[left] and target <= arr[right]:
        if left == right:
            if arr[left] == target:
                return left
            return -1
        
        # Estimate position
        pos = left + int(((target - arr[left]) / (arr[right] - arr[left])) 
                        * (right - left))
        
        if arr[pos] == target:
            return pos
        elif arr[pos] < target:
            left = pos + 1
        else:
            right = pos - 1
    
    return -1

# Example: [10, 20, 30, 40, 50, 60, 70, 80, 90]
# Target: 70
# Estimate: pos ≈ left + (70-10)/(90-10) * (8-0) = 6
# Much faster than binary search for uniform data!
```

**Visual**:
```
Array: [10, 20, 30, 40, 50, 60, 70, 80, 90]
Target: 70

Binary search would start at mid=4 (value 50)
Interpolation estimates pos≈6 (value 70) directly!
```

#### **Exponential Search**:
- **Idea**: Find range where element exists, then binary search
- **Best for**: Unbounded/infinite arrays, element near beginning
- **Time**: O(log n)

**Implementation**:
```python
def exponential_search(arr, target):
    """
    Search in sorted array, efficient when target is near start
    """
    n = len(arr)
    
    # If target at first position
    if arr[0] == target:
        return 0
    
    # Find range for binary search
    i = 1
    while i < n and arr[i] <= target:
        i *= 2
    
    # Binary search in range [i//2, min(i, n-1)]
    return binary_search_range(arr, target, i // 2, min(i, n - 1))

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

# Example: [1, 2, 3, 4, 5, ..., 1000]
# Target: 10
# Exponential: Check 1, 2, 4, 8, 16 → binary search in [8, 16]
# Only 4 + log(8) ≈ 7 comparisons vs log(1000) ≈ 10 for binary
```

**Use cases**:
- Searching in unbounded/infinite lists
- Element likely near beginning
- Don't know array size

#### **Jump Search**:
- **Idea**: Jump ahead by fixed steps, then linear search
- **Best for**: Sorted arrays, when binary search overhead too high
- **Time**: O(√n)

**Implementation**:
```python
import math

def jump_search(arr, target):
    """
    Jump search in sorted array
    """
    n = len(arr)
    step = int(math.sqrt(n))
    prev = 0
    
    # Jump to find block
    while arr[min(step, n) - 1] < target:
        prev = step
        step += int(math.sqrt(n))
        if prev >= n:
            return -1
    
    # Linear search in block
    while arr[prev] < target:
        prev += 1
        if prev == min(step, n):
            return -1
    
    if arr[prev] == target:
        return prev
    
    return -1
```

### 5. Complexity and preconditions
Understanding requirements and performance:

#### **Time complexity summary**:

| Algorithm | Best | Average | Worst | Space |
|-----------|------|---------|-------|-------|
| Linear | O(1) | O(n) | O(n) | O(1) |
| Binary | O(1) | O(log n) | O(log n) | O(1) |
| Interpolation | O(1) | O(log log n) | O(n) | O(1) |
| Exponential | O(1) | O(log n) | O(log n) | O(1) |
| Jump | O(1) | O(√n) | O(√n) | O(1) |
| BST | O(log n) | O(log n) | O(n) | O(n) |
| Hash Table | O(1) | O(1) | O(n) | O(n) |

#### **Preconditions**:

**Binary Search**:
```python
# MUST be sorted
arr = [1, 3, 5, 7, 9, 11, 13]  # ✓ Sorted
arr = [3, 1, 5, 9, 7, 11, 13]  # ✗ Not sorted - binary search fails!

# Check if sorted
def is_sorted(arr):
    return all(arr[i] <= arr[i+1] for i in range(len(arr)-1))
```

**Interpolation Search**:
```python
# MUST be sorted AND uniformly distributed
arr = [10, 20, 30, 40, 50]  # ✓ Uniform
arr = [1, 2, 3, 100, 1000]  # ✗ Not uniform - may be slow
```

**Hash Table**:
```python
# Keys must be hashable (immutable)
hash_table[42] = "value"           # ✓ int is hashable
hash_table["key"] = "value"        # ✓ str is hashable
hash_table[(1, 2)] = "value"       # ✓ tuple is hashable
hash_table[[1, 2]] = "value"       # ✗ list is not hashable!
```

#### **Choosing the right algorithm**:
```python
def choose_search_algorithm(data_size, is_sorted, is_uniform, 
                            insertion_frequency):
    """
    Decision tree for choosing search algorithm
    """
    if insertion_frequency == "high":
        return "Hash Table"  # O(1) search + insert
    
    if not is_sorted:
        if data_size < 100:
            return "Linear Search"
        else:
            return "Sort first, then Binary Search"
    
    # Sorted data
    if data_size < 100:
        return "Linear Search"  # Simple, good cache locality
    
    if is_uniform:
        return "Interpolation Search"  # O(log log n)
    
    return "Binary Search"  # O(log n), reliable
```

### 6. Applications and patterns
Real-world uses and common patterns:

#### **1. Finding boundaries**:
```python
def find_first_occurrence(arr, target):
    """Find first occurrence of target in sorted array"""
    left, right = 0, len(arr) - 1
    result = -1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            result = mid
            right = mid - 1  # Continue searching left
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return result

def find_last_occurrence(arr, target):
    """Find last occurrence of target"""
    left, right = 0, len(arr) - 1
    result = -1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            result = mid
            left = mid + 1  # Continue searching right
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return result

# Count occurrences
def count_occurrences(arr, target):
    first = find_first_occurrence(arr, target)
    if first == -1:
        return 0
    last = find_last_occurrence(arr, target)
    return last - first + 1
```

#### **2. Rotated array search**:
```python
def search_rotated(arr, target):
    """
    Search in rotated sorted array
    Example: [4,5,6,7,0,1,2] (rotated at index 4)
    """
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            return mid
        
        # Determine which half is sorted
        if arr[left] <= arr[mid]:
            # Left half is sorted
            if arr[left] <= target < arr[mid]:
                right = mid - 1
            else:
                left = mid + 1
        else:
            # Right half is sorted
            if arr[mid] < target <= arr[right]:
                left = mid + 1
            else:
                right = mid - 1
    
    return -1
```

#### **3. Peak finding**:
```python
def find_peak_element(arr):
    """
    Find a peak element (greater than neighbors)
    """
    left, right = 0, len(arr) - 1
    
    while left < right:
        mid = left + (right - left) // 2
        
        if arr[mid] < arr[mid + 1]:
            left = mid + 1  # Peak is on right
        else:
            right = mid  # Peak is on left or at mid
    
    return left
```

#### **4. Search in 2D matrix**:
```python
def search_matrix(matrix, target):
    """
    Search in row-wise and column-wise sorted matrix
    """
    if not matrix or not matrix[0]:
        return False
    
    rows, cols = len(matrix), len(matrix[0])
    
    # Start from top-right corner
    row, col = 0, cols - 1
    
    while row < rows and col >= 0:
        if matrix[row][col] == target:
            return True
        elif matrix[row][col] > target:
            col -= 1  # Move left
        else:
            row += 1  # Move down
    
    return False
```

#### **5. Finding missing number**:
```python
def find_missing(arr):
    """
    Find missing number in [0, n]
    Example: [0,1,3,4,5] → missing 2
    """
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == mid:
            left = mid + 1  # Missing is on right
        else:
            right = mid - 1  # Missing is on left or at mid
    
    return left
```

#### **Common patterns summary**:
1. **Find exact match**: Standard binary search
2. **Find first/last occurrence**: Binary search with boundary tracking
3. **Find insertion position**: Binary search returning left pointer
4. **Search in rotated array**: Identify sorted half first
5. **Find peak/valley**: Compare with neighbors
6. **2D search**: Start from corner, eliminate row or column
7. **Binary search on answer**: Search solution space, not array
