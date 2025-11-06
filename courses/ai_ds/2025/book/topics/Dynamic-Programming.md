---
layout: splash
author_profile: false
---

# Dynamic Programming

Optimize recursive solutions by reusing subproblem results.


### 1. Overlapping subproblems and optimal substructure
The two key properties that enable dynamic programming:

#### **Overlapping Subproblems**:
- **Definition**: Same subproblems are solved multiple times in naive recursion
- **Example: Fibonacci sequence**
  ```python
  # Naive recursion - exponential time O(2^n)
  def fib(n):
      if n <= 1:
          return n
      return fib(n-1) + fib(n-2)
  
  # Call tree for fib(5):
  #                 fib(5)
  #              /          \
  #         fib(4)          fib(3)
  #        /      \        /      \
  #    fib(3)   fib(2)  fib(2)  fib(1)
  #    /    \   /   \   /   \
  # fib(2) fib(1) ...
  #
  # fib(3) computed 2 times
  # fib(2) computed 3 times
  # fib(1) computed 5 times
  ```

- **DP solution**: Store results to avoid recomputation
  ```python
  # With memoization - linear time O(n)
  def fib_memo(n, memo={}):
      if n in memo:
          return memo[n]
      if n <= 1:
          return n
      memo[n] = fib_memo(n-1, memo) + fib_memo(n-2, memo)
      return memo[n]
  ```

#### **Optimal Substructure**:
- **Definition**: Optimal solution contains optimal solutions to subproblems
- **Example: Shortest path**
  - If shortest path A→C goes through B
  - Then A→B and B→C must also be shortest paths
  - Can build optimal solution from optimal subproblems

- **Counter-example: Longest simple path**
  - Longest path A→C through B
  - Does NOT guarantee A→B and B→C are longest
  - Why? Path cannot revisit nodes (constraint breaks substructure)

#### **When to use DP**:
- ✓ Problem has overlapping subproblems
- ✓ Problem has optimal substructure
- ✓ Can define recursive relation
- ✗ Subproblems are independent → use divide-and-conquer instead
- ✗ No optimal substructure → greedy or other approach

#### **Classic examples**:

| Problem | Overlapping? | Optimal Substructure? | DP Applicable? |
|---------|-------------|----------------------|----------------|
| Fibonacci | Yes | Yes | ✓ Yes |
| Shortest path | Yes | Yes | ✓ Yes |
| Longest increasing subsequence | Yes | Yes | ✓ Yes |
| Knapsack | Yes | Yes | ✓ Yes |
| Merge sort | No | Yes | ✗ No (D&C better) |
| Longest simple path | Yes | No | ✗ No (NP-hard) |

### 2. Top-down (memoization) vs bottom-up
Two approaches to implementing dynamic programming:

#### **Top-down (Memoization)**:
- **Approach**: Start from original problem, recurse down, cache results
- **Implementation**: Recursion + hash table/array for caching

- **Example: Climbing stairs**
  ```python
  # Problem: n stairs, can climb 1 or 2 steps at a time
  # How many distinct ways to reach top?
  
  def climb_stairs_memo(n, memo={}):
      # Base cases
      if n <= 2:
          return n
      
      # Check cache
      if n in memo:
          return memo[n]
      
      # Recursive relation: ways(n) = ways(n-1) + ways(n-2)
      memo[n] = climb_stairs_memo(n-1, memo) + climb_stairs_memo(n-2, memo)
      return memo[n]
  ```

- **Advantages**:
  - ✓ Natural recursive thinking
  - ✓ Only computes needed subproblems
  - ✓ Easy to write from recursive solution
  - ✓ Good for sparse subproblem space

- **Disadvantages**:
  - ✗ Recursion overhead (stack space)
  - ✗ Risk of stack overflow for deep recursion
  - ✗ Slightly slower due to function calls

#### **Bottom-up (Tabulation)**:
- **Approach**: Start from base cases, build up iteratively
- **Implementation**: Loops + array/table for storing results

- **Example: Climbing stairs**
  ```python
  def climb_stairs_dp(n):
      if n <= 2:
          return n
      
      # DP table
      dp = [0] * (n + 1)
      dp[1] = 1
      dp[2] = 2
      
      # Fill table bottom-up
      for i in range(3, n + 1):
          dp[i] = dp[i-1] + dp[i-2]
      
      return dp[n]
  ```

