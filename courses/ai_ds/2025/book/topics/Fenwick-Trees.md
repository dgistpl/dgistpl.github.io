---
layout: splash
author_profile: false
---

# Fenwick Trees (Binary Indexed Trees)

Compact structure for prefix sums and range queries.

### 1. Internal bit representation
Understanding how Fenwick Trees use binary representation for efficient operations:

#### **Core concept**:
- **Fenwick Tree (BIT)**: Array-based structure where each index stores cumulative information
- **Key insight**: Use binary representation of indices to determine responsibility ranges
- **Index convention**: 1-indexed (index 0 unused or used as sentinel)

#### **Binary representation and ranges**:
Each index `i` is responsible for a range of elements determined by the least significant bit (LSB):
- **LSB(i)**: The rightmost set bit in binary representation
- **Range**: Index `i` stores sum of elements from `[i - LSB(i) + 1, i]`

```python
# LSB calculation using bit manipulation
def lsb(i):
    return i & (-i)

# Examples:
# i = 12 (binary: 1100)
# -i in two's complement: 0100
# i & (-i) = 0100 = 4
# So index 12 covers 4 elements: [9, 10, 11, 12]

# i = 10 (binary: 1010)
# -i: 0110
# i & (-i) = 0010 = 2
# So index 10 covers 2 elements: [9, 10]
```

#### **Visual representation**:
```
Array indices:  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
Binary:      0001 0010 0011 0100 0101 0110 0111 1000 ...

LSB values:     1   2   1   4   1   2   1   8   1   2   1   4   1   2   1  16

Responsibility ranges:
tree[1] = arr[1]           (covers 1 element)
tree[2] = arr[1..2]        (covers 2 elements)
tree[3] = arr[3]           (covers 1 element)
tree[4] = arr[1..4]        (covers 4 elements)
tree[5] = arr[5]           (covers 1 element)
tree[6] = arr[5..6]        (covers 2 elements)
tree[7] = arr[7]           (covers 1 element)
tree[8] = arr[1..8]        (covers 8 elements)
...
```

#### **Tree structure visualization**:
```
Conceptual tree for array of size 8:

                    [1-8]
                   /     \
              [1-4]       [5-8]
             /    \       /    \
         [1-2]  [3-4]  [5-6]  [7-8]
         /  \    /  \   /  \   /  \
       [1] [2] [3] [4][5] [6][7] [8]

Actual BIT array indices:
tree[8] covers [1-8]
tree[4] covers [1-4]
tree[6] covers [5-6]
tree[2] covers [1-2]
tree[7] covers [7]
...
```

#### **Why this works**:
- **Efficient navigation**: Adding/subtracting LSB moves to parent/child in O(log n)
- **No explicit pointers**: Structure encoded in binary representation
- **Cache-friendly**: Sequential array access
- **Space-efficient**: Only n+1 elements needed

#### **Implementation**:
```python
class FenwickTree:
    def __init__(self, n):
        self.n = n
        self.tree = [0] * (n + 1)  # 1-indexed
    
    def _lsb(self, i):
        """Get least significant bit"""
        return i & (-i)
```

### 2. Point update and prefix sum
Core operations that make Fenwick Trees powerful:

#### **Point update**: Add value to single element
```python
def update(self, i, delta):
    """Add delta to element at index i (1-indexed)"""
    while i <= self.n:
        self.tree[i] += delta
        i += self._lsb(i)  # Move to parent
```

**How it works**:
- Start at index `i`
- Update current node
- Move to parent by adding LSB: `i += LSB(i)`
- Repeat until out of bounds

**Example**: Update index 5 with delta = 3
```
Initial: tree = [0, 1, 3, 2, 10, 5, 11, 7, 36, ...]

Step 1: tree[5] += 3  → tree[5] = 8
        Next: 5 + LSB(5) = 5 + 1 = 6

Step 2: tree[6] += 3  → tree[6] = 14
        Next: 6 + LSB(6) = 6 + 2 = 8

Step 3: tree[8] += 3  → tree[8] = 39
        Next: 8 + LSB(8) = 8 + 8 = 16 (out of bounds if n < 16)

Done! Updated 3 nodes in O(log n) time.
```

