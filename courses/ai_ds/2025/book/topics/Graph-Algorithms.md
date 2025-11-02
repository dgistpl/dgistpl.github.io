---
layout: splash
author_profile: false
---

# Graph Algorithms

Compute connectivity, paths, and structures over graphs.


### 1. BFS/DFS applications
Fundamental graph traversal algorithms with diverse applications:

#### **Breadth-First Search (BFS)**:
- **Approach**: Explore level by level using a queue
- **Time**: O(V + E) where V = vertices, E = edges
- **Space**: O(V) for queue and visited array

**Implementation**:
```python
from collections import deque

def bfs(graph, start):
    """BFS traversal from start node"""
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
```

**Key BFS applications**:
1. **Shortest path in unweighted graph**: Find minimum number of edges
2. **Level-order traversal**: Process nodes by distance from source
3. **Connected components**: Find all connected subgraphs
4. **Bipartite check**: Determine if graph is 2-colorable

#### **Depth-First Search (DFS)**:
- **Approach**: Explore as deep as possible using recursion/stack
- **Time**: O(V + E)
- **Space**: O(V) for recursion stack

**Implementation**:
```python
def dfs_recursive(graph, node, visited=None):
    """DFS traversal (recursive)"""
    if visited is None:
        visited = set()
    
    visited.add(node)
    result = [node]
    
    for neighbor in graph[node]:
        if neighbor not in visited:
            result.extend(dfs_recursive(graph, neighbor, visited))
    
    return result
```

**Key DFS applications**:
1. **Cycle detection**: Find back edges in graph
2. **Path finding**: Find all paths between two nodes
3. **Topological sorting**: Order vertices in DAG
4. **Maze solving**: Find path through grid

#### **BFS vs DFS comparison**:

| Feature | BFS | DFS |
|---------|-----|-----|
| Data structure | Queue | Stack/Recursion |
| Path found | Shortest (unweighted) | Any path |
| Memory | O(V) - wider | O(h) - height |
| Use case | Shortest path, level-order | Cycle detection, topological sort |

### 2. Shortest paths: Dijkstra/Bellman-Ford
Algorithms for finding shortest paths in weighted graphs:

#### **Dijkstra's Algorithm**:
- **Use case**: Single-source shortest path with non-negative weights
- **Time**: O((V + E) log V) with min-heap
- **Space**: O(V)

**Implementation**:
```python
import heapq

def dijkstra(graph, start):
    dist = {node: float('inf') for node in graph}
    dist[start] = 0
    pq = [(0, start)]
    visited = set()
    
    while pq:
        d, node = heapq.heappop(pq)
        if node in visited:
            continue
        visited.add(node)
        
        for neighbor, weight in graph[node]:
            new_dist = d + weight
            if new_dist < dist[neighbor]:
                dist[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
    
    return dist
```

#### **Bellman-Ford Algorithm**:
- **Use case**: Single-source shortest path with negative weights
- **Time**: O(V × E)
- **Detects**: Negative cycles

**Implementation**:
```python
def bellman_ford(edges, n, start):
    dist = [float('inf')] * n
    dist[start] = 0
    
    for _ in range(n - 1):
        for u, v, weight in edges:
            if dist[u] != float('inf') and dist[u] + weight < dist[v]:
                dist[v] = dist[u] + weight
    
    # Check for negative cycles
    for u, v, weight in edges:
        if dist[u] + weight < dist[v]:
            return None  # Negative cycle
    
    return dist
```

#### **Comparison**:

| Algorithm | Time | Negative Weights | Use Case |
|-----------|------|------------------|----------|
| Dijkstra | O(E log V) | No | Fast, non-negative |
| Bellman-Ford | O(VE) | Yes | Negative weights, cycle detection |
| Floyd-Warshall | O(V³) | Yes | All-pairs shortest paths |

### 3. Minimum spanning trees: Kruskal/Prim
Finding minimum cost tree connecting all vertices:

#### **Kruskal's Algorithm**:
- **Approach**: Sort edges, add if doesn't create cycle
- **Time**: O(E log E)
- **Uses**: Union-Find data structure

**Implementation**:
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
        return True

def kruskal(n, edges):
    edges.sort()  # Sort by weight
    uf = UnionFind(n)
    mst, total = [], 0
    
    for weight, u, v in edges:
        if uf.union(u, v):
            mst.append((u, v, weight))
            total += weight
    
    return total, mst