- **Advantages**:
  - ✓ No recursion overhead
  - ✓ Better cache locality (sequential access)
  - ✓ Easier to optimize space
  - ✓ Predictable performance

- **Disadvantages**:
  - ✗ Must compute all subproblems (even unneeded ones)
  - ✗ Harder to derive from recursive solution
  - ✗ Need to determine correct order

#### **Comparison table**:

| Aspect | Top-down (Memoization) | Bottom-up (Tabulation) |
|--------|----------------------|----------------------|
| Direction | Problem → base cases | Base cases → problem |
| Implementation | Recursion + cache | Iteration + table |
| Subproblems computed | Only needed | All |
| Space | O(n) + recursion stack | O(n) |
| Time overhead | Function calls | None |
| Intuition | Natural | Requires planning |
| Space optimization | Harder | Easier |

#### **When to choose**:
- **Use top-down if**:
  - Recursive solution is natural
  - Not all subproblems needed
  - Subproblem dependencies are complex
  
- **Use bottom-up if**:
  - Want best performance
  - Need space optimization
  - Iterative order is clear

### 3. State definition and transitions
The core of designing a DP solution:

#### **State definition**:
- **What is a state?** A unique subproblem characterized by parameters
- **Good state**: Captures all information needed to solve subproblem

#### **Steps to define state**:
1. **Identify what varies**: What parameters change between subproblems?
2. **Define DP array**: `dp[i]`, `dp[i][j]`, etc.
3. **Specify meaning**: What does `dp[i]` represent?
4. **Find recurrence**: How to compute `dp[i]` from smaller states?
5. **Set base cases**: Initial values for smallest subproblems

#### **Example 1: Longest Increasing Subsequence (LIS)**
```python
# Problem: Find length of longest increasing subsequence in array

# State definition:
# dp[i] = length of LIS ending at index i

def length_of_LIS(nums):
    n = len(nums)
    dp = [1] * n  # Base case: each element is LIS of length 1
    
    # Transition: for each i, check all j < i
    for i in range(1, n):
        for j in range(i):
            if nums[j] < nums[i]:
                dp[i] = max(dp[i], dp[j] + 1)
    
    return max(dp)  # Answer: maximum among all dp[i]

# Example: [10, 9, 2, 5, 3, 7, 101, 18]
# dp =     [1,  1, 1, 2, 2, 3, 4,   4]
#                      ↑        ↑
#                   [2,5,7,101] or [2,5,7,18]
```

#### **Example 2: 0/1 Knapsack**
```python
# Problem: n items with weights and values, capacity W
# Maximize value without exceeding capacity

# State definition:
# dp[i][w] = max value using first i items with capacity w

def knapsack(weights, values, W):
    n = len(weights)
    dp = [[0] * (W + 1) for _ in range(n + 1)]
    
    # Transition
    for i in range(1, n + 1):
        for w in range(W + 1):
            # Don't take item i-1
            dp[i][w] = dp[i-1][w]
            
            # Take item i-1 (if it fits)
            if weights[i-1] <= w:
                dp[i][w] = max(dp[i][w], 
                              dp[i-1][w - weights[i-1]] + values[i-1])
    
    return dp[n][W]
```

#### **Example 3: Edit Distance**
```python
# Problem: Minimum operations to convert word1 to word2
# Operations: insert, delete, replace

# State definition:
# dp[i][j] = min operations to convert word1[0..i-1] to word2[0..j-1]

def min_distance(word1, word2):
    m, n = len(word1), len(word2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    
    # Base cases
    for i in range(m + 1):
        dp[i][0] = i  # Delete all characters
    for j in range(n + 1):
        dp[0][j] = j  # Insert all characters
    
    # Transition
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if word1[i-1] == word2[j-1]:
                dp[i][j] = dp[i-1][j-1]  # No operation needed
            else:
                dp[i][j] = 1 + min(
                    dp[i-1][j],      # Delete from word1
                    dp[i][j-1],      # Insert to word1
                    dp[i-1][j-1]     # Replace
                )
    
    return dp[m][n]
```

#### **Common state patterns**:

| Pattern | State | Example Problems |
|---------|-------|------------------|
| Linear | `dp[i]` | Fibonacci, climbing stairs, house robber |
| 2D grid | `dp[i][j]` | Unique paths, edit distance, LCS |
| Subsequence | `dp[i]` ending at i | LIS, maximum subarray |
| Knapsack | `dp[i][w]` | 0/1 knapsack, coin change |
| Interval | `dp[i][j]` for range [i,j] | Matrix chain multiplication, palindrome |
| State machine | `dp[i][state]` | Stock trading with cooldown |