**Time complexity**: O(log n)
- At most log₂(n) updates (height of tree)
- Each update is O(1)

#### **Prefix sum**: Query sum from index 1 to i
```python
def prefix_sum(self, i):
    """Get sum of elements from index 1 to i (1-indexed)"""
    result = 0
    while i > 0:
        result += self.tree[i]
        i -= self._lsb(i)  # Move to previous range
    return result
```

**How it works**:
- Start at index `i`
- Add current node's value
- Move to previous non-overlapping range by subtracting LSB: `i -= LSB(i)`
- Repeat until i = 0

**Example**: Query prefix sum up to index 13
```
Query: prefix_sum(13)

Step 1: result += tree[13]  (covers [13])
        Next: 13 - LSB(13) = 13 - 1 = 12

Step 2: result += tree[12]  (covers [9-12])
        Next: 12 - LSB(12) = 12 - 4 = 8

Step 3: result += tree[8]   (covers [1-8])
        Next: 8 - LSB(8) = 8 - 8 = 0

Done! Summed ranges: [13] + [9-12] + [1-8] = [1-13]
```

**Time complexity**: O(log n)

#### **Complete implementation**:
```python
class FenwickTree:
    def __init__(self, arr):
        """Initialize from array (0-indexed input)"""
        self.n = len(arr)
        self.tree = [0] * (self.n + 1)
        
        # Build tree efficiently
        for i in range(self.n):
            self.update(i + 1, arr[i])
    
    def update(self, i, delta):
        """Add delta to index i (1-indexed)"""
        while i <= self.n:
            self.tree[i] += delta
            i += i & (-i)
    
    def prefix_sum(self, i):
        """Sum from index 1 to i (1-indexed)"""
        result = 0
        while i > 0:
            result += self.tree[i]
            i -= i & (-i)
        return result
    
    def range_sum(self, left, right):
        """Sum from left to right (1-indexed, inclusive)"""
        return self.prefix_sum(right) - self.prefix_sum(left - 1)
```

#### **Building the tree efficiently**:
```python
# Method 1: Using update (O(n log n))
def build_slow(arr):
    bit = FenwickTree([0] * len(arr))
    for i, val in enumerate(arr):
        bit.update(i + 1, val)
    return bit

# Method 2: Direct construction (O(n))
def build_fast(arr):
    n = len(arr)
    tree = [0] * (n + 1)
    
    for i in range(1, n + 1):
        tree[i] += arr[i - 1]
        j = i + (i & -i)
        if j <= n:
            tree[j] += tree[i]
    
    return tree
```

### 3. Range queries via prefix sums
Using prefix sums to answer various range queries:

#### **Range sum query**:
```python
def range_sum(self, left, right):
    """Sum of elements from left to right (1-indexed, inclusive)"""
    return self.prefix_sum(right) - self.prefix_sum(left - 1)
```

**Example**:
```
Array: [3, 2, -1, 6, 5, 4, -3, 3, 7, 2, 3]
Query: sum from index 3 to 7

Solution:
sum[3..7] = prefix_sum(7) - prefix_sum(2)
          = sum[1..7] - sum[1..2]
          = (3+2-1+6+5+4-3) - (3+2)
          = 16 - 5
          = 11
```

#### **Point query** (get single element value):
```python
def point_query(self, i):
    """Get value at index i (1-indexed)"""
    return self.range_sum(i, i)
```

#### **Range update with range query**:
For range updates, use difference array technique:
```python
class FenwickTreeRangeUpdate:
    def __init__(self, n):
        self.n = n
        self.tree = [0] * (n + 1)
    
    def range_update(self, left, right, delta):
        """Add delta to all elements in [left, right]"""
        self.update(left, delta)
        self.update(right + 1, -delta)
    
    def point_query(self, i):
        """Get value at index i after all updates"""
        return self.prefix_sum(i)
    
    def update(self, i, delta):
        while i <= self.n:
            self.tree[i] += delta
            i += i & (-i)
    
    def prefix_sum(self, i):
        result = 0
        while i > 0:
            result += self.tree[i]
            i -= i & (-i)
        return result
```

