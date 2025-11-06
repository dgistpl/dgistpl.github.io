---
layout: splash
author_profile: false
---

# Segment Trees

Tree structure for range queries and updates.

### 1. Building segment trees
Understanding construction and structure:

#### **Concept**:
- **Purpose**: Efficiently answer range queries and updates
- **Structure**: Binary tree where each node represents an interval
- **Property**: Each node stores aggregate information about its range
- **Height**: O(log n) for n elements

#### **Array representation**:
```python
# For array of size n, segment tree needs 4*n space
# Node i has children at 2*i and 2*i+1
# Parent of node i is at i//2

class SegmentTree:
    def __init__(self, arr):
        self.n = len(arr)
        self.tree = [0] * (4 * self.n)
        self.arr = arr
        if self.n > 0:
            self.build(1, 0, self.n - 1)
```

#### **Building the tree (bottom-up)**:
```python
def build(self, node, start, end):
    """
    Build segment tree recursively
    node: current node index in tree array
    start, end: range this node represents
    """
    if start == end:
        # Leaf node
        self.tree[node] = self.arr[start]
        return
    
    mid = (start + end) // 2
    left_child = 2 * node
    right_child = 2 * node + 1
    
    # Build left and right subtrees
    self.build(left_child, start, mid)
    self.build(right_child, mid + 1, end)
    
    # Internal node stores sum of children
    self.tree[node] = self.tree[left_child] + self.tree[right_child]
```

#### **Visual example**:
```
Array: [1, 3, 5, 7, 9, 11]

Segment Tree (sum):
                    [0-5: 36]
                   /          \
            [0-2: 9]          [3-5: 27]
           /        \         /         \
      [0-1: 4]   [2: 5]  [3-4: 16]  [5: 11]
      /      \            /      \
  [0: 1]  [1: 3]     [3: 7]  [4: 9]

Tree array: [_, 36, 9, 27, 4, 5, 16, 11, 1, 3, _, _, 7, 9, _, _]
Indices:     0   1  2   3  4  5   6   7  8  9 10 11 12 13 14 15
```

#### **Iterative build (more efficient)**:
```python
def build_iterative(self, arr):
    """Build segment tree iteratively"""
    n = len(arr)
    self.tree = [0] * (2 * n)
    
    # Copy array to second half
    for i in range(n):
        self.tree[n + i] = arr[i]
    
    # Build tree by calculating parents
    for i in range(n - 1, 0, -1):
        self.tree[i] = self.tree[2 * i] + self.tree[2 * i + 1]
```

#### **Time and space**:
- **Build time**: O(n)
- **Space**: O(4n) = O(n) for recursive, O(2n) for iterative

### 2. Range sum/min/max queries
Efficiently querying aggregate values over ranges:

#### **Range sum query**:
```python
def query_sum(self, node, start, end, left, right):
    """
    Query sum in range [left, right]
    node: current node
    [start, end]: range of current node
    [left, right]: query range
    """
    # No overlap
    if right < start or left > end:
        return 0
    
    # Complete overlap
    if left <= start and end <= right:
        return self.tree[node]
    
    # Partial overlap
    mid = (start + end) // 2
    left_sum = self.query_sum(2 * node, start, mid, left, right)
    right_sum = self.query_sum(2 * node + 1, mid + 1, end, left, right)
    
    return left_sum + right_sum

# Wrapper method
def range_sum(self, left, right):
    return self.query_sum(1, 0, self.n - 1, left, right)
```

#### **Range minimum query**:
```python
class SegmentTreeMin:
    def __init__(self, arr):
        self.n = len(arr)
        self.tree = [float('inf')] * (4 * self.n)
        self.arr = arr
        if self.n > 0:
            self.build(1, 0, self.n - 1)
    
    def build(self, node, start, end):
        if start == end:
            self.tree[node] = self.arr[start]
            return
        
        mid = (start + end) // 2
        self.build(2 * node, start, mid)
        self.build(2 * node + 1, mid + 1, end)
        
        # Store minimum of children
        self.tree[node] = min(self.tree[2 * node], 
                             self.tree[2 * node + 1])
    
    def query_min(self, node, start, end, left, right):
        if right < start or left > end:
            return float('inf')
        
        if left <= start and end <= right:
            return self.tree[node]
        
        mid = (start + end) // 2
        left_min = self.query_min(2 * node, start, mid, left, right)
        right_min = self.query_min(2 * node + 1, mid + 1, end, left, right)
        
        return min(left_min, right_min)
```