### 4. 1D/2D DP and space optimization
Reducing memory usage while maintaining correctness:

#### **1D DP examples**:
```python
# Fibonacci - O(n) space
def fib_1d(n):
    dp = [0] * (n + 1)
    dp[1] = 1
    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]
    return dp[n]

# Space optimized - O(1) space
def fib_optimized(n):
    if n <= 1:
        return n
    prev2, prev1 = 0, 1
    for i in range(2, n + 1):
        curr = prev1 + prev2
        prev2, prev1 = prev1, curr
    return prev1
```

#### **2D DP space optimization**:

**Example: Unique Paths**
```python
# Problem: m×n grid, count paths from top-left to bottom-right

# Standard 2D DP - O(m×n) space
def unique_paths_2d(m, n):
    dp = [[0] * n for _ in range(m)]
    
    # Base cases
    for i in range(m):
        dp[i][0] = 1
    for j in range(n):
        dp[0][j] = 1
    
    # Fill table
    for i in range(1, m):
        for j in range(1, n):
            dp[i][j] = dp[i-1][j] + dp[i][j-1]
    
    return dp[m-1][n-1]

# Space optimized - O(n) space
def unique_paths_1d(m, n):
    dp = [1] * n  # Only need current row
    
    for i in range(1, m):
        for j in range(1, n):
            dp[j] = dp[j] + dp[j-1]
            # dp[j] was previous row's value
            # dp[j-1] is current row's previous column
    
    return dp[n-1]
```

#### **Optimization techniques**:

1. **Rolling array** (when only previous row/column needed):
   ```python
   # Instead of dp[i][j], use dp[i%2][j]
   # Only keeps 2 rows in memory
   
   def optimized_2d(m, n):
       dp = [[0] * n for _ in range(2)]
       
       for i in range(m):
           for j in range(n):
               if i == 0 or j == 0:
                   dp[i%2][j] = 1
               else:
                   dp[i%2][j] = dp[(i-1)%2][j] + dp[i%2][j-1]
       
       return dp[(m-1)%2][n-1]
   ```

2. **In-place update** (when update order allows):
   ```python
   # Update dp array in-place
   # Careful: must update in correct order
   
   def coin_change(coins, amount):
       dp = [float('inf')] * (amount + 1)
       dp[0] = 0
       
       for coin in coins:
           for i in range(coin, amount + 1):
               dp[i] = min(dp[i], dp[i - coin] + 1)
       
       return dp[amount] if dp[amount] != float('inf') else -1
   ```

3. **State compression** (bit manipulation for small state space):
   ```python
   # Example: Traveling Salesman Problem
   # State: dp[mask][i] = min cost to visit cities in mask, ending at i
   # mask is bitmask representing visited cities
   
   def tsp(dist):
       n = len(dist)
       dp = [[float('inf')] * n for _ in range(1 << n)]
       dp[1][0] = 0  # Start at city 0
       
       for mask in range(1 << n):
           for u in range(n):
               if dp[mask][u] == float('inf'):
                   continue
               for v in range(n):
                   if mask & (1 << v):
                       continue
                   new_mask = mask | (1 << v)
                   dp[new_mask][v] = min(dp[new_mask][v], 
                                        dp[mask][u] + dist[u][v])
       
       return min(dp[(1<<n)-1][i] + dist[i][0] for i in range(1, n))
   ```

#### **Space optimization checklist**:
- Can I use only O(1) variables instead of array?
- Do I only need the previous row/column?
- Can I update in-place without affecting future computations?
- Is the state space small enough for bitmask?

### 5. Combining DP with data structures
Enhancing DP with auxiliary data structures for efficiency:

#### **DP + Hash Map**:
```python
# Problem: Two Sum variant - count pairs with sum k
# Using DP to count subsequences

def count_pairs_with_sum(nums, k):
    dp = {}  # dp[sum] = count of subsequences with this sum
    dp[0] = 1  # Empty subsequence
    
    for num in nums:
        new_dp = dp.copy()
        for s in dp:
            new_sum = s + num
            new_dp[new_sum] = new_dp.get(new_sum, 0) + dp[s]
        dp = new_dp
    
    return dp.get(k, 0)
```