**Example**: Range update
```
Initial array: [0, 0, 0, 0, 0, 0, 0, 0]

range_update(3, 6, 5):  # Add 5 to indices 3-6
  update(3, 5)   → diff[3] += 5
  update(7, -5)  → diff[7] += -5

Difference array: [0, 0, 5, 0, 0, 0, -5, 0]
Prefix sums:      [0, 0, 5, 5, 5, 5,  0, 0]
Result array:     [0, 0, 5, 5, 5, 5,  0, 0] ✓
```

#### **2D Fenwick Tree** (for matrix range sums):
```python
class FenwickTree2D:
    def __init__(self, rows, cols):
        self.rows = rows
        self.cols = cols
        self.tree = [[0] * (cols + 1) for _ in range(rows + 1)]
    
    def update(self, row, col, delta):
        """Add delta to cell (row, col)"""
        i = row
        while i <= self.rows:
            j = col
            while j <= self.cols:
                self.tree[i][j] += delta
                j += j & (-j)
            i += i & (-i)
    
    def prefix_sum(self, row, col):
        """Sum of rectangle from (1,1) to (row, col)"""
        result = 0
        i = row
        while i > 0:
            j = col
            while j > 0:
                result += self.tree[i][j]
                j -= j & (-j)
            i -= i & (-i)
        return result
    
    def range_sum(self, r1, c1, r2, c2):
        """Sum of rectangle from (r1,c1) to (r2,c2)"""
        return (self.prefix_sum(r2, c2) 
                - self.prefix_sum(r1 - 1, c2)
                - self.prefix_sum(r2, c1 - 1)
                + self.prefix_sum(r1 - 1, c1 - 1))
```

**Time complexity**:
- 1D: O(log n) per operation
- 2D: O(log m × log n) per operation

### 4. Space/time trade-offs vs segment trees
Comparing Fenwick Trees with Segment Trees:

#### **Fenwick Tree characteristics**:
- **Space**: O(n) - single array
- **Point update**: O(log n)
- **Range query**: O(log n)
- **Construction**: O(n log n) or O(n) optimized
- **Limitations**: Only supports associative operations (sum, XOR, etc.)

#### **Segment Tree characteristics**:
- **Space**: O(4n) - tree array
- **Point update**: O(log n)
- **Range query**: O(log n)
- **Construction**: O(n)
- **Advantages**: Supports any associative operation (min, max, GCD, etc.)

#### **Detailed comparison**:

| Feature | Fenwick Tree | Segment Tree |
|---------|--------------|--------------|
| **Space** | O(n) | O(4n) |
| **Code complexity** | Simple (~20 lines) | Moderate (~50 lines) |
| **Constants** | Lower | Higher |
| **Cache performance** | Better | Good |
| **Operations** | Sum, XOR, etc. | Any associative op |
| **Range updates** | Needs difference array | Native support |
| **Lazy propagation** | Not applicable | Supported |
| **Point query** | O(log n) | O(log n) or O(1)* |
| **Implementation** | Bit manipulation | Recursion/iteration |

*Segment tree can store original values at leaves

#### **When to use Fenwick Tree**:
✓ Need prefix sums or range sums
✓ Want minimal memory usage
✓ Prefer simple implementation
✓ Operations are invertible (sum, XOR)
✓ Competitive programming (faster to code)

#### **When to use Segment Tree**:
✓ Need range minimum/maximum queries
✓ Need range GCD, LCM queries
✓ Need lazy propagation for range updates
✓ Operations are not invertible
✓ Need to store additional information per node

#### **Performance comparison** (1M elements):
```
Operation          Fenwick Tree    Segment Tree
-------------------------------------------------
Memory             4 MB            16 MB
Build time         ~20 ms          ~15 ms
1M updates         ~50 ms          ~80 ms
1M range queries   ~50 ms          ~80 ms
Code lines         ~20             ~50
```

#### **Example: When Fenwick Tree fails**:
```python
# Range minimum query - Fenwick Tree CANNOT do this efficiently
# Must use Segment Tree or Sparse Table

# Why? Subtraction doesn't work for min:
# min(arr[1..7]) ≠ min(arr[1..7]) - min(arr[1..2])

# Segment Tree solution:
class SegmentTree:
    def range_min(self, left, right):
        return self._query(1, 1, self.n, left, right)
```