#### **Range maximum query**:
```python
class SegmentTreeMax:
    def build(self, node, start, end):
        if start == end:
            self.tree[node] = self.arr[start]
            return
        
        mid = (start + end) // 2
        self.build(2 * node, start, mid)
        self.build(2 * node + 1, mid + 1, end)
        
        # Store maximum of children
        self.tree[node] = max(self.tree[2 * node], 
                             self.tree[2 * node + 1])
```

#### **Query visualization**:
```
Query: sum(2, 4) in array [1, 3, 5, 7, 9, 11]

Tree traversal:
                [0-5: 36]
               /          \
        [0-2: 9]          [3-5: 27]
           ✗              /         \
                    [3-4: 16]✓   [5: 11]✗
                    /      \
                [3: 7]✓  [4: 9]✓

Result: 5 (from [2:5]) + 16 (from [3-4:16]) = 21
Actually: 5 + 7 + 9 = 21 ✓
```

#### **Time complexity**: O(log n) per query

### 3. Point and range updates
Modifying values in the segment tree:

#### **Point update**:
```python
def update_point(self, node, start, end, idx, value):
    """
    Update element at index idx to value
    """
    if start == end:
        # Leaf node
        self.arr[idx] = value
        self.tree[node] = value
        return
    
    mid = (start + end) // 2
    
    if idx <= mid:
        # Update left child
        self.update_point(2 * node, start, mid, idx, value)
    else:
        # Update right child
        self.update_point(2 * node + 1, mid + 1, end, idx, value)
    
    # Update current node
    self.tree[node] = self.tree[2 * node] + self.tree[2 * node + 1]

# Wrapper
def update(self, idx, value):
    self.update_point(1, 0, self.n - 1, idx, value)
```

#### **Range update (naive)**:
```python
def update_range_naive(self, left, right, delta):
    """
    Add delta to all elements in [left, right]
    Naive approach: update each element individually
    Time: O(n log n) - BAD!
    """
    for i in range(left, right + 1):
        self.update(i, self.arr[i] + delta)
```

#### **Range update with difference array**:
```python
class SegmentTreeRangeUpdate:
    """
    For range updates, use difference array
    diff[i] = arr[i] - arr[i-1]
    """
    def __init__(self, arr):
        self.n = len(arr)
        # Build difference array
        self.diff = [arr[0]] + [arr[i] - arr[i-1] 
                                 for i in range(1, len(arr))]
        self.tree = [0] * (4 * self.n)
        self.build(1, 0, self.n - 1)
    
    def range_update(self, left, right, delta):
        """Add delta to range [left, right] in O(log n)"""
        self.update(left, delta)
        if right + 1 < self.n:
            self.update(right + 1, -delta)
    
    def point_query(self, idx):
        """Get value at index idx"""
        return self.query_sum(1, 0, self.n - 1, 0, idx)
```

#### **Update visualization**:
```
Update index 2 from 5 to 8 (delta = +3)

Before:
                [0-5: 36]
               /          \
        [0-2: 9]          [3-5: 27]
       /        \
  [0-1: 4]   [2: 5]←

After:
                [0-5: 39]
               /          \
        [0-2: 12]         [3-5: 27]
       /        \
  [0-1: 4]   [2: 8]←

Updated nodes: [2], [0-2], [0-5] - O(log n) nodes
```

### 4. Lazy propagation
Optimizing range updates to O(log n):

#### **Concept**:
- **Problem**: Naive range update is O(n log n)
- **Solution**: Defer updates using lazy propagation
- **Idea**: Mark nodes as "lazy" instead of updating immediately
- **Propagate**: Push lazy values down only when needed