#### **DP + Segment Tree**:
```python
# Problem: Range Maximum Query with updates during DP
# Example: LIS with range queries

class SegmentTree:
    def __init__(self, n):
        self.n = n
        self.tree = [0] * (4 * n)
    
    def update(self, node, start, end, idx, val):
        if start == end:
            self.tree[node] = max(self.tree[node], val)
            return
        mid = (start + end) // 2
        if idx <= mid:
            self.update(2*node, start, mid, idx, val)
        else:
            self.update(2*node+1, mid+1, end, idx, val)
        self.tree[node] = max(self.tree[2*node], self.tree[2*node+1])
    
    def query(self, node, start, end, l, r):
        if r < start or l > end:
            return 0
        if l <= start and end <= r:
            return self.tree[node]
        mid = (start + end) // 2
        return max(self.query(2*node, start, mid, l, r),
                  self.query(2*node+1, mid+1, end, l, r))
```

#### **DP + Priority Queue (Heap)**:
```python
# Problem: Sliding window maximum with DP
# Example: Maximum sum of k-length subarray with constraints

import heapq

def max_sum_k_subarray(nums, k):
    n = len(nums)
    dp = [0] * n
    heap = []  # Max heap (negate values)
    
    for i in range(n):
        # Add current element
        dp[i] = nums[i]
        
        if i >= k:
            # Can extend from previous k positions
            heapq.heappush(heap, (-dp[i-k], i-k))
            
            # Remove outdated elements
            while heap and heap[0][1] < i - k:
                heapq.heappop(heap)
            
            if heap:
                dp[i] = max(dp[i], -heap[0][0] + nums[i])
    
    return max(dp)
```

#### **DP + Monotonic Stack/Queue**:
```python
# Problem: Maximum subarray sum with size constraint
# dp[i] = max sum ending at i
# Constraint: subarray length ≤ k

from collections import deque

def max_subarray_sum_with_constraint(nums, k):
    n = len(nums)
    dp = [0] * n
    dp[0] = nums[0]
    
    # Monotonic deque stores indices of dp values
    # Maintains decreasing order of dp values
    dq = deque([0])
    result = dp[0]
    
    for i in range(1, n):
        # Remove elements outside window
        while dq and dq[0] < i - k:
            dq.popleft()
        
        # dp[i] = max(nums[i], nums[i] + max(dp[j]) for j in [i-k, i-1])
        dp[i] = nums[i]
        if dq:
            dp[i] = max(dp[i], nums[i] + dp[dq[0]])
        
        # Maintain monotonic property
        while dq and dp[dq[-1]] <= dp[i]:
            dq.pop()
        dq.append(i)
        
        result = max(result, dp[i])
    
    return result
```

#### **DP + Trie**:
```python
# Problem: Word Break with dictionary
# Optimize with Trie for fast prefix matching

class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_word = False

def word_break(s, word_dict):
    # Build Trie
    root = TrieNode()
    for word in word_dict:
        node = root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_word = True
    
    # DP with Trie
    n = len(s)
    dp = [False] * (n + 1)
    dp[0] = True
    
    for i in range(1, n + 1):
        node = root
        for j in range(i - 1, -1, -1):
            if s[j] not in node.children:
                break
            node = node.children[s[j]]
            if node.is_word and dp[j]:
                dp[i] = True
                break
    
    return dp[n]
```

#### **Common combinations**:

| Data Structure | Use Case | Example Problem |
|----------------|----------|-----------------|
| Hash Map | Fast lookup of states | Two Sum, Subarray Sum |
| Segment Tree | Range queries during DP | LIS with range max |
| Priority Queue | Track k best/worst | K-th largest element |
| Monotonic Stack | Maintain increasing/decreasing | Next greater element |
| Monotonic Deque | Sliding window optimization | Sliding window maximum |
| Trie | String prefix matching | Word Break, Autocomplete |
| Union-Find | Connected components | Number of islands with DP |

### 6. Common pitfalls and patterns
Avoiding mistakes and recognizing standard patterns:

#### **Common pitfalls**:

1. **Wrong base case**:
   ```python
   # Wrong: Missing base case
   def climb_stairs(n):
       dp = [0] * (n + 1)
       dp[1] = 1  # Missing dp[2] = 2
       for i in range(3, n + 1):
           dp[i] = dp[i-1] + dp[i-2]
       return dp[n]  # Fails for n=2
   
   # Correct:
   def climb_stairs(n):
       if n <= 2:
           return n
       dp = [0] * (n + 1)
       dp[1], dp[2] = 1, 2
       for i in range(3, n + 1):
           dp[i] = dp[i-1] + dp[i-2]
       return dp[n]
   ```