#### **Hybrid approach**:
```python
# Use both for different queries on same array
class HybridStructure:
    def __init__(self, arr):
        self.fenwick = FenwickTree(arr)  # For sum queries
        self.segment = SegmentTree(arr)  # For min/max queries
    
    def range_sum(self, l, r):
        return self.fenwick.range_sum(l, r)
    
    def range_min(self, l, r):
        return self.segment.range_min(l, r)
```

### 5. Common patterns and pitfalls
Best practices and mistakes to avoid:

#### **Common patterns**:

1. **Inversion count** (count pairs where i < j but arr[i] > arr[j]):
   ```python
   def count_inversions(arr):
       # Coordinate compression
       sorted_arr = sorted(set(arr))
       rank = {v: i+1 for i, v in enumerate(sorted_arr)}
       
       bit = FenwickTree(len(sorted_arr))
       inversions = 0
       
       for i in range(len(arr) - 1, -1, -1):
           r = rank[arr[i]]
           inversions += bit.prefix_sum(r - 1)
           bit.update(r, 1)
       
       return inversions
   ```

2. **Dynamic median** (maintain median with updates):
   ```python
   # Use two Fenwick Trees: one for counts, one for sums
   class DynamicMedian:
       def __init__(self, max_val):
           self.count_tree = FenwickTree(max_val)
           self.sum_tree = FenwickTree(max_val)
       
       def insert(self, val):
           self.count_tree.update(val, 1)
           self.sum_tree.update(val, val)
       
       def find_median(self):
           total = self.count_tree.prefix_sum(self.max_val)
           target = (total + 1) // 2
           # Binary search for target-th element
           return self._binary_search(target)
   ```

3. **Range frequency query**:
   ```python
   # Count occurrences of value x in range [l, r]
   class RangeFrequency:
       def __init__(self, arr):
           self.positions = {}
           for i, val in enumerate(arr):
               if val not in self.positions:
                   self.positions[val] = []
               self.positions[val].append(i)
       
       def count(self, l, r, x):
           if x not in self.positions:
               return 0
           pos = self.positions[x]
           # Binary search for range [l, r]
           left_idx = bisect_left(pos, l)
           right_idx = bisect_right(pos, r)
           return right_idx - left_idx
   ```

#### **Common pitfalls**:

1. **0-indexed vs 1-indexed confusion**:
   ```python
   # Wrong: Using 0-indexed directly
   bit = FenwickTree(n)
   bit.update(0, 5)  # Error! Fenwick Tree is 1-indexed
   
   # Correct: Convert to 1-indexed
   bit.update(1, 5)  # Update first element
   
   # Or use wrapper:
   def update_0indexed(self, i, delta):
       self.update(i + 1, delta)
   ```

2. **Forgetting to handle negative values**:
   ```python
   # Wrong: Fenwick Tree with negative indices
   # Fenwick Tree requires positive indices
   
   # Correct: Coordinate compression
   def compress(arr):
       sorted_unique = sorted(set(arr))
       return {v: i+1 for i, v in enumerate(sorted_unique)}
   ```

3. **Using Fenwick Tree for non-invertible operations**:
   ```python
   # Wrong: Range minimum with Fenwick Tree
   # min(a, b) - min(c, d) doesn't give meaningful result
   
   # Correct: Use Segment Tree for min/max
   ```

4. **Not initializing with correct size**:
   ```python
   # Wrong: Size too small
   bit = FenwickTree(len(arr))
   bit.update(len(arr), 5)  # Out of bounds!
   
   # Correct: Account for 1-indexing
   bit = FenwickTree(len(arr))
   bit.update(len(arr), 5)  # OK if tree size is len(arr)
   ```

5. **Inefficient construction**:
   ```python
   # Slow: O(n log n)
   bit = FenwickTree(n)
   for i, val in enumerate(arr):
       bit.update(i + 1, val)
   
   # Fast: O(n) construction
   def build_optimized(arr):
       n = len(arr)
       tree = [0] * (n + 1)
       for i in range(1, n + 1):
           tree[i] += arr[i - 1]
           j = i + (i & -i)
           if j <= n:
               tree[j] += tree[i]
       return tree
   ```