#### **Implementation**:
```python
class SegmentTreeLazy:
    def __init__(self, arr):
        self.n = len(arr)
        self.tree = [0] * (4 * self.n)
        self.lazy = [0] * (4 * self.n)  # Lazy array
        self.arr = arr
        if self.n > 0:
            self.build(1, 0, self.n - 1)
    
    def build(self, node, start, end):
        if start == end:
            self.tree[node] = self.arr[start]
            return
        
        mid = (start + end) // 2
        self.build(2 * node, start, mid)
        self.build(2 * node + 1, mid + 1, end)
        self.tree[node] = self.tree[2 * node] + self.tree[2 * node + 1]
    
    def push_down(self, node, start, end):
        """Propagate lazy value to children"""
        if self.lazy[node] != 0:
            # Apply lazy value to current node
            self.tree[node] += (end - start + 1) * self.lazy[node]
            
            # If not leaf, propagate to children
            if start != end:
                self.lazy[2 * node] += self.lazy[node]
                self.lazy[2 * node + 1] += self.lazy[node]
            
            # Clear lazy value
            self.lazy[node] = 0
    
    def update_range(self, node, start, end, left, right, delta):
        """Add delta to range [left, right]"""
        # Push down pending updates
        self.push_down(node, start, end)
        
        # No overlap
        if right < start or left > end:
            return
        
        # Complete overlap
        if left <= start and end <= right:
            # Mark as lazy instead of updating
            self.lazy[node] += delta
            self.push_down(node, start, end)
            return
        
        # Partial overlap
        mid = (start + end) // 2
        self.update_range(2 * node, start, mid, left, right, delta)
        self.update_range(2 * node + 1, mid + 1, end, left, right, delta)
        
        # Update current node after children are updated
        self.push_down(2 * node, start, mid)
        self.push_down(2 * node + 1, mid + 1, end)
        self.tree[node] = self.tree[2 * node] + self.tree[2 * node + 1]
    
    def query_range(self, node, start, end, left, right):
        """Query sum in range [left, right]"""
        # Push down pending updates
        self.push_down(node, start, end)
        
        # No overlap
        if right < start or left > end:
            return 0
        
        # Complete overlap
        if left <= start and end <= right:
            return self.tree[node]
        
        # Partial overlap
        mid = (start + end) // 2
        left_sum = self.query_range(2 * node, start, mid, left, right)
        right_sum = self.query_range(2 * node + 1, mid + 1, end, left, right)
        
        return left_sum + right_sum
    
    # Wrapper methods
    def update(self, left, right, delta):
        self.update_range(1, 0, self.n - 1, left, right, delta)
    
    def query(self, left, right):
        return self.query_range(1, 0, self.n - 1, left, right)
```

#### **Lazy propagation example**:
```
Array: [1, 2, 3, 4, 5]
Update: add 10 to range [1, 3]

Without lazy (naive):
- Update index 1: O(log n)
- Update index 2: O(log n)
- Update index 3: O(log n)
Total: O(n log n)

With lazy:
- Mark nodes covering [1, 3] as lazy
- Only O(log n) nodes marked
- Updates propagated only when queried

Lazy array after update:
lazy[node covering 1-3] = 10
Children not updated yet!

On next query:
- Push lazy value down to children
- Update happens on-demand
```

#### **Benefits**:
- Range update: O(log n) instead of O(n log n)
- Multiple updates before query: Very efficient
- Trade-off: Slightly more complex code

### 5. Space/time complexities
Understanding performance characteristics:

#### **Space complexity**:
```python
# Recursive representation (array-based)
# For n elements:
# - Tree height: ceil(log₂ n)
# - Nodes at level i: 2^i
# - Total nodes: 2^(h+1) - 1 ≈ 4n

# Example: n = 5
# Height = 3
# Nodes = 2^4 - 1 = 15
# Array size = 4 * 5 = 20 (safe upper bound)

def calculate_tree_size(n):
    import math
    height = math.ceil(math.log2(n))
    return 2 ** (height + 1)

# Iterative representation
# Size = 2 * n (more space-efficient)
```

#### **Time complexities**:

| Operation | Without Lazy | With Lazy |
|-----------|-------------|-----------|
| Build | O(n) | O(n) |
| Point update | O(log n) | O(log n) |
| Point query | O(log n) | O(log n) |
| Range query | O(log n) | O(log n) |
| Range update | O(n log n) | O(log n) |

#### **Comparison with alternatives**:

| Structure | Build | Query | Update | Space |
|-----------|-------|-------|--------|-------|
| Array | O(1) | O(n) | O(1) | O(n) |
| Prefix Sum | O(n) | O(1) | O(n) | O(n) |
| Sqrt Decomposition | O(n) | O(√n) | O(√n) | O(n) |
| Segment Tree | O(n) | O(log n) | O(log n) | O(4n) |
| Fenwick Tree | O(n log n) | O(log n) | O(log n) | O(n) |

#### **Memory usage example**:
```python
# For 1 million elements
n = 1_000_000

# Segment tree
seg_tree_size = 4 * n * 8 bytes  # 32 MB (with lazy: 64 MB)

# Fenwick tree
fenwick_size = n * 8 bytes  # 8 MB

# Trade-off: Segment tree uses more memory but more versatile
```

#### **When to use segment trees**:
✓ Need range queries (sum, min, max, GCD, etc.)
✓ Need range updates
✓ Operation is associative
✓ Memory not severely constrained
✓ Need flexibility (any associative operation)

