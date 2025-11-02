---
layout: splash
author_profile: false
---

# Foundations

Build the essential programming base before tackling data structures.

### Choosing a primary language (C/C++/Java/Python)
- Why this matters:
  - Data structures look different across languages (manual memory in C/C++ vs GC in Java/Python).
  - Interviews/competitive programming often prefer C++/Java; teaching materials often use Python/Java.
- How to choose:
  - C/C++: Maximum control and performance; great for CP and systems; steeper learning curve (pointers, manual memory).
  - Java: Strong standard libraries, object-oriented, widely used in interviews.
  - Python: Fast to write and readable; slower runtime but ideal for learning/prototyping.
- Recommendation:
  - Beginners: Python or Java to focus on ideas.
  - Performance/CP: C++ (learn STL: `vector`, `list`, `stack`, `queue`, `unordered_map`).
- Action: Pick one language for consistency and implement every structure from scratch at least once.

### Variables, control flow, and loops
- Core concepts:
  - Data types (int, float, bool), type conversion, scope, and lifetime.
  - Control flow: if/else, switch, early returns.
  - Loops: for/while; be careful with off-by-one errors and loop invariants.
- Patterns to master:
  - Loop over arrays/lists with indices and iterators.
  - Nested loops and their time complexity (O(n^2), O(n^3), etc.).
  - Use break/continue judiciously; avoid deeply nested logic with early exits.
- Practice: Write small programs (sum, min/max, frequency count, reverse arrays, rotate arrays).

### Functions and recursion basics
- Functions:
  - Parameters by value vs reference; return values; side effects; purity.
  - Use small functions with single responsibility; name clearly.
- Recursion:
  - Base and recursive cases; ensure progress toward base.
  - Stack frames: each call pushes parameters/locals onto the call stack.
  - Typical patterns: divide and conquer (merge sort), tree/graph traversals, backtracking.
- Pitfalls: Missing/incorrect base cases (infinite recursion), stack overflow for deep recursion (switch to iterative + explicit stack).
- Practice: Implement factorial, Fibonacci (memoized), binary search (recursive/iterative), tree traversals.

### Arrays and strings fundamentals
- Arrays:
  - Contiguous memory, O(1) indexing; fixed size vs resizable (dynamic array/vector).
  - Operations: traversal, insert/delete (O(n) in middle), binary search on sorted arrays.
- Strings:
  - Often arrays of characters; immutability (Java/Python) vs mutability (C char arrays).
  - Common tasks: substring, search (naive vs KMP overview), concatenation costs.
- Practical tips: Be careful with boundaries and indices; understand memory layout and cache friendliness.
- Practice: Reverse string/array in place, rotate array, deduplicate sorted array, two-pointer patterns.

### Memory model: stack vs heap
- Stack:
  - Stores function call frames (parameters, locals). Fast allocation/deallocation; limited size.
  - Deep recursion risks stack overflow.
- Heap:
  - Dynamic memory for objects/larger arrays with longer lifetimes.
  - Manual management (C/C++) vs garbage collection (Java/Python).
- References/pointers: Pointer/reference semantics, aliasing, ownership; in managed languages, understand object references and mutability.
- Practice:
  - C/C++: allocate/free arrays and structs; avoid leaks and dangling pointers.
  - Java/Python: observe when objects are shared across variables and mutated.

### Debugging and testing basics
- Debugging:
  - Use a step debugger (breakpoints, watch variables), not just print.
  - Add assertions to capture invariants early (e.g., index in bounds).
  - Binary search your bug: isolate with logging; reduce input to a minimal repro.
- Testing:
  - Start with unit tests for each function; include edge cases and large/small inputs.
  - Property-based thinking: e.g., reversing twice returns original.
  - Measure performance with simple timers for baseline complexity checks.
- Tooling:
  - C/C++: gdb/lldb, sanitizers (ASan/UBSan), valgrind.
  - Java: JUnit; Python: `unittest`/`pytest`.
- Practice: Write tests for array operations, stack/queue APIs, linked list insert/delete.

### Using online judges (LeetCode/HackerRank)
- Approach: Categorize problems by topic; focus on patterns (two pointers, sliding window, stack, BFS/DFS).
- Routine: Read problem → design with complexity → implement → test edge cases → reflect and document takeaways.
- Measuring progress: Track time per problem, success rate, and revisits until first-try success.
- Avoid pitfalls: Copying solutions without re-implementing; ignoring constraints that hint at proper data structures/algorithms.
