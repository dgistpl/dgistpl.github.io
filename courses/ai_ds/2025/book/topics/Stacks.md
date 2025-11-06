---
layout: splash
author_profile: false
---

# Stacks

LIFO structure for managing nested operations and histories.


### Core operations: push/pop/peek
- Push: add an element to the top.
- Pop: remove and return the top element. Underflow if empty.
- Peek: return the top element without removing it.
- Empty/Size: check if the stack is empty and how many elements it has.

Example (Python list as stack):
```python
s = []
s.append(10)      # push
s.append(20)
top = s[-1]       # peek -> 20
x = s.pop()       # pop -> 20, stack now [10]
empty = (len(s) == 0)
```

Complexities:
- push: O(1) amortized
- pop: O(1)
- peek: O(1)

### Array vs linked-list implementation
- Array-based stack:
  - Backed by a dynamic array (e.g., Python list, C++ vector).
  - Pros: contiguous memory, great cache locality, simple O(1) amortized push.
  - Cons: occasional resize; capacity management if manual.
- Linked-list-based stack:
  - Singly linked list where head is the top.
  - Pros: no resize cost; push/pop always O(1).
  - Cons: extra pointer memory per node; worse cache locality.

Example (linked-list stack in Python):
```python
class Node:
    def __init__(self, val, next=None):
        self.val = val
        self.next = next

class StackLL:
    def __init__(self):
        self.head = None
        self.n = 0

    def push(self, x):
        self.head = Node(x, self.head)
        self.n += 1

    def pop(self):
        if not self.head:
            raise IndexError("pop from empty stack")
        x = self.head.val
        self.head = self.head.next
        self.n -= 1
        return x

    def peek(self):
        if not self.head:
            raise IndexError("peek from empty stack")
        return self.head.val

    def empty(self):
        return self.head is None

    def size(self):
        return self.n
```

### Expression evaluation and parentheses
- Parentheses balancing:
  - Push opening bracket.
  - For each closing bracket, check top matches type and pop.
  - If mismatch or underflow → invalid.
- Infix to postfix (Shunting Yard):
  - Use a stack for operators; output operands; manage precedence and associativity.
- Postfix evaluation:
  - Push operands; on operator, pop two operands, apply, push result.

Example (parentheses check):
```python
def valid_brackets(s):
    pairs = {')':'(', ']':'[', '}':'{'}
    st = []
    for ch in s:
        if ch in '([{':
            st.append(ch)
        elif ch in ')]}':
            if not st or st[-1] != pairs[ch]:
                return False
            st.pop()
    return not st

# Examples:
# valid_brackets("([]){}") -> True
# valid_brackets("([)]") -> False
```

### Function call stack and recursion
- Each function call pushes a frame (parameters, locals, return address) on the call stack.
- Recursion uses the call stack implicitly.
- Deep recursion can cause stack overflow; convert to iterative with an explicit stack if needed.

Example (DFS iterative with explicit stack instead of recursion):
```python
def dfs_iterative(graph, start):
    visited = set()
    st = [start]
    while st:
        u = st.pop()
        if u in visited: 
            continue
        visited.add(u)
        for v in graph[u]:
            if v not in visited:
                st.append(v)
    return visited
```

### Undo/redo and backtracking
- Undo/redo:
  - Use two stacks: `undo` and `redo`.
  - On action: push action onto `undo`, clear `redo`.
  - On undo: pop from `undo`, apply inverse, push onto `redo`.
  - On redo: pop from `redo`, apply, push back onto `undo`.
- Backtracking:
  - Push choices; when a choice fails, pop to revert state and try next option (e.g., maze solving, N-Queens).

Example (tiny undo/redo skeleton):
```python
undo, redo = [], []

def do(action):
    action.apply()
    undo.append(action)
    redo.clear()

def undo_action():
    if undo:
        a = undo.pop()
        a.unapply()
        redo.append(a)

def redo_action():
    if redo:
        a = redo.pop()
        a.apply()
        undo.append(a)
```

### Time/space complexity
- Array-backed:
  - push/pop/peek: O(1) amortized
  - Space: O(n)
- Linked-list-backed:
  - push/pop/peek: O(1)
  - Space: O(n) plus pointer overhead
- Additional concerns:
  - Resizing cost is amortized; worst-case single push can be O(n).
  - In languages with GC, object allocation can influence performance.
  - Iterating through a stack: O(n).
