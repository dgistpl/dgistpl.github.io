---
layout: splash
author_profile: false
---

# Graphs

Nodes and edges modeling relationships and connectivity.

### 1. Adjacency list vs adjacency matrix
Two primary representations for storing graph structure:

#### **Adjacency List**:
- **Structure**: Array/dict of lists, each storing neighbors
- **Space**: O(V + E) where V = vertices, E = edges
- **Best for**: Sparse graphs (few edges)

**Implementation**:
```python
# Using dictionary
graph = {
    0: [1, 2],
    1: [0, 3, 4],
    2: [0, 4],
    3: [1],
    4: [1, 2]
}

# Using list of lists
graph = [
    [1, 2],      # neighbors of vertex 0
    [0, 3, 4],   # neighbors of vertex 1
    [0, 4],      # neighbors of vertex 2
    [1],         # neighbors of vertex 3
    [1, 2]       # neighbors of vertex 4
]

# With weights (weighted graph)
graph = {
    0: [(1, 5), (2, 3)],  # (neighbor, weight)
    1: [(0, 5), (3, 2), (4, 1)],
    2: [(0, 3), (4, 4)],
    3: [(1, 2)],
    4: [(1, 1), (2, 4)]
}
```

**Advantages**:
- ✓ Space-efficient for sparse graphs
- ✓ Fast to iterate over neighbors: O(degree)
- ✓ Easy to add edges
- ✓ Natural for most graph algorithms

**Disadvantages**:
- ✗ Checking if edge exists: O(degree) or O(log degree) with sorted list
- ✗ Slightly more complex to implement

#### **Adjacency Matrix**:
- **Structure**: 2D array where matrix[i][j] = 1 if edge exists
- **Space**: O(V²)
- **Best for**: Dense graphs (many edges)

**Implementation**:
```python
# Unweighted graph (0 = no edge, 1 = edge)
n = 5
matrix = [
    [0, 1, 1, 0, 0],
    [1, 0, 0, 1, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 0, 0, 0],
    [0, 1, 1, 0, 0]
]

# Weighted graph (0 or inf = no edge, value = weight)
matrix = [
    [0,   5,   3,   inf, inf],
    [5,   0,   inf, 2,   1],
    [3,   inf, 0,   inf, 4],
    [inf, 2,   inf, 0,   inf],
    [inf, 1,   4,   inf, 0]
]

# Check if edge exists
def has_edge(matrix, u, v):
    return matrix[u][v] != 0  # or != inf for weighted

# Get all neighbors
def get_neighbors(matrix, u):
    return [v for v in range(len(matrix)) if matrix[u][v] != 0]
```

**Advantages**:
- ✓ O(1) edge lookup: matrix[i][j]
- ✓ O(1) edge insertion/deletion
- ✓ Simple implementation
- ✓ Good for dense graphs

**Disadvantages**:
- ✗ O(V²) space even for sparse graphs
- ✗ O(V) to iterate over neighbors
- ✗ Wasteful for sparse graphs

#### **Comparison table**:

| Operation | Adjacency List | Adjacency Matrix |
|-----------|----------------|------------------|
| Space | O(V + E) | O(V²) |
| Add edge | O(1) | O(1) |
| Remove edge | O(degree) | O(1) |
| Check edge | O(degree) | O(1) |
| Get neighbors | O(degree) | O(V) |
| Iterate all edges | O(V + E) | O(V²) |
| Best for | Sparse graphs | Dense graphs |

#### **When to use each**:
- **Adjacency List**: Most real-world graphs (social networks, web graphs, road networks)
- **Adjacency Matrix**: Dense graphs, need fast edge queries, matrix operations (Floyd-Warshall)

### 2. Directed vs undirected graphs
Understanding edge directionality:

#### **Undirected Graph**:
- **Edges**: Bidirectional, (u, v) = (v, u)
- **Representation**: Store edge in both directions or mark as undirected
- **Examples**: Friendships, road networks (two-way streets)

**Implementation**:
```python
# Adjacency list (store both directions)
def add_undirected_edge(graph, u, v):
    graph[u].append(v)
    graph[v].append(u)

# Example: friendship network
graph = {
    'Alice': ['Bob', 'Charlie'],
    'Bob': ['Alice', 'David'],
    'Charlie': ['Alice', 'David'],
    'David': ['Bob', 'Charlie']
}
```

**Properties**:
- Degree: Number of edges incident to vertex
- Handshaking lemma: Sum of degrees = 2 × |E|
- Edge count: Each edge counted once