#### **Debugging tips**:
- Print tree array to visualize state
- Verify LSB calculation: `i & (-i)`
- Check 1-indexed vs 0-indexed conversions
- Test with small arrays first
- Compare with brute force for correctness

### 6. Applications
Real-world uses of Fenwick Trees:

#### **Competitive programming**:
1. **Range sum queries**:
   - Given array, answer Q queries for sum in range [L, R]
   - With updates: modify single elements
   
2. **Counting inversions**:
   - Count pairs (i, j) where i < j but arr[i] > arr[j]
   - Used in sorting analysis, ranking systems

3. **Order statistics**:
   - Find k-th smallest element in dynamic array
   - Maintain sorted order with insertions/deletions

#### **Database systems**:
1. **Aggregate queries**:
   - Fast SUM, COUNT queries over ranges
   - Used in OLAP (Online Analytical Processing)
   
2. **Time-series data**:
   - Cumulative metrics (total sales, user counts)
   - Sliding window aggregations

#### **Graphics and gaming**:
1. **2D range queries**:
   - Sum of values in rectangular region
   - Used in image processing, collision detection
   
2. **Particle systems**:
   - Count particles in spatial regions
   - Update particle properties efficiently

#### **Example problems**:

**Problem 1: Range Sum Query - Mutable (LeetCode 307)**
```python
class NumArray:
    def __init__(self, nums):
        self.nums = nums
        self.bit = FenwickTree(nums)
    
    def update(self, index, val):
        delta = val - self.nums[index]
        self.nums[index] = val
        self.bit.update(index + 1, delta)
    
    def sumRange(self, left, right):
        return self.bit.range_sum(left + 1, right + 1)
```

**Problem 2: Count of Smaller Numbers After Self (LeetCode 315)**
```python
def countSmaller(nums):
    # Coordinate compression
    sorted_nums = sorted(set(nums))
    rank = {v: i+1 for i, v in enumerate(sorted_nums)}
    
    bit = FenwickTree(len(sorted_nums))
    result = []
    
    for num in reversed(nums):
        r = rank[num]
        result.append(bit.prefix_sum(r - 1))
        bit.update(r, 1)
    
    return result[::-1]
```

**Problem 3: Range Addition (LeetCode 370)**
```python
def getModifiedArray(length, updates):
    bit = FenwickTree(length)
    
    for start, end, inc in updates:
        bit.update(start + 1, inc)
        if end + 2 <= length:
            bit.update(end + 2, -inc)
    
    result = []
    for i in range(1, length + 1):
        result.append(bit.prefix_sum(i))
    
    return result
```

**Problem 4: 2D Matrix Range Sum (LeetCode 308)**
```python
class NumMatrix:
    def __init__(self, matrix):
        if not matrix or not matrix[0]:
            return
        self.matrix = matrix
        self.bit = FenwickTree2D(len(matrix), len(matrix[0]))
        
        for i in range(len(matrix)):
            for j in range(len(matrix[0])):
                self.bit.update(i + 1, j + 1, matrix[i][j])
    
    def update(self, row, col, val):
        delta = val - self.matrix[row][col]
        self.matrix[row][col] = val
        self.bit.update(row + 1, col + 1, delta)
    
    def sumRegion(self, row1, col1, row2, col2):
        return self.bit.range_sum(row1 + 1, col1 + 1, 
                                   row2 + 1, col2 + 1)
```

#### **Performance in practice**:
- **Codeforces**: Fenwick Tree preferred for speed
- **LeetCode**: Often overkill, but useful for hard problems
- **Production systems**: Used in analytics databases
- **Real-time systems**: Low latency for range queries

#### **Advanced applications**:
1. **Persistent Fenwick Tree**: Support queries on historical versions
2. **Parallel Fenwick Tree**: Concurrent updates with lock-free operations
3. **Compressed Fenwick Tree**: For sparse arrays (coordinate compression)
4. **Multi-dimensional**: 3D, 4D for spatial queries