#### **When to use alternatives**:
- **Fenwick Tree**: Only sum/XOR, want less memory
- **Sqrt Decomposition**: Simpler code, O(√n) acceptable
- **Sparse Table**: Static array, only queries (no updates)

### 6. Use cases in CP and databases
Real-world applications:

#### **Competitive Programming**:

**1. Range sum with updates**:
```python
# Problem: Dynamic range sum queries
def solve_range_sum():
    arr = [1, 3, 5, 7, 9, 11]
    seg_tree = SegmentTreeLazy(arr)
    
    # Query sum in range [1, 4]
    print(seg_tree.query(1, 4))  # 3+5+7+9 = 24
    
    # Update: add 10 to range [2, 4]
    seg_tree.update(2, 4, 10)
    
    # Query again
    print(seg_tree.query(1, 4))  # 3+15+17+19 = 54
```

**2. Range minimum query with updates**:
```python
# Problem: Find minimum in range, with updates
class RMQSegmentTree:
    # Similar to sum, but use min instead
    def build(self, node, start, end):
        if start == end:
            self.tree[node] = self.arr[start]
            return
        mid = (start + end) // 2
        self.build(2*node, start, mid)
        self.build(2*node+1, mid+1, end)
        self.tree[node] = min(self.tree[2*node], self.tree[2*node+1])
```

**3. Count elements in range**:
```python
# Problem: Count elements in range [L, R] with value in [a, b]
# Solution: Merge sort tree (segment tree of sorted arrays)
class MergeSortTree:
    def build(self, node, start, end):
        if start == end:
            self.tree[node] = [self.arr[start]]
            return
        
        mid = (start + end) // 2
        self.build(2*node, start, mid)
        self.build(2*node+1, mid+1, end)
        
        # Merge sorted arrays
        self.tree[node] = self.merge(self.tree[2*node], 
                                     self.tree[2*node+1])
    
    def count_in_range(self, node, start, end, left, right, a, b):
        """Count elements in [left,right] with value in [a,b]"""
        if right < start or left > end:
            return 0
        
        if left <= start and end <= right:
            # Binary search in sorted array
            return self.count_between(self.tree[node], a, b)
        
        mid = (start + end) // 2
        return (self.count_in_range(2*node, start, mid, left, right, a, b) +
                self.count_in_range(2*node+1, mid+1, end, left, right, a, b))
```

**4. Maximum subarray sum in range**:
```python
class MaxSubarraySegTree:
    """
    Each node stores: (max_sum, prefix_sum, suffix_sum, total_sum)
    """
    def combine(self, left, right):
        max_sum = max(left[0], right[0], 
                     left[2] + right[1])  # Crossing middle
        prefix_sum = max(left[1], left[3] + right[1])
        suffix_sum = max(right[2], right[3] + left[2])
        total_sum = left[3] + right[3]
        
        return (max_sum, prefix_sum, suffix_sum, total_sum)
```

#### **Database applications**:

**1. Range aggregations**:
```sql
-- SQL query: SELECT SUM(value) FROM table WHERE id BETWEEN 100 AND 200
-- Internally: Segment tree for fast range sum
```

**2. Time-series databases**:
```python
# Store time-series data with efficient range queries
class TimeSeriesDB:
    def __init__(self):
        self.seg_tree = SegmentTreeLazy([])
    
    def add_metric(self, timestamp, value):
        # Add value at timestamp
        pass
    
    def get_avg(self, start_time, end_time):
        # Get average in time range
        total = self.seg_tree.query(start_time, end_time)
        count = end_time - start_time + 1
        return total / count
```

**3. Spatial databases**:
```python
# 2D segment tree for spatial range queries
class SpatialIndex:
    """
    Query: Find all points in rectangle [x1,y1] to [x2,y2]
    Solution: 2D segment tree
    """
    def range_query_2d(self, x1, y1, x2, y2):
        # Query x-dimension segment tree
        # Each node has y-dimension segment tree
        pass
```

#### **Other applications**:
- **Graphics**: Rectangle union area, line sweep algorithms
- **Computational geometry**: Closest pair, intersection queries
- **Game development**: Collision detection, visibility queries
- **Network monitoring**: Traffic analysis, anomaly detection
- **Financial systems**: OHLC (Open-High-Low-Close) queries

#### **Example: LeetCode problems using segment trees**:
1. **Range Sum Query - Mutable** (LeetCode 307)
2. **Count of Range Sum** (LeetCode 327)
3. **Range Module** (LeetCode 715)
4. **Falling Squares** (LeetCode 699)
5. **My Calendar III** (LeetCode 732)