#### **Directed Graph (Digraph)**:
- **Edges**: One-way, (u, v) ≠ (v, u)
- **Representation**: Store edge in one direction only
- **Examples**: Twitter follows, web links, dependencies

**Implementation**:
```python
# Adjacency list (store one direction)
def add_directed_edge(graph, u, v):
    graph[u].append(v)

# Example: Twitter follows
graph = {
    'Alice': ['Bob', 'Charlie'],      # Alice follows Bob and Charlie
    'Bob': ['David'],                 # Bob follows David
    'Charlie': ['Alice', 'David'],    # Charlie follows Alice and David
    'David': []                       # David follows no one
}
```

**Properties**:
- In-degree: Number of incoming edges
- Out-degree: Number of outgoing edges
- Edge count: Each edge counted once
- Can have cycles even with 2 vertices: u → v, v → u

#### **Visual comparison**:
```
Undirected:           Directed:
    A --- B              A --> B
    |     |              |     ↓
    C --- D              C <-- D

Edge (A,B) means:     Edge A→B means:
- A can reach B       - A can reach B
- B can reach A       - B cannot reach A (unless B→A exists)
```

#### **Conversion**:
```python
# Undirected to directed (create both directions)
def undirected_to_directed(undirected):
    directed = {v: [] for v in undirected}
    for u in undirected:
        for v in undirected[u]:
            if v not in directed[u]:
                directed[u].append(v)
            if u not in directed[v]:
                directed[v].append(u)
    return directed

# Directed to undirected (ignore direction)
def directed_to_undirected(directed):
    undirected = {v: [] for v in directed}
    for u in directed:
        for v in directed[u]:
            if v not in undirected[u]:
                undirected[u].append(v)
            if u not in undirected[v]:
                undirected[v].append(u)
    return undirected
```

### 3. Weighted vs unweighted
Edges with or without associated costs:

#### **Unweighted Graph**:
- **Edges**: All have equal cost (implicitly weight = 1)
- **Use case**: Simple connectivity, shortest path = fewest edges
- **Examples**: Social networks, maze solving

**Implementation**:
```python
# Adjacency list
graph = {
    0: [1, 2],
    1: [0, 3],
    2: [0, 3],
    3: [1, 2]
}

# Shortest path: BFS finds path with fewest edges
from collections import deque

def shortest_path_unweighted(graph, start, end):
    queue = deque([(start, 0)])
    visited = {start}
    
    while queue:
        node, dist = queue.popleft()
        if node == end:
            return dist
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, dist + 1))
    
    return -1  # No path
```

#### **Weighted Graph**:
- **Edges**: Have associated costs/weights
- **Use case**: Optimization problems, realistic modeling
- **Examples**: Road networks (distances), flight routes (costs)

**Implementation**:
```python
# Adjacency list with weights
graph = {
    0: [(1, 4), (2, 1)],      # (neighbor, weight)
    1: [(0, 4), (3, 5)],
    2: [(0, 1), (3, 2)],
    3: [(1, 5), (2, 2)]
}

# Shortest path: Dijkstra's algorithm for weighted graphs
import heapq

def shortest_path_weighted(graph, start, end):
    dist = {node: float('inf') for node in graph}
    dist[start] = 0
    pq = [(0, start)]
    
    while pq:
        d, node = heapq.heappop(pq)
        
        if node == end:
            return d
        
        if d > dist[node]:
            continue
        
        for neighbor, weight in graph[node]:
            new_dist = d + weight
            if new_dist < dist[neighbor]:
                dist[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
    
    return -1  # No path
```

#### **Weight types**:
- **Positive weights**: Most common, use Dijkstra's
- **Negative weights**: Use Bellman-Ford, watch for negative cycles
- **Zero weights**: Valid, but may need special handling
- **Non-numeric weights**: Can represent other metrics (time, reliability)

#### **Example: Road network**:
```python
# Cities and distances (km)
roads = {
    'NYC': [('Boston', 215), ('Philadelphia', 95)],
    'Boston': [('NYC', 215)],
    'Philadelphia': [('NYC', 95), ('Washington', 140)],
    'Washington': [('Philadelphia', 140)]
}

# Find shortest route from NYC to Washington
# Answer: NYC → Philadelphia → Washington = 235 km
```

### 4. BFS and DFS traversals
Fundamental algorithms for exploring graphs:

#### **Breadth-First Search (BFS)**:
- **Strategy**: Explore level by level (nearest first)
- **Data structure**: Queue (FIFO)
- **Time**: O(V + E)
- **Space**: O(V)

**Implementation**:
```python
from collections import deque

def bfs(graph, start):
    visited = set([start])
    queue = deque([start])
    result = []
    
    while queue:
        node = queue.popleft()
        result.append(node)
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    
    return result

# Example traversal:
# Graph:  0 -- 1 -- 3
#         |    |
#         2 -- 4
# BFS from 0: [0, 1, 2, 3, 4]
```

**BFS applications**:
- Shortest path in unweighted graph
- Level-order traversal
- Connected components
- Bipartite checking

#### **Depth-First Search (DFS)**:
- **Strategy**: Explore as deep as possible first
- **Data structure**: Stack (recursion or explicit)
- **Time**: O(V + E)
- **Space**: O(V)

**Implementation**:
```python
# Recursive
def dfs_recursive(graph, node, visited=None):
    if visited is None:
        visited = set()
    
    visited.add(node)
    result = [node]
    
    for neighbor in graph[node]:
        if neighbor not in visited:
            result.extend(dfs_recursive(graph, neighbor, visited))
    
    return result

# Iterative
def dfs_iterative(graph, start):
    visited = set()
    stack = [start]
    result = []
    
    while stack:
        node = stack.pop()
        if node not in visited:
            visited.add(node)
            result.append(node)
            
            for neighbor in reversed(graph[node]):
                if neighbor not in visited:
                    stack.append(neighbor)
    
    return result

# Example traversal:
# Graph:  0 -- 1 -- 3
#         |    |
#         2 -- 4
# DFS from 0: [0, 1, 3, 4, 2] or [0, 2, 4, 1, 3]
```

**DFS applications**:
- Cycle detection
- Topological sorting
- Strongly connected components
- Path finding

#### **Comparison**:

| Feature | BFS | DFS |
|---------|-----|-----|
| Data structure | Queue | Stack/Recursion |
| Order | Level by level | Deep first |
| Shortest path | Yes (unweighted) | No |
| Memory | More (stores level) | Less (stores path) |
| Completeness | Yes | Yes (with visited set) |

### 5. Connected components and cycles
Analyzing graph structure:

#### **Connected Components** (undirected graphs):
- **Definition**: Maximal subgraphs where every pair of vertices is connected
- **Algorithm**: Run BFS/DFS from unvisited vertices

**Implementation**:
```python
def count_components(graph):
    visited = set()
    count = 0
    
    def dfs(node):
        visited.add(node)
        for neighbor in graph[node]:
            if neighbor not in visited:
                dfs(neighbor)
    
    for node in graph:
        if node not in visited:
            dfs(node)
            count += 1
    
    return count

def find_components(graph):
    visited = set()
    components = []
    
    def dfs(node, component):
        visited.add(node)
        component.append(node)
        for neighbor in graph[node]:
            if neighbor not in visited:
                dfs(neighbor, component)
    
    for node in graph:
        if node not in visited:
            component = []
            dfs(node, component)
            components.append(component)
    
    return components

# Example:
# Graph: 0-1-2  3-4  5
# Components: [[0,1,2], [3,4], [5]]
```

#### **Cycle Detection**:

**Undirected graph**:
```python
def has_cycle_undirected(graph):
    visited = set()
    
    def dfs(node, parent):
        visited.add(node)
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                if dfs(neighbor, node):
                    return True
            elif neighbor != parent:
                return True  # Back edge found
        
        return False
    
    for node in graph:
        if node not in visited:
            if dfs(node, -1):
                return True
    
    return False
```

**Directed graph** (using colors):
```python
def has_cycle_directed(graph):
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {node: WHITE for node in graph}
    
    def dfs(node):
        color[node] = GRAY
        
        for neighbor in graph[node]:
            if color[neighbor] == GRAY:
                return True  # Back edge (cycle)
            if color[neighbor] == WHITE and dfs(neighbor):
                return True
        
        color[node] = BLACK
        return False
    
    for node in graph:
        if color[node] == WHITE:
            if dfs(node):
                return True
    
    return False
```

#### **Union-Find for connected components**:
```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.components = n
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        
        if self.rank[px] < self.rank[py]:
            self.parent[px] = py
        elif self.rank[px] > self.rank[py]:
            self.parent[py] = px
        else:
            self.parent[py] = px
            self.rank[px] += 1
        
        self.components -= 1
        return True
```

### 6. Applications: social networks, maps
Real-world uses of graph structures:

#### **Social Networks**:
- **Vertices**: Users
- **Edges**: Friendships, follows, connections
- **Type**: Usually undirected (Facebook) or directed (Twitter)

**Applications**:
1. **Friend recommendations**: Find friends of friends
   ```python
   def recommend_friends(graph, user):
       friends = set(graph[user])
       recommendations = set()
       
       for friend in friends:
           for friend_of_friend in graph[friend]:
               if friend_of_friend != user and friend_of_friend not in friends:
                   recommendations.add(friend_of_friend)
       
       return recommendations
   ```

2. **Influence analysis**: Find most connected users
   ```python
   def find_influencers(graph, top_k=10):
       # Calculate degree centrality
       degrees = [(node, len(graph[node])) for node in graph]
       degrees.sort(key=lambda x: x[1], reverse=True)
       return degrees[:top_k]
   ```

3. **Community detection**: Find clusters of users
4. **Six degrees of separation**: Shortest path between users

#### **Maps and Navigation**:
- **Vertices**: Locations, intersections
- **Edges**: Roads, paths
- **Weights**: Distance, time, cost

**Applications**:
1. **Route planning**: Shortest path (Dijkstra's, A*)
   ```python
   def find_route(map_graph, start, end):
       return dijkstra(map_graph, start, end)
   ```

2. **Traffic optimization**: Find alternative routes
3. **Delivery routing**: Traveling salesman problem
4. **Public transit**: Multi-modal routing

#### **Web and Internet**:
- **Vertices**: Web pages, routers
- **Edges**: Hyperlinks, network connections
- **Type**: Directed (links), weighted (bandwidth)

**Applications**:
1. **PageRank**: Rank web pages by importance
2. **Web crawling**: BFS/DFS to discover pages
3. **Network routing**: Find optimal packet paths
4. **Load balancing**: Distribute traffic

#### **Other applications**:
- **Dependency graphs**: Build systems, package managers
- **Recommendation systems**: User-item bipartite graphs
- **Biology**: Protein interaction networks, phylogenetic trees
- **Chemistry**: Molecular structures
- **Game AI**: State space search, pathfinding

### 7. Complexities and storage
Understanding performance characteristics:

#### **Time complexities**:

| Operation | Adjacency List | Adjacency Matrix |
|-----------|----------------|------------------|
| Add vertex | O(1) | O(V²) (resize) |
| Add edge | O(1) | O(1) |
| Remove vertex | O(E) | O(V²) |
| Remove edge | O(E) | O(1) |
| Check edge | O(degree) | O(1) |
| Get neighbors | O(degree) | O(V) |
| BFS/DFS | O(V + E) | O(V²) |
| Dijkstra | O((V+E) log V) | O(V²) |

#### **Space complexities**:

| Representation | Space | Best For |
|----------------|-------|----------|
| Adjacency List | O(V + E) | Sparse graphs (E << V²) |
| Adjacency Matrix | O(V²) | Dense graphs (E ≈ V²) |
| Edge List | O(E) | Simple storage, sorting |

#### **Graph density**:
- **Sparse**: E = O(V), few edges
  - Example: Social networks (avg degree ~100)
  - Use adjacency list
  
- **Dense**: E = O(V²), many edges
  - Example: Complete graph (all pairs connected)
  - Use adjacency matrix

#### **Memory calculations**:
```python
# Example: 1 million vertices
V = 1_000_000

# Sparse graph (avg degree = 10)
E_sparse = 5_000_000  # ~5M edges
list_memory = (V + E_sparse) * 8 bytes = 40 MB
matrix_memory = V * V * 1 byte = 1 TB (impractical!)

# Dense graph (E = V²/2)
E_dense = 500_000_000_000  # 500B edges
list_memory = (V + E_dense) * 8 bytes = 4 TB
matrix_memory = V * V * 1 byte = 1 TB (better!)
```

#### **Optimization techniques**:
1. **Compressed sparse row (CSR)**: Efficient sparse matrix storage
2. **Adjacency array**: Flatten adjacency list for cache efficiency
3. **Bit vectors**: Use bits instead of bytes for unweighted graphs
4. **Graph databases**: Neo4j, specialized storage for large graphs

#### **Practical considerations**:
- **Small graphs** (V < 1000): Either representation works
- **Medium graphs** (V < 100K): Adjacency list usually better
- **Large graphs** (V > 1M): Must use adjacency list or specialized storage
- **Very dense graphs**: Consider adjacency matrix or compressed formats