```

#### **Prim's Algorithm**:
- **Approach**: Grow tree from starting vertex
- **Time**: O(E log V) with min-heap
- **Best for**: Dense graphs

**Implementation**:
```python
def prim(graph, start):
    mst, total = [], 0
    visited = {start}
    edges = [(w, start, v) for v, w in graph[start]]
    heapq.heapify(edges)
    
    while edges:
        weight, u, v = heapq.heappop(edges)
        if v in visited:
            continue
        
        visited.add(v)
        mst.append((u, v, weight))
        total += weight
        
        for neighbor, w in graph[v]:
            if neighbor not in visited:
                heapq.heappush(edges, (w, v, neighbor))
    
    return total, mst
```

### 4. Topological sort and DAG DP
Ordering vertices in directed acyclic graphs:

#### **Topological Sort (Kahn's Algorithm)**:
```python
from collections import deque

def topological_sort(graph, n):
    in_degree = [0] * n
    for node in range(n):
        for neighbor in graph[node]:
            in_degree[neighbor] += 1
    
    queue = deque([i for i in range(n) if in_degree[i] == 0])
    result = []
    
    while queue:
        node = queue.popleft()
        result.append(node)
        
        for neighbor in graph[node]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)
    
    return result if len(result) == n else None  # None if cycle
```

#### **DAG Dynamic Programming**:
```python
def longest_path_dag(graph, n):
    topo_order = topological_sort(graph, n)
    dp = [0] * n
    
    for node in topo_order:
        for neighbor in graph[node]:
            dp[neighbor] = max(dp[neighbor], dp[node] + 1)
    
    return max(dp)
```

**Applications**: Course scheduling, task dependencies, build systems

### 5. Strongly connected components
Finding maximal subgraphs where every vertex reaches every other:

#### **Kosaraju's Algorithm**:
```python
def kosaraju_scc(graph, n):
    # Step 1: DFS to get finish order
    visited = [False] * n
    finish_order = []
    
    def dfs1(node):
        visited[node] = True
        for neighbor in graph[node]:
            if not visited[neighbor]:
                dfs1(neighbor)
        finish_order.append(node)
    
    for i in range(n):
        if not visited[i]:
            dfs1(i)
    
    # Step 2: Transpose graph
    transpose = [[] for _ in range(n)]
    for u in range(n):
        for v in graph[u]:
            transpose[v].append(u)
    
    # Step 3: DFS on transpose
    visited = [False] * n
    components = []
    
    def dfs2(node, component):
        visited[node] = True
        component.append(node)
        for neighbor in transpose[node]:
            if not visited[neighbor]:
                dfs2(neighbor, component)
    
    for node in reversed(finish_order):
        if not visited[node]:
            component = []
            dfs2(node, component)
            components.append(component)
    
    return components
```

**Applications**: 2-SAT, reachability queries, deadlock detection

### 6. Flow algorithms overview
Computing maximum flow in networks:

#### **Ford-Fulkerson / Edmonds-Karp**:
- **Approach**: Find augmenting paths until no more exist
- **Time**: O(V × E²) for Edmonds-Karp
- **Space**: O(V²)

**Implementation**:
```python
def max_flow(capacity, source, sink):
    n = len(capacity)
    flow = [[0] * n for _ in range(n)]
    
    def bfs():
        parent = [-1] * n
        visited = [False] * n
        visited[source] = True
        queue = deque([(source, float('inf'))])
        
        while queue:
            u, min_cap = queue.popleft()
            
            for v in range(n):
                if not visited[v] and capacity[u][v] - flow[u][v] > 0:
                    visited[v] = True
                    parent[v] = u
                    new_cap = min(min_cap, capacity[u][v] - flow[u][v])
                    
                    if v == sink:
                        return parent, new_cap
                    queue.append((v, new_cap))
        
        return None, 0
    
    total_flow = 0
    while True:
        parent, path_flow = bfs()
        if path_flow == 0:
            break
        
        total_flow += path_flow
        v = sink
        while v != source:
            u = parent[v]
            flow[u][v] += path_flow
            flow[v][u] -= path_flow
            v = u
    
    return total_flow
```

**Applications**:
- **Maximum bipartite matching**: Model as flow problem
- **Min-cut**: Find minimum capacity cut separating source and sink
- **Network routing**: Optimize data flow through network
- **Assignment problems**: Match workers to tasks optimally