2. **Index out of bounds**:
   ```python
   # Wrong: Accessing dp[i-1] when i=0
   for i in range(n):
       dp[i] = dp[i-1] + nums[i]  # Error when i=0
   
   # Correct:
   dp[0] = nums[0]
   for i in range(1, n):
       dp[i] = dp[i-1] + nums[i]
   ```

3. **Incorrect transition order**:
   ```python
   # Wrong: 0/1 Knapsack with 1D array (forward iteration)
   for i in range(n):
       for w in range(weights[i], W + 1):
           dp[w] = max(dp[w], dp[w - weights[i]] + values[i])
           # This allows using same item multiple times!
   
   # Correct: Iterate backwards
   for i in range(n):
       for w in range(W, weights[i] - 1, -1):
           dp[w] = max(dp[w], dp[w - weights[i]] + values[i])
   ```

4. **Forgetting to initialize**:
   ```python
   # Wrong: Using max without proper initialization
   dp = [0] * n  # Should be -inf for max problems
   
   # Correct:
   dp = [float('-inf')] * n
   dp[0] = nums[0]
   ```

5. **Modifying input during DP**:
   ```python
   # Wrong: Modifying grid in-place without considering dependencies
   for i in range(m):
       for j in range(n):
           grid[i][j] += max(grid[i-1][j], grid[i][j-1])
   # Overwrites values needed for future computations
   
   # Correct: Use separate DP array or be careful with order
   ```

#### **Common DP patterns**:

1. **Linear DP** (1D):
   - State: `dp[i]` depends on `dp[i-1]`, `dp[i-2]`, etc.
   - Examples: Fibonacci, climbing stairs, house robber
   ```python
   for i in range(n):
       dp[i] = f(dp[i-1], dp[i-2], ...)
   ```

2. **Grid DP** (2D):
   - State: `dp[i][j]` depends on `dp[i-1][j]`, `dp[i][j-1]`
   - Examples: Unique paths, minimum path sum
   ```python
   for i in range(m):
       for j in range(n):
           dp[i][j] = f(dp[i-1][j], dp[i][j-1])
   ```

3. **Knapsack pattern**:
   - State: `dp[i][capacity]` or `dp[capacity]`
   - Examples: 0/1 knapsack, coin change, partition
   ```python
   for item in items:
       for capacity in range(W, item.weight - 1, -1):
           dp[capacity] = max(dp[capacity], 
                            dp[capacity - item.weight] + item.value)
   ```

4. **Interval DP**:
   - State: `dp[i][j]` for subproblem on range [i, j]
   - Examples: Matrix chain multiplication, burst balloons
   ```python
   for length in range(2, n + 1):
       for i in range(n - length + 1):
           j = i + length - 1
           for k in range(i, j + 1):
               dp[i][j] = min(dp[i][j], 
                            dp[i][k] + dp[k+1][j] + cost(i, j, k))
   ```

5. **State machine DP**:
   - State: `dp[i][state]` where state represents different modes
   - Examples: Stock trading, string with constraints
   ```python
   # Stock trading: state = {hold, sold, cooldown}
   for i in range(n):
       dp[i][hold] = max(dp[i-1][hold], dp[i-1][cooldown] - price[i])
       dp[i][sold] = dp[i-1][hold] + price[i]
       dp[i][cooldown] = max(dp[i-1][cooldown], dp[i-1][sold])
   ```

6. **Bitmask DP**:
   - State: `dp[mask]` where mask represents subset
   - Examples: TSP, assignment problem
   ```python
   for mask in range(1 << n):
       for i in range(n):
           if mask & (1 << i):
               prev_mask = mask ^ (1 << i)
               dp[mask] = min(dp[mask], dp[prev_mask] + cost[i])
   ```

#### **Problem-solving checklist**:
1. ✓ Identify if DP is applicable (overlapping + optimal substructure)
2. ✓ Define state clearly (what does `dp[i]` mean?)
3. ✓ Write recurrence relation
4. ✓ Identify base cases
5. ✓ Determine iteration order (dependencies)
6. ✓ Consider space optimization
7. ✓ Test with small examples
8. ✓ Handle edge cases (empty input, single element, etc.)

#### **Debugging tips**:
- Print DP table to visualize
- Verify base cases with hand calculation
- Check if recurrence matches problem statement
- Test with simple inputs first
- Compare memoization vs tabulation results
