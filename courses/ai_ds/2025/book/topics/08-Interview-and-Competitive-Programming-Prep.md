---
layout: splash
author_profile: false
---

# Interview & Competitive Programming Prep

Targeted practice to master patterns and speed.


### 1. Arrays/strings/stacks/queues patterns
Common algorithmic patterns using fundamental data structures:
- **Two pointers**: Fast/slow pointers, sliding window techniques for arrays/strings
  - Example: Finding longest substring without repeating characters
  - Example: Container with most water problem
- **Stack patterns**: Monotonic stack for next greater/smaller element, parentheses matching, expression evaluation
  - Example: Valid parentheses, daily temperatures
  - Example: Evaluate reverse polish notation
- **Queue patterns**: BFS traversal, sliding window maximum, level-order processing
  - Example: Binary tree level order traversal
  - Example: Sliding window maximum using deque
- **String manipulation**: Palindrome checking, substring search (KMP, Rabin-Karp), anagram detection
  - Example: Longest palindromic substring
  - Example: Group anagrams
- **Array techniques**: Prefix sums, difference arrays, in-place modifications
  - Example: Range sum queries, subarray sum equals k

### 2. Daily problem-solving routine
Structured practice schedule for consistent improvement:
- **Consistency**: Solve 1-3 problems daily to build muscle memory
  - Morning: 1 medium problem (30 min)
  - Evening: Review and optimize solutions
- **Difficulty progression**: Start with easy, gradually increase to medium/hard
  - Week 1-2: Easy problems to build confidence
  - Week 3-4: Mix of easy and medium
  - Week 5+: Focus on medium with occasional hard
- **Topic rotation**: Alternate between different data structures and algorithms
  - Monday: Arrays/Strings
  - Tuesday: Stacks/Queues
  - Wednesday: Trees/Graphs
  - Thursday: Dynamic Programming
  - Friday: Mixed review
- **Time-boxing**: Practice under time constraints (20-30 min per problem)
- **Review cycle**: Revisit problems after 1 week, 1 month to reinforce learning

### 3. Time complexity estimation
Quickly analyzing algorithm efficiency before coding:
- **Big-O notation**: O(1), O(log n), O(n), O(n log n), O(n²), O(2ⁿ)
  - Constant: Hash table lookup
  - Logarithmic: Binary search
  - Linear: Single pass through array
  - Linearithmic: Merge sort, heap operations
  - Quadratic: Nested loops
  - Exponential: Recursive backtracking
- **Input size guidelines**: 
  - n ≤ 10: O(n!) or O(2ⁿ) acceptable
  - n ≤ 100: O(n³) acceptable
  - n ≤ 1,000: O(n²) acceptable
  - n ≤ 100,000: O(n log n) required
  - n ≤ 1,000,000: O(n) or O(n log n) required
- **Space-time tradeoffs**: When to use extra memory for faster solutions
  - Hash maps for O(1) lookup vs O(n) space
  - Memoization in DP to avoid recomputation
- **Worst-case analysis**: Identifying bottlenecks in nested loops, recursion depth
- **Quick mental math**: Estimating operations per second (~10⁸-10⁹)

### 4. Pattern recognition and templates
Identifying problem types and applying standard solutions:
- **Problem categories**: 
  - Sliding window: Variable/fixed size windows
  - Backtracking: Generating combinations, permutations
  - Dynamic programming: Optimization problems with overlapping subproblems
  - Graph traversal: DFS for paths, BFS for shortest paths
- **Template library**: Pre-written code skeletons
  ```python
  # Binary Search Template
  def binary_search(arr, target):
      left, right = 0, len(arr) - 1
      while left <= right:
          mid = left + (right - left) // 2
          if arr[mid] == target:
              return mid
          elif arr[mid] < target:
              left = mid + 1
          else:
              right = mid - 1
      return -1
  
  # Sliding Window Template
  def sliding_window(s):
      left = 0
      result = 0
      window = {}
      for right in range(len(s)):
          # Expand window
          window[s[right]] = window.get(s[right], 0) + 1
          # Contract window if needed
          while condition_violated:
              window[s[left]] -= 1
              left += 1
          # Update result
          result = max(result, right - left + 1)
      return result
  ```
- **Signal words**: 
  - "Contiguous subarray" → sliding window
  - "All combinations" → backtracking
  - "Minimum/maximum" → DP or greedy
  - "Shortest path" → BFS
- **Similar problem mapping**: Recognizing variations of classic problems
  - Coin change → Unbounded knapsack
  - House robber → Linear DP with constraints

### 5. Mock interviews and reviews
Simulating real interview conditions:
- **Timed practice**: 45-60 minute sessions with unseen problems
  - 5 min: Clarify problem, ask questions
  - 10 min: Discuss approach, edge cases
  - 25 min: Code solution
  - 5 min: Test and debug
  - 5 min: Discuss optimization
- **Communication**: Explaining approach before coding, thinking aloud
  - "I'm thinking of using a hash map to store..."
  - "The time complexity would be O(n) because..."
  - "Let me trace through an example..."
- **Peer/platform practice**: 
  - LeetCode mock interviews
  - Pramp (peer-to-peer)
  - interviewing.io
  - CodeSignal
- **Post-mortem analysis**: 
  - What went well: Clear communication, correct solution
  - What to improve: Missed edge case, slow implementation
  - Alternative approaches: Could have used DP instead of recursion
- **Behavioral prep**: Discussing past projects, system design basics

### 6. Tracking progress and metrics
Measuring improvement systematically:
- **Problem log**: Spreadsheet tracking
  | Date | Problem | Difficulty | Time | Status | Notes |
  |------|---------|-----------|------|--------|-------|
  | 11/01 | Two Sum | Easy | 15min | ✓ | Used hash map |
  | 11/01 | Valid Parentheses | Easy | 20min | ✓ | Stack approach |
  
- **Topic coverage**: Checklist of data structures/algorithms mastered
  - ✓ Arrays (80% proficiency)
  - ✓ Stacks (90% proficiency)
  - ⚠ Trees (60% proficiency - needs work)
  - ✗ Graphs (40% proficiency - priority)
  
- **Speed metrics**: Average time per difficulty level
  - Easy: Target 15-20 min (Current: 18 min)
  - Medium: Target 25-35 min (Current: 40 min)
  - Hard: Target 40-50 min (Current: 60+ min)
  
- **Weak areas**: Identifying patterns that need more practice
  - Dynamic programming: Need more practice
  - Graph algorithms: Struggling with DFS/BFS variations
  
- **Contest participation**: Regular contests for benchmarking
  - LeetCode Weekly Contest: Track ranking over time
  - Codeforces: Aim for rating improvement
  - AtCoder Beginner Contest: Weekly practice
