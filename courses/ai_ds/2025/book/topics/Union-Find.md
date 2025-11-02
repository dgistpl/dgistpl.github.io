---
layout: splash
author_profile: false
---

# Disjoint Set / Union-Find

Maintain dynamic connectivity across disjoint sets.


### 1. Parent array and forest representation
Understanding the fundamental structure:

#### **Concept**:
- **Disjoint Set**: Collection of non-overlapping sets
- **Representative**: Each set has a representative (root) element
- **Parent Array**: Each element points to its parent
- **Forest**: Multiple trees, each representing a set

#### **Basic structure**:
```python
class UnionFind:
    def __init__(self, n):
        # Initially, each element is its own parent (separate set)
        self.parent = list(range(n))
        self.count = n  # Number of disjoint sets
```

**Visual representation**:
```
Initial state (n=5):
parent = [0, 1, 2, 3, 4]

Each element is its own set:
0    1    2    3    4

After union(0, 1) and union(2, 3):
parent = [0, 0, 2, 2, 4]

Forest representation:
  0       2     4
  |       |
  1       3

Sets: {0,1}, {2,3}, {4}
```

#### **Basic operations (naive)**:
```python
def find(self, x):
    """Find root of element x"""
    while self.parent[x] != x:
        x = self.parent[x]
    return x

def union(self, x, y):
    """Merge sets containing x and y"""
    root_x = self.find(x)
    root_y = self.find(y)
    
    if root_x != root_y:
        self.parent[root_x] = root_y
        self.count -= 1

def connected(self, x, y):
    """Check if x and y are in same set"""
    return self.find(x) == self.find(y)
```

**Example usage**:
```python
uf = UnionFind(5)

# Union operations
uf.union(0, 1)  # Merge {0} and {1}
uf.union(2, 3)  # Merge {2} and {3}
uf.union(0, 2)  # Merge {0,1} and {2,3}

# Check connectivity
print(uf.connected(1, 3))  # True (both in {0,1,2,3})
print(uf.connected(1, 4))  # False (4 is separate)
print(uf.count)  # 2 sets: {0,1,2,3}, {4}
```

### 2. Find with path compression
Optimizing the find operation:

#### **Problem with naive find**:
```
Worst case: Linear chain
0 → 1 → 2 → 3 → 4

find(4) requires 4 steps
Multiple finds on same element: O(n) each time
```

#### **Path compression**:
- **Idea**: Make every node point directly to root during find
- **Effect**: Flattens tree structure
- **Benefit**: Future finds become O(1)

**Implementation**:
```python
def find(self, x):
    """Find with path compression"""
    if self.parent[x] != x:
        # Recursively find root and compress path
        self.parent[x] = self.find(self.parent[x])
    return self.parent[x]
```

**Visual example**:
```
Before find(4):
    0
    |
    1
    |
    2
    |
    3
    |
    4

After find(4) with path compression:
    0
   /|\\\
  1 2 3 4

All nodes now point directly to root!
```

**Iterative path compression**:
```python
def find_iterative(self, x):
    """Iterative find with path compression"""
    root = x
    
    # Find root
    while self.parent[root] != root:
        root = self.parent[root]
    
    # Compress path
    while x != root:
        next_parent = self.parent[x]
        self.parent[x] = root
        x = next_parent
    
    return root
```

**Two-pass path compression**:
```python
def find_two_pass(self, x):
    """Two-pass: find root, then compress"""
    # First pass: find root
    root = x
    while self.parent[root] != root:
        root = self.parent[root]
    
    # Second pass: point all nodes to root
    while x != root:
        parent = self.parent[x]
        self.parent[x] = root
        x = parent
    
    return root
```

**Path halving (one-pass optimization)**:
```python
def find_path_halving(self, x):
    """Point every other node to its grandparent"""
    while self.parent[x] != x:
        self.parent[x] = self.parent[self.parent[x]]
        x = self.parent[x]
    return x
```

### 3. Union by rank/size
Optimizing the union operation:

#### **Problem with naive union**:
```
Always attach first tree to second:
union(0, 1): 0 → 1
union(0, 2): 0 → 1 → 2
union(0, 3): 0 → 1 → 2 → 3

Creates linear chain (worst case)
```

#### **Union by rank**:
- **Rank**: Upper bound on tree height
- **Rule**: Attach smaller rank tree under larger rank tree
- **Benefit**: Keeps trees balanced

**Implementation**:
```python
class UnionFindRank:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n  # Initial rank is 0
        self.count = n
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)
        
        if root_x == root_y:
            return False
        
        # Attach smaller rank tree under larger rank tree
        if self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        elif self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        else:
            # Equal rank: attach either way, increase rank
            self.parent[root_y] = root_x
            self.rank[root_x] += 1
        
        self.count -= 1
        return True
```

**Visual example**:
```
Union by rank:

Tree A (rank 1):    Tree B (rank 2):
    0                   2
    |                  / \
    1                 3   4

union(0, 2): Attach A under B (smaller rank under larger)
Result (rank 2):
        2
       /|\
      3 4 0
          |
          1
```

#### **Union by size**:
- **Size**: Number of elements in tree
- **Rule**: Attach smaller tree under larger tree
- **Benefit**: Also keeps trees balanced

**Implementation**:
```python
class UnionFindSize:
    def __init__(self, n):
        self.parent = list(range(n))
        self.size = [1] * n  # Initial size is 1
        self.count = n
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)
        
        if root_x == root_y:
            return False
        
        # Attach smaller tree under larger tree
        if self.size[root_x] < self.size[root_y]:
            self.parent[root_x] = root_y
            self.size[root_y] += self.size[root_x]
        else:
            self.parent[root_y] = root_x
            self.size[root_x] += self.size[root_y]
        
        self.count -= 1
        return True
    
    def get_size(self, x):
        """Get size of set containing x"""
        return self.size[self.find(x)]
```

**Comparison**:
```python
# Without optimization: O(n) per operation
# With path compression only: O(log n) amortized
# With union by rank only: O(log n) per operation
# With both: O(α(n)) amortized (nearly O(1))
```

### 4. Amortized inverse Ackermann complexity
Understanding the remarkable efficiency:

#### **Ackermann function**:
```python
# Ackermann function (grows extremely fast)
def A(m, n):
    if m == 0:
        return n + 1
    if n == 0:
        return A(m - 1, 1)
    return A(m - 1, A(m, n - 1))

# A(0,n) = n+1
# A(1,n) = n+2
# A(2,n) = 2n+3
# A(3,n) = 2^(n+3) - 3
# A(4,n) = 2^2^2^... (n+3 times) - 3
```

#### **Inverse Ackermann α(n)**:
```python
# α(n) = minimum m such that A(m, m) ≥ n
# 
# α(n) grows EXTREMELY slowly:
# α(1) = 1
# α(3) = 2
# α(7) = 3
# α(2047) = 4
# α(2^2048 - 1) = 5
# 
# For all practical n (even n = 10^80), α(n) ≤ 5
```

#### **Complexity analysis**:
```python
# Union-Find with both optimizations:
# - Path compression
# - Union by rank/size
# 
# Time complexity:
# - m operations on n elements: O(m · α(n))
# - Amortized per operation: O(α(n))
# - Practically: O(1) per operation
# 
# Space complexity: O(n)
```

**Practical implications**:
```python
# For n = 10^9 elements:
# α(10^9) ≈ 4
# 
# This means operations are essentially O(1)!
# 
# Example: 10^9 operations on 10^9 elements
# Theoretical: O(10^9 · 4) ≈ 4 billion operations
# vs naive O(n): O(10^9 · 10^9) = 10^18 operations
# 
# Speedup: ~250 million times faster!
```

### 5. Applications: Kruskal's MST, connectivity
Real-world uses of Union-Find:

#### **Kruskal's Minimum Spanning Tree**:
```python
def kruskal_mst(n, edges):
    """
    Find minimum spanning tree using Kruskal's algorithm
    n: number of vertices
    edges: list of (weight, u, v)
    """
    # Sort edges by weight
    edges.sort()
    
    uf = UnionFind(n)
    mst = []
    total_weight = 0
    
    for weight, u, v in edges:
        # If u and v not connected, add edge
        if uf.union(u, v):
            mst.append((u, v, weight))
            total_weight += weight
            
            # MST complete when n-1 edges added
            if len(mst) == n - 1:
                break
    
    return mst, total_weight

# Example
edges = [
    (1, 0, 1),  # (weight, u, v)
    (2, 0, 2),
    (3, 1, 2),
    (4, 1, 3),
    (5, 2, 3)
]

mst, weight = kruskal_mst(4, edges)
# MST: [(0,1,1), (0,2,2), (1,3,4)]
# Total weight: 7
```

#### **Network connectivity**:
```python
class NetworkConnectivity:
    """Check if network is fully connected"""
    def __init__(self, n):
        self.uf = UnionFind(n)
    
    def add_connection(self, u, v):
        """Add connection between nodes u and v"""
        self.uf.union(u, v)
    
    def is_connected(self, u, v):
        """Check if u and v can communicate"""
        return self.uf.connected(u, v)
    
    def is_fully_connected(self):
        """Check if all nodes are connected"""
        return self.uf.count == 1
    
    def count_components(self):
        """Count number of separate networks"""
        return self.uf.count
```

#### **Number of islands (2D grid)**:
```python
def num_islands(grid):
    """Count islands in 2D grid"""
    if not grid:
        return 0
    
    rows, cols = len(grid), len(grid[0])
    uf = UnionFind(rows * cols)
    
    def get_id(r, c):
        return r * cols + c
    
    # Union adjacent land cells
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '1':
                # Check right neighbor
                if c + 1 < cols and grid[r][c + 1] == '1':
                    uf.union(get_id(r, c), get_id(r, c + 1))
                
                # Check down neighbor
                if r + 1 < rows and grid[r + 1][c] == '1':
                    uf.union(get_id(r, c), get_id(r + 1, c))
    
    # Count unique roots for land cells
    islands = set()
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '1':
                islands.add(uf.find(get_id(r, c)))
    
    return len(islands)

# Example
grid = [
    ['1', '1', '0', '0', '0'],
    ['1', '1', '0', '0', '0'],
    ['0', '0', '1', '0', '0'],
    ['0', '0', '0', '1', '1']
]
print(num_islands(grid))  # 3 islands
```

#### **Detect cycle in undirected graph**:
```python
def has_cycle(n, edges):
    """Check if undirected graph has cycle"""
    uf = UnionFind(n)
    
    for u, v in edges:
        # If u and v already connected, adding edge creates cycle
        if uf.connected(u, v):
            return True
        uf.union(u, v)
    
    return False

# Example
edges = [(0, 1), (1, 2), (2, 0)]  # Triangle
print(has_cycle(3, edges))  # True
```

#### **Friend circles**:
```python
def find_circle_num(is_connected):
    """
    Count number of friend circles
    is_connected[i][j] = 1 if person i and j are friends
    """
    n = len(is_connected)
    uf = UnionFind(n)
    
    for i in range(n):
        for j in range(i + 1, n):
            if is_connected[i][j] == 1:
                uf.union(i, j)
    
    return uf.count

# Example
is_connected = [
    [1, 1, 0],
    [1, 1, 0],
    [0, 0, 1]
]
print(find_circle_num(is_connected))  # 2 circles
```

#### **Redundant connection**:
```python
def find_redundant_connection(edges):
    """Find edge that creates cycle in tree"""
    n = len(edges)
    uf = UnionFind(n + 1)
    
    for u, v in edges:
        if not uf.union(u, v):
            # Union failed: u and v already connected
            return [u, v]
    
    return []

# Example
edges = [[1,2], [1,3], [2,3]]
print(find_redundant_connection(edges))  # [2,3]
```

### 6. Implementation patterns
Common variations and techniques:

#### **Complete optimized implementation**:
```python
class UnionFind:
    """Union-Find with all optimizations"""
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.count = n
    
    def find(self, x):
        """Find with path compression"""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        """Union by rank"""
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
        
        self.count -= 1
        return True
    
    def connected(self, x, y):
        """Check connectivity"""
        return self.find(x) == self.find(y)
    
    def get_count(self):
        """Get number of disjoint sets"""
        return self.count
```

#### **With component size tracking**:
```python
class UnionFindWithSize:
    """Track size of each component"""
    def __init__(self, n):
        self.parent = list(range(n))
        self.size = [1] * n
        self.count = n
        self.max_size = 1  # Track largest component
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)
        
        if root_x == root_y:
            return False
        
        # Always attach smaller to larger
        if self.size[root_x] < self.size[root_y]:
            self.parent[root_x] = root_y
            self.size[root_y] += self.size[root_x]
            self.max_size = max(self.max_size, self.size[root_y])
        else:
            self.parent[root_y] = root_x
            self.size[root_x] += self.size[root_y]
            self.max_size = max(self.max_size, self.size[root_x])
        
        self.count -= 1
        return True
    
    def get_size(self, x):
        """Get size of component containing x"""
        return self.size[self.find(x)]
    
    def get_max_size(self):
        """Get size of largest component"""
        return self.max_size
```

#### **With custom merge logic**:
```python
class UnionFindCustom:
    """Union-Find with custom merge function"""
    def __init__(self, n, merge_fn=None):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.data = [None] * n  # Store custom data
        self.merge_fn = merge_fn or (lambda a, b: a)
        self.count = n
    
    def set_data(self, x, data):
        """Set data for element x"""
        self.data[x] = data
    
    def get_data(self, x):
        """Get data for component containing x"""
        return self.data[self.find(x)]
    
    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)
        
        if root_x == root_y:
            return False
        
        # Merge data using custom function
        merged_data = self.merge_fn(self.data[root_x], self.data[root_y])
        
        if self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
            self.data[root_y] = merged_data
        elif self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
            self.data[root_x] = merged_data
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1
            self.data[root_x] = merged_data
        
        self.count -= 1
        return True

# Example: Track sum of each component
uf = UnionFindCustom(5, merge_fn=lambda a, b: a + b)
for i in range(5):
    uf.set_data(i, i)  # Set initial values

uf.union(0, 1)  # Merge: data becomes 0+1=1
uf.union(2, 3)  # Merge: data becomes 2+3=5
print(uf.get_data(0))  # 1
print(uf.get_data(2))  # 5
```

#### **Persistent Union-Find (immutable)**:
```python
class PersistentUnionFind:
    """Immutable Union-Find for time-travel queries"""
    def __init__(self, n):
        self.history = []
        self.parent = list(range(n))
        self.rank = [0] * n
    
    def find(self, x, version=-1):
        """Find at specific version"""
        if version == -1:
            parent = self.parent
        else:
            parent = self.history[version]['parent']
        
        if parent[x] != x:
            return self.find(parent[x], version)
        return x
    
    def union(self, x, y):
        """Create new version with union"""
        # Save current state
        self.history.append({
            'parent': self.parent[:],
            'rank': self.rank[:]
        })
        
        root_x = self.find(x)
        root_y = self.find(y)
        
        if root_x != root_y:
            if self.rank[root_x] < self.rank[root_y]:
                self.parent[root_x] = root_y
            elif self.rank[root_x] > self.rank[root_y]:
                self.parent[root_y] = root_x
            else:
                self.parent[root_y] = root_x
                self.rank[root_x] += 1
        
        return len(self.history) - 1  # Return version number
```

#### **Complexity summary**:

| Operation | Naive | Path Compression | Union by Rank | Both |
|-----------|-------|------------------|---------------|------|
| Find | O(n) | O(log n) amortized | O(log n) | O(α(n)) |
| Union | O(n) | O(log n) amortized | O(log n) | O(α(n)) |
| Space | O(n) | O(n) | O(n) | O(n) |

Where α(n) is the inverse Ackermann function, effectively O(1) for all practical values of n.
